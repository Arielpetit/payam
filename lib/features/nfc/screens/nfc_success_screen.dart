import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

class NfcSuccessScreen extends StatefulWidget {
  final double amount;
  final String? recipientName;
  final bool isSender;

  const NfcSuccessScreen({
    super.key,
    required this.amount,
    this.recipientName,
    required this.isSender,
  });

  @override
  State<NfcSuccessScreen> createState() => _NfcSuccessScreenState();
}

class _NfcSuccessScreenState extends State<NfcSuccessScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _checkController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // Slight delay then pop the check
    Timer(const Duration(milliseconds: 200), () {
      if (mounted) _checkController.forward();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _checkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.white;
    final cardBg = isDark ? const Color(0xFF111111) : AppColors.white;
    final dividerColor = isDark ? const Color(0xFF1E1E1E) : AppColors.border;
    final textPrimary = isDark ? AppColors.white : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top section ──────────────────────────────────────────
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Pulsing rings + checkmark
                  SizedBox(
                    width: 180,
                    height: 180,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer pulse ring
                        AnimatedBuilder(
                          animation: _pulseController,
                          builder: (_, __) {
                            final v = _pulseController.value;
                            return Container(
                              width: 160 + (v * 20),
                              height: 160 + (v * 20),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.success
                                    .withOpacity((1 - v) * 0.08),
                              ),
                            );
                          },
                        ),
                        // Middle ring
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.success.withOpacity(0.12),
                          ),
                        ),
                        // Inner green circle with check
                        ScaleTransition(
                          scale: CurvedAnimation(
                            parent: _checkController,
                            curve: Curves.elasticOut,
                          ),
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.success,
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 44,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  Text(
                    widget.isSender ? 'Payment Sent!' : 'Payment Received!',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),

                  const SizedBox(height: 8),

                  Text(
                    widget.isSender
                        ? 'Your payment has been successfully sent.'
                        : 'Payment has been successfully received.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: textSecondary,
                      height: 1.5,
                    ),
                  ).animate().fadeIn(delay: 400.ms),
                ],
              ),
            ),

            // ── Details card ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: dividerColor),
                  boxShadow: isDark ? null : AppColors.cardShadow,
                ),
                child: Column(
                  children: [
                    _DetailRow(
                      label: 'Amount',
                      value: '${widget.amount.toStringAsFixed(0)} FCFA',
                      valueColor: AppColors.success,
                      bold: true,
                      isDark: isDark,
                    ),
                    Divider(height: 1, color: dividerColor),
                    _DetailRow(
                      label: widget.isSender ? 'Sent to' : 'Received from',
                      value: widget.recipientName ?? 'Unknown',
                      isDark: isDark,
                    ),
                    Divider(height: 1, color: dividerColor),
                    _DetailRow(
                      label: 'Payment Method',
                      value: 'NFC Tap',
                      isDark: isDark,
                    ),
                    Divider(height: 1, color: dividerColor),
                    _DetailRow(
                      label: 'Status',
                      value: 'Completed',
                      valueColor: AppColors.success,
                      isDark: isDark,
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.15),
            ),

            // ── Done button ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () => context.go('/home'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Back to Home',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool bold;
  final bool isDark;

  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.bold = false,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final textPrimary = isDark ? AppColors.white : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
              color: valueColor ?? textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
