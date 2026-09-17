import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/bkash_transaction.dart';
import '../theme/bkash_theme.dart';

class PaymentStatusScreen extends StatelessWidget {
  final BkashTransaction transaction;

  const PaymentStatusScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isSuccess = transaction.status == BkashPaymentStatus.success;
    final formattedDate =
        DateFormat('dd MMM yyyy, hh:mm a').format(transaction.date);

    return Scaffold(
      backgroundColor: BkashTheme.bgLight,
      appBar: AppBar(
        title: Text(isSuccess ? 'Payment Receipt' : 'Payment Failed'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            // Header Icon Badge
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSuccess
                    ? BkashTheme.successGreen.withValues(alpha: 0.12)
                    : BkashTheme.errorRed.withValues(alpha: 0.12),
              ),
              child: Icon(
                isSuccess
                    ? Icons.check_circle_rounded
                    : Icons.cancel_rounded,
                size: 72,
                color: isSuccess
                    ? BkashTheme.successGreen
                    : BkashTheme.errorRed,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isSuccess ? 'Payment Successful!' : 'Payment Failed',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: BkashTheme.textDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isSuccess
                  ? 'Your transaction has been processed by bKash'
                  : (transaction.errorMessage ?? 'Payment transaction could not be completed'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: BkashTheme.textMuted),
            ),
            const SizedBox(height: 24),

            // Receipt Card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
                border: Border.all(
                  color: isSuccess
                      ? BkashTheme.primaryPink.withValues(alpha: 0.3)
                      : BkashTheme.errorRed.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  // Receipt Top Pink Strip
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: const BoxDecoration(
                      gradient: BkashTheme.bkashGradient,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'bKash Digital Receipt',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            transaction.currency,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        // Amount Header
                        const Text(
                          'Total Paid',
                          style: TextStyle(fontSize: 12, color: BkashTheme.textMuted),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '৳ ${transaction.amount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: BkashTheme.primaryPink,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Divider(color: BkashTheme.dividerColor),
                        const SizedBox(height: 12),

                        // Receipt Key-Values
                        if (isSuccess && transaction.trxID.isNotEmpty)
                          _buildReceiptRow(
                            context,
                            label: 'bKash TrxID',
                            value: transaction.trxID,
                            isCopyable: true,
                            isHighlighted: true,
                          ),
                        _buildReceiptRow(
                          context,
                          label: 'Merchant Invoice',
                          value: transaction.merchantInvoiceNumber,
                        ),
                        _buildReceiptRow(
                          context,
                          label: 'Payment ID',
                          value: transaction.paymentId,
                        ),
                        _buildReceiptRow(
                          context,
                          label: 'bKash Account',
                          value: transaction.customerMsisdn,
                        ),
                        _buildReceiptRow(
                          context,
                          label: 'Date & Time',
                          value: formattedDate,
                        ),
                        _buildReceiptRow(
                          context,
                          label: 'Status',
                          value: transaction.status.name.toUpperCase(),
                          valueColor: isSuccess
                              ? BkashTheme.successGreen
                              : BkashTheme.errorRed,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
            // Actions
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back to Home'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptRow(
    BuildContext context, {
    required String label,
    required String value,
    bool isCopyable = false,
    bool isHighlighted = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: BkashTheme.textMuted),
          ),
          Row(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w500,
                  color: valueColor ?? (isHighlighted ? BkashTheme.primaryPink : BkashTheme.textDark),
                ),
              ),
              if (isCopyable) ...[
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: value));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('TrxID copied to clipboard!'),
                        duration: Duration(seconds: 2),
                        backgroundColor: BkashTheme.primaryPink,
                      ),
                    );
                  },
                  child: const Icon(
                    Icons.copy_rounded,
                    size: 16,
                    color: BkashTheme.primaryPink,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
