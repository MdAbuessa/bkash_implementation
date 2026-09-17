import 'package:flutter/material.dart';
import '../services/bkash_service.dart';
import '../theme/bkash_theme.dart';
import 'hold_to_confirm_bar.dart';
import 'payment_status_screen.dart';

class MobileRechargeScreen extends StatefulWidget {
  final BkashService bkashService;

  const MobileRechargeScreen({super.key, required this.bkashService});

  @override
  State<MobileRechargeScreen> createState() => _MobileRechargeScreenState();
}

class _MobileRechargeScreenState extends State<MobileRechargeScreen> {
  int _currentStep = 1; // 1: Number & Operator, 2: Amount, 3: PIN & Hold
  final _phoneController = TextEditingController(text: '01711223344');
  final _amountController = TextEditingController(text: '99');
  final _pinController = TextEditingController(text: '12345');

  String _selectedOperator = 'Grameenphone';
  final List<Map<String, dynamic>> _operators = [
    {'name': 'Grameenphone', 'color': const Color(0xFF00A3E0), 'code': '017'},
    {'name': 'Robi', 'color': const Color(0xFFE20613), 'code': '018'},
    {'name': 'Banglalink', 'color': const Color(0xFFFF6600), 'code': '019'},
    {'name': 'Airtel', 'color': const Color(0xFFD90000), 'code': '016'},
    {'name': 'Teletalk', 'color': const Color(0xFF008000), 'code': '015'},
  ];

  final List<double> _quickAmounts = [20, 50, 99, 149, 199, 299, 499, 999];
  String? _errorMessage;

  @override
  void dispose() {
    _phoneController.dispose();
    _amountController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  void _onConfirmRecharge() async {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final trx = await widget.bkashService.performMobileRecharge(
      mobileNumber: _phoneController.text.trim(),
      operatorName: _selectedOperator,
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
      appBar: AppBar(
        title: const Text('মোবাইল রিচার্জ (Mobile Recharge)'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Available Balance
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: BkashTheme.primaryPink.withValues(alpha: 0.3)),
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
                      Text('Available Balance', style: TextStyle(fontSize: 11, color: BkashTheme.textMuted)),
                      Text('প্রাপ্য ব্যালেন্স', style: TextStyle(fontSize: 12, color: BkashTheme.textDark, fontWeight: FontWeight.bold)),
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
                child: Text(_errorMessage!, style: const TextStyle(color: BkashTheme.errorRed, fontSize: 13)),
              ),

            if (_currentStep == 1) _buildOperatorStep(),
            if (_currentStep == 2) _buildAmountStep(),
            if (_currentStep == 3) _buildPinAndHoldStep(),
          ],
        ),
      ),
    );
  }

  // STEP 1: Number & Operator Selection
  Widget _buildOperatorStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'মোবাইল নম্বর (Mobile Number)',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: BkashTheme.textDark),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          style: const TextStyle(color: BkashTheme.textDark),
          decoration: const InputDecoration(
            labelText: '11-Digit Mobile Number',
            prefixIcon: Icon(Icons.smartphone_rounded, color: BkashTheme.primaryPink),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'অপারেটর নির্বাচন করুন (Select Operator)',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: BkashTheme.textDark),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _operators.map((op) {
            final isSelected = _selectedOperator == op['name'];
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedOperator = op['name'];
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? BkashTheme.softPinkContainer : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? BkashTheme.primaryPink : BkashTheme.dividerColor,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: op['color'],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      op['name'],
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? BkashTheme.primaryPink : BkashTheme.textDark,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
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
                setState(() => _errorMessage = 'Please enter valid 11-digit mobile number.');
              }
            },
            child: const Text('পরবর্তী (NEXT)'),
          ),
        ),
      ],
    );
  }

  // STEP 2: Amount & Quick Pack Selection
  Widget _buildAmountStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recharging $_selectedOperator (${_phoneController.text})',
          style: const TextStyle(fontSize: 13, color: BkashTheme.textMuted),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: BkashTheme.textDark),
          decoration: const InputDecoration(
            prefixText: '৳ ',
            prefixStyle: TextStyle(color: BkashTheme.primaryPink, fontWeight: FontWeight.bold, fontSize: 24),
            labelText: 'Recharge Amount',
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Quick Amounts (৳)',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: BkashTheme.textDark),
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
                  if (amount > 0 && amount <= widget.bkashService.walletBalance) {
                    setState(() {
                      _errorMessage = null;
                      _currentStep = 3;
                    });
                  } else {
                    setState(() => _errorMessage = 'Invalid recharge amount.');
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

  // STEP 3: PIN & Hold to Recharge
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
                  const Text('অপারেটর / Operator', style: TextStyle(color: BkashTheme.textMuted)),
                  Text(_selectedOperator, style: const TextStyle(fontWeight: FontWeight.bold, color: BkashTheme.textDark)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('মোবাইল / Mobile', style: TextStyle(color: BkashTheme.textMuted)),
                  Text(_phoneController.text, style: const TextStyle(fontWeight: FontWeight.bold, color: BkashTheme.textDark)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('রিচার্জ পরিমাণ / Amount', style: TextStyle(color: BkashTheme.textMuted)),
                  Text('৳ ${amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: BkashTheme.primaryPink, fontSize: 16)),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),
        const Text(
          'bKash PIN দিন (Enter PIN)',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: BkashTheme.textDark),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _pinController,
          keyboardType: TextInputType.number,
          obscureText: true,
          maxLength: 5,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 22, letterSpacing: 8, fontWeight: FontWeight.bold, color: BkashTheme.textDark),
          decoration: const InputDecoration(
            hintText: '•••••',
            counterText: '',
          ),
        ),

        const SizedBox(height: 30),
        HoldToConfirmBar(
          label: 'রিচার্জ করতে ট্যাপ করে ধরে রাখুন',
          onConfirmed: _onConfirmRecharge,
        ),
      ],
    );
  }
}
