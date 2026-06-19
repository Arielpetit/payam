import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/localization/app_localizations.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: Text(loc.translate('about') ?? 'About'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 32),

            // App logo / icon
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [AppColors.primaryLight, AppColors.primary]
                      : [AppColors.primary, AppColors.primaryDark],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: isDark
                    ? null
                    : [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
              ),
              child: Icon(
                Icons.account_balance_wallet_rounded,
                size: 44,
                color: isDark ? Colors.black : Colors.white,
              ),
            ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),

            const SizedBox(height: 20),

            // App name
            Text(
              'Payam',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),

            const SizedBox(height: 4),

            // Tagline
            Text(
              'Modern African Digital Wallet',
              style: TextStyle(
                fontSize: 15,
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 8),

            // Version
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'v1.0.0',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Mission section
            _SectionCard(
              isDark: isDark,
              icon: Icons.lightbulb_outline_rounded,
              iconColor: AppColors.warning,
              title: 'Our Mission',
              child: Text(
                'To make financial services accessible, affordable, and instant for every African — regardless of banking status, location, or connectivity.',
                style: TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Vision section
            _SectionCard(
              isDark: isDark,
              icon: Icons.visibility_rounded,
              iconColor: AppColors.primary,
              title: 'Our Vision',
              child: Text(
                'A financially inclusive Africa where anyone with a phone can send, receive, save, and grow money — instantly and securely.',
                style: TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // What we offer
            _SectionCard(
              isDark: isDark,
              icon: Icons.star_rounded,
              iconColor: const Color(0xFFE8A838),
              title: 'What We Offer',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FeatureRow(icon: Icons.send_rounded, text: 'Instant money transfers to anyone', isDark: isDark),
                  const SizedBox(height: 12),
                  _FeatureRow(icon: Icons.phone_android_rounded, text: 'Mobile money top-up (MTN, Orange)', isDark: isDark),
                  const SizedBox(height: 12),
                  _FeatureRow(icon: Icons.qr_code_rounded, text: 'QR code payments at merchants', isDark: isDark),
                  const SizedBox(height: 12),
                  _FeatureRow(icon: Icons.nfc_rounded, text: 'NFC tap-to-pay for contactless transactions', isDark: isDark),
                  const SizedBox(height: 12),
                  _FeatureRow(icon: Icons.account_balance_rounded, text: 'Bank transfers (Afriland, UBA, BGFI)', isDark: isDark),
                  const SizedBox(height: 12),
                  _FeatureRow(icon: Icons.security_rounded, text: 'Bank-grade security & KYC verification', isDark: isDark),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Built for Africa
            _SectionCard(
              isDark: isDark,
              icon: Icons.public_rounded,
              iconColor: AppColors.info,
              title: 'Built for Africa',
              child: Text(
                'Payam is designed from the ground up for African markets. We support FCFA currency, local mobile money providers, regional banks, and work even on low-connectivity networks. Our interface is available in English and French.',
                style: TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Security section
            _SectionCard(
              isDark: isDark,
              icon: Icons.verified_user_rounded,
              iconColor: AppColors.success,
              title: 'Security & Trust',
              child: Text(
                'Your money and data are protected with end-to-end encryption, biometric authentication, and real-time fraud monitoring. Payam is built with the same security standards trusted by leading financial institutions.',
                style: TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Contact / Links
            _SectionCard(
              isDark: isDark,
              icon: Icons.contact_support_rounded,
              iconColor: AppColors.primary,
              title: 'Get in Touch',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ContactRow(icon: Icons.language_rounded, label: 'www.payam.app', isDark: isDark),
                  const SizedBox(height: 10),
                  _ContactRow(icon: Icons.email_rounded, label: 'support@payam.app', isDark: isDark),
                  const SizedBox(height: 10),
                  _ContactRow(icon: Icons.location_on_rounded, label: 'Douala, Cameroon', isDark: isDark),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Legal links
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _LinkButton(label: loc.translate('terms_of_service') ?? 'Terms of Service', isDark: isDark),
                Text('  ·  ', style: TextStyle(color: isDark ? AppColors.darkTextHint : AppColors.textTertiary)),
                _LinkButton(label: loc.translate('privacy_policy') ?? 'Privacy Policy', isDark: isDark),
              ],
            ),

            const SizedBox(height: 12),

            Text(
              '© ${DateTime.now().year} Payam. All rights reserved.',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.darkTextHint : AppColors.textTertiary,
              ),
            ),

            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final bool isDark;
  final IconData icon;
  final Color iconColor;
  final String title;
  final Widget child;

  const _SectionCard({
    required this.isDark,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF121212) : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: isDark ? Border.all(color: const Color(0xFF1E1E1E)) : null,
        boxShadow: isDark ? null : AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: iconColor),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isDark;

  const _FeatureRow({required this.icon, required this.text, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              height: 1.4,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;

  const _ContactRow({required this.icon, required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _LinkButton extends StatelessWidget {
  final String label;
  final bool isDark;

  const _LinkButton({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO: Navigate to terms/privacy pages
      },
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.primary,
          decoration: TextDecoration.underline,
          decorationColor: AppColors.primary.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}