import 'package:flutter/material.dart';
import '../services/bkash_service.dart';
import '../theme/bkash_theme.dart';
import 'api_config_dialog.dart';
import 'bkash_payment_modal.dart';
import 'payment_status_screen.dart';
import 'transaction_history_screen.dart';

class CheckoutItem {
  final String title;
  final String subtitle;
  final double price;
  final IconData icon;

  const CheckoutItem({
    required this.title,
    required this.subtitle,
    required this.price,
    required this.icon,
  });
}

class CheckoutScreen extends StatefulWidget {
  final BkashService bkashService;

  const CheckoutScreen({super.key, required this.bkashService});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final List<CheckoutItem> _items = const [
    CheckoutItem(
      title: 'Flutter Developer Masterclass',
      subtitle: 'Full course bundle + bKash source code',
      price: 1250.00,
      icon: Icons.school_outlined,
    ),
    CheckoutItem(
      title: 'Premium Cloud Hosting',
      subtitle: '1 Month VPS - Dhaka Data Center',
      price: 499.00,
      icon: Icons.cloud_done_outlined,
    ),
    CheckoutItem(
      title: 'Digital Gadget Accessories',
      subtitle: 'Wireless Bluetooth Headset',
      price: 850.00,
      icon: Icons.headset_mic_outlined,
    ),
  ];

  int _selectedItemIndex = 0;
  final _customAmountController = TextEditingController();
  bool _useCustomAmount = false;

  @override
  void dispose() {
    _customAmountController.dispose();
    super.dispose();
  }

  double get _currentAmount {
    if (_useCustomAmount) {
      return double.tryParse(_customAmountController.text) ?? 100.0;
    }
    return _items[_selectedItemIndex].price;
  }

  String get _generatedInvoice {
    return 'INV-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
  }

  void _openBkashModal() {
    final amount = _currentAmount;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid payment amount.'),
          backgroundColor: BkashTheme.errorRed,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BkashPaymentModal(
        amount: amount,
        invoiceNumber: _generatedInvoice,
        bkashService: widget.bkashService,
        onPaymentCompleted: (trx) {
          Navigator.pop(ctx);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PaymentStatusScreen(transaction: trx),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final creds = widget.bkashService.credentials;

    return Scaffold(
      backgroundColor: BkashTheme.bgLight,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'bKash',
                style: TextStyle(
                  color: BkashTheme.primaryPink,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text('Payment Gateway'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            tooltip: 'Transaction History',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TransactionHistoryScreen(
                    bkashService: widget.bkashService,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'API Credentials',
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => ApiConfigDialog(
                  initialCredentials: widget.bkashService.credentials,
                  onSave: (newCreds) async {
                    await widget.bkashService.saveCredentials(newCreds);
                    setState(() {});
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // API Mode Status Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: creds.isSandbox
                      ? Colors.amber.withValues(alpha: 0.6)
                      : BkashTheme.successGreen.withValues(alpha: 0.6),
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
                  Icon(
                    creds.isSandbox
                        ? Icons.science_outlined
                        : Icons.check_circle_outline,
                    color: creds.isSandbox ? Colors.amber[800] : BkashTheme.successGreen,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          creds.isSandbox
                              ? 'bKash Tokenized Sandbox Mode'
                              : 'bKash Live Merchant Mode',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: BkashTheme.textDark,
                          ),
                        ),
                        Text(
                          creds.isSandbox
                              ? 'Testing with simulated responses & OTP/PIN checks'
                              : 'Connected to Live bKash Gateway',
                          style: const TextStyle(
                            fontSize: 11,
                            color: BkashTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Text(
              'Select Product / Service',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: BkashTheme.textDark,
              ),
            ),
            const SizedBox(height: 12),

            // Item Cards
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                final isSelected = !_useCustomAmount && _selectedItemIndex == index;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _useCustomAmount = false;
                      _selectedItemIndex = index;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
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
                          child: Icon(
                            item.icon,
                            color: BkashTheme.primaryPink,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: BkashTheme.textDark,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item.subtitle,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: BkashTheme.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '৳ ${item.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: BkashTheme.primaryPink,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            // Custom Amount Option
            GestureDetector(
              onTap: () {
                setState(() {
                  _useCustomAmount = true;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _useCustomAmount ? BkashTheme.softPinkContainer : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _useCustomAmount
                        ? BkashTheme.primaryPink
                        : BkashTheme.dividerColor,
                    width: _useCustomAmount ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.edit_note_rounded, color: BkashTheme.primaryPink),
                        SizedBox(width: 10),
                        Text(
                          'Custom Amount Entry',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: BkashTheme.textDark,
                          ),
                        ),
                      ],
                    ),
                    if (_useCustomAmount) ...[
                      const SizedBox(height: 12),
                      TextField(
                        controller: _customAmountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(color: BkashTheme.textDark, fontSize: 16),
                        decoration: const InputDecoration(
                          prefixText: '৳ ',
                          prefixStyle: TextStyle(
                            color: BkashTheme.primaryPink,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                          hintText: 'Enter amount (e.g. 500)',
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Checkout Summary Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: BkashTheme.cardHeaderGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: BkashTheme.primaryPink.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Payable',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white70,
                        ),
                      ),
                      Text(
                        '৳ ${_currentAmount.toStringAsFixed(2)} BDT',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: BkashTheme.primaryPink,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 4,
                      ),
                      onPressed: _openBkashModal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: BkashTheme.primaryPink,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'bKash',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Pay with bKash',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, size: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
