import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/models/transaction_model.dart';
import '../../../shared/repositories/mock_repository.dart';
import '../../../shared/providers/app_providers.dart';

class TransactionSuccessScreen extends ConsumerStatefulWidget {
  final String title;
  final String subtitle;
  final String? amount;
  final IconData icon;
  final String? recipientName;
  final String? recipientPhone;
  final String? recipientId;
  final bool isKnownContact;
  final TransactionType? transactionType;
  final String? reference;
  final String? paymentMethod;
  final DateTime? date;
  final String? fee;

  const TransactionSuccessScreen({
    super.key,
    required this.title,
    required this.subtitle,
    this.amount,
    this.icon = Icons.check_circle_rounded,
    this.recipientName,
    this.recipientPhone,
    this.recipientId,
    this.isKnownContact = true,
    this.transactionType,
    this.reference,
    this.paymentMethod,
    this.date,
    this.fee,
  });

  @override
  ConsumerState<TransactionSuccessScreen> createState() => _TransactionSuccessScreenState();
}

class _TransactionSuccessScreenState extends ConsumerState<TransactionSuccessScreen> {
  bool _contactSaved = false;
  bool _copied = false;
  bool _sharing = false;
  bool _downloading = false;
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.recipientName ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveContact() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final contacts = [...MockRepository.instance.contacts];
    final alreadyExists = contacts.any((c) =>
      c.id == widget.recipientId || c.phone == widget.recipientPhone);

    if (!alreadyExists) {
      final newContact = UserModel(
        id: widget.recipientId ?? 'contact_${DateTime.now().millisecondsSinceEpoch}',
        fullName: name,
        phone: widget.recipientPhone ?? '',
        email: '',
        balance: 0,
        accountNumber: widget.recipientPhone ?? '',
        isVerified: false,
      );
      MockRepository.instance.contacts = [...contacts, newContact];
      ref.read(contactsProvider.notifier).state = [...MockRepository.instance.contacts];
    }

    setState(() => _contactSaved = true);
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'U';
    final parts = name.trim().split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  Future<void> _shareReceipt() async {
    setState(() => _sharing = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _sharing = false);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('Receipt shared successfully'),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _downloadReceipt() async {
    setState(() => _downloading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => _downloading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.file_download_done_rounded, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('Receipt PDF saved to Downloads'),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final showSaveContact = !widget.isKnownContact && !_contactSaved && widget.recipientPhone != null;
    
    final bg = isDark ? Colors.black : const Color(0xFFF8FAFC); // Slate 50
    final cardBg = isDark ? const Color(0xFF0F0F10) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569);
    final dividerColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    final shadowColor = isDark ? Colors.transparent : Colors.black.withValues(alpha: 0.03);

    final refText = widget.reference ?? 'PAY${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
    
    // Auto-resolve transaction label
    String typeLabel = 'Transaction';
    if (widget.transactionType != null) {
      switch (widget.transactionType!) {
        case TransactionType.send:
          typeLabel = 'Money Transfer';
          break;
        case TransactionType.receive:
          typeLabel = 'Received Funds';
          break;
        case TransactionType.deposit:
          typeLabel = 'Wallet Top-Up';
          break;
        case TransactionType.withdrawal:
          typeLabel = 'Wallet Withdrawal';
          break;
        case TransactionType.payment:
          typeLabel = 'Merchant Payment';
          break;
        case TransactionType.airtime:
          typeLabel = 'Airtime Top-Up';
          break;
        case TransactionType.data:
          typeLabel = 'Data Purchase';
          break;
        case TransactionType.bills:
          typeLabel = 'Bill Payment';
          break;
      }
    } else if (widget.title.toLowerCase().contains('top up') || widget.title.toLowerCase().contains('top-up')) {
      typeLabel = 'Wallet Top-Up';
    } else if (widget.title.toLowerCase().contains('withdraw')) {
      typeLabel = 'Wallet Withdrawal';
    } else if (widget.title.toLowerCase().contains('pay') || widget.title.toLowerCase().contains('merchant')) {
      typeLabel = 'Merchant Payment';
    } else if (widget.title.toLowerCase().contains('send') || widget.title.toLowerCase().contains('transfer')) {
      typeLabel = 'Money Transfer';
    }

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 36),

              // Animated Success Icon with multiple pulsing rings
              Center(
                child: SizedBox(
                  width: 140,
                  height: 140,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer Pulse Ring
                      Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.success.withValues(alpha: 0.06),
                        ),
                      ).animate(onPlay: (c) => c.repeat(reverse: true))
                       .scale(begin: const Offset(0.95, 0.95), end: const Offset(1.08, 1.08), duration: 1500.ms, curve: Curves.easeInOut),

                      // Middle Pulse Ring
                      Container(
                        width: 104,
                        height: 104,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.success.withValues(alpha: 0.12),
                        ),
                      ).animate().scale(begin: const Offset(0.5, 0.5), end: const Offset(1.0, 1.0), duration: 500.ms, curve: Curves.elasticOut),

