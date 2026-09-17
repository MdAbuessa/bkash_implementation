import 'package:flutter/material.dart';
import '../services/bkash_service.dart';
import '../theme/bkash_theme.dart';
import 'bkash_home_screen.dart';

class BkashLoginScreen extends StatefulWidget {
  final BkashService bkashService;

  const BkashLoginScreen({super.key, required this.bkashService});

  @override
  State<BkashLoginScreen> createState() => _BkashLoginScreenState();
}

class _BkashLoginScreenState extends State<BkashLoginScreen> {
  final _accountController = TextEditingController(text: '01712345678');
  final _pinController = TextEditingController();
  bool _isObscure = true;
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedLanguage = 'বাংলা';

  @override
  void dispose() {
    _accountController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    final pin = _pinController.text.trim();
    if (pin.length < 4) {
      setState(() {
        _errorMessage =
            'দয়া করে সঠিক ৫-সংখ্যার পিন নম্বর দিন (Enter valid PIN)';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    await Future.delayed(const Duration(milliseconds: 800));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => BkashHomeScreen(bkashService: widget.bkashService),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BkashTheme.bgLight,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section with bKash Logo & Language Toggle
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 24,
                ),
                decoration: const BoxDecoration(
                  gradient: BkashTheme.bkashGradient,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Language Selector Badge
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedLanguage = _selectedLanguage == 'বাংলা'
                                  ? 'English'
                                  : 'বাংলা';
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white30),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.language_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _selectedLanguage,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Helpline info
                        Row(
                          children: const [
                            Icon(
                              Icons.headset_mic_outlined,
                              color: Colors.white,
                              size: 18,
                            ),
                            SizedBox(width: 6),
                            Text(
                              '16247',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // Official bKash Logo Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.flutter_dash_rounded,
                            color: BkashTheme.primaryPink,
                            size: 28,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'bKash',
                            style: TextStyle(
                              color: BkashTheme.primaryPink,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),
                    const Text(
                      'লগ ইন করুন (Log In)',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Login Form Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Account Info Box
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                              color: BkashTheme.softPinkContainer,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.person_outline_rounded,
                              color: BkashTheme.primaryPink,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Abu essa',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: BkashTheme.textDark,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _accountController.text,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: BkashTheme.textMuted,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: const Text(
                              'পরিবর্তন',
                              style: TextStyle(
                                color: BkashTheme.primaryPink,
                                fontWeight: FontWeight.bold,
                              ),
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
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: BkashTheme.errorRed),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              color: BkashTheme.errorRed,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(
                                  color: BkashTheme.errorRed,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // PIN Entry Box
                    const Text(
                      'bKash পিন নম্বর (bKash PIN)',
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
                      obscureText: _isObscure,
                      maxLength: 5,
                      style: const TextStyle(
                        fontSize: 22,
                        letterSpacing: 8,
                        fontWeight: FontWeight.bold,
                        color: BkashTheme.textDark,
                      ),
                      decoration: InputDecoration(
                        hintText: '•••••',
                        counterText: '',
                        prefixIcon: const Icon(
                          Icons.lock_outline_rounded,
                          color: BkashTheme.primaryPink,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isObscure
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: BkashTheme.textMuted,
                          ),
                          onPressed: () {
                            setState(() {
                              _isObscure = !_isObscure;
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'PIN reset instruction sent to 16247',
                              ),
                              backgroundColor: BkashTheme.primaryPink,
                            ),
                          );
                        },
                        child: const Text(
                          'পিন ভুলে গেছেন? (Forgot PIN?)',
                          style: TextStyle(
                            color: BkashTheme.primaryPink,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Submit Arrow Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: _isLoading ? null : _handleLogin,
                        child: _isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text(
                                    'লগ ইন (LOG IN)',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(Icons.arrow_forward_rounded, size: 20),
                                ],
                              ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Biometric Touch ID Login Option
                    Center(
                      child: Column(
                        children: [
                          IconButton(
                            iconSize: 48,
                            icon: const Icon(
                              Icons.fingerprint_rounded,
                              color: BkashTheme.primaryPink,
                            ),
                            onPressed: _handleLogin,
                          ),
                          const Text(
                            'বায়োমেট্রিক দিয়ে লগ ইন করুন',
                            style: TextStyle(
                              fontSize: 12,
                              color: BkashTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Footer Support Info
              const Center(
                child: Text(
                  '© 2026 bKash Limited | All Rights Reserved',
                  style: TextStyle(fontSize: 11, color: BkashTheme.textMuted),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
