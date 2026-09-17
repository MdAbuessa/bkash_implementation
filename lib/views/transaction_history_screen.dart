import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/bkash_transaction.dart';
import '../services/bkash_service.dart';
import '../theme/bkash_theme.dart';
import 'payment_status_screen.dart';

class TransactionHistoryScreen extends StatefulWidget {
  final BkashService bkashService;

  const TransactionHistoryScreen({super.key, required this.bkashService});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  List<BkashTransaction> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final history = await widget.bkashService.getTransactionHistory();
    setState(() {
      _transactions = history;
      _isLoading = false;
    });
  }

  Future<void> _clearHistory() async {
    await widget.bkashService.clearHistory();
    _loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BkashTheme.bgLight,
      appBar: AppBar(
        title: const Text('bKash Statement / History'),
        actions: [
          if (_transactions.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.white),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: Colors.white,
                    title: const Text('Clear History', style: TextStyle(color: BkashTheme.textDark)),
                    content: const Text('Are you sure you want to clear all transaction logs?', style: TextStyle(color: BkashTheme.textMuted)),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _clearHistory();
                        },
                        child: const Text(
                          'Clear',
                          style: TextStyle(color: BkashTheme.errorRed),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: BkashTheme.primaryPink),
            )
          : _transactions.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _transactions.length,
                  itemBuilder: (context, index) {
                    final trx = _transactions[index];
                    return _buildTransactionCard(trx);
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: BkashTheme.textMuted,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Transactions Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: BkashTheme.textDark,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Your bKash payment history will appear here.',
            style: TextStyle(color: BkashTheme.textMuted, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(BkashTransaction trx) {
    final isSuccess = trx.status == BkashPaymentStatus.success;
    final formattedDate =
        DateFormat('dd MMM yyyy, hh:mm a').format(trx.date);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PaymentStatusScreen(transaction: trx),
            ),
          );
        },
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isSuccess
                ? BkashTheme.successGreen.withValues(alpha: 0.12)
                : BkashTheme.errorRed.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isSuccess ? Icons.arrow_upward_rounded : Icons.close_rounded,
            color: isSuccess ? BkashTheme.successGreen : BkashTheme.errorRed,
            size: 20,
          ),
        ),
        title: Text(
          trx.type.bnName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: BkashTheme.textDark),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(
              trx.trxID.isNotEmpty ? 'TrxID: ${trx.trxID}' : 'Payment ID: ${trx.paymentId}',
              style: const TextStyle(fontSize: 12, color: BkashTheme.textMuted),
            ),
            Text(
              formattedDate,
              style: const TextStyle(fontSize: 11, color: BkashTheme.textMuted),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '৳ ${trx.amount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: BkashTheme.primaryPink,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isSuccess
                    ? BkashTheme.successGreen.withValues(alpha: 0.12)
                    : BkashTheme.errorRed.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                trx.status.name.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isSuccess
                      ? BkashTheme.successGreen
                      : BkashTheme.errorRed,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
