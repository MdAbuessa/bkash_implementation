import 'package:flutter/material.dart';
import '../models/bkash_transaction.dart';
import '../services/bkash_service.dart';
import '../theme/bkash_theme.dart';
import 'payment_status_screen.dart';

class AddMoneyScreen extends StatefulWidget {
  final BkashService bkashService;

  const AddMoneyScreen({super.key, required this.bkashService});

  @override
  State<AddMoneyScreen> createState() => _AddMoneyScreenState();
}

class _AddMoneyScreenState extends State<AddMoneyScreen> {
  int _currentStep = 1; // 1: Source, 2: Amount & Card Details, 3: Processing
  String _selectedSource = 'Card to bKash';

  final _amountController = TextEditingController(text: '1000');
  final _cardController = TextEditingController(text: '4532 •••• •••• 8901');
  final List<double> _quickAmounts = [500, 1000, 2000, 5000, 10000];
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    _cardController.dispose();
    super.dispose();
  }

  void _processAddMoney() async {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    if (amount <= 0) {
      setState(() => _errorMessage = 'Please enter a valid amount.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    await Future.delayed(const Duration(milliseconds: 1000));

    final trx = BkashTransaction(
      paymentId:
          'ADD_${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      trxID:
          'BKS${DateTime.now().millisecondsSinceEpoch.toString().substring(4)}',
      amount: amount,
      customerMsisdn: _cardController.text,
      merchantInvoiceNumber: 'ADD-MONEY-${_selectedSource.split(' ')[0]}',
      date: DateTime.now(),
      status: BkashPaymentStatus.success,
      type: BkashTransactionType.addMoney,
    );

    // Save transaction and add to wallet balance
    await widget.bkashService.saveTransaction(trx);
    await widget.bkashService.executePayment(
      paymentID: trx.paymentId,
      customerMsisdn: trx.customerMsisdn,
      amount: -amount, // Adding money increases wallet balance
      invoiceNumber: trx.merchantInvoiceNumber,
      pin: '12345',
    );

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentStatusScreen(transaction: trx),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BkashTheme.bgLight,
      appBar: AppBar(title: const Text('এড মানি (Add Money)')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Balance Card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: BkashTheme.primaryPink.withValues(alpha: 0.3),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Wallet Balance',
                        style: TextStyle(
                          fontSize: 11,
                          color: BkashTheme.textMuted,
                        ),
                      ),
                      Text(
                        'বর্তমান ব্যালেন্স',
                        style: TextStyle(
                          fontSize: 12,
                          color: BkashTheme.textDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '৳ ${widget.bkashService.walletBalance.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: BkashTheme.primaryPink,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            if (_errorMessage != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: BkashTheme.errorRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: BkashTheme.errorRed),
                ),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(
                    color: BkashTheme.errorRed,
                    fontSize: 13,
                  ),
                ),
              ),

            if (_currentStep == 1) _buildSourceStep(),
            if (_currentStep == 2) _buildAmountAndDetailsStep(),
          ],
        ),
      ),
    );
  }

  // STEP 1: Select Source (Card or Bank)
  Widget _buildSourceStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'উৎস নির্বাচন করুন (Select Source)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: BkashTheme.textDark,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Select where you want to add money from',
          style: TextStyle(fontSize: 12, color: BkashTheme.textMuted),
        ),
        const SizedBox(height: 16),

        _buildSourceCard(
          title: 'Card to bKash',
          subtitle: 'Visa, Mastercard, or Amex Card',
          icon: Icons.credit_card_rounded,
          isSelected: _selectedSource == 'Card to bKash',
          onTap: () => setState(() => _selectedSource = 'Card to bKash'),
        ),
        const SizedBox(height: 12),
        _buildSourceCard(
          title: 'Bank to bKash',
          subtitle: 'City Bank, BRAC, DBBL, EBL, etc.',
          icon: Icons.account_balance_rounded,
          isSelected: _selectedSource == 'Bank to bKash',
          onTap: () => setState(() => _selectedSource = 'Bank to bKash'),
        ),

        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => setState(() => _currentStep = 2),
            child: const Text('পরবর্তী (NEXT)'),
          ),
        ),
      ],
    );
  }

  Widget _buildSourceCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? BkashTheme.softPinkContainer : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? BkashTheme.primaryPink
                : BkashTheme.dividerColor,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: BkashTheme.primaryPink.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: BkashTheme.primaryPink, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: isSelected
                          ? BkashTheme.primaryPink
                          : BkashTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: BkashTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked,
              color: isSelected ? BkashTheme.primaryPink : BkashTheme.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  // STEP 2: Amount & Card Details
  Widget _buildAmountAndDetailsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Adding via $_selectedSource',
          style: const TextStyle(fontSize: 13, color: BkashTheme.textMuted),
        ),
        const SizedBox(height: 16),

        TextField(
          controller: _amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: BkashTheme.textDark,
          ),
          decoration: const InputDecoration(
            prefixText: '৳ ',
            prefixStyle: TextStyle(
              color: BkashTheme.primaryPink,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
            labelText: 'Add Money Amount (BDT)',
          ),
        ),
        const SizedBox(height: 16),

        const Text(
          'Quick Amounts (৳)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: BkashTheme.textDark,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _quickAmounts.map((amt) {
            final isSelected = _amountController.text == amt.toInt().toString();
            return ChoiceChip(
              label: Text('৳ ${amt.toInt()}'),
              selected: isSelected,
              selectedColor: BkashTheme.primaryPink,
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : BkashTheme.textDark,
                fontWeight: FontWeight.bold,
              ),
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _amountController.text = amt.toInt().toString();
                  });
                }
              },
            );
          }).toList(),
        ),

        const SizedBox(height: 20),
        TextField(
          controller: _cardController,
          style: const TextStyle(color: BkashTheme.textDark),
          decoration: InputDecoration(
            labelText: _selectedSource.contains('Card')
                ? 'Card Number'
                : 'Bank Account Number',
            prefixIcon: Icon(
              _selectedSource.contains('Card')
                  ? Icons.credit_card
                  : Icons.account_balance,
              color: BkashTheme.primaryPink,
            ),
          ),
        ),

        const SizedBox(height: 30),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _currentStep = 1),
                child: const Text('BACK'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _isLoading ? null : _processAddMoney,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('এড মানি করুন (ADD MONEY)'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
