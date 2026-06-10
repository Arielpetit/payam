import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/widgets/user_avatar.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final loc = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: Text(loc.translate('settings')),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),
            // Avatar & Name
            Center(
              child: Column(
                children: [
                  UserAvatar(user: user, size: 96, showBadge: user.isVerified),
                  const SizedBox(height: 16),
                  Text(
                    user.fullName,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: TextStyle(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: user.isVerified
                          ? AppColors.successSurface
                          : AppColors.warningSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: isDark
                          ? Border.all(
                              color: user.isVerified
                                  ? AppColors.success.withOpacity(0.3)
                                  : AppColors.warning.withOpacity(0.3),
                            )
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          user.isVerified ? Icons.verified_rounded : Icons.info_outline_rounded,
                          size: 14,
                          color: user.isVerified ? AppColors.success : AppColors.warning,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          user.isVerified ? 'Verified Account' : 'Unverified',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: user.isVerified ? AppColors.success : AppColors.warning,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn().slideY(begin: 0.1),

            const SizedBox(height: 32),

            // KYC Card (if not verified)
            if (!user.isVerified)
              _KYCCard(isDark: isDark, context: context)
                  .animate()
                  .fadeIn(delay: 100.ms)
                  .slideY(begin: 0.1),

            const SizedBox(height: 20),

            // Settings List
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceVariant : AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: isDark ? Border.all(color: AppColors.darkBorder) : null,
                boxShadow: isDark ? null : AppColors.cardShadow,
              ),
              child: Column(
                children: [
                  _ProfileMenuItem(
                    icon: Icons.person_outline_rounded,
                    title: loc.translate('personal_information') ?? 'Personal Information',
                    isDark: isDark,
                    onTap: () {},
                  ),
                  Divider(height: 1, indent: 56, color: isDark ? AppColors.darkBorder : AppColors.border),
                  _ProfileMenuItem(
                    icon: Icons.account_balance_rounded,
                    title: loc.translate('linked_banks') ?? 'Bank Accounts',
                    isDark: isDark,
                    onTap: () {},
                  ),
                  Divider(height: 1, indent: 56, color: isDark ? AppColors.darkBorder : AppColors.border),
                  _ProfileMenuItem(
                    icon: Icons.security_rounded,
                    title: loc.translate('security') ?? 'Security',
                    isDark: isDark,
                    onTap: () {},
                  ),
                  Divider(height: 1, indent: 56, color: isDark ? AppColors.darkBorder : AppColors.border),
                  _ProfileMenuItem(
                    icon: Icons.qr_code_rounded,
                    title: loc.translate('scan_to_pay_me') ?? 'My QR Code',
                    isDark: isDark,
                    onTap: () => context.push('/receive-money'),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),

            const SizedBox(height: 16),

            // Settings Button
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceVariant : AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: isDark ? Border.all(color: AppColors.darkBorder) : null,
                boxShadow: isDark ? null : AppColors.cardShadow,
              ),
              child: _ProfileMenuItem(
                icon: Icons.settings_rounded,
                title: loc.translate('preferences') ?? 'Settings',
                isDark: isDark,
                onTap: () => context.push('/settings'),
              ),
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),

            const SizedBox(height: 24),

            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceVariant : AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: isDark ? Border.all(color: AppColors.darkBorder) : null,
                boxShadow: isDark ? null : AppColors.cardShadow,
              ),
              child: Column(
                children: [
                  _ProfileMenuItem(
                    icon: Icons.help_outline_rounded,
                    title: loc.translate('about') ?? 'Help Center',
                    isDark: isDark,
                    onTap: () {},
                  ),
                  Divider(height: 1, indent: 56, color: isDark ? AppColors.darkBorder : AppColors.border),
                  _ProfileMenuItem(
                    icon: Icons.logout_rounded,
                    title: loc.translate('log_out') ?? 'Log Out',
                    iconColor: AppColors.error,
                    textColor: AppColors.error,
                    isDark: isDark,
                    showArrow: false,
                    onTap: () {
                      context.go('/login');
                    },
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),

            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}

class _KYCCard extends StatelessWidget {
  final bool isDark;
  final BuildContext context;

  const _KYCCard({required this.isDark, required this.context});

  @override
  Widget build(BuildContext ctx) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  AppColors.warning.withOpacity(0.15),
                  AppColors.warning.withOpacity(0.25),
                ]
              : [
                  const Color(0xFFFFF7ED),
                  const Color(0xFFFFEDD5),
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.warning.withOpacity(isDark ? 0.4 : 0.6),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.verified_user_rounded,
              color: AppColors.warning,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'KYC Verification Required',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Unlock all features including virtual cards',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.warning,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Verify',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.black : Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? textColor;
  final bool showArrow;
  final bool isDark;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.iconColor,
    this.textColor,
    this.showArrow = true,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.primary).withOpacity(isDark ? 0.15 : 0.1),
                borderRadius: BorderRadius.circular(10),
                border: isDark ? Border.all(color: (iconColor ?? AppColors.primary).withOpacity(0.3)) : null,
              ),
              child: Icon(icon, color: iconColor ?? AppColors.primary, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: textColor ?? (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                ),
              ),
            ),
            if (showArrow)
              Icon(
                Icons.chevron_right_rounded,
                color: isDark ? AppColors.darkTextHint : AppColors.textHint,
              ),
          ],
        ),
      ),
    );
  }
}