                      // Inner Success Badge
                      Container(
                        width: 76,
                        height: 76,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [AppColors.success, Color(0xFF16A34A)],
                          ),
                        ),
                        child: Icon(widget.icon, size: 40, color: Colors.white),
                      ).animate().scale(begin: const Offset(0.3, 0.3), end: const Offset(1.0, 1.0), duration: 400.ms, curve: Curves.elasticOut),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Title
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                  letterSpacing: -0.5,
                ),
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.15, end: 0),

              const SizedBox(height: 6),

              // Subtitle
              Text(
                widget.subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: textSecondary,
                ),
              ).animate().fadeIn(delay: 250.ms),

              const SizedBox(height: 24),

              // Amount Card
              if (widget.amount != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF121214) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: dividerColor, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: shadowColor,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Text(
                    widget.amount!,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: textPrimary,
                      letterSpacing: -1,
                    ),
                  ),
                ).animate().fadeIn(delay: 300.ms).scale(begin: const Offset(0.9, 0.9), end: const Offset(1.0, 1.0), duration: 400.ms, curve: Curves.elasticOut),
                const SizedBox(height: 24),
              ],

              // Receipt Details Card (Ticket Style Layout)
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: dividerColor, width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: shadowColor,
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // Status Detail Row
                          _buildDetailRow(
                            label: 'Status',
                            valueWidget: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppColors.success,
                                    shape: BoxShape.circle,
                                  ),
                                ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                                 .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.3, 1.3), duration: 800.ms),
                                const SizedBox(width: 6),
                                const Text(
                                  'Completed',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.success,
                                  ),
                                ),
                              ],
                            ),
                            textSecondaryColor: textSecondary,
                          ),
                          
                          _buildDetailDivider(dividerColor),

                          // Transaction Type Row
                          _buildDetailRow(
                            label: 'Type',
                            valueText: typeLabel,
                            textPrimaryColor: textPrimary,
                            textSecondaryColor: textSecondary,
                          ),

                          _buildDetailDivider(dividerColor),

                          // Date & Time Row
                          _buildDetailRow(
                            label: 'Date & Time',
                            valueText: DateFormatter.formatDateTime(widget.date ?? DateTime.now()),
                            textPrimaryColor: textPrimary,
                            textSecondaryColor: textSecondary,
                          ),

                          _buildDetailDivider(dividerColor),

                          // Payment Method / Source
                          if (widget.paymentMethod != null || widget.transactionType != null)
                            _buildDetailRow(
                              label: 'Payment Source',
                              valueText: widget.paymentMethod ?? 'Payam Wallet',
                              textPrimaryColor: textPrimary,
                              textSecondaryColor: textSecondary,
                            ),

                          if (widget.paymentMethod != null || widget.transactionType != null)
                            _buildDetailDivider(dividerColor),

                          // Recipient Detail Row (if applicable)
                          if (widget.recipientName != null) ...[
                            _buildDetailRow(
                              label: widget.transactionType == TransactionType.receive ? 'Sender' : 'Recipient',
                              valueWidget: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircleAvatar(
                                    radius: 12,
                                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                                    child: Text(
                                      _getInitials(widget.recipientName!),
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
      SizedBox(width: 8),
                                  Text(
                                    widget.recipientName!,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              textSecondaryColor: textSecondary,
                            ),
                            _buildDetailDivider(dividerColor),
                          ],

                          // Fee Detail Row
                          _buildDetailRow(
                            label: 'Fee',
                            valueWidget: const Text(
                              'Free (0 FCFA)',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.success,
                              ),
                            ),
                            textSecondaryColor: textSecondary,
                          ),

                          _buildDetailDivider(dividerColor),

                          // Reference ID Row (with tap-to-copy)
                          _buildDetailRow(
                            label: 'Reference',
                            valueWidget: InkWell(
                              onTap: () {
                                Clipboard.setData(ClipboardData(text: refText));
                                setState(() => _copied = true);
                                Future.delayed(const Duration(seconds: 2), () {
                                  if (mounted) setState(() => _copied = false);
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Row(
                                      children: [
                                        Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                                        SizedBox(width: 8),
                                        Text('Reference copied to clipboard'),
                                      ],
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                    backgroundColor: AppColors.primary,
                                    duration: const Duration(seconds: 1),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(6),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      refText,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Icon(
                                      _copied ? Icons.check_circle_rounded : Icons.copy_rounded,
                                      size: 13,
                                      color: _copied ? AppColors.success : AppColors.primary,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            textSecondaryColor: textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.1, end: 0),

              const SizedBox(height: 24),

              // Action Chips (Share & PDF)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionChip(
                    icon: Icons.share_outlined,
                    label: 'Share',
                    isLoading: _sharing,
                    onTap: _shareReceipt,
                    isDark: isDark,
                  ),
                  _buildActionChip(
                    icon: Icons.file_download_outlined,
                    label: 'PDF Receipt',
                    isLoading: _downloading,
                    onTap: _downloadReceipt,
                    isDark: isDark,
                  ),
                ],
              ).animate().fadeIn(delay: 400.ms),

              const SizedBox(height: 28),

              // Save contact prompt (if unknown contact)
              if (showSaveContact)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurfaceVariant : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: dividerColor, width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: shadowColor,
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.person_add_rounded, size: 22, color: AppColors.primary),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Save Contact',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: textPrimary,
                                  ),
                                ),
                                Text(
                                  widget.recipientPhone!,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E1E1F) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: _nameController,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: textPrimary,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Enter contact name',
                            hintStyle: TextStyle(
                              color: isDark ? Colors.white30 : AppColors.textHint,
                              fontSize: 14,
                            ),
                            prefixIcon: Icon(Icons.badge_outlined, color: isDark ? Colors.white30 : AppColors.textHint, size: 18),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => context.go('/home'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: textSecondary,
                                side: BorderSide(color: dividerColor),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text('Not Now', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _nameController.text.trim().isNotEmpty ? _saveContact : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                              child: const Text('Save', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 450.ms).slideY(begin: 0.1, end: 0),

              // Show "Contact saved!" message after saving
              if (_contactSaved)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.success.withValues(alpha: 0.2)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_rounded, color: AppColors.success, size: 18),
      SizedBox(width: 8),
                      Text(
                        'Contact saved successfully!',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 250.ms),

              const SizedBox(height: 36),

              // Main Action: Done Button
              if (!showSaveContact)
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => context.go('/home'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Done',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                ).animate().fadeIn(delay: 500.ms),

              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required String label,
    String? valueText,
    Widget? valueWidget,
    Color? textPrimaryColor,
    required Color textSecondaryColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: textSecondaryColor,
            ),
          ),
          if (valueWidget != null)
            valueWidget
          else
            Text(
              valueText ?? '',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: textPrimaryColor,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailDivider(Color dividerColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final boxWidth = constraints.constrainWidth();
          const dashWidth = 4.0;
          const dashHeight = 1.0;
          final dashCount = (boxWidth / (2 * dashWidth)).floor();
          return Flex(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            direction: Axis.horizontal,
            children: List.generate(dashCount, (_) {
              return SizedBox(
                width: dashWidth,
                height: dashHeight,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: dividerColor),
                ),
              );
            }),
          );
        },
      ),
    );
  }

  Widget _buildActionChip({
    required IconData icon,
    required String label,
    required bool isLoading,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF121214) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLoading)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              )
            else
              Icon(icon, size: 16, color: AppColors.primary),
      SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}