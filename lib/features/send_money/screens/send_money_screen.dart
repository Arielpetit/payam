import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/widgets/payam_button.dart';
import '../../../shared/widgets/payam_text_field.dart';
import '../../../shared/widgets/user_avatar.dart';
import '../../../shared/widgets/success/success_overlay.dart';
import '../../../shared/models/transaction_model.dart';
import '../../../shared/models/notification_model.dart';
import '../../../shared/repositories/mock_repository.dart';

class SendMoneyScreen extends ConsumerStatefulWidget {
  const SendMoneyScreen({super.key});

  @override
  ConsumerState<SendMoneyScreen> createState() => _SendMoneyScreenState();
}

class _SendMoneyScreenState extends ConsumerState<SendMoneyScreen> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  int _currentStep = 0; // 0 = select recipient, 1 = amount, 2 = confirm

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _nextStep(SendMoneyState state) async {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
    } else {
      // Execute the real in-memory transaction
      final transaction = TransactionModel(
        id: 'txn_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Transfer Sent',
        subtitle: 'To: ${state.recipient?.fullName ?? ''}',
        amount: state.amount,
        isCredit: false,
        type: TransactionType.send,
        status: TransactionStatus.success,
        date: DateTime.now(),
        reference: 'PAY${DateTime.now().millisecondsSinceEpoch}',
        recipientName: state.recipient?.fullName,
        recipientPhone: state.recipient?.phone,
        note: state.note,
      );

      MockRepository.instance.addTransaction(transaction);

      final notification = NotificationModel(
        id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
        title: '📱 Transfer Sent',
        message: 'You successfully sent FCFA ${state.amount} to ${state.recipient?.fullName ?? ''}.',
        category: NotificationCategory.transaction,
        isRead: false,
        date: DateTime.now(),
      );
      MockRepository.instance.addNotification(notification);

      // Re-read mutable state to update UI instantly
      ref.read(userProvider.notifier).state = MockRepository.instance.currentUser;
      ref.read(transactionsProvider.notifier).state = [...MockRepository.instance.transactions];
      ref.read(notificationsProvider.notifier).state = [...MockRepository.instance.notifications];

      // Reset state
      ref.read(sendMoneyStateProvider.notifier).state = const SendMoneyState();

      context.pop();

      await SuccessOverlay.show(
        context,
        title: context.loc('send_success_msg'),
        subtitle: 'Sent to ${state.recipient?.fullName ?? 'recipient'}',
        amount: 'FCFA ${CurrencyFormatter.format(state.amount)}',
        icon: Icons.send_rounded,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sendMoneyStateProvider);
    final contacts = ref.watch(contactsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    String stepTitle = context.loc('send_money');
    if (_currentStep == 1) stepTitle = context.loc('amount');
    if (_currentStep == 2) stepTitle = context.loc('confirm');

    return Scaffold(
      backgroundColor: isDark ? Colors.black : AppColors.background,
      appBar: AppBar(
        title: Text(stepTitle),
        backgroundColor: isDark ? Colors.black : AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (_currentStep > 0) {
              setState(() => _currentStep--);
            } else {
              context.pop();
            }
          },
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _buildCurrentStep(contacts, state, isDark),
      ),
    );
  }

  Widget _buildCurrentStep(contacts, state, bool isDark) {
    switch (_currentStep) {
      case 0:
        return _buildSelectRecipient(contacts, isDark);
      case 1:
        return _buildAmount(state, isDark);
      case 2:
        return _buildConfirm(state, isDark);
      default:
        return const SizedBox();
    }
  }

  Widget _buildSelectRecipient(contacts, bool isDark) {
    return Column(
      key: const ValueKey('step0'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: PayamTextField(
            label: context.loc('to_who'),
            hint: context.loc('recipient_hint'),
            prefixIcon: Icon(Icons.search_rounded, color: isDark ? Colors.white38 : AppColors.textHint),
          ),
        ).animate().fadeIn().slideY(begin: 0.1),
        
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            context.loc('recent_contacts'),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ).animate().fadeIn(delay: 100.ms),
        
        const SizedBox(height: 16),
        
        Expanded(
          child: ListView.builder(
            itemCount: contacts.length,
            itemBuilder: (context, i) {
              final contact = contacts[i];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                leading: UserAvatar(user: contact),
                title: Text(
                  contact.fullName,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                subtitle: Text(
                  contact.phone,
                  style: TextStyle(
                    color: isDark ? Colors.white60 : AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                onTap: () {
                  ref.read(sendMoneyStateProvider.notifier).state = ref.read(sendMoneyStateProvider).copyWith(recipient: contact);
                  _nextStep(ref.read(sendMoneyStateProvider));
                },
              ).animate().fadeIn(delay: Duration(milliseconds: 150 + (i * 50)));
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAmount(state, bool isDark) {
    return SingleChildScrollView(
      key: const ValueKey('step1'),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              UserAvatar(user: state.recipient, size: 56),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.loc('sending_to'),
                    style: TextStyle(
                      color: isDark ? Colors.white60 : AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    state.recipient?.fullName ?? '',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ).animate().fadeIn().slideY(begin: -0.1),
          
          const SizedBox(height: 48),
          
          Text(
            'FCFA',
            style: TextStyle(
              color: isDark ? Colors.white : AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
            decoration: const InputDecoration(
              hintText: '0',
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              filled: false,
            ),
            onChanged: (v) {
              ref.read(sendMoneyStateProvider.notifier).state = ref.read(sendMoneyStateProvider).copyWith(amount: double.tryParse(v) ?? 0);
            },
          ).animate().fadeIn(delay: 100.ms),
          
          const SizedBox(height: 48),
          
          PayamTextField(
            label: context.loc('add_note_optional'),
            hint: 'e.g. Rent share',
            controller: _noteController,
            onChanged: (v) {
              ref.read(sendMoneyStateProvider.notifier).state = ref.read(sendMoneyStateProvider).copyWith(note: v);
            },
          ).animate().fadeIn(delay: 200.ms),
          
          const SizedBox(height: 32),
          
          PayamButton(
            label: context.loc('continue'),
            onPressed: () => _nextStep(state),
          ).animate().fadeIn(delay: 300.ms),
        ],
      ),
    );
  }

  Widget _buildConfirm(state, bool isDark) {
    return SingleChildScrollView(
      key: const ValueKey('step2'),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(Icons.send_rounded, size: 64, color: isDark ? Colors.white : AppColors.primary)
            .animate().scale(curve: Curves.easeOutBack, duration: 500.ms),
          const SizedBox(height: 24),
          Text(
            context.loc('ready_to_send'),
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white60 : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${state.amount} FCFA',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 32),
          
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
                _ConfirmRow(context.loc('to'), state.recipient?.fullName ?? '', isDark),
                const Divider(height: 32),
                _ConfirmRow(context.loc('phone'), state.recipient?.phone ?? '', isDark),
                const Divider(height: 32),
                _ConfirmRow(context.loc('note'), state.note.isEmpty ? 'None' : state.note, isDark),
                const Divider(height: 32),
                _ConfirmRow(context.loc('fee'), '0 FCFA', isDark),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
          
          const SizedBox(height: 32),
          
          PayamButton(
            label: context.loc('send_now'),
            onPressed: () => _nextStep(state),
          ).animate().fadeIn(delay: 400.ms),
        ],
      ),
    );
  }
}

class _ConfirmRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;
  const _ConfirmRow(this.label, this.value, this.isDark);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.white60 : AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
