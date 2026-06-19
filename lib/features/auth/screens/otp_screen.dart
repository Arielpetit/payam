import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/payam_button.dart';

class OtpScreen extends StatefulWidget {
  final String phone;
  final bool isRecovery;
  const OtpScreen({super.key, required this.phone, this.isRecovery = false});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isLoading = false;
  bool _showLoadingOverlay = false;
  int _countdown = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
    Future.delayed(const Duration(milliseconds: 200), () {
      _focusNodes[0].requestFocus();
    });
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _countdown = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_countdown == 0) {
        t.cancel();
      } else {
        setState(() => _countdown--);
      }
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _verify() async {
    final otp = _controllers.map((c) => c.text).join();
    if (otp.length < 6) return;

    setState(() {
      _isLoading = true;
      _showLoadingOverlay = true;
    });

    await Future.delayed(const Duration(milliseconds: 1500));

    if (mounted) {
      setState(() {
        _isLoading = false;
        _showLoadingOverlay = false;
      });
      
      // If recovery flow, go to verification pending
      // Otherwise go directly to home
      if (widget.isRecovery) {
        context.go('/verification-pending');
      } else {
        context.go('/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: isDark ? Colors.black : AppColors.background,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),

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
                      Icons.lock_rounded,
                      size: 40,
                      color: Colors.white,
                    ),
                  ).animate().fadeIn().scale(
                    begin: const Offset(0.5, 0.5),
                    end: const Offset(1, 1),
                    duration: 400.ms,
                  ),

                  const SizedBox(height: 32),

                  Text(
                    'Verification',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                      height: 1.2,
                    ),
                  ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 12),

                  Text(
                    'Enter the 6-digit code sent to',
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.white60 : AppColors.textSecondary,
                      decoration: TextDecoration.none,
                    ),
                  ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 8),

                  Text(
                    widget.phone.isEmpty ? '+237 6 XX XXX XXX' : widget.phone,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                      decoration: TextDecoration.none,
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 48),

                  // OTP Input
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(6, (index) {
                      return Container(
                        width: 48,
                        height: 56,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _focusNodes[index].hasFocus
                                ? AppColors.primary
                                : (isDark ? AppColors.darkBorder : AppColors.border),
                            width: _focusNodes[index].hasFocus ? 2 : 1,
                          ),
                          boxShadow: isDark ? null : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: TextField(
                          controller: _controllers[index],
                          focusNode: _focusNodes[index],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 1,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppColors.textPrimary,
                          ),
                          decoration: InputDecoration(
                            counterText: '',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onChanged: (value) {
                            if (value.isNotEmpty && index < 5) {
                              _focusNodes[index + 1].requestFocus();
                            }
                            if (value.isNotEmpty && index == 5) {
                              _focusNodes[index].unfocus();
                              _verify();
                            }
                          },
                        ),
                      ).animate().fadeIn(delay: Duration(milliseconds: 250 + (index * 50))).slideY(begin: 0.3, end: 0);
                    }),
                  ),

                  const SizedBox(height: 40),

                  // Verify Button
                  PayamButton(
                    label: 'Verify Code',
                    onPressed: _verify,
                    isLoading: _isLoading,
                  ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.15, end: 0),

                  const SizedBox(height: 24),

                  // Resend
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Didn\'t receive the code? ',
                        style: TextStyle(
                          fontSize: 15,
                          color: isDark ? Colors.white60 : AppColors.textSecondary,
                        ),
                      ),
                      if (_countdown == 0)
                        GestureDetector(
                          onTap: () {
                            _startTimer();
                            // Resend OTP logic here
                          },
                          child: Text(
                            'Resend',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        )
                      else
                        Text(
                          'Resend in ${_countdown}s',
                          style: TextStyle(
                            fontSize: 15,
                            color: isDark ? Colors.white38 : AppColors.textHint,
                          ),
                        ),
                    ],
                  ).animate().fadeIn(delay: 700.ms),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),

        // Loading overlay
        if (_showLoadingOverlay)
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
                    'Verifying...',
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