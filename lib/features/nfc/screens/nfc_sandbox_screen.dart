import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/providers/nfc_provider.dart';
import '../../../shared/widgets/payam_button.dart';

class NfcSandboxScreen extends ConsumerStatefulWidget {
  const NfcSandboxScreen({super.key});

  @override
  ConsumerState<NfcSandboxScreen> createState() => _NfcSandboxScreenState();
}

class _NfcSandboxScreenState extends ConsumerState<NfcSandboxScreen>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _successController;
  
  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    ref.read(nfcSandboxProvider.notifier).reset();
  }

  @override
  void dispose() {
    _waveController.dispose();
    _successController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(nfcSandboxProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ref.listen<NfcSandboxState>(nfcSandboxProvider, (prev, next) {
      if (next.phase == NfcSandboxPhase.transmitting) {
        _waveController.repeat();
      } else if (next.phase == NfcSandboxPhase.success) {
        _waveController.stop();
        _successController.forward();
      } else if (next.phase == NfcSandboxPhase.failed) {
        _waveController.stop();
      }
    });

    return Scaffold(
      backgroundColor: isDark ? Colors.black : AppColors.background,
      appBar: AppBar(
        title: const Text('NFC Sandbox'),
        backgroundColor: isDark ? Colors.black : AppColors.background,
        elevation: 0,
      ),
      body: _buildBody(state, isDark),
    );
  }

  Widget _buildBody(NfcSandboxState state, bool isDark) {
    switch (state.phase) {
      case NfcSandboxPhase.idle:
        return _buildAmountEntry(state, isDark);
      case NfcSandboxPhase.biometric:
        return _buildBiometricPrompt(isDark);
      case NfcSandboxPhase.transmitting:
        return _buildTransmitting(state, isDark);
      case NfcSandboxPhase.processing:
        return _buildProcessing(isDark);
      case NfcSandboxPhase.success:
        return _buildSuccess(state, isDark);
      case NfcSandboxPhase.failed:
        return _buildFailed(state, isDark);
    }
  }

  Widget _buildAmountEntry(NfcSandboxState state, bool isDark) {
    final amountController = TextEditingController(text: state.amount.toStringAsFixed(0));
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF121212) : AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: isDark ? Border.all(color: const Color(0xFF1E1E1E)) : null,
              boxShadow: isDark ? null : AppColors.cardShadow,
            ),
            child: Column(
              children: [
                Text(
                  'Amount to Send (FCFA)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: '0',
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: isDark ? Colors.white24 : AppColors.textHint),
                  ),
                  onChanged: (v) {
                    ref.read(nfcSandboxProvider.notifier).setAmount(double.tryParse(v) ?? 0);
                  },
                ),
              ],
            ),
          ).animate().fadeIn().scale(curve: Curves.easeOutBack),

          const SizedBox(height: 24),

          SwitchListTile(
            title: Text(
              'Require Biometric',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
            subtitle: Text(
              'Fingerprint/Face ID before sending',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white60 : AppColors.textSecondary,
              ),
            ),
            value: state.requireBiometric,
            onChanged: (v) => ref.read(nfcSandboxProvider.notifier).toggleBiometric(v),
            activeColor: AppColors.primary,
          ),

          const SizedBox(height: 24),

          PayamButton(
            label: 'Tap To Send',
            icon: Icons.nfc_rounded,
            onPressed: () {
              ref.read(nfcSandboxProvider.notifier).simulateTap();
            },
          ).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: 16),
          Text(
            'Simulating frontend-only NFC transfer',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white38 : AppColors.textSecondary,
            ),
          ).animate().fadeIn(delay: 300.ms),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildBiometricPrompt(bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.fingerprint_rounded,
              size: 64,
              color: AppColors.primary,
            ),
          ).animate().scale(curve: Curves.easeOutBack, duration: 600.ms),
          
          const SizedBox(height: 32),
          
          Text(
            'Biometric Check',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          
          const SizedBox(height: 12),
          
          Text(
            'Verifying your identity...',
            style: TextStyle(
              fontSize: 15,
              color: isDark ? Colors.white60 : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransmitting(NfcSandboxState state, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                // Animated waves
                ...List.generate(3, (i) {
                  return AnimatedBuilder(
                    animation: _waveController,
                    builder: (context, child) {
                      return Container(
                        width: 160 + (_waveController.value * 60),
                        height: 160 + (_waveController.value * 60),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary
                                .withOpacity((1 - _waveController.value) * 0.5),
                            width: 2,
                          ),
                        ),
                      );
                    },
                  );
                }),
                
                // Phone icon with NFC symbol
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 24,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.nfc_rounded,
                    size: 56,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 40),
            
            Text(
              'Bring Phones Together',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ).animate().fadeIn(duration: 300.ms),
            
            const SizedBox(height: 12),
            
            Text(
              'Tap phones together to complete transfer',
              style: TextStyle(
                fontSize: 15,
                color: isDark ? Colors.white60 : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 100.ms),
            
            const SizedBox(height: 24),
            
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? Colors.white10 : AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.timer_rounded, size: 16, color: AppColors.warning),
                  const SizedBox(width: 8),
                  Text(
                    'Expires in ${state.countdown}s',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms),
            
            const SizedBox(height: 12),
            
            Text(
              '${state.amount.toStringAsFixed(0)} FCFA',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessing(bool isDark) {
    final logsAsync = ref.watch(nfcSandboxProvider);
    
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          Text(
            'Processing Transfer',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Backend log simulation
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxHeight: 300),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0A0A0A) : const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFF333333)),
            ),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: logsAsync.logs.length,
              itemBuilder: (context, i) {
                final log = logsAsync.logs[i];
                Color logColor = AppColors.textHint;
                if (log.level == NfcLogLevel.success) logColor = AppColors.success;
                if (log.level == NfcLogLevel.error) logColor = AppColors.error;
                if (log.level == NfcLogLevel.warning) logColor = AppColors.warning;
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (log.message.startsWith('{'))
                        Text(
                          log.message,
                          style: TextStyle(
                            fontSize: 11,
                            fontFamily: 'monospace',
                            color: logColor,
                            height: 1.5,
                          ),
                        )
                      else
                        Row(
                          children: [
                            Text(
                              log.message,
                              style: TextStyle(
                                fontSize: 12,
                                color: logColor,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ).animate().fadeIn(delay: Duration(milliseconds: i * 100));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccess(NfcSandboxState state, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: Tween<double>(begin: 0, end: 1).animate(
                CurvedAnimation(
                  parent: _successController,
                  curve: Curves.elasticOut,
                ),
              ),
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 64,
                  color: AppColors.success,
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            Text(
              'Transfer Complete!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ).animate().fadeIn(delay: 200.ms),
            
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF121212) : AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: isDark ? Border.all(color: const Color(0xFF1E1E1E)) : null,
              ),
              child: Column(
                children: [
                  Text(
                    '${state.amount.toStringAsFixed(0)} FCFA',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sent Successfully',
                    style: TextStyle(
                      fontSize: 15,
                      color: isDark ? Colors.white60 : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
            
            const SizedBox(height: 40),
            
            PayamButton(
              label: 'Done',
              icon: Icons.check_rounded,
              onPressed: () {
                ref.read(nfcSandboxProvider.notifier).reset();
                context.pop();
              },
            ).animate().fadeIn(delay: 400.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildFailed(NfcSandboxState state, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close_rounded,
                size: 64,
                color: AppColors.error,
              ),
            ).animate().scale(curve: Curves.easeOutBack),
            
            const SizedBox(height: 32),
            
            Text(
              'Transfer Failed',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
            
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF121212) : AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.error.withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: AppColors.error,
                    size: 32,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Insufficient Balance',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please add funds to your wallet',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white60 : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
            
            const SizedBox(height: 32),
            
            Row(
              children: [
                Expanded(
                  child: PayamButton(
                    label: 'Cancel',
                    isOutlined: true,
                    onPressed: () {
                      ref.read(nfcSandboxProvider.notifier).reset();
                      context.pop();
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: PayamButton(
                    label: 'Try Again',
                    icon: Icons.refresh_rounded,
                    onPressed: () {
                      ref.read(nfcSandboxProvider.notifier).reset();
                    },
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 400.ms),
          ],
        ),
      ),
    );
  }
}