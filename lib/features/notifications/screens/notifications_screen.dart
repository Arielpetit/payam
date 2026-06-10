import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/models/notification_model.dart';
import '../../../shared/providers/app_providers.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: isDark ? Colors.black : AppColors.background,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.done_all_rounded, color: isDark ? Colors.white : AppColors.textPrimary),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: const Text('All marked as read')),
              );
            },
          ),
        ],
      ),
      body: notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_rounded,
                    size: 64,
                    color: isDark ? Colors.white24 : AppColors.textHint.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No new notifications',
                    style: TextStyle(
                      color: isDark ? Colors.white60 : AppColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: notifications.length,
              itemBuilder: (context, i) {
                return _NotificationTile(notification: notifications[i])
                    .animate().fadeIn(delay: Duration(milliseconds: 100 * i)).slideX(begin: 0.1);
              },
            ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  const _NotificationTile({required this.notification});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final (icon, color, bg) = _getStyle(isDark);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: notification.isRead
            ? (isDark ? const Color(0xFF121212) : AppColors.surface)
            : (isDark ? const Color(0xFF1A1A2E) : AppColors.primarySurface),
        borderRadius: BorderRadius.circular(16),
        border: isDark ? Border.all(color: const Color(0xFF1E1E1E)) : null,
        boxShadow: isDark ? null : AppColors.cardShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: bg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: notification.isRead ? FontWeight.w600 : FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      DateFormatter.formatRelative(notification.date, languageCode: Localizations.localeOf(context).languageCode),
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white38 : AppColors.textHint,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  notification.message,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white60 : AppColors.textSecondary,
                    fontWeight: notification.isRead ? FontWeight.normal : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  (IconData, Color, Color) _getStyle(bool isDark) {
    switch (notification.category) {
      case NotificationCategory.transaction:
        return (
          Icons.account_balance_wallet_rounded,
          AppColors.success,
          isDark ? AppColors.success.withOpacity(0.15) : AppColors.successSurface,
        );
      case NotificationCategory.promotion:
        return (
          Icons.star_rounded,
          const Color(0xFFF59E0B),
          isDark ? const Color(0xFFF59E0B).withOpacity(0.15) : const Color(0xFFFEF3C7),
        );
      case NotificationCategory.security:
        return (
          Icons.security_rounded,
          AppColors.error,
          isDark ? AppColors.error.withOpacity(0.15) : AppColors.errorSurface,
        );
      case NotificationCategory.system:
        return (
          Icons.info_rounded,
          AppColors.info,
          isDark ? AppColors.info.withOpacity(0.15) : AppColors.infoSurface,
        );
    }
  }
}