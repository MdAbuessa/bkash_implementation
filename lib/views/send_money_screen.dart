import 'package:flutter/material.dart';
import '../services/bkash_service.dart';
import '../theme/bkash_theme.dart';
import 'hold_to_confirm_bar.dart';
import 'payment_status_screen.dart';

class SendMoneyScreen extends StatefulWidget {
  final BkashService bkashService;

  const SendMoneyScreen({super.key, required this.bkashService});

  @override
  State<SendMoneyScreen> createState() => _SendMoneyScreenState();
}

class _SendMoneyScreenState extends State<SendMoneyScreen> {
  int _currentStep = 1; // 1: Recipient, 2: Amount, 3: PIN & Hold
  final _phoneController = TextEditingController(text: '01798765432');
  final _nameController = TextEditingController(text: 'Essa');
  final _amountController = TextEditingController(text: '500');
  final _pinController = TextEditingController(text: '12345');

  String? _errorMessage;

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    _amountController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  void _onConfirmSendMoney() async {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final trx = await widget.bkashService.performSendMoney(
      recipientNumber: _phoneController.text.trim(),
      recipientName: _nameController.text.trim(),
      amount: amount,
      pin: _pinController.text.trim(),
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
      appBar: AppBar(title: const Text('সেন্ড মানি (Send Money)')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Balance Badge
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
                        'Available Balance',
                        style: TextStyle(
                          fontSize: 11,
                          color: BkashTheme.textMuted,
                        ),
                      ),
                      Text(
                        'প্রাপ্য ব্যালেন্স',
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

            if (_currentStep == 1) _buildRecipientStep(),
            if (_currentStep == 2) _buildAmountStep(),
            if (_currentStep == 3) _buildPinAndHoldStep(),
          ],
        ),
      ),
    );
  }

  // STEP 1: Recipient Phone/Name
  Widget _buildRecipientStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'প্রাপক (Recipient)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: BkashTheme.textDark,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Enter recipient bKash mobile number or select contact',
          style: TextStyle(fontSize: 12, color: BkashTheme.textMuted),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          style: const TextStyle(color: BkashTheme.textDark),
          decoration: const InputDecoration(
            labelText: 'bKash Mobile Number',
            prefixIcon: Icon(
              Icons.phone_android,
              color: BkashTheme.primaryPink,
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _nameController,
          style: const TextStyle(color: BkashTheme.textDark),
          decoration: const InputDecoration(
            labelText: 'Recipient Name (Optional)',
            prefixIcon: Icon(
              Icons.person_outline,
              color: BkashTheme.primaryPink,
            ),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              if (_phoneController.text.trim().length == 11) {
                setState(() {
                  _errorMessage = null;
                  _currentStep = 2;
                });
              } else {
                setState(
                  () => _errorMessage =
                      'Please enter a valid 11-digit mobile number.',
                );
              }
            },
            child: const Text('পরবর্তী (NEXT)'),
          ),
        ),
      ],
    );
  }

  // STEP 2: Amount Entry
  Widget _buildAmountStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'পরিমাণ (Amount)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: BkashTheme.textDark,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Sending to ${_nameController.text} (${_phoneController.text})',
          style: const TextStyle(fontSize: 12, color: BkashTheme.textMuted),
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
            labelText: 'Amount (BDT)',
          ),
        ),
        const SizedBox(height: 24),
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
                onPressed: () {
                  final amount = double.tryParse(_amountController.text) ?? 0.0;
                  if (amount > 0 &&
                      amount <= widget.bkashService.walletBalance) {
                    setState(() {
                      _errorMessage = null;
                      _currentStep = 3;
                    });
                  } else {
                    setState(
                      () => _errorMessage =
                          'Insufficient balance or invalid amount.',
                    );
                  }
                },
                child: const Text('পরবর্তী (NEXT)'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // STEP 3: PIN Entry & Hold to Confirm
  Widget _buildPinAndHoldStep() {
    final amount = double.tryParse(_amountController.text) ?? 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'প্রাপক / Recipient',
                    style: TextStyle(color: BkashTheme.textMuted),
                  ),
                  Text(
                    _nameController.text,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: BkashTheme.textDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'মোবাইল / Mobile',
                    style: TextStyle(color: BkashTheme.textMuted),
                  ),
                  Text(
                    _phoneController.text,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: BkashTheme.textDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'মোট পরিমাণ / Total',
                    style: TextStyle(color: BkashTheme.textMuted),
                  ),
                  Text(
                    '৳ ${amount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: BkashTheme.primaryPink,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),
        const Text(
          'bKash PIN দিন (Enter PIN)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: BkashTheme.textDark,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _pinController,
          keyboardType: TextInputType.number,
          obscureText: true,
          maxLength: 5,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 22,
            letterSpacing: 8,
            fontWeight: FontWeight.bold,
            color: BkashTheme.textDark,
          ),
          decoration: const InputDecoration(hintText: '•••••', counterText: ''),
        ),

        const SizedBox(height: 30),
        HoldToConfirmBar(
          label: 'সেন্ড মানি করতে ট্যাপ করে ধরে রাখুন',
          onConfirmed: _onConfirmSendMoney,
        ),
      ],
    );
  }
}
