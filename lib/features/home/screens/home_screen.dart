import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/widgets/transaction_tile.dart';
import '../../../shared/widgets/user_avatar.dart';
import '../../../shared/models/transaction_model.dart';
import '../../../shared/models/notification_model.dart';
import '../../../shared/repositories/mock_repository.dart';
import '../../../shared/widgets/payam_button.dart';
import '../../../shared/widgets/payam_text_field.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final transactions = ref.watch(transactionsProvider);
    final isBalanceVisible = ref.watch(balanceVisibleProvider);
    final unreadCount = ref.watch(unreadNotificationsCountProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.fromLTRB(24, MediaQuery.of(context).padding.top + 16, 24, 0),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.loc('good_morning'),
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white70 : AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        user.firstName,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Stack(
                    children: [
                      GestureDetector(
                        onTap: () => context.push('/notifications'),
                        child: Icon(
                          Icons.notifications_rounded,
                          size: 24,
                          color: isDark ? Colors.white70 : AppColors.textPrimary,
                        ),
                      ),
                      if (unreadCount > 0)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.error,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () => context.go('/profile'),
                    child: UserAvatar(user: user, showBadge: true),
                  ),
                ],
              ).animate().fadeIn().slideY(begin: -0.2, end: 0),
            ),
          ),

          // Wallet Card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: _WalletCard(
                balance: user.balance,
                accountNumber: user.accountNumber,
                isVisible: isBalanceVisible,
                isDark: isDark,
                onToggleVisibility: () =>
                    ref.read(balanceVisibleProvider.notifier).state = !isBalanceVisible,
              ),
            ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0),
          ),

          // Quick Actions
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.loc('quick_actions'),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white60 : AppColors.textSecondary,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _QuickActionsGrid(isDark: isDark),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms),
          ),

          // Recent Transactions
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 6),
              child: Row(
                children: [
                  Text(
                    context.loc('recent_transactions'),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white60 : AppColors.textSecondary,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => context.go('/transactions'),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      context.loc('see_all'),
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white70 : AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: TransactionTile(
                  transaction: transactions[i],
                  onTap: () => context.push('/transaction-detail', extra: transactions[i]),
                ).animate().fadeIn(delay: Duration(milliseconds: 100 * i)).slideX(begin: 0.05, end: 0),
              ),
              childCount: transactions.length.clamp(0, 5),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }
}

class _WalletCard extends StatelessWidget {
  final double balance;
  final String accountNumber;
  final bool isVisible;
  final bool isDark;
  final VoidCallback onToggleVisibility;

  const _WalletCard({
    required this.balance,
    required this.accountNumber,
    required this.isVisible,
    required this.isDark,
    required this.onToggleVisibility,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  AppColors.primary.withOpacity(0.18),
                  AppColors.primaryDark.withOpacity(0.25),
                ]
              : [
                  AppColors.primary,
                  AppColors.primaryDark,
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: isDark ? Border.all(color: AppColors.darkBorder, width: 1) : null,
        boxShadow: isDark ? null : AppColors.primaryShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                context.loc('total_balance'),
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.primaryLight.withOpacity(0.8) : Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onToggleVisibility,
                child: Icon(
                  isVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                  size: 16,
                  color: isDark ? AppColors.primaryLight : Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              isVisible ? CurrencyFormatter.format(balance) : '•••••• FCFA',
              key: ValueKey(isVisible),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkTextPrimary : Colors.white,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Icon(
                Icons.trending_up_rounded,
                size: 12,
                color: isDark ? AppColors.success.withOpacity(0.9) : const Color(0xFF22C55E),
              ),
              const SizedBox(width: 3),
              Text(
                context.loc('balance_growth'),
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? AppColors.success.withOpacity(0.9) : const Color(0xFF22C55E),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: Colors.white.withOpacity(isDark ? 0.06 : 0.1)),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                accountNumber,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.darkTextPrimary.withOpacity(0.7) : Colors.white70,
                  letterSpacing: 1,
                ),
              ),
              const Spacer(),
              Text(
                context.loc('fcfa_wallet'),
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? AppColors.primaryLight.withOpacity(0.7) : Colors.white60,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  final bool isDark;

  const _QuickActionsGrid({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final actions = [
      (Icons.send_rounded, context.loc('send'), 'send'),
      (Icons.arrow_downward_rounded, context.loc('receive'), 'receive'),
      (Icons.qr_code_rounded, context.loc('pay'), 'pay'),
      (Icons.nfc_rounded, context.loc('nfc'), 'nfc'),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: actions.map((action) {
        final (icon, label, type) = action;
        return GestureDetector(
          onTap: () {
            if (type == 'send') {
              context.push('/send-money');
            } else if (type == 'receive') {
              context.push('/receive-money');
            } else if (type == 'pay') {
              context.push('/merchant');
            } else if (type == 'nfc') {
              context.push('/nfc-payment');
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.primary.withOpacity(0.18)
                      : AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: isDark
                      ? Border.all(color: AppColors.primary.withOpacity(0.3))
                      : null,
                ),
                child: Icon(
                  icon,
                  size: 22,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
