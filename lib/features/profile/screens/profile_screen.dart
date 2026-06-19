import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/widgets/user_avatar.dart';
import '../../../shared/widgets/payam_button.dart';
import '../../../shared/repositories/mock_repository.dart';

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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        user.email,
                        style: TextStyle(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        user.isEmailVerified ? Icons.verified_rounded : Icons.warning_amber_rounded,
                        size: 16,
                        color: user.isEmailVerified ? AppColors.success : AppColors.warning,
                      ),
                    ],
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
                                  ? AppColors.success.withValues(alpha: 0.3)
                                  : AppColors.warning.withValues(alpha: 0.3),
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
                  if (!user.isVerified) ...[
                    Divider(height: 1, indent: 56, color: isDark ? AppColors.darkBorder : AppColors.border),
                    _ProfileMenuItem(
                      icon: Icons.verified_user_rounded,
                      title: 'Complete KYC',
                      isDark: isDark,
                      iconColor: AppColors.warning,
                      textColor: AppColors.warning,
                      onTap: () async {
                        final uri = Uri.parse('https://inquiry.withpersona.com/verify?inquiry-id=inq_A7YE3mwdHp4B6rxBiyvDzJNPyySucC');
                        try {
                          final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
                          if (!launched && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Could not open verification link. Please try again.'), backgroundColor: AppColors.error),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Could not open verification link: $e'), backgroundColor: AppColors.error),
                            );
                          }
                        }
                      },
                    ),
                  ],
                  if (!user.isEmailVerified) ...[
                    Divider(height: 1, indent: 56, color: isDark ? AppColors.darkBorder : AppColors.border),
                    _ProfileMenuItem(
                      icon: Icons.email_outlined,
                      title: 'Verify Email',
                      subtitle: user.email.isEmpty ? 'Add & verify your email' : 'Tap to verify your email',
                      isDark: isDark,
                      iconColor: AppColors.primary,
                      onTap: () => _showEmailVerification(context, ref, isDark, user.email),
                    ),
                  ] else ...[
                    Divider(height: 1, indent: 56, color: isDark ? AppColors.darkBorder : AppColors.border),
                    _ProfileMenuItem(
                      icon: Icons.email_rounded,
                      title: 'Email Verified',
                      subtitle: user.email,
                      isDark: isDark,
                      iconColor: AppColors.success,
                      showArrow: false,
                      onTap: () {},
                    ),
                  ],
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
                    title: loc.translate('about') ?? 'About',
                    isDark: isDark,
                    onTap: () => context.push('/about'),
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

  void _showEmailVerification(BuildContext context, WidgetRef ref, bool isDark, String currentEmail) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _EmailVerificationSheet(
          isDark: isDark,
          currentEmail: currentEmail,
          onVerified: (email) {
            final user = ref.read(userProvider);
            final updatedUser = user.copyWith(
              email: email,
              isEmailVerified: true,
            );
            ref.read(userProvider.notifier).state = updatedUser;
            MockRepository.instance.updateUser(updatedUser);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Email verified successfully!'),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
          },
        );
      },
    );
  }
}

class _EmailVerificationSheet extends StatefulWidget {
  final bool isDark;
  final String currentEmail;
  final void Function(String email) onVerified;

  const _EmailVerificationSheet({
    required this.isDark,
    required this.currentEmail,
    required this.onVerified,
  });

  @override
  State<_EmailVerificationSheet> createState() => _EmailVerificationSheetState();
}

