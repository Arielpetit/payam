import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/widgets/payam_button.dart';
import '../../../shared/widgets/payam_text_field.dart';
import '../../../shared/widgets/transaction_tile.dart';
import '../../../shared/models/transaction_model.dart';
import '../../../shared/models/notification_model.dart';
import '../../../shared/repositories/mock_repository.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  void _showTopUpSheet(BuildContext context, WidgetRef ref) {
    final amountController = TextEditingController();
    final formKey = GlobalKey<FormState>();

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
                  'Top Up Wallet',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 20),
                PayamTextField(
                  label: 'Amount (FCFA)',
                  hint: '0',
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || double.tryParse(v) == null || double.parse(v) <= 0) {
                      return 'Enter valid amount';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                PayamButton(
                  label: 'Top Up Now',
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      final amt = double.parse(amountController.text);

                      final transaction = TransactionModel(
                        id: 'txn_${DateTime.now().millisecondsSinceEpoch}',
                        title: 'Wallet Top Up',
                        subtitle: 'Bank Transfer',
                        amount: amt,
                        isCredit: true,
                        type: TransactionType.deposit,
                        status: TransactionStatus.success,
                        date: DateTime.now(),
                        reference: 'PAY${DateTime.now().millisecondsSinceEpoch}',
                      );

                      MockRepository.instance.addTransaction(transaction);

                      final notification = NotificationModel(
                        id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
                        title: '💰 Top Up Success',
                        message: 'You successfully topped up FCFA $amt to your wallet.',
                        category: NotificationCategory.transaction,
                        isRead: false,
                        date: DateTime.now(),
                      );
                      MockRepository.instance.addNotification(notification);

                      ref.read(userProvider.notifier).state = MockRepository.instance.currentUser;
                      ref.read(transactionsProvider.notifier).state = [...MockRepository.instance.transactions];
                      ref.read(notificationsProvider.notifier).state = [...MockRepository.instance.notifications];

                      Navigator.pop(context);
                      
                      if (context.mounted) {
                        context.go('/transaction-success', extra: {
                          'title': 'Top Up Successful',
                          'subtitle': 'Your wallet has been credited',
                          'amount': 'FCFA ${CurrencyFormatter.format(amt)}',
                          'icon': Icons.account_balance_rounded,
                          'transactionType': TransactionType.deposit,
                          'reference': 'PAY${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
                          'paymentMethod': 'Bank Transfer',
                          'fee': '0 FCFA',
                          'isKnownContact': true,
                        });
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showWithdrawSheet(BuildContext context, WidgetRef ref) {
    final amountController = TextEditingController();
    final formKey = GlobalKey<FormState>();

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
                  'Withdraw Money',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 20),
                PayamTextField(
                  label: 'Amount (FCFA)',
                  hint: '0',
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || double.tryParse(v) == null || double.parse(v) <= 0) {
                      return 'Enter valid amount';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                PayamButton(
                  label: 'Withdraw Now',
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      final amt = double.parse(amountController.text);
                      final user = ref.read(userProvider);
                      if (user.balance < amt) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(context.loc('insufficient_balance')),
                            backgroundColor: AppColors.error,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        return;
                      }

                      final transaction = TransactionModel(
                        id: 'txn_${DateTime.now().millisecondsSinceEpoch}',
                        title: 'Wallet Withdrawal',
                        subtitle: 'Bank Transfer',
                        amount: amt,
                        isCredit: false,
                        type: TransactionType.withdrawal,
                        status: TransactionStatus.success,
                        date: DateTime.now(),
                        reference: 'PAY${DateTime.now().millisecondsSinceEpoch}',
                      );

                      MockRepository.instance.addTransaction(transaction);

                      final notification = NotificationModel(
                        id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
                        title: '💸 Withdrawal Success',
                        message: 'You successfully withdrew FCFA $amt from your wallet.',
                        category: NotificationCategory.transaction,
                        isRead: false,
                        date: DateTime.now(),
                      );
                      MockRepository.instance.addNotification(notification);

                      ref.read(userProvider.notifier).state = MockRepository.instance.currentUser;
                      ref.read(transactionsProvider.notifier).state = [...MockRepository.instance.transactions];
                      ref.read(notificationsProvider.notifier).state = [...MockRepository.instance.notifications];

                      Navigator.pop(context);
                      
                      if (context.mounted) {
                        context.go('/transaction-success', extra: {
                          'title': 'Withdrawal Successful',
                          'subtitle': 'Funds sent to your bank account',
                          'amount': 'FCFA ${CurrencyFormatter.format(amt)}',
                          'icon': Icons.payments_rounded,
                          'transactionType': TransactionType.withdrawal,
                          'reference': 'PAY${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
                          'paymentMethod': 'Bank Account',
                          'fee': '0 FCFA',
                          'isKnownContact': true,
                        });
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final transactions = ref.watch(transactionsProvider).take(3).toList();
    final isBalanceVisible = ref.watch(balanceVisibleProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 0,
            floating: true,
            snap: true,
            pinned: true,
            title: Text(
              context.loc('my_wallet'),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.add_circle_outline_rounded),
                onPressed: () => _showTopUpSheet(context, ref),
              ),
              const SizedBox(width: 8),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _WalletBalanceCard(
                    balance: user.balance,
                    accountNumber: '**** ${user.phone.substring(user.phone.length - 4)}',
                    isVisible: isBalanceVisible,
                    onToggleVisibility: () =>ref.read(balanceVisibleProvider.notifier).state = !isBalanceVisible,
                  ).animate().fadeIn().slideY(begin: 0.05, end: 0),

                  const SizedBox(height: 16),

                  _QuickActionsRow(
                    onTopUp: () => _showTopUpSheet(context, ref),
                    onWithdraw: () => _showWithdrawSheet(context, ref),
                  ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.05, end: 0),

                  const SizedBox(height: 24),

                  Text(
                    context.loc('linked_banks'),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ).animate().fadeIn(delay: 150.ms),
                  const SizedBox(height: 10),

                  _BankAccountsList().animate().fadeIn(delay: 200.ms).slideY(begin: 0.05, end: 0),

                  const SizedBox(height: 12),

                  // KYC Verification Card
                  _KYCVerificationCard(isVerified: user.isVerified)
                      .animate()
                      .fadeIn(delay: 250.ms)
                      .slideY(begin: 0.05, end: 0),

                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.loc('recent_activity'),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.go('/transactions'),
                        child: Text(context.loc('view_all')),
                      ),
                    ],
                  ).animate().fadeIn(delay: 250.ms),

                  const SizedBox(height: 8),

                  ...transactions.map((tx) => TransactionTile(
                        transaction: tx,
                        onTap: () => context.push('/transaction-detail', extra: tx),
                      ).animate().fadeIn(delay: 300.ms)),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WalletBalanceCard extends StatelessWidget {
  final double balance;
  final String accountNumber;
  final bool isVisible;
  final VoidCallback onToggleVisibility;

  const _WalletBalanceCard({
    required this.balance,
    required this.accountNumber,
    required this.isVisible,
    required this.onToggleVisibility,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
              Icon(
                Icons.account_balance_wallet_rounded,
                color: isDark ? AppColors.primaryLight : Colors.white70,
                size: 15,
              ),
              const SizedBox(width: 6),
              Text(
                context.loc('total_balance'),
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.darkTextSecondary : Colors.white70,
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
          const SizedBox(height: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              isVisible ? CurrencyFormatter.format(balance) : '•••••• FCFA',
              key: ValueKey(isVisible),
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkTextPrimary : Colors.white,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            accountNumber,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.darkTextSecondary : Colors.white54,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionsRow extends StatelessWidget {
  final VoidCallback onTopUp;
  final VoidCallback onWithdraw;

  const _QuickActionsRow({
    required this.onTopUp,
    required this.onWithdraw,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionButton(
            icon: Icons.add_rounded,
            label: context.loc('top_up'),
            onTap: onTopUp,
            isPrimary: true,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickActionButton(
            icon: Icons.arrow_upward_rounded,
            label: context.loc('withdraw'),
            onTap: onWithdraw,
            isPrimary: false,
          ),
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isPrimary,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 16),
        decoration: BoxDecoration(
          color: isPrimary
              ? (isDark ? AppColors.primaryDark.withOpacity(0.25) : AppColors.primary)
              : (isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant),
          borderRadius: BorderRadius.circular(12),
          border: isDark
              ? Border.all(color: isPrimary ? AppColors.primary.withOpacity(0.3) : AppColors.darkBorder)
              : null,
          boxShadow: isDark ? null : (isPrimary ? AppColors.primaryShadow : null),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isPrimary
                  ? Colors.white
                  : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isPrimary
                    ? Colors.white
                    : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BankAccountsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final banks = [
      {'name': 'Ecobank Cameroon', 'last4': '4567', 'color': const Color(0xFF00A651), 'type': 'Checking'},
      {'name': 'UBA Cameroon', 'last4': '8901', 'color': const Color(0xFFE53935), 'type': 'Savings'},
      {'name': 'Afriland First Bank', 'last4': '2345', 'color': const Color(0xFF1E88E5), 'type': 'Current'},
    ];

    return Column(
      children: [
        ...banks.map((bank) => _BankAccountTile(
              bankName: bank['name'] as String,
              last4: bank['last4'] as String,
              color: bank['color'] as Color,
              accountType: bank['type'] as String,
              isDark: isDark,
            )),
        const SizedBox(height: 12),
        _AddBankButton(isDark: isDark),
      ],
    );
  }
}

class _BankAccountTile extends StatelessWidget {
  final String bankName;
  final String last4;
  final Color color;
  final String accountType;
  final bool isDark;

  const _BankAccountTile({
    required this.bankName,
    required this.last4,
    required this.color,
    required this.accountType,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceVariant : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isDark ? Border.all(color: AppColors.darkBorder) : null,
        boxShadow: isDark ? null : AppColors.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.account_balance_rounded, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bankName,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
                Text(
                  '$accountType •••• $last4',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: isDark ? AppColors.darkTextHint : AppColors.textHint,
            size: 18,
          ),
        ],
      ),
    );
  }
}

class _AddBankButton extends StatelessWidget {
  final bool isDark;
  const _AddBankButton({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.border,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_rounded,
              color: isDark ? AppColors.primaryLight : AppColors.primary,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              context.loc('add_bank'),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.primaryLight : AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KYCVerificationCard extends StatelessWidget {
  final bool isVerified;
  const _KYCVerificationCard({required this.isVerified});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (isVerified) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.success.withOpacity(0.08)
              : const Color(0xFFECFDF5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.success.withOpacity(isDark ? 0.3 : 0.4)),
        ),
        child: Row(
          children: [
            Icon(Icons.verified_user_rounded, color: AppColors.success, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'KYC Verified · All features unlocked',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              ),
            ),
            Icon(Icons.check_circle_rounded, color: AppColors.success, size: 16),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.warning.withOpacity(0.08)
            : const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withOpacity(isDark ? 0.3 : 0.5)),
      ),
      child: Row(
        children: [
          Icon(Icons.shield_outlined, color: AppColors.warning, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'KYC required · Unlock higher limits',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
          ),
          GestureDetector(
            onTap: () async {
              final uri = Uri.parse('https://inquiry.withpersona.com/verify?inquiry-id=inq_A7YE3mwdHp4B6rxBiyvDzJNPyySucC');
              try {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Could not open verification link: $e'), backgroundColor: AppColors.error),
                  );
                }
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.warning,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Verify',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.black : Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}