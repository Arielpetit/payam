import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../models/transaction_model.dart';
import '../../core/utils/formatters.dart';
import '../../core/localization/app_localizations.dart';

class TransactionTile extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback? onTap;

  const TransactionTile({
    super.key,
    required this.transaction,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurfaceVariant : AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: isDark ? Border.all(color: AppColors.darkBorder, width: 0.5) : null,
          boxShadow: isDark ? null : AppColors.cardShadow,
        ),
        child: Row(
          children: [
            _TransactionIcon(type: transaction.type, isCredit: transaction.isCredit),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    transaction.subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${transaction.isCredit ? '+' : '-'} ${CurrencyFormatter.format(transaction.amount)}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: transaction.isCredit
                        ? AppColors.success
                        : AppColors.error,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormatter.formatRelative(transaction.date),
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionIcon extends StatelessWidget {
  final TransactionType type;
  final bool isCredit;

  const _TransactionIcon({required this.type, required this.isCredit});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final (icon, color) = _getStyle();
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: isDark ? color.withOpacity(0.15) : color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(13),
        border: isDark ? Border.all(color: color.withOpacity(0.25)) : null,
      ),
      child: Icon(icon, size: 21, color: color),
    );
  }

  (IconData, Color) _getStyle() {
    switch (type) {
      case TransactionType.send:
        return (Icons.arrow_upward_rounded, AppColors.error);
      case TransactionType.receive:
        return (Icons.arrow_downward_rounded, AppColors.success);
      case TransactionType.payment:
        return (Icons.shopping_bag_rounded, AppColors.info);
      case TransactionType.airtime:
        return (Icons.phone_android_rounded, AppColors.warning);
      case TransactionType.data:
        return (Icons.wifi_rounded, AppColors.info);
      case TransactionType.bills:
        return (Icons.receipt_rounded, AppColors.warning);
      case TransactionType.deposit:
        return (Icons.account_balance_rounded, AppColors.success);
      case TransactionType.withdrawal:
        return (Icons.money_off_rounded, AppColors.error);
    }
  }
}

