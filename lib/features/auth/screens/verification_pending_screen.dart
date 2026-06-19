import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

class VerificationPendingScreen extends StatelessWidget {
  const VerificationPendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 80),

              // Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark 
                        ? [AppColors.primaryLight, AppColors.primary]
                        : [AppColors.primary, AppColors.primaryDark],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: isDark ? null : AppColors.primaryShadow,
                ),
                child: Icon(
                  Icons.verified_user_rounded,
                  size: 50,
                  color: Colors.white,
                ),
              ).animate().fadeIn().scale(
                begin: const Offset(0.5, 0.5),
                end: const Offset(1, 1),
                duration: 400.ms,
              ),

              const SizedBox(height: 40),

              Text(
                'Verification in Progress',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2, end: 0),

              const SizedBox(height: 20),

              Text(
                'Our team is verifying your identity to restore your account.',
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.white60 : AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.2, end: 0),

              const SizedBox(height: 12),

              Text(
                'This might take some time. Please be patient.',
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.white60 : AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),

              const SizedBox(height: 48),

              // Info card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.border,
                  ),
                  boxShadow: isDark ? null : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _InfoRow(
                      icon: Icons.access_time_rounded,
                      title: 'Processing Time',
                      subtitle: '1-3 business days',
                      isDark: isDark,
                    ),
                    const SizedBox(height: 16),
                    _InfoRow(
                      icon: Icons.email_rounded,
                      title: 'Contact',
                      subtitle: 'support@payam.app',
                      isDark: isDark,
                    ),
                    const SizedBox(height: 16),
                    _InfoRow(
                      icon: Icons.security_rounded,
                      title: 'Your Data',
                      subtitle: 'Secure and encrypted',
                      isDark: isDark,
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.15, end: 0),

              const SizedBox(height: 48),

              // Back to home button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => context.go('/home'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Back to Home',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.15, end: 0),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDark;

  const _InfoRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(isDark ? 0.15 : 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 20,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white60 : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}