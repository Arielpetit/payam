import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/localization/app_localizations.dart';

class KycVerificationScreen extends StatelessWidget {
  const KycVerificationScreen({super.key});

  static const _kycUrl =
      'https://inquiry.withpersona.com/verify?inquiry-id=inq_A7YE3mwdHp4B6rxBiyvDzJNPyySucC';

  Future<void> _launchKyc(BuildContext context) async {
    final uri = Uri.parse(_kycUrl);
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open verification link. Please try again.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open verification link: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: Text('KYC Verification'),
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // Hero icon
            Center(
              child: Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [AppColors.primary.withOpacity(0.25), AppColors.primaryDark.withOpacity(0.35)]
                        : [AppColors.primary, AppColors.primaryDark],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: isDark
                      ? null
                      : [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                ),
                child: Icon(
                  Icons.verified_user_rounded,
                  size: 44,
                  color: isDark ? AppColors.primaryLight : Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 28),

            // Title
            Text(
              'Verify Your Identity',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              'Complete your KYC verification to unlock all Payam features and increase your transaction limits.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 32),

            // Benefits list
            _BenefitTile(
              icon: Icons.lock_open_rounded,
              title: 'Higher Limits',
              subtitle: 'Send and receive larger amounts',
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _BenefitTile(
              icon: Icons.credit_card_rounded,
              title: 'Virtual Cards',
              subtitle: 'Create and use virtual debit cards',
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _BenefitTile(
              icon: Icons.account_balance_rounded,
              title: 'Bank Withdrawals',
              subtitle: 'Withdraw directly to your bank',
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _BenefitTile(
              icon: Icons.shield_rounded,
              title: 'Full Protection',
              subtitle: 'Enhanced security and fraud protection',
              isDark: isDark,
            ),

            const SizedBox(height: 36),

            // CTA Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => _launchKyc(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: isDark ? 0 : 4,
                  shadowColor: AppColors.primary.withOpacity(0.3),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.open_in_new_rounded, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      'Start Verification',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Disclaimer
            Text(
              'By continuing, you will be redirected to our trusted verification partner, Persona. Your data is processed securely and in compliance with applicable regulations.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.darkTextHint : AppColors.textTertiary,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _BenefitTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDark;

  const _BenefitTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceVariant : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: isDark ? Border.all(color: AppColors.darkBorder) : null,
        boxShadow: isDark ? null : AppColors.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(isDark ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(12),
              border: isDark ? Border.all(color: AppColors.primary.withOpacity(0.3)) : null,
            ),
            child: Icon(icon, size: 22, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}