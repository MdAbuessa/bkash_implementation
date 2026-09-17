import 'dart:async';
import 'package:flutter/material.dart';
import '../services/bkash_service.dart';
import '../theme/bkash_theme.dart';
import 'add_money_screen.dart';
import 'bkash_login_screen.dart';
import 'checkout_screen.dart';
import 'mobile_recharge_screen.dart';
import 'send_money_screen.dart';
import 'transaction_history_screen.dart';

class BkashHomeScreen extends StatefulWidget {
  final BkashService bkashService;

  const BkashHomeScreen({super.key, required this.bkashService});

  @override
  State<BkashHomeScreen> createState() => _BkashHomeScreenState();
}

class _BkashHomeScreenState extends State<BkashHomeScreen> {
  int _currentNavIndex = 0;
  bool _showBalance = false;
  Timer? _balanceTimer;

  void _toggleBalance() {
    setState(() {
      _showBalance = true;
    });

    _balanceTimer?.cancel();
    _balanceTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _showBalance = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _balanceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BkashTheme.bgLight,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(90),
        child: Container(
          decoration: const BoxDecoration(gradient: BkashTheme.bkashGradient),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  // User Avatar
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const CircleAvatar(
                      backgroundColor: BkashTheme.primaryPink,
                      child: Icon(Icons.person, color: Colors.white, size: 24),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Name & Tap for Balance Pill Column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Abu essa',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),

                        // Tap for Balance Pill
                        GestureDetector(
                          onTap: _toggleBalance,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: const BoxDecoration(
                                    color: BkashTheme.primaryPink,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.account_balance_wallet,
                                    color: Colors.white,
                                    size: 11,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                AnimatedCrossFade(
                                  duration: const Duration(milliseconds: 250),
                                  crossFadeState: _showBalance
                                      ? CrossFadeState.showSecond
                                      : CrossFadeState.showFirst,
                                  firstChild: const Text(
                                    'ব্যালেন্স দেখুন',
                                    style: TextStyle(
                                      color: BkashTheme.primaryPink,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  secondChild: Text(
                                    '৳ ${widget.bkashService.walletBalance.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: BkashTheme.primaryPink,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Notification & Menu Actions
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.notifications_none_rounded,
                          color: Colors.white,
                        ),
                        onPressed: () {},
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 8),
                      PopupMenuButton<String>(
                        icon: const Icon(
                          Icons.more_vert_rounded,
                          color: Colors.white,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onSelected: (value) {
                          if (value == 'logout') {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BkashLoginScreen(
                                  bkashService: widget.bkashService,
                                ),
                              ),
                            );
                          }
                        },
                        itemBuilder: (BuildContext context) => [
                          const PopupMenuItem<String>(
                            value: 'logout',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.logout_rounded,
                                  color: BkashTheme.primaryPink,
                                ),
                                SizedBox(width: 8),
                                Text('লগ আউট (Log Out)'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: IndexedStack(
        index: _currentNavIndex,
        children: [
          _buildHomeTab(),
          TransactionHistoryScreen(bkashService: widget.bkashService),
          CheckoutScreen(bkashService: widget.bkashService),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentNavIndex,
        backgroundColor: Colors.white,
        selectedItemColor: BkashTheme.primaryPink,
        unselectedItemColor: BkashTheme.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        onTap: (index) {
          setState(() {
            _currentNavIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'হোম (Home)',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_rounded),
            label: 'স্টেটমেন্ট',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            label: 'পেমেন্ট (Merchant)',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Services Grid Container (White Card with Soft Shadow)
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              mainAxisSpacing: 16,
              crossAxisSpacing: 12,
              childAspectRatio: 0.82,
              children: [
                _buildServiceItem(
                  icon: Icons.send_rounded,
                  labelBn: 'সেন্ড মানি',
                  labelEn: 'Send Money',
                  color: const Color(0xFFE2136E),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            SendMoneyScreen(bkashService: widget.bkashService),
                      ),
                    ).then((_) => setState(() {}));
                  },
                ),
                _buildServiceItem(
                  icon: Icons.smartphone_rounded,
                  labelBn: 'মোবাইল রিচার্জ',
                  labelEn: 'Recharge',
                  color: const Color(0xFF00A3E0),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MobileRechargeScreen(
                          bkashService: widget.bkashService,
                        ),
                      ),
                    ).then((_) => setState(() {}));
                  },
                ),
                _buildServiceItem(
                  icon: Icons.local_atm_rounded,
                  labelBn: 'ক্যাশ আউট',
                  labelEn: 'Cash Out',
                  color: const Color(0xFFFF9800),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Cash Out at any bKash Agent Point.'),
                        backgroundColor: BkashTheme.primaryPink,
                      ),
                    );
                  },
                ),
                _buildServiceItem(
                  icon: Icons.storefront_rounded,
                  labelBn: 'পেমেন্ট',
                  labelEn: 'Payment',
                  color: const Color(0xFFE2136E),
                  onTap: () {
                    setState(() {
                      _currentNavIndex = 2;
                    });
                  },
                ),
                _buildServiceItem(
                  icon: Icons.add_card_rounded,
                  labelBn: 'এড মানি',
                  labelEn: 'Add Money',
                  color: const Color(0xFF4CAF50),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            AddMoneyScreen(bkashService: widget.bkashService),
                      ),
                    ).then((_) => setState(() {}));
                  },
                ),
                _buildServiceItem(
                  icon: Icons.receipt_long_rounded,
                  labelBn: 'পে বিল',
                  labelEn: 'Pay Bill',
                  color: const Color(0xFF9C27B0),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Pay Electricity, Water, Gas & Internet bills.',
                        ),
                        backgroundColor: BkashTheme.primaryPink,
                      ),
                    );
                  },
                ),
                _buildServiceItem(
                  icon: Icons.savings_rounded,
                  labelBn: 'সেভিংস',
                  labelEn: 'Savings',
                  color: const Color(0xFF009688),
                  onTap: () {},
                ),
                _buildServiceItem(
                  icon: Icons.account_balance_rounded,
                  labelBn: 'লোন',
                  labelEn: 'Loan',
                  color: const Color(0xFF3F51B5),
                  onTap: () {},
                ),
              ],
            ),
          ),

          // Suggestions / Recent Transfers Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'পরামর্শ / Recent Contacts',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: BkashTheme.textDark,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'সব দেখুন',
                    style: TextStyle(color: BkashTheme.primaryPink),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(
            height: 90,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildContactPill('Rahim', '01712...'),
                _buildContactPill('Karim', '01898...'),
                _buildContactPill('Mother', '01933...'),
                _buildContactPill('Father', '01552...'),
                _buildContactPill('Friend', '01677...'),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Promotional Offers Banner
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const Text(
              'অফার এবং নোটিফিকেশন (Offers)',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: BkashTheme.textDark,
              ),
            ),
          ),
          const SizedBox(height: 12),

          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            height: 140,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE2136E), Color(0xFFC20D5D)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: BkashTheme.primaryPink.withValues(alpha: 0.25),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'bKash CashBack Offer',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Get ৳ 100 CashBack on Merchant Payment!',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Valid until 30 Sept 2026',
                        style: TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.card_giftcard_rounded,
                  color: Colors.white,
                  size: 56,
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildServiceItem({
    required IconData icon,
    required String labelBn,
    required String labelEn,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: 0.2)),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 6),
          Text(
            labelBn,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: BkashTheme.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactPill(String name, String phone) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      width: 70,
      child: Column(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: BkashTheme.softPinkContainer,
            child: Text(
              name[0],
              style: const TextStyle(
                color: BkashTheme.primaryPink,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: BkashTheme.textDark),
          ),
        ],
      ),
    );
  }
}
