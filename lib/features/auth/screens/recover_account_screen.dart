import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

class RecoverAccountScreen extends StatefulWidget {
  const RecoverAccountScreen({super.key});

  @override
  State<RecoverAccountScreen> createState() => _RecoverAccountScreenState();
}

class _RecoverAccountScreenState extends State<RecoverAccountScreen> {
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_phoneController.text.length < 9) return;
    context.push('/otp', extra: {'phone': '+237${_phoneController.text}', 'isRecovery': true});
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),

                  // Back button
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E1E1E) : AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark ? AppColors.darkBorder : AppColors.border,
                          ),
                        ),
                        child: Icon(
                          Icons.arrow_back_rounded,
                          size: 20,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Icon
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
                      Icons.restore_rounded,
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
                    'Recover Account',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                      height: 1.2,
                    ),
                  ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 12),

                  Text(
                    'Please enter your phone number\nto recover your account',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.white60 : AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 48),

                  // Phone input card
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
                        
                        // Phone input
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
                                    Icon(
                                      Icons.flag_rounded,
                                      size: 20,
                                      color: isDark ? Colors.white70 : AppColors.textSecondary,
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
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.15, end: 0),

                  const SizedBox(height: 40),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _phoneController.text.length >= 9 && !_isLoading 
                      ? () {
                          context.push('/otp', extra: '+237${_phoneController.text}');
                        } 
                      : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: isDark ? AppColors.darkBorder : AppColors.border,
                        disabledForegroundColor: isDark ? Colors.white38 : AppColors.textHint,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isLoading
                          ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              'Continue',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.15, end: 0),

                  const SizedBox(height: 60),
                ],
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
                      'Sending verification code...',
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
      ),
    );
  }
}