import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/widgets/payam_button.dart';
import '../../../shared/widgets/payam_text_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) {
      setState(() => _isLoading = false);
      ref.read(isAuthenticatedProvider.notifier).state = true;
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final locale = ref.watch(localeProvider);

    return Scaffold(
      backgroundColor: isDark ? Colors.black : AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),

                // Top Actions Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => context.go('/onboarding'),
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E1E1E) : AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                          border: isDark ? Border.all(color: const Color(0xFF2D2D2D)) : null,
                        ),
                        child: Icon(Icons.arrow_back_rounded,
                            size: 20, color: isDark ? Colors.white : AppColors.textPrimary),
                      ),
                    ),
                    
                    // Floating Language Switcher
                    PopupMenuButton<String>(
                      icon: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E1E1E) : AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                          border: isDark ? Border.all(color: const Color(0xFF2D2D2D)) : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.language_rounded,
                                size: 16, color: isDark ? Colors.white : AppColors.textPrimary),
                            const SizedBox(width: 6),
                            Text(
                              locale.languageCode.toUpperCase(),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : AppColors.textPrimary,
                              ),
                            ),
                            Icon(Icons.arrow_drop_down_rounded,
                                size: 18, color: isDark ? Colors.white60 : AppColors.textSecondary),
                          ],
                        ),
                      ),
                      onSelected: (langCode) {
                        ref.read(localeProvider.notifier).state = Locale(langCode);
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'en', child: Text('English')),
                        const PopupMenuItem(value: 'fr', child: Text('Français')),
                      ],
                    ),
                  ],
                ).animate().fadeIn().slideY(begin: -0.2, end: 0),

                const SizedBox(height: 32),

                // Header Title
                Text(
                  '${context.loc('welcome_back')} 👋',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                    height: 1.2,
                    letterSpacing: -0.8,
                  ),
                ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2, end: 0),

                const SizedBox(height: 8),

                Text(
                  context.loc('login_subtitle'),
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.white60 : AppColors.textSecondary,
                  ),
                ).animate().fadeIn(delay: 150.ms),

                const SizedBox(height: 36),

                // Phone Input
                PayamTextField(
                  label: context.loc('phone_number'),
                  hint: '+242 06 000 0000',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icon(Icons.phone_rounded,
                      size: 18, color: isDark ? Colors.white38 : AppColors.textHint),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Phone number required';
                    return null;
                  },
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),

                const SizedBox(height: 20),

                // Password Input
                PayamTextField(
                  label: context.loc('password'),
                  hint: context.loc('password_hint'),
                  controller: _passwordController,
                  obscureText: true,
                  prefixIcon: Icon(Icons.lock_rounded,
                      size: 18, color: isDark ? Colors.white38 : AppColors.textHint),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password required';
                    return null;
                  },
                ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.1, end: 0),

                const SizedBox(height: 20),

                // Remember me + Forgot Password
                Row(
                  children: [
                    GestureDetector(
                      onTap: () =>
                          setState(() => _rememberMe = !_rememberMe),
                      child: Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: _rememberMe
                                  ? (isDark ? Colors.white : AppColors.primary)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: _rememberMe
                                    ? (isDark ? Colors.white : AppColors.primary)
                                    : (isDark ? const Color(0xFF2D2D2D) : AppColors.border),
                                width: 1.5,
                              ),
                            ),
                            child: _rememberMe
                                ? Icon(Icons.check,
                                    size: 12, color: isDark ? Colors.black : Colors.white)
                                : null,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isDark ? 'Remember' : 'Remember me',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? Colors.white70 : AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        context.loc('forgot_password'),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 300.ms),

                const SizedBox(height: 36),

                // Submit Sign In Button
                PayamButton(
                  label: context.loc('sign_in'),
                  onPressed: _login,
                  isLoading: _isLoading,
                ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.1, end: 0),

                const SizedBox(height: 20),

                // Divider
                Row(
                  children: [
                    Expanded(child: Divider(color: isDark ? const Color(0xFF2D2D2D) : AppColors.border)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        isDark ? 'OR' : 'or',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white24 : AppColors.textHint,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: isDark ? const Color(0xFF2D2D2D) : AppColors.border)),
                  ],
                ).animate().fadeIn(delay: 400.ms),

                const SizedBox(height: 20),

                // Demo bypass option
                OutlinedButton.icon(
                  onPressed: () {
                    ref.read(isAuthenticatedProvider.notifier).state = true;
                    context.go('/home');
                  },
                  icon: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white : AppColors.primary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(Icons.bolt_rounded,
                        size: 14, color: isDark ? Colors.black : Colors.white),
                  ),
                  label: Text(
                    isDark ? 'DEMO BYPASS' : 'Continue as Demo User',
                    style: TextStyle(
                      color: isDark ? Colors.white : AppColors.primary,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ).animate().fadeIn(delay: 450.ms),

                const SizedBox(height: 32),

                // Footer link to Register
                Center(
                  child: GestureDetector(
                    onTap: () => context.go('/register'),
                    child: RichText(
                      text: TextSpan(
                        text: locale.languageCode == 'fr' 
                          ? "Vous n'avez pas de compte? "
                          : "Don't have an account? ",
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white60 : AppColors.textSecondary,
                        ),
                        children: [
                          TextSpan(
                            text: context.loc('sign_up'),
                            style: TextStyle(
                              color: isDark ? Colors.white : AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 500.ms),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
