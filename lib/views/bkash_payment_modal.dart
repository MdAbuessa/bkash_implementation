import 'dart:async';
import 'package:flutter/material.dart';
import '../models/bkash_transaction.dart';
import '../services/bkash_service.dart';
import '../theme/bkash_theme.dart';

class BkashPaymentModal extends StatefulWidget {
  final double amount;
  final String invoiceNumber;
  final BkashService bkashService;
  final Function(BkashTransaction) onPaymentCompleted;

  const BkashPaymentModal({
    super.key,
    required this.amount,
    required this.invoiceNumber,
    required this.bkashService,
    required this.onPaymentCompleted,
  });

  @override
  State<BkashPaymentModal> createState() => _BkashPaymentModalState();
}

class _BkashPaymentModalState extends State<BkashPaymentModal> {
  int _currentStep = 1; // 1: Phone, 2: OTP, 3: PIN, 4: Processing
  final _phoneController = TextEditingController(text: '01770618575');
  final _otpController = TextEditingController(text: '123456');
  final _pinController = TextEditingController(text: '12121');

  String? _paymentID;
  String? _errorMessage;
  int _timerSeconds = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _initPayment();
  }

  Future<void> _initPayment() async {
    final result = await widget.bkashService.createPayment(
      amount: widget.amount,
      invoiceNumber: widget.invoiceNumber,
    );
    if (result['success'] == true) {
      setState(() {
        _paymentID = result['paymentID'];
      });
    }
  }

  void _startTimer() {
    _timerSeconds = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_timerSeconds > 0) {
        setState(() => _timerSeconds--);
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _pinController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _processPayment() async {
    setState(() {
      _currentStep = 4; // Processing
      _errorMessage = null;
    });

    final trx = await widget.bkashService.executePayment(
      paymentID: _paymentID ?? 'MOCK_PAYMENT_ID',
      customerMsisdn: _phoneController.text.trim(),
      amount: widget.amount,
      invoiceNumber: widget.invoiceNumber,
      pin: _pinController.text.trim(),
    );

    if (trx.status == BkashPaymentStatus.success) {
      widget.onPaymentCompleted(trx);
    } else {
      setState(() {
        _currentStep = 3;
        _errorMessage = trx.errorMessage ?? 'Payment failed. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E2C),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // bKash Signature Pink Header Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: const BoxDecoration(
                gradient: BkashTheme.bkashGradient,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'bKash',
                              style: TextStyle(
                                color: BkashTheme.primaryPink,
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Checkout',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Merchant Invoice',
                              style: TextStyle(fontSize: 11, color: Colors.white70),
                            ),
                            Text(
                              widget.invoiceNumber,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'Amount to Pay',
                              style: TextStyle(fontSize: 11, color: Colors.white70),
                            ),
                            Text(
                              '৳ ${widget.amount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            if (_errorMessage != null)
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: BkashTheme.errorRed.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: BkashTheme.errorRed),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: BkashTheme.errorRed),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: BkashTheme.errorRed, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: _buildStepContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 1:
        return _buildPhoneStep();
      case 2:
        return _buildOtpStep();
      case 3:
        return _buildPinStep();
      case 4:
        return _buildProcessingStep();
      default:
        return const SizedBox.shrink();
    }
  }

  // STEP 1: Phone Number Entry
  Widget _buildPhoneStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your bKash Account Number',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Enter your 11-digit bKash mobile number',
          style: TextStyle(fontSize: 12, color: BkashTheme.textMuted),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          maxLength: 11,
          style: const TextStyle(fontSize: 16, letterSpacing: 1),
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.phone_android, color: BkashTheme.primaryPink),
            hintText: 'e.g. 01712345678',
            counterText: '',
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              if (_phoneController.text.trim().length == 11) {
                _startTimer();
                setState(() => _currentStep = 2);
              } else {
                setState(() => _errorMessage = 'Please enter a valid 11-digit mobile number.');
              }
            },
            child: const Text('CONFIRM'),
          ),
        ),
        const SizedBox(height: 12),
        const Center(
          child: Text(
            'By clicking Confirm, you agree to bKash Terms & Conditions',
            style: TextStyle(fontSize: 11, color: BkashTheme.textMuted),
          ),
        ),
      ],
    );
  }

  // STEP 2: OTP Verification
  Widget _buildOtpStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Enter Verification Code',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              '00:$_timerSeconds',
              style: const TextStyle(
                color: BkashTheme.primaryPink,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'A 6-digit verification code sent to ${_phoneController.text}',
          style: const TextStyle(fontSize: 12, color: BkashTheme.textMuted),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 22,
            letterSpacing: 8,
            fontWeight: FontWeight.bold,
          ),
          decoration: const InputDecoration(
            hintText: '123456',
            counterText: '',
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: BkashTheme.dividerColor),
                ),
                onPressed: () => setState(() => _currentStep = 1),
                child: const Text('BACK'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  if (_otpController.text.trim().length == 6) {
                    setState(() => _currentStep = 3);
                  } else {
                    setState(() => _errorMessage = 'Please enter 6-digit OTP code.');
                  }
                },
                child: const Text('CONFIRM'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // STEP 3: PIN Entry
  Widget _buildPinStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Enter bKash Account PIN',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Enter your 5-digit bKash secret PIN',
          style: TextStyle(fontSize: 12, color: BkashTheme.textMuted),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _pinController,
          keyboardType: TextInputType.number,
          obscureText: true,
          maxLength: 5,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 22,
            letterSpacing: 10,
            fontWeight: FontWeight.bold,
          ),
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.lock_clock_outlined, color: BkashTheme.primaryPink),
            hintText: '•••••',
            counterText: '',
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: BkashTheme.dividerColor),
                ),
                onPressed: () => setState(() => _currentStep = 2),
                child: const Text('BACK'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: BkashTheme.primaryPink,
                ),
                onPressed: () {
                  if (_pinController.text.trim().length >= 4) {
                    _processPayment();
                  } else {
                    setState(() => _errorMessage = 'Please enter your 5-digit PIN.');
                  }
                },
                child: const Text('PAY NOW'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // STEP 4: Processing Animation
  Widget _buildProcessingStep() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 30),
      child: Column(
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(BkashTheme.primaryPink),
            strokeWidth: 3,
          ),
          SizedBox(height: 20),
          Text(
            'Processing bKash Payment...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Communicating securely with bKash Gateway',
            style: TextStyle(fontSize: 12, color: BkashTheme.textMuted),
          ),
        ],
      ),
    );
  }
}