class _EmailVerificationSheetState extends State<_EmailVerificationSheet> {
  final _emailController = TextEditingController();
  final List<TextEditingController> _otpControllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());
  int _step = 0; // 0 = email, 1 = OTP
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.currentEmail;
    if (widget.currentEmail.isNotEmpty) {
      // If they already have an email, start at step 0 but pre-filled
      _step = 0;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    for (final c in _otpControllers) { c.dispose(); }
    for (final f in _otpFocusNodes) { f.dispose(); }
    super.dispose();
  }

  bool get _isEmailValid => _emailController.text.trim().contains('@') && _emailController.text.trim().contains('.');

  void _goToOtpStep() {
    setState(() => _step = 1);
    Future.delayed(const Duration(milliseconds: 300), () {
      _otpFocusNodes[0].requestFocus();
    });
  }

  Future<void> _verifyOtp() async {
    final otp = _otpControllers.map((c) => c.text).join();
    if (otp.length < 6) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1500));

    if (mounted) {
      setState(() => _isLoading = false);
      widget.onVerified(_emailController.text.trim());
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 40),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF121212) : AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 24, right: 24, top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: widget.isDark ? Colors.white24 : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            if (_step == 0) ...[
              // Step 0: Enter email
              Container(
                width: 64, height: 64,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: widget.isDark ? AppColors.primary.withValues(alpha: 0.15) : AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(Icons.email_outlined, color: AppColors.primary, size: 28),
              ),
              const SizedBox(height: 20),
              Text(
                'Verify your email',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: widget.isDark ? Colors.white : AppColors.textPrimary,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'We\'ll send a verification code to confirm your email address.',
                style: TextStyle(
                  fontSize: 15,
                  color: widget.isDark ? Colors.white60 : AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),
              Container(
                decoration: BoxDecoration(
                  color: widget.isDark ? const Color(0xFF1A1A1A) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: widget.isDark ? AppColors.darkBorder : AppColors.border,
                    width: 1.5,
                  ),
                  boxShadow: widget.isDark ? null : AppColors.shadowSm,
                ),
                child: TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autofocus: true,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: widget.isDark ? Colors.white : AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter your email address',
                    hintStyle: TextStyle(
                      color: widget.isDark ? Colors.white24 : AppColors.textHint,
                      fontSize: 16,
                    ),
                    prefixIcon: Icon(Icons.email_outlined, color: widget.isDark ? Colors.white38 : AppColors.textHint),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(height: 24),
              PayamButton(
                label: 'Next',
                onPressed: _isEmailValid ? _goToOtpStep : null,
                icon: Icons.arrow_forward_rounded,
              ),
            ] else ...[
              // Step 1: Enter OTP
              Container(
                width: 64, height: 64,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: widget.isDark ? AppColors.primary.withValues(alpha: 0.15) : AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(Icons.mark_email_read_rounded, color: AppColors.primary, size: 28),
              ),
              const SizedBox(height: 20),
              Text(
                'Check your email',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: widget.isDark ? Colors.white : AppColors.textPrimary,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'We sent a 6-digit code to',
                style: TextStyle(
                  fontSize: 15,
                  color: widget.isDark ? Colors.white60 : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _emailController.text.trim(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: widget.isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) {
                  return Container(
                    width: 48,
                    height: 56,
                    decoration: BoxDecoration(
                      color: widget.isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _otpFocusNodes[index].hasFocus
                            ? AppColors.primary
                            : (widget.isDark ? AppColors.darkBorder : AppColors.border),
                        width: _otpFocusNodes[index].hasFocus ? 2 : 1,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: TextField(
                      controller: _otpControllers[index],
                      focusNode: _otpFocusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: widget.isDark ? Colors.white : AppColors.textPrimary,
                      ),
                      decoration: const InputDecoration(
                        counterText: '',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty && index < 5) {
                          _otpFocusNodes[index + 1].requestFocus();
                        }
                        if (value.isNotEmpty && index == 5) {
                          _otpFocusNodes[index].unfocus();
                          _verifyOtp();
                        }
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),
              PayamButton(
                label: 'Verify Code',
                onPressed: _isLoading ? null : _verifyOtp,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Didn\'t receive the code? ',
                    style: TextStyle(
                      fontSize: 14,
                      color: widget.isDark ? Colors.white60 : AppColors.textSecondary,
                    ),
                  ),
                  GestureDetector(
                    onTap: _goToOtpStep, // Resend mock
                    child: Text(
                      'Resend',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => setState(() => _step = 0),
                child: Text(
                  'Change email address',
                  style: TextStyle(
                    fontSize: 14,
                    color: widget.isDark ? Colors.white54 : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? textColor;
  final bool showArrow;
  final bool isDark;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    this.subtitle,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: textColor ?? (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
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