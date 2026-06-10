import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/widgets/payam_button.dart';
import '../../../shared/widgets/user_avatar.dart';

class ReceiveMoneyScreen extends ConsumerWidget {
  const ReceiveMoneyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : AppColors.primary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          context.loc('receive_money'),
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          const SizedBox(height: 24),
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF121212) : AppColors.surface,
                borderRadius: BorderRadius.circular(32),
                border: isDark ? Border.all(color: const Color(0xFF1E1E1E)) : null,
                boxShadow: isDark ? null : AppColors.elevatedShadow,
              ),
              child: Column(
                children: [
                  UserAvatar(user: user, size: 80),
                  const SizedBox(height: 16),
                  Text(
                    user.fullName,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.phone,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white60 : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 28),
                  
                  // Stylized QR Code
                  Container(
                    width: 200,
                    height: 200,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E1E) : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(24),
                      border: isDark ? Border.all(color: const Color(0xFF2D2D2D)) : null,
                    ),
                    child: Icon(
                      Icons.qr_code_2_rounded,
                      size: 168,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  
                  const SizedBox(height: 28),
                  Text(
                    context.loc('scan_to_pay_me'),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white60 : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ).animate().scale(curve: Curves.easeOutBack, duration: 600.ms),
          ),
          
          const Spacer(),
          
          Container(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF121212) : AppColors.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              border: isDark ? const Border(top: BorderSide(color: Color(0xFF1E1E1E))) : null,
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PayamButton(
                    label: context.loc('share_qr'),
                    icon: Icons.share_rounded,
                    onPressed: () {},
                  ),
                  const SizedBox(height: 16),
                  PayamButton(
                    label: context.loc('copy_link'),
                    icon: Icons.content_copy_rounded,
                    isOutlined: true,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(context.loc('copied_link_msg')),
                          backgroundColor: isDark ? Colors.white : AppColors.primary,
                        ),
                      );
                    },
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
