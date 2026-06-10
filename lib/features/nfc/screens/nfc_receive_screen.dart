import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/hce_payment_provider.dart';
import '../../../shared/widgets/payam_button.dart';

class NfcReceiveScreen extends ConsumerStatefulWidget {
  final String transactionId;
  const NfcReceiveScreen({super.key, required this.transactionId});

  @override
  ConsumerState<NfcReceiveScreen> createState() => _NfcReceiveScreenState();
}

class _NfcReceiveScreenState extends ConsumerState<NfcReceiveScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _successController;
  bool _processed = false;

  @override
  void initState() {
    super.initState();
    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _process());
  }

  @override
  void dispose() {
    _successController.dispose();
    super.dispose();
  }

  Future<void> _process() async {
    if (_processed) return;
    _processed = true;
    await ref
        .read(hcePaymentProvider.notifier)
        .handleIncomingNfcTransaction(widget.transactionId);
    if (mounted) _successController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(hcePaymentProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : AppColors.background,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : AppColors.background,
        title: const Text('Money Received'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: _buildContent(state, isDark),
        ),
      ),
    );
  }

  Widget _buildContent(NfcPaymentState state, bool isDark) {
    // Processing
    if (state.phase == NfcPaymentPhase.processing) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const CircularProgressIndicator(
              strokeWidth: 3,
              color: AppColors.primary,
            ),
          ).animate().fadeIn(),
          const SizedBox(height: 24),
          Text(
            'Processing payment...',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white70 : AppColors.textSecondary,
            ),
          ).animate().fadeIn(delay: 200.ms),
        ],
      );
    }

    // Failed
    if (state.phase == NfcPaymentPhase.failed) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.close_rounded, size: 52, color: AppColors.error),
          ).animate().scale(curve: Curves.easeOutBack),
          const SizedBox(height: 24),
          Text(
            'Payment Failed',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            state.errorMessage ?? 'Something went wrong',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white60 : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          PayamButton(
            label: 'Close',
            isOutlined: true,
            onPressed: () {
              ref.read(hcePaymentProvider.notifier).reset();
              context.go('/home');
            },
          ),
        ],
      );
    }

    // Success
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ScaleTransition(
          scale: Tween<double>(begin: 0, end: 1).animate(
            CurvedAnimation(parent: _successController, curve: Curves.elasticOut),
          ),
          child: Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_rounded, size: 60, color: AppColors.success),
          ),
        ),
        const SizedBox(height: 28),
        Text(
          'Money Received!',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ).animate().fadeIn(delay: 300.ms),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF121212) : AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: isDark ? Border.all(color: const Color(0xFF1E1E1E)) : null,
            boxShadow: isDark ? null : AppColors.cardShadow,
          ),
          child: Column(
            children: [
              Text(
                '+${state.amount.toStringAsFixed(0)} FCFA',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: AppColors.success,
                ),
              ),
              if (state.recipientName != null) ...[
                const SizedBox(height: 6),
                Text(
                  'From ${state.recipientName}',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white60 : AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
        const SizedBox(height: 32),
        PayamButton(
          label: 'Done',
          icon: Icons.check_rounded,
          onPressed: () {
            ref.read(hcePaymentProvider.notifier).reset();
            context.go('/home');
          },
        ).animate().fadeIn(delay: 500.ms),
      ],
    );
  }
}
