import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/bkash_credentials.dart';
import '../models/bkash_transaction.dart';

class BkashService {
  static const String _credentialsKey = 'bkash_saved_credentials';
  static const String _historyKey = 'bkash_transaction_history';
  static const String _balanceKey = 'bkash_wallet_balance';

  BkashCredentials _credentials = const BkashCredentials();
  String? _idToken;
  double _walletBalance = 1000.00;

  BkashCredentials get credentials => _credentials;
  double get walletBalance => _walletBalance;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final credentialsJson = prefs.getString(_credentialsKey);
    if (credentialsJson != null) {
      try {
        _credentials = BkashCredentials.fromJson(jsonDecode(credentialsJson));
      } catch (_) {}
    }

    _walletBalance = prefs.getDouble(_balanceKey) ?? 1000.00;

    // Seed initial mock transactions if empty
    final historyList = prefs.getStringList(_historyKey);
    if (historyList == null || historyList.isEmpty) {
      await _seedInitialTransactions();
    }
  }

  Future<void> _seedInitialTransactions() async {
    final initialTrxs = [
      BkashTransaction(
        paymentId: 'PAY1001',
        trxID: 'BKS9A2B3C4D5',
        amount: 500.00,
        customerMsisdn: '01712345678',
        merchantInvoiceNumber: 'INV-88492',
        date: DateTime.now().subtract(const Duration(hours: 2)),
        status: BkashPaymentStatus.success,
        type: BkashTransactionType.sendMoney,
        recipientName: 'Rahim Ahmed',
      ),
      BkashTransaction(
        paymentId: 'PAY1002',
        trxID: 'BKS8X7Y6Z5W4',
        amount: 199.00,
        customerMsisdn: '01898765432',
        merchantInvoiceNumber: 'GP-RECHARGE',
        date: DateTime.now().subtract(const Duration(days: 1)),
        status: BkashPaymentStatus.success,
        type: BkashTransactionType.mobileRecharge,
        operator: 'Grameenphone',
      ),
    ];

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _historyKey,
      initialTrxs.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }

  Future<void> saveCredentials(BkashCredentials creds) async {
    _credentials = creds;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_credentialsKey, jsonEncode(creds.toJson()));
  }

  Future<void> _updateBalance(double amountChange) async {
    _walletBalance += amountChange;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_balanceKey, _walletBalance);
  }

  // --- REST API: Grant Token ---
  Future<String?> grantToken() async {
    try {
      final response = await http.post(
        Uri.parse('${_credentials.baseUrl}/create'),
        headers: {
          'Content-Type': 'application/json',
          'username': _credentials.username,
          'password': _credentials.password,
        },
        body: jsonEncode({
          'app_key': _credentials.appKey,
          'app_secret': _credentials.appSecret,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _idToken = data['id_token'];
        return _idToken;
      }
    } catch (_) {}
    _idToken = 'sandbox_id_token_${DateTime.now().millisecondsSinceEpoch}';
    return _idToken;
  }

  // --- REST API: Create Payment ---
  Future<Map<String, dynamic>> createPayment({
    required double amount,
    required String invoiceNumber,
  }) async {
    if (_idToken == null) {
      await grantToken();
    }

    try {
      final response = await http.post(
        Uri.parse('${_credentials.baseUrl}/create'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': _idToken!,
          'X-APP-Key': _credentials.appKey,
        },
        body: jsonEncode({
          'mode': '0011',
          'payerReference': '01700000000',
          'callbackURL': 'https://example.com/bkash/callback',
          'amount': amount.toStringAsFixed(2),
          'currency': 'BDT',
          'intent': 'sale',
          'merchantInvoiceNumber': invoiceNumber,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['paymentID'] != null) {
          return {
            'success': true,
            'paymentID': data['paymentID'],
            'bkashURL': data['bkashURL'],
          };
        }
      }
    } catch (_) {}

    final mockPaymentID = 'TRX_MOCK_${Random().nextInt(900000) + 100000}';
    return {
      'success': true,
      'paymentID': mockPaymentID,
      'bkashURL': 'https://demo.bka.sh/checkout?paymentID=$mockPaymentID',
    };
  }

  // --- Execute Merchant Payment ---
  Future<BkashTransaction> executePayment({
    required String paymentID,
    required String customerMsisdn,
    required double amount,
    required String invoiceNumber,
    required String pin,
  }) async {
    if (pin.length < 4) {
      final failedTrx = BkashTransaction(
        paymentId: paymentID,
        trxID: '',
        amount: amount,
        customerMsisdn: customerMsisdn,
        merchantInvoiceNumber: invoiceNumber,
        date: DateTime.now(),
        status: BkashPaymentStatus.failed,
        type: BkashTransactionType.merchantPayment,
        errorMessage: 'Invalid bKash Account PIN.',
      );
      await saveTransaction(failedTrx);
      return failedTrx;
    }

    final mockTrxID = _generateMockTrxID();
    final trx = BkashTransaction(
      paymentId: paymentID,
      trxID: mockTrxID,
      amount: amount,
      customerMsisdn: customerMsisdn,
      merchantInvoiceNumber: invoiceNumber,
      date: DateTime.now(),
      status: BkashPaymentStatus.success,
      type: BkashTransactionType.merchantPayment,
    );

    await _updateBalance(-amount);
    await saveTransaction(trx);
    return trx;
  }

  // --- Perform Send Money ---
  Future<BkashTransaction> performSendMoney({
    required String recipientNumber,
    required String recipientName,
    required double amount,
    required String pin,
  }) async {
    final trxID = _generateMockTrxID();
    final trx = BkashTransaction(
      paymentId: 'PAY_${Random().nextInt(900000) + 100000}',
      trxID: trxID,
      amount: amount,
      customerMsisdn: recipientNumber,
      merchantInvoiceNumber:
          'SEND-MONEY-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      date: DateTime.now(),
      status: BkashPaymentStatus.success,
      type: BkashTransactionType.sendMoney,
      recipientName: recipientName,
    );

    await _updateBalance(-amount);
    await saveTransaction(trx);
    return trx;
  }

  // --- Perform Mobile Recharge ---
  Future<BkashTransaction> performMobileRecharge({
    required String mobileNumber,
    required String operatorName,
    required double amount,
    required String pin,
  }) async {
    final trxID = _generateMockTrxID();
    final trx = BkashTransaction(
      paymentId: 'PAY_${Random().nextInt(900000) + 100000}',
      trxID: trxID,
      amount: amount,
      customerMsisdn: mobileNumber,
      merchantInvoiceNumber: 'RECHARGE-${operatorName.toUpperCase()}',
      date: DateTime.now(),
      status: BkashPaymentStatus.success,
      type: BkashTransactionType.mobileRecharge,
      operator: operatorName,
    );

    await _updateBalance(-amount);
    await saveTransaction(trx);
    return trx;
  }

  String _generateMockTrxID() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return 'BKS${List.generate(9, (index) => chars[random.nextInt(chars.length)]).join()}';
  }

  // --- Transaction History ---
  Future<List<BkashTransaction>> getTransactionHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyList = prefs.getStringList(_historyKey) ?? [];
    return historyList
        .map((e) => BkashTransaction.fromJson(jsonDecode(e)))
        .toList();
  }

  Future<void> saveTransaction(BkashTransaction trx) async {
    final prefs = await SharedPreferences.getInstance();
    final historyList = prefs.getStringList(_historyKey) ?? [];
    historyList.insert(0, jsonEncode(trx.toJson()));
    await prefs.setStringList(_historyKey, historyList);
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }
}
