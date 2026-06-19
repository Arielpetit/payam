import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../shared/widgets/payam_button.dart';
import '../../../shared/widgets/payam_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;
  bool _agreed = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.loc('agree_terms_warning')),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) {
      setState(() => _isLoading = false);
      context.push('/otp', extra: _phoneController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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

                // Back button
                GestureDetector(
                  onTap: () => context.go('/login'),
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
                ).animate().fadeIn().slideX(begin: -0.2),

                const SizedBox(height: 32),

                // Title Header
                Text(
                  '${context.loc('create_account')} ✨',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                    height: 1.2,
                    letterSpacing: -0.8,
                  ),
                ).animate().fadeIn().slideY(begin: 0.2, end: 0),

                const SizedBox(height: 8),

                Text(
                  context.loc('register_subtitle'),
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.white60 : AppColors.textSecondary,
                  ),
                ).animate().fadeIn(delay: 100.ms),

                const SizedBox(height: 36),

                // Inputs
                PayamTextField(
                  label: context.loc('full_name'),
                  hint: 'Jean Dupont',
                  controller: _nameController,
                  prefixIcon: Icon(Icons.person_rounded,
                      size: 18, color: isDark ? Colors.white38 : AppColors.textHint),
                  validator: (v) => (v == null || v.isEmpty) ? 'Name required' : null,
                ).animate().fadeIn(delay: 150.ms),

                const SizedBox(height: 18),

                PayamTextField(
                  label: context.loc('phone_number'),
                  hint: '+237 6 XX XXX XXX',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icon(Icons.phone_rounded,
                      size: 18, color: isDark ? Colors.white38 : AppColors.textHint),
                  validator: (v) => (v == null || v.isEmpty) ? 'Phone required' : null,
                ).animate().fadeIn(delay: 200.ms),

                const SizedBox(height: 18),

                PayamTextField(
                  label: context.loc('email'),
                  hint: 'you@email.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icon(Icons.email_rounded,
                      size: 18, color: isDark ? Colors.white38 : AppColors.textHint),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Email required';
                    if (!v.contains('@')) return 'Invalid email';
                    return null;
                  },
                ).animate().fadeIn(delay: 250.ms),

                const SizedBox(height: 18),

                PayamTextField(
                  label: context.loc('password'),
                  hint: '••••••••',
                  controller: _passwordController,
                  obscureText: true,
                  prefixIcon: Icon(Icons.lock_rounded,
                      size: 18, color: isDark ? Colors.white38 : AppColors.textHint),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password required';
                    if (v.length < 6) return 'At least 6 characters';
                    return null;
                  },
                ).animate().fadeIn(delay: 300.ms),

                const SizedBox(height: 18),

                PayamTextField(
                  label: context.loc('confirm_password'),
                  hint: '••••••••',
                  controller: _confirmController,
                  obscureText: true,
                  prefixIcon: Icon(Icons.lock_outline_rounded,
                      size: 18, color: isDark ? Colors.white38 : AppColors.textHint),
                  validator: (v) => (v != _passwordController.text)
                      ? 'Passwords do not match'
                      : null,
                ).animate().fadeIn(delay: 350.ms),

                const SizedBox(height: 24),

                // Terms of Service agreement checkbox
                GestureDetector(
                  onTap: () => setState(() => _agreed = !_agreed),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: _agreed
                              ? (isDark ? Colors.white : AppColors.primary)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: _agreed
                                ? (isDark ? Colors.white : AppColors.primary)
                                : (isDark ? const Color(0xFF2D2D2D) : AppColors.border),
                            width: 1.5,
                          ),
                        ),
                        child: _agreed
                            ? Icon(Icons.check,
                                size: 13, color: isDark ? Colors.black : Colors.white)
                            : null,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            text: isDark ? 'I agree to ' : 'I agree to the ',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? Colors.white70 : AppColors.textSecondary,
                            ),
                            children: [
                              TextSpan(
                                text: context.loc('terms_of_service'),
                                style: TextStyle(
                                  color: isDark ? Colors.white : AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const TextSpan(text: ' & '),
                              TextSpan(
                                text: context.loc('privacy_policy'),
                                style: TextStyle(
                                  color: isDark ? Colors.white : AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 400.ms),

                const SizedBox(height: 32),

                // Submit button
                PayamButton(
                  label: context.loc('create_account'),
                  onPressed: _register,
                  isLoading: _isLoading,
                ).animate().fadeIn(delay: 450.ms),

                const SizedBox(height: 24),

                // Footer link to Login
                Center(
                  child: GestureDetector(
                    onTap: () => context.go('/login'),
                    child: RichText(
                      text: TextSpan(
                        text: isDark ? 'Already have an account? ' : 'Already have an account? ',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white60 : AppColors.textSecondary,
                        ),
                        children: [
                          TextSpan(
                            text: context.loc('sign_in'),
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

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
