enum BkashPaymentStatus { success, failed, pending, refunded }

enum BkashTransactionType {
  sendMoney,
  mobileRecharge,
  merchantPayment,
  cashOut,
  addMoney,
  payBill,
}

extension BkashTransactionTypeExt on BkashTransactionType {
  String get displayName {
    switch (this) {
      case BkashTransactionType.sendMoney:
        return 'Send Money';
      case BkashTransactionType.mobileRecharge:
        return 'Mobile Recharge';
      case BkashTransactionType.merchantPayment:
        return 'Merchant Payment';
      case BkashTransactionType.cashOut:
        return 'Cash Out';
      case BkashTransactionType.addMoney:
        return 'Add Money';
      case BkashTransactionType.payBill:
        return 'Pay Bill';
    }
  }

  String get bnName {
    switch (this) {
      case BkashTransactionType.sendMoney:
        return 'সেন্ড মানি';
      case BkashTransactionType.mobileRecharge:
        return 'মোবাইল রিচার্জ';
      case BkashTransactionType.merchantPayment:
        return 'পেমেন্ট';
      case BkashTransactionType.cashOut:
        return 'ক্যাশ আউট';
      case BkashTransactionType.addMoney:
        return 'এড মানি';
      case BkashTransactionType.payBill:
        return 'পে বিল';
    }
  }
}

class BkashTransaction {
  final String paymentId;
  final String trxID;
  final double amount;
  final String currency;
  final String customerMsisdn;
  final String merchantInvoiceNumber;
  final DateTime date;
  final BkashPaymentStatus status;
  final BkashTransactionType type;
  final String? recipientName;
  final String? operator;
  final String? errorMessage;

  BkashTransaction({
    required this.paymentId,
    required this.trxID,
    required this.amount,
    this.currency = 'BDT',
    required this.customerMsisdn,
    required this.merchantInvoiceNumber,
    required this.date,
    required this.status,
    this.type = BkashTransactionType.merchantPayment,
    this.recipientName,
    this.operator,
    this.errorMessage,
  });

  Map<String, dynamic> toJson() => {
        'paymentId': paymentId,
        'trxID': trxID,
        'amount': amount,
        'currency': currency,
        'customerMsisdn': customerMsisdn,
        'merchantInvoiceNumber': merchantInvoiceNumber,
        'date': date.toIso8601String(),
        'status': status.name,
        'type': type.name,
        'recipientName': recipientName,
        'operator': operator,
        'errorMessage': errorMessage,
      };

  factory BkashTransaction.fromJson(Map<String, dynamic> json) {
    return BkashTransaction(
      paymentId: json['paymentId'] ?? '',
      trxID: json['trxID'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] ?? 'BDT',
      customerMsisdn: json['customerMsisdn'] ?? '',
      merchantInvoiceNumber: json['merchantInvoiceNumber'] ?? '',
      date: json['date'] != null
          ? DateTime.parse(json['date'])
          : DateTime.now(),
      status: BkashPaymentStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => BkashPaymentStatus.failed,
      ),
      type: BkashTransactionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => BkashTransactionType.merchantPayment,
      ),
      recipientName: json['recipientName'],
      operator: json['operator'],
      errorMessage: json['errorMessage'],
    );
  }
}
