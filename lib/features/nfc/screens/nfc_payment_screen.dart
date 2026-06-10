import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/biometric_service.dart';
import '../../../core/providers/hce_payment_provider.dart';
import '../../../shared/widgets/payam_button.dart';

class NfcPaymentScreen extends ConsumerStatefulWidget {
  const NfcPaymentScreen({super.key});

  @override
  ConsumerState<NfcPaymentScreen> createState() => _NfcPaymentScreenState();
}

class _NfcPaymentScreenState extends ConsumerState<NfcPaymentScreen>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _successController;
  late AnimationController _pulseController;
  final TextEditingController _amountController = TextEditingController();
  final BiometricService _biometricService = BiometricService();

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _biometricService.initialize();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(hcePaymentProvider.notifier).recheckNfc();
    });
  }

  @override
  void dispose() {
    _waveController.dispose();
    _successController.dispose();
    _pulseController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(hcePaymentProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ref.listen<NfcPaymentState>(hcePaymentProvider, (_, next) {
      if (next.phase == NfcPaymentPhase.waitingForTap) {
        _waveController.repeat();
      } else if (next.phase == NfcPaymentPhase.success) {
        _waveController.stop();
        _successController.forward();
      } else {
        _waveController.stop();
      }
    });

    return Scaffold(
      backgroundColor: isDark ? Colors.black : AppColors.background,
      appBar: AppBar(
        title: const Text('NFC Payment'),
        backgroundColor: isDark ? Colors.black : AppColors.background,
        elevation: 0,
        actions: [
          if (state.phase == NfcPaymentPhase.waitingForTap)
            IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () => ref.read(hcePaymentProvider.notifier).reset(),
            ),
        ],
      ),
      body: _buildBody(state, isDark),
    );
  }

  Widget _buildBody(NfcPaymentState state, bool isDark) {
    switch (state.phase) {
      case NfcPaymentPhase.idle:
      case NfcPaymentPhase.amountEntry:
        return _buildAmountEntry(state, isDark);
      case NfcPaymentPhase.biometric:
        return _buildBiometric(state, isDark);
      case NfcPaymentPhase.waitingForTap:
        return _buildWaitingForTap(state, isDark);
      case NfcPaymentPhase.processing:
        return _buildProcessing(isDark);
      case NfcPaymentPhase.success:
        return _buildSuccess(state, isDark);
      case NfcPaymentPhase.failed:
        return _buildFailed(state, isDark);
    }
  }

  // ─── Amount Entry ────────────────────────────────────────────────────────────

  Widget _buildAmountEntry(NfcPaymentState state, bool isDark) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        children: [
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF121212) : AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: isDark ? Border.all(color: const Color(0xFF1E1E1E)) : null,
              boxShadow: isDark ? null : AppColors.cardShadow,
            ),
            child: Column(
              children: [
                Icon(
                  Icons.nfc_rounded,
                  size: 52,
                  color: state.nfcAvailable ? AppColors.primary : AppColors.error,
                ),
                const SizedBox(height: 12),
                if (!state.nfcAvailable) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.error.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning_rounded, color: AppColors.error, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'NFC not available on this device',
                            style: TextStyle(fontSize: 12, color: AppColors.error),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                Text(
                  'Enter Amount',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Amount to send via NFC tap',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white60 : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'FCFA',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                TextField(
                  controller: _amountController,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: '0',
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      color: isDark ? Colors.white24 : AppColors.textHint,
                    ),
                    counterText: '',
                  ),
                  maxLength: 10,
                  onChanged: (v) {
                    ref.read(hcePaymentProvider.notifier).setAmount(
                          double.tryParse(v) ?? 0,
                        );
                  },
                ),
              ],
            ),
          ).animate().fadeIn().scale(curve: Curves.easeOutBack),

          const SizedBox(height: 16),

          // How it works
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.info.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline_rounded, size: 16, color: AppColors.info),
                    const SizedBox(width: 8),
                    Text(
                      'How it works',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.info,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '1. Enter amount → tap Continue\n'
                  '2. Bring phones together (< 4cm)\n'
                  '3. Receiver\'s app opens automatically\n'
                  '4. Backend processes transfer securely',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white60 : AppColors.textSecondary,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 150.ms),

          const SizedBox(height: 16),

          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'Require Biometric',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
            subtitle: Text(
              'Fingerprint before sending',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white60 : AppColors.textSecondary,
              ),
            ),
            value: state.isBiometricRequired,
            onChanged: (v) =>
                ref.read(hcePaymentProvider.notifier).setBiometricRequired(v),
            activeColor: AppColors.primary,
          ),

          const SizedBox(height: 16),

          PayamButton(
            label: 'Continue',
            icon: Icons.arrow_forward_rounded,
            onPressed: state.amount > 0 && state.nfcAvailable
                ? () => ref.read(hcePaymentProvider.notifier).startPaymentFlow()
                : null,
          ),
        ],
      ),
    );
  }

  // ─── Biometric ───────────────────────────────────────────────────────────────

  Widget _buildBiometric(NfcPaymentState state, bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScaleTransition(
            scale: Tween<double>(begin: 0.85, end: 1.0).animate(
              CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
            ),
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.fingerprint_rounded, size: 56, color: AppColors.primary),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Authenticating...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Verify your identity to send\n${state.amount.toStringAsFixed(0)} FCFA',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white60 : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Waiting For Tap ─────────────────────────────────────────────────────────

  Widget _buildWaitingForTap(NfcPaymentState state, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                for (int i = 0; i < 3; i++)
                  AnimatedBuilder(
                    animation: _waveController,
                    builder: (_, __) => Container(
                      width: 140 + (_waveController.value * 70),
                      height: 140 + (_waveController.value * 70),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primary
                              .withOpacity((1 - _waveController.value) * 0.5),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.35),
                        blurRadius: 20,
                        spreadRadius: 6,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.nfc_rounded, size: 52, color: Colors.white),
                ),
              ],
            ),

            const SizedBox(height: 36),

            Text(
              'Bring Phones Together',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Hold phones back-to-back (< 4cm)',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white60 : AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 20),

            // Amount + countdown row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${state.amount.toStringAsFixed(0)} FCFA',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: state.countdown <= 10
                        ? AppColors.error.withOpacity(0.1)
                        : AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.timer_rounded,
                        size: 14,
                        color: state.countdown <= 10
                            ? AppColors.error
                            : AppColors.warning,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${state.countdown}s',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: state.countdown <= 10
                              ? AppColors.error
                              : AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Text(
              'Receiver\'s Payam app will open automatically',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white38 : AppColors.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Processing ──────────────────────────────────────────────────────────────

  Widget _buildProcessing(bool isDark) {
    return Center(
      child: Column(
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
          const SizedBox(height: 20),
          Text(
            'Processing...',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white70 : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Success ─────────────────────────────────────────────────────────────────

  Widget _buildSuccess(NfcPaymentState state, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
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
              'Transfer Complete!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ).animate().fadeIn(delay: 200.ms),
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
                    '${state.amount.toStringAsFixed(0)} FCFA',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: AppColors.success,
                    ),
                  ),
                  if (state.recipientName != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Sent to ${state.recipientName}',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white60 : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
            const SizedBox(height: 32),
            PayamButton(
              label: 'Done',
              icon: Icons.check_rounded,
              onPressed: () {
                ref.read(hcePaymentProvider.notifier).reset();
                context.pop();
              },
            ).animate().fadeIn(delay: 400.ms),
          ],
        ),
      ),
    );
  }

  // ─── Failed ──────────────────────────────────────────────────────────────────

  Widget _buildFailed(NfcPaymentState state, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
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
              'Transfer Failed',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF121212) : AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.error.withOpacity(0.25)),
              ),
              child: Column(
                children: [
                  Text(
                    state.errorMessage ?? 'An error occurred',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (state.errorCode != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      state.errorCode!,
                      style: TextStyle(
                        fontSize: 11,
                        fontFamily: 'monospace',
                        color: isDark ? Colors.white38 : AppColors.textHint,
                      ),
                    ),
                  ],
                ],
              ),
            ).animate().fadeIn(delay: 150.ms),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: PayamButton(
                    label: 'Cancel',
                    isOutlined: true,
                    onPressed: () {
                      ref.read(hcePaymentProvider.notifier).reset();
                      context.pop();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PayamButton(
                    label: 'Try Again',
                    icon: Icons.refresh_rounded,
                    onPressed: () => ref.read(hcePaymentProvider.notifier).reset(),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 300.ms),
          ],
        ),
      ),
    );
  }
}
