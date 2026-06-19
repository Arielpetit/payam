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
import '../../../shared/models/transaction_model.dart';
import '../../../shared/models/notification_model.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/repositories/mock_repository.dart';

class SendMoneyScreen extends ConsumerStatefulWidget {
  const SendMoneyScreen({super.key});

  @override
  ConsumerState<SendMoneyScreen> createState() => _SendMoneyScreenState();
}

class _SendMoneyScreenState extends ConsumerState<SendMoneyScreen> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _searchController = TextEditingController();
  int _currentStep = 0; // 0 = select recipient, 1 = amount, 2 = confirm
  bool _isManualEntry = false;
  String _manualAccountId = '';
  String _manualRecipientName = '';
  bool _isKnownContact = true;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _selectContact(UserModel contact) {
    setState(() {
      _isManualEntry = false;
      _isKnownContact = true;
    });
    ref.read(sendMoneyStateProvider.notifier).state = ref.read(sendMoneyStateProvider).copyWith(recipient: contact);
    _nextStep(ref.read(sendMoneyStateProvider));
  }

  void _selectManualEntry() {
    setState(() {
      _isManualEntry = true;
      _isKnownContact = false;
    });
    // Create a temporary UserModel for the manual entry
    final tempRecipient = UserModel(
      id: 'manual_${DateTime.now().millisecondsSinceEpoch}',
      fullName: _manualRecipientName.isNotEmpty ? _manualRecipientName : _manualAccountId,
      phone: _manualAccountId,
      email: '',
      balance: 0,
      accountNumber: _manualAccountId,
      isVerified: false,
    );
    ref.read(sendMoneyStateProvider.notifier).state = ref.read(sendMoneyStateProvider).copyWith(recipient: tempRecipient);
    _nextStep(ref.read(sendMoneyStateProvider));
  }

  void _nextStep(SendMoneyState state) {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
    } else {
      _executeTransaction(state);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      context.pop();
    }
  }

  void _executeTransaction(SendMoneyState state) async {
    final transaction = TransactionModel(
      id: 'txn_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Transfer Sent',
      subtitle: 'To: ${state.recipient?.fullName ?? _manualAccountId}',
      amount: state.amount,
      isCredit: false,
      type: TransactionType.send,
      status: TransactionStatus.success,
      date: DateTime.now(),
      reference: 'PAY${DateTime.now().millisecondsSinceEpoch}',
      recipientName: state.recipient?.fullName ?? _manualRecipientName,
      recipientPhone: state.recipient?.phone ?? _manualAccountId,
      note: state.note,
    );

    MockRepository.instance.addTransaction(transaction);

    final notification = NotificationModel(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Transfer Sent',
      message: 'You successfully sent FCFA ${CurrencyFormatter.format(state.amount)} to ${state.recipient?.fullName ?? _manualAccountId}.',
      category: NotificationCategory.transaction,
      isRead: false,
      date: DateTime.now(),
    );
    MockRepository.instance.addNotification(notification);

    ref.read(userProvider.notifier).state = MockRepository.instance.currentUser;
    ref.read(transactionsProvider.notifier).state = [...MockRepository.instance.transactions];
    ref.read(notificationsProvider.notifier).state = [...MockRepository.instance.notifications];
    ref.read(sendMoneyStateProvider.notifier).state = const SendMoneyState();

    // Capture data before navigating (state is already reset)
    final recipientName = state.recipient?.fullName ?? _manualRecipientName;
    final recipientPhone = state.recipient?.phone ?? _manualAccountId;
    final recipientId = state.recipient?.id;
    final wasKnownContact = _isKnownContact;

    // Navigate to success page
    context.go('/transaction-success', extra: {
      'title': context.loc('send_success_msg'),
      'subtitle': 'Sent to $recipientName',
      'amount': 'FCFA ${CurrencyFormatter.format(state.amount)}',
      'icon': Icons.send_rounded,
      'recipientName': recipientName,
      'recipientPhone': recipientPhone,
      'recipientId': recipientId,
      'isKnownContact': wasKnownContact,
      'transactionType': TransactionType.send,
      'reference': 'PAY${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
      'paymentMethod': 'Payam Wallet',
      'fee': '0 FCFA',
    });
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
          onPressed: _prevStep,
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _buildCurrentStep(contacts, state, isDark),
      ),
    );
  }

  Widget _buildCurrentStep(contacts, SendMoneyState state, bool isDark) {
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

  Widget _buildSelectRecipient(List<UserModel> contacts, bool isDark) {
    final filteredContacts = _searchController.text.isEmpty
        ? contacts
        : contacts.where((c) =>
            c.fullName.toLowerCase().contains(_searchController.text.toLowerCase()) ||
            c.phone.contains(_searchController.text) ||
            c.accountNumber.contains(_searchController.text)).toList();

    return Column(
      key: const ValueKey('step0'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Send Money',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter an account ID or search your contacts',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white60 : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              // Search / Account ID field
              Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.border,
                    width: 1.5,
                  ),
                  boxShadow: isDark ? null : AppColors.shadowSm,
                ),
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Account ID, phone, or name',
                    hintStyle: TextStyle(
                      color: isDark ? Colors.white24 : AppColors.textHint,
                      fontSize: 16,
                    ),
                    prefixIcon: Icon(Icons.search_rounded, color: isDark ? Colors.white38 : AppColors.textHint),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  onChanged: (v) => setState(() {}),
                ),
              ),
            ],
          ),
        ).animate().fadeIn().slideY(begin: 0.1),

        // Manual entry "Send to this account" button
        if (_searchController.text.isNotEmpty && filteredContacts.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurfaceVariant : AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.5),
                      width: 1.5,
                    ),
                    boxShadow: isDark ? null : AppColors.cardShadow,
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(isDark ? 0.2 : 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: isDark ? Border.all(color: AppColors.primary.withOpacity(0.3)) : null,
                        ),
                        child: Icon(Icons.person_add_rounded, size: 26, color: AppColors.primary),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Send to this account',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _searchController.text,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white54 : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            _manualAccountId = _searchController.text;
                            _manualRecipientName = '';
                            _selectManualEntry();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            elevation: 0,
                          ),
                          child: const Text('Continue', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
              ],
            ),
          ),

        if (filteredContacts.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              context.loc('recent_contacts'),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: isDark ? Colors.white60 : AppColors.textSecondary,
                letterSpacing: 0.3,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: filteredContacts.length,
              itemBuilder: (context, i) {
                final contact = filteredContacts[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurfaceVariant : AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: isDark ? Border.all(color: AppColors.darkBorder, width: 0.5) : null,
                    boxShadow: isDark ? null : AppColors.cardShadow,
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    leading: UserAvatar(user: contact),
                    title: Text(
                      contact.fullName,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      contact.phone,
                      style: TextStyle(
                        color: isDark ? Colors.white54 : AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    trailing: Icon(Icons.chevron_right_rounded, color: isDark ? Colors.white24 : AppColors.textHint),
                    onTap: () => _selectContact(contact),
                  ),
                ).animate().fadeIn(delay: Duration(milliseconds: 100 + (i * 50)));
              },
            ),
          ),
        ] else if (_searchController.text.isEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              context.loc('recent_contacts'),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: isDark ? Colors.white60 : AppColors.textSecondary,
                letterSpacing: 0.3,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: contacts.length,
              itemBuilder: (context, i) {
                final contact = contacts[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurfaceVariant : AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: isDark ? Border.all(color: AppColors.darkBorder, width: 0.5) : null,
                    boxShadow: isDark ? null : AppColors.cardShadow,
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    leading: UserAvatar(user: contact),
                    title: Text(
                      contact.fullName,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      contact.phone,
                      style: TextStyle(
                        color: isDark ? Colors.white54 : AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    trailing: Icon(Icons.chevron_right_rounded, color: isDark ? Colors.white24 : AppColors.textHint),
                    onTap: () => _selectContact(contact),
                  ),
                ).animate().fadeIn(delay: Duration(milliseconds: 100 + (i * 50)));
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAmount(SendMoneyState state, bool isDark) {
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
                    state.recipient?.fullName ?? _manualAccountId,
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
            onPressed: state.amount > 0 ? () => _nextStep(state) : null,
          ).animate().fadeIn(delay: 300.ms),
        ],
      ),
    );
  }

  Widget _buildConfirm(SendMoneyState state, bool isDark) {
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
                _ConfirmRow(context.loc('to'), state.recipient?.fullName ?? _manualAccountId, isDark),
                const Divider(height: 32),
                _ConfirmRow(context.loc('phone'), state.recipient?.phone ?? _manualAccountId, isDark),
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
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}