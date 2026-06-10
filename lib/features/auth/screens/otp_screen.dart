import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../shared/widgets/payam_button.dart';

class OtpScreen extends StatefulWidget {
  final String phone;
  const OtpScreen({super.key, required this.phone});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isLoading = false;
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
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) {
      setState(() => _isLoading = false);
      context.go('/home');
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                    border: isDark ? Border.all(color: const Color(0xFF2D2D2D)) : null,
                  ),
                  child: Icon(
                    Icons.arrow_back_rounded,
                    size: 20,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: isDark
                      ? const LinearGradient(
                          colors: [Color(0xFF2D2D2D), Color(0xFF121212)],
                        )
                      : AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(18),
                  border: isDark ? Border.all(color: const Color(0xFF333333)) : null,
                ),
                child: Icon(
                  Icons.sms_rounded,
                  size: 32,
                  color: isDark ? Colors.white70 : Colors.white,
                ),
              ).animate().scale(
                    begin: const Offset(0.7, 0.7),
                    end: const Offset(1, 1),
                    curve: Curves.elasticOut,
                    duration: 600.ms,
                  ),
              const SizedBox(height: 28),
              Text(
                '${context.loc('otp_title')} 📱',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                  height: 1.2,
                  letterSpacing: -0.5,
                ),
              ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2, end: 0),
              const SizedBox(height: 12),
              RichText(
                text: TextSpan(
                  text: '${context.loc('otp_subtitle')}\n',
                  style: TextStyle(
                    fontSize: 15,
                    color: isDark ? Colors.white60 : AppColors.textSecondary,
                    height: 1.5,
                  ),
                  children: [
                    TextSpan(
                      text: widget.phone.isEmpty ? '+242 06 *** ****' : widget.phone,
                      style: TextStyle(
                        color: isDark ? Colors.white : AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 150.ms),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  6,
                  (i) => _OtpBox(
                    controller: _controllers[i],
                    focusNode: _focusNodes[i],
                    isDark: isDark,
                    onChanged: (v) {
                      if (v.isNotEmpty && i < 5) {
                        _focusNodes[i + 1].requestFocus();
                      } else if (v.isEmpty && i > 0) {
                        _focusNodes[i - 1].requestFocus();
                      }
                      // Auto-verify
                      final otp = _controllers.map((c) => c.text).join();
                      if (otp.length == 6) _verify();
                    },
                  ),
                ).animate(interval: 60.ms).fadeIn().slideY(begin: 0.2, end: 0),
              ),
              const SizedBox(height: 36),
              PayamButton(
                label: context.loc('otp_verify'),
                onPressed: _verify,
                isLoading: _isLoading,
              ).animate().fadeIn(delay: 400.ms),
              const SizedBox(height: 28),
              Center(
                child: _countdown > 0
                    ? RichText(
                        text: TextSpan(
                          text: '${context.loc('otp_resend_in')} ',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.white60 : AppColors.textSecondary,
                          ),
                          children: [
                            TextSpan(
                              text: '${_countdown}s',
                              style: TextStyle(
                                color: isDark ? Colors.white : AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      )
                    : GestureDetector(
                        onTap: _startTimer,
                        child: Text(
                          context.loc('otp_resend'),
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.white : AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
              ).animate().fadeIn(delay: 500.ms),
            ],
          ),
        ),
      ),
    );
  }
}

class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isDark;
  final ValueChanged<String> onChanged;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 56,
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        onChanged: onChanged,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.white : AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: isDark ? const Color(0xFF121212) : AppColors.surfaceVariant,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: isDark ? const Color(0xFF2D2D2D) : AppColors.border,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: isDark ? Colors.white : AppColors.primary,
              width: 2,
            ),
          ),
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}
