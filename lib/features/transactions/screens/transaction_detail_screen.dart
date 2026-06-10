import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../shared/models/transaction_model.dart';
import '../../../shared/widgets/payam_button.dart';

class TransactionDetailScreen extends StatelessWidget {
  final TransactionModel transaction;
  const TransactionDetailScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : AppColors.background,
      appBar: AppBar(
        title: Text(context.loc('transaction_details')),
        backgroundColor: isDark ? Colors.black : AppColors.background,
        iconTheme: IconThemeData(color: isDark ? Colors.white : AppColors.textPrimary),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Status Icon & Amount
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF121212) : AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: isDark ? Border.all(color: const Color(0xFF1E1E1E)) : null,
                boxShadow: isDark ? null : AppColors.cardShadow,
              ),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: transaction.status == TransactionStatus.success
                          ? (isDark ? Colors.white12 : AppColors.successSurface)
                          : transaction.status == TransactionStatus.failed
                              ? (isDark ? Colors.white12 : AppColors.errorSurface)
                              : (isDark ? Colors.white12 : AppColors.warningSurface),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      transaction.status == TransactionStatus.success
                          ? Icons.check_circle_rounded
                          : transaction.status == TransactionStatus.failed
                              ? Icons.error_rounded
                              : Icons.access_time_rounded,
                      color: transaction.status == TransactionStatus.success
                          ? (isDark ? Colors.white : AppColors.success)
                          : transaction.status == TransactionStatus.failed
                              ? (isDark ? Colors.white54 : AppColors.error)
                              : (isDark ? Colors.white30 : AppColors.warning),
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '${transaction.isCredit ? '+' : '-'} ${CurrencyFormatter.format(transaction.amount)}',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: transaction.isCredit
                          ? (isDark ? Colors.white : AppColors.success)
                          : (isDark ? Colors.white : AppColors.textPrimary),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    transaction.title,
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.white60 : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn().scale(curve: Curves.easeOutBack),
            
            const SizedBox(height: 24),
            
            // Details List
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF121212) : AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: isDark ? Border.all(color: const Color(0xFF1E1E1E)) : null,
                boxShadow: isDark ? null : AppColors.cardShadow,
              ),
              child: Column(
                children: [
                  _DetailRow(
                    context.loc('status'),
                    transaction.status.name.toUpperCase(),
                    isDark,
                    valueColor: transaction.status == TransactionStatus.success
                        ? (isDark ? Colors.white : AppColors.success)
                        : null,
                  ),
                  Divider(height: 32, color: isDark ? const Color(0xFF1E1E1E) : AppColors.border),
                  _DetailRow(context.loc('date_time'), DateFormatter.formatDateTime(transaction.date), isDark),
                  Divider(height: 32, color: isDark ? const Color(0xFF1E1E1E) : AppColors.border),
                  _DetailRow(context.loc('reference'), transaction.reference ?? 'N/A', isDark),
                  if (transaction.recipientName != null) ...[
                    Divider(height: 32, color: isDark ? const Color(0xFF1E1E1E) : AppColors.border),
                    _DetailRow(context.loc('recipient'), transaction.recipientName!, isDark),
                  ],
                  if (transaction.note != null) ...[
                    Divider(height: 32, color: isDark ? const Color(0xFF1E1E1E) : AppColors.border),
                    _DetailRow(context.loc('note'), transaction.note!, isDark),
                  ],
                ],
              ),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
            
            const SizedBox(height: 32),
            
            PayamButton(
              label: context.loc('download_receipt'),
              icon: Icons.download_rounded,
              isOutlined: true,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(context.loc('receipt_download_msg')),
                    backgroundColor: isDark ? Colors.white : AppColors.primary,
                  ),
                );
              },
            ).animate().fadeIn(delay: 400.ms),
            
            const SizedBox(height: 16),
            
            PayamButton(
              label: context.loc('report_issue'),
              icon: Icons.flag_rounded,
              backgroundColor: isDark ? const Color(0xFFE53935) : AppColors.error,
              onPressed: () {},
            ).animate().fadeIn(delay: 500.ms),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;
  final Color? valueColor;

  const _DetailRow(this.label, this.value, this.isDark, {this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.white60 : AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: valueColor ?? (isDark ? Colors.white : AppColors.textPrimary),
            ),
          ),
        ),
      ],
    );
  }
}
