import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/hce_payment_provider.dart';

/// Widget that listens for background payments and shows overlay
class BackgroundPaymentListener extends ConsumerStatefulWidget {
  final Widget child;

  const BackgroundPaymentListener({super.key, required this.child});

  @override
  ConsumerState<BackgroundPaymentListener> createState() => _BackgroundPaymentListenerState();
}

class _BackgroundPaymentListenerState extends ConsumerState<BackgroundPaymentListener> {
  StreamSubscription<PaymentReceivedEvent>? _subscription;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _subscription = backgroundPaymentStream.stream.listen(_onPaymentReceived);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _hideOverlay();
    super.dispose();
  }

  void _onPaymentReceived(PaymentReceivedEvent event) {
    // Only show overlay if we're not already showing one
    if (_overlayEntry != null) return;
    
    // Show overlay
    _showPaymentOverlay(event);
  }

  void _showPaymentOverlay(PaymentReceivedEvent event) {
    final overlay = Overlay.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    _overlayEntry = OverlayEntry(
      builder: (context) => Material(
        color: Colors.black54,
        child: SafeArea(
          child: Center(
            child: Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(24),
              constraints: const BoxConstraints(maxWidth: 400),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF121212) : AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      size: 48,
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Payment Received!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '+${event.amount.toStringAsFixed(0)} FCFA',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: AppColors.success,
                    ),
                  ),
                  if (event.senderName != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'From ${event.senderName}',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white60 : AppColors.textSecondary,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => _hideOverlay(),
                          child: Text(
                            'Dismiss',
                            style: TextStyle(
                              color: isDark ? Colors.white60 : AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            _hideOverlay();
                            ref.read(hcePaymentProvider.notifier).reset();
                            context.go('/home');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'View',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(_overlayEntry!);

    // Auto-dismiss after 10 seconds
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted && _overlayEntry != null) {
        _hideOverlay();
      }
    });
  }

  void _hideOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}