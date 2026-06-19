import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/widgets/payam_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    
    final phone = _phoneController.text.trim();
    if (phone.isEmpty || phone.length < 9) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid phone number')),
      );
      return;
    }
    
    setState(() => _isLoading = true);
    
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (mounted) {
      setState(() => _isLoading = false);
      context.push('/otp', extra: {'phone': '+237 $phone', 'isRecovery': false});
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final locale = ref.watch(localeProvider);

    return Stack(
      children: [
        Scaffold(
          backgroundColor: isDark ? Colors.black : AppColors.background,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),

                    // Language selector - Top Right
                    Align(
                      alignment: Alignment.centerRight,
                      child: PopupMenuButton<String>(
                        icon: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E1E1E) : AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark ? AppColors.darkBorder : AppColors.border,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.language_rounded,
                                  size: 18, color: isDark ? Colors.white70 : AppColors.textSecondary),
                              const SizedBox(width: 8),
                              Text(
                                locale.languageCode.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(Icons.arrow_drop_down_rounded,
                                  size: 20, color: isDark ? Colors.white70 : AppColors.textSecondary),
                            ],
                          ),
                        ),
                        itemBuilder: (context) => [
                          PopupMenuItem(value: 'en', child: Text('English')),
                          PopupMenuItem(value: 'fr', child: Text('Français')),
                        ],
                        onSelected: (value) {
                          ref.read(localeProvider.notifier).state = Locale(value);
                        },
                      ),
                    ).animate().fadeIn(delay: 100.ms),

                    const SizedBox(height: 24),

                    // Logo
                    Container(
                      width: 80,
                      height: 80,
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
                        Icons.account_balance_wallet_rounded,
                        size: 40,
                        color: Colors.white,
                      ),
                    ).animate().fadeIn().scale(
                      begin: const Offset(0.5, 0.5),
                      end: const Offset(1, 1),
                      duration: 400.ms,
                    ),

                    const SizedBox(height: 28),

                    Text(
                      'Welcome',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                        height: 1.2,
                      ),
                    ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.2, end: 0),

                    const SizedBox(height: 12),

                    Text(
                      'Please put your phone number to\ncreate your Payam account',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? Colors.white60 : AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),

                    const SizedBox(height: 40),

                    // Phone number card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                        borderRadius: BorderRadius.circular(24),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Phone number',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white70 : AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          
                          // Phone input with flag
                          Container(
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF2D2D2D) : AppColors.background,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isDark ? AppColors.darkBorder : AppColors.border,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '🇨🇲',
                                        style: TextStyle(fontSize: 22),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        '+237',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: isDark ? Colors.white : AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 1,
                                  height: 24,
                                  color: isDark ? Colors.white10 : AppColors.border,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextField(
                                    controller: _phoneController,
                                    keyboardType: TextInputType.phone,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(9),
                                    ],
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: isDark ? Colors.white : AppColors.textPrimary,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: '6 XX XXX XXX',
                                      hintStyle: TextStyle(
                                        color: isDark ? Colors.white24 : AppColors.textHint,
                                        fontSize: 16,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.15, end: 0),

                    const SizedBox(height: 40),

                    // Create Account Button
                    PayamButton(
                      label: 'Create Account',
                      onPressed: _login,
                      isLoading: _isLoading,
                    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.15, end: 0),

                    const SizedBox(height: 60),

                    // Footer link to Recover Account
                    GestureDetector(
                      onTap: () {
                        context.push('/recover-account');
                      },
                      child: RichText(
                        text: TextSpan(
                          text: 'Already have an account? ',
                          style: TextStyle(
                            fontSize: 15,
                            color: isDark ? Colors.white60 : AppColors.textSecondary,
                          ),
                          children: [
                            TextSpan(
                              text: 'Recover Account',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(delay: 450.ms),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Loading overlay
        if (_isLoading)
          Container(
            color: isDark ? Colors.black.withOpacity(0.9) : Colors.white.withOpacity(0.95),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Creating account...',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}