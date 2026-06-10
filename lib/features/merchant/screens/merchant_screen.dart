import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/widgets/payam_button.dart';
import '../../../shared/widgets/success/success_overlay.dart';
import '../../../shared/models/transaction_model.dart';
import '../../../shared/models/notification_model.dart';
import '../../../shared/repositories/mock_repository.dart';

class MerchantScreen extends ConsumerStatefulWidget {
  const MerchantScreen({super.key});

  @override
  ConsumerState<MerchantScreen> createState() => _MerchantScreenState();
}

class _MerchantScreenState extends ConsumerState<MerchantScreen> {
  final MobileScannerController _scannerController = MobileScannerController(
    autoStart: true,
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );
  bool _isScannerActive = true;
  bool _hasScanned = false;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _onBarcodeDetected(BarcodeCapture capture) {
    if (_hasScanned) return;
    final barcode = capture.barcodes.firstOrNull;
    if (barcode == null || barcode.rawValue == null) return;

    _hasScanned = true;
    _scannerController.stop();

    final code = barcode.rawValue!;
    _processMerchantPayment(context, ref, code);
  }

  void _showMerchantIdSheet(BuildContext context) {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    _scannerController.stop();
    setState(() => _isScannerActive = false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            top: 24,
            left: 24,
            right: 24,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(
                  context.loc('enter_merchant_id'),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  context.loc('enter_merchant_hint'),
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: controller,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'MERCH-1092',
                    prefixIcon: Icon(
                      Icons.store_rounded,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Please enter a merchant ID';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                PayamButton(
                  label: context.loc('confirm_and_pay'),
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      Navigator.pop(context);
                      _processMerchantPayment(context, ref, controller.text.trim());
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    ).then((_) {
      if (mounted && !_hasScanned) {
        setState(() => _isScannerActive = true);
        _scannerController.start();
      }
    });
  }

  void _processMerchantPayment(BuildContext context, WidgetRef ref, String merchantId) async {
    final amount = 5000.0;
    final user = ref.read(userProvider);
    if (user.balance < amount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.loc('insufficient_balance')),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      _hasScanned = false;
      if (mounted) {
        setState(() => _isScannerActive = true);
        _scannerController.start();
      }
      return;
    }

    final transaction = TransactionModel(
      id: 'txn_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Merchant Payment',
      subtitle: 'Merchant: $merchantId',
      amount: amount,
      isCredit: false,
      type: TransactionType.payment,
      status: TransactionStatus.success,
      date: DateTime.now(),
      reference: 'PAY${DateTime.now().millisecondsSinceEpoch}',
    );

    MockRepository.instance.addTransaction(transaction);

    final notification = NotificationModel(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      title: '🛍️ Merchant Paid',
      message: 'You successfully paid FCFA $amount to merchant $merchantId.',
      category: NotificationCategory.transaction,
      isRead: false,
      date: DateTime.now(),
    );
    MockRepository.instance.addNotification(notification);

    ref.read(userProvider.notifier).state = MockRepository.instance.currentUser;
    ref.read(transactionsProvider.notifier).state = [...MockRepository.instance.transactions];
    ref.read(notificationsProvider.notifier).state = [...MockRepository.instance.notifications];

    await SuccessOverlay.show(
      context,
      title: context.loc('payment_success'),
      subtitle: 'Payment sent to $merchantId',
      amount: 'FCFA ${CurrencyFormatter.format(amount)}',
      icon: Icons.storefront_rounded,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: Text(context.loc('pay_merchant')),
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                MobileScanner(
                  controller: _scannerController,
                  onDetect: _onBarcodeDetected,
                ),
                Container(
                  decoration: ShapeDecoration(
                    shape: ScannerOverlayShape(
                      borderColor: isDark ? AppColors.primaryLight : AppColors.primary,
                      overlayColor: Colors.black.withOpacity(0.6),
                    ),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 120),
                      Icon(
                        Icons.qr_code_scanner_rounded,
                        size: 48,
                        color: Colors.white.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 48),
                        child: Text(
                          context.loc('align_qr_instruction'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.5,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              border: isDark ? Border(top: BorderSide(color: AppColors.darkBorder)) : null,
              boxShadow: isDark ? null : AppColors.elevatedShadow,
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _ActionButton(
                        icon: Icons.photo_library_rounded,
                        label: context.loc('upload'),
                        isDark: isDark,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Gallery upload coming soon'),
                              backgroundColor: AppColors.info,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                      _ActionButton(
                        icon: Icons.keyboard_rounded,
                        label: context.loc('enter_code'),
                        isDark: isDark,
                        onTap: () => _showMerchantIdSheet(context),
                      ),
                      _ActionButton(
                        icon: _isScannerActive
                            ? Icons.flash_on_rounded
                            : Icons.flash_off_rounded,
                        label: context.loc('flashlight'),
                        isDark: isDark,
                        onTap: () {
                          _scannerController.toggleTorch();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ).animate().slideY(begin: 1, end: 0, duration: 400.ms),
        ],
      ),
    );
  }
}

class ScannerOverlayShape extends ShapeBorder {
  final Color borderColor;
  final Color overlayColor;

  const ScannerOverlayShape({
    required this.borderColor,
    required this.overlayColor,
  });

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    final scanArea = Rect.fromCenter(
      center: rect.center,
      width: rect.width * 0.75,
      height: rect.width * 0.75,
    );
    return Path()..addRect(scanArea);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return Path()..addRect(rect);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final scanArea = Rect.fromCenter(
      center: rect.center - const Offset(0, 40),
      width: rect.width * 0.75,
      height: rect.width * 0.75,
    );

    // Draw dark overlay with transparent hole
    final overlayPath = Path()
      ..addRect(rect)
      ..addRRect(RRect.fromRectAndRadius(scanArea, const Radius.circular(24)))
      ..fillType = PathFillType.evenOdd;
    
    canvas.drawPath(overlayPath, Paint()..color = overlayColor);

    // Draw corner brackets
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final cornerLength = 28.0;

    // Top-left corner
    canvas.drawPath(
      Path()
        ..moveTo(scanArea.left, scanArea.top + cornerLength)
        ..lineTo(scanArea.left, scanArea.top)
        ..lineTo(scanArea.left + cornerLength, scanArea.top),
      borderPaint,
    );

    // Top-right corner
    canvas.drawPath(
      Path()
        ..moveTo(scanArea.right - cornerLength, scanArea.top)
        ..lineTo(scanArea.right, scanArea.top)
        ..lineTo(scanArea.right, scanArea.top + cornerLength),
      borderPaint,
    );

    // Bottom-left corner
    canvas.drawPath(
      Path()
        ..moveTo(scanArea.left, scanArea.bottom - cornerLength)
        ..lineTo(scanArea.left, scanArea.bottom)
        ..lineTo(scanArea.left + cornerLength, scanArea.bottom),
      borderPaint,
    );

    // Bottom-right corner
    canvas.drawPath(
      Path()
        ..moveTo(scanArea.right - cornerLength, scanArea.bottom)
        ..lineTo(scanArea.right, scanArea.bottom)
        ..lineTo(scanArea.right, scanArea.bottom - cornerLength),
      borderPaint,
    );
  }

  @override
  ShapeBorder scale(double t) => this;
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(18),
              border: isDark ? Border.all(color: AppColors.darkBorder) : null,
            ),
            child: Icon(
              icon,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              size: 26,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}