import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/widgets/payam_button.dart';
import '../../../shared/models/transaction_model.dart';
import '../../../shared/repositories/mock_repository.dart';

class TopupScreen extends ConsumerStatefulWidget {
  const TopupScreen({super.key});

  @override
  ConsumerState<TopupScreen> createState() => _TopupScreenState();
}

class _TopupScreenState extends ConsumerState<TopupScreen> {
  int _step = 0;
  String _selectedProvider = '';
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_step == 0 && _selectedProvider.isEmpty) return;
    if (_step == 1 && _phoneController.text.length < 9) return;
    setState(() => _step++);
  }

  void _prevStep() {
    if (_step > 0) {
      setState(() => _step--);
    } else {
      context.pop();
    }
  }

  Future<void> _processTopup() async {
    if (_amountController.text.isEmpty) return;
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount < 100) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      final user = ref.read(userProvider);
      final updatedUser = user.copyWith(balance: user.balance + amount);
      ref.read(userProvider.notifier).state = updatedUser;
      ref.read(transactionsProvider.notifier).state = [...ref.read(transactionsProvider)];

      final providerLabel = _selectedProvider == 'bank'
          ? 'Bank Transfer'
          : (_selectedProvider == 'mtn' ? 'MTN MoMo' : 'Orange Money');

      // Add transaction
      final transaction = TransactionModel(
        id: 'txn_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Top Up',
        subtitle: '$providerLabel top up',
        amount: amount,
        isCredit: true,
        type: TransactionType.deposit,
        status: TransactionStatus.success,
        date: DateTime.now(),
        reference: 'PAY${DateTime.now().millisecondsSinceEpoch}',
      );
      MockRepository.instance.addTransaction(transaction);
      ref.read(transactionsProvider.notifier).state = [...MockRepository.instance.transactions];

      setState(() => _isLoading = false);

      context.go('/transaction-success', extra: {
        'title': 'Top Up Successful',
        'subtitle': '$providerLabel top up completed',
        'amount': 'FCFA ${CurrencyFormatter.format(amount)}',
        'icon': Icons.account_balance_wallet_rounded,
        'isKnownContact': true,
        'transactionType': TransactionType.deposit,
        'reference': 'PAY${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
        'paymentMethod': providerLabel,
        'fee': '0 FCFA',
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(userProvider);

    return Stack(
      children: [
        Scaffold(
          backgroundColor: isDark ? Colors.black : AppColors.background,
          appBar: AppBar(
            title: Text(
              _step == 0 ? 'Select Provider' : _step == 1 ? 'Phone Number' : 'Enter Amount',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 20,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
              onPressed: _prevStep,
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _step == 0
                    ? _buildProviderStep(isDark)
                    : _step == 1
                        ? _buildPhoneStep(isDark)
                        : _buildAmountStep(isDark, user),
              ),
            ),
          ),
        ),

        if (_isLoading)
          Container(
            color: isDark ? Colors.black.withOpacity(0.9) : Colors.white.withOpacity(0.95),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Processing top up...',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please wait',
                    style: TextStyle(
                      fontSize: 15,
                      color: isDark ? Colors.white60 : AppColors.textSecondary,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProviderStep(bool isDark) {
    return Column(
      key: const ValueKey('provider'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),

        Text(
          'Choose your mobile money provider',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ).animate().fadeIn(delay: 100.ms),

        const SizedBox(height: 8),

        Text(
          'Select the provider you want to top up from',
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.white60 : AppColors.textSecondary,
          ),
        ).animate().fadeIn(delay: 150.ms),

        const SizedBox(height: 24),

        _ProviderCard(
          name: 'Bank Transfer',
          imagePath: 'assets/images/bank.png',
          subtitle: 'Afriland First Bank, UBA, BGFI Bank',
          isSelected: _selectedProvider == 'bank',
          isDark: isDark,
          onTap: () => setState(() => _selectedProvider = 'bank'),
        ).animate().fadeIn(delay: 100.ms).slideX(begin: 0.1, end: 0),

        const SizedBox(height: 16),

        _ProviderCard(
          name: 'MTN MoMo',
          imagePath: 'assets/images/MoMo1.png',
          subtitle: 'Mobile Money by MTN',
          isSelected: _selectedProvider == 'mtn',
          isDark: isDark,
          onTap: () => setState(() => _selectedProvider = 'mtn'),
        ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.1, end: 0),

        const SizedBox(height: 16),

        _ProviderCard(
          name: 'Orange Money',
          imagePath: 'assets/images/orange-money.jpg',
          subtitle: 'Mobile Money by Orange',
          isSelected: _selectedProvider == 'orange',
          isDark: isDark,
          onTap: () => setState(() => _selectedProvider = 'orange'),
        ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.1, end: 0),

        const SizedBox(height: 32),

        PayamButton(
          label: 'Continue',
          onPressed: _selectedProvider.isEmpty ? null : _nextStep,
          isLoading: false,
        ).animate().fadeIn(delay: 400.ms),

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildPhoneStep(bool isDark) {
    return Column(
      key: const ValueKey('phone'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),

        _StepIndicator(currentStep: 1, totalSteps: 3, isDark: isDark),

        const SizedBox(height: 24),

        Container(
          width: 64,
          height: 64,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? AppColors.primary.withOpacity(0.15) : AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            Icons.phone_android_rounded,
            color: AppColors.primary,
            size: 28,
          ),
        ).animate().fadeIn().scale(begin: Offset(0.5, 0.5), end: Offset(1, 1)),

        const SizedBox(height: 20),

        Text(
          'Enter your phone number',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : AppColors.textPrimary,
            height: 1.2,
          ),
        ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2, end: 0),

        const SizedBox(height: 8),

        Text(
          'We\'ll send a confirmation to this number',
          style: TextStyle(
            fontSize: 15,
            color: isDark ? Colors.white60 : AppColors.textSecondary,
          ),
        ).animate().fadeIn(delay: 150.ms),

        const SizedBox(height: 32),

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
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '🇨🇲',
                      style: TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '+237',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 24,
                color: isDark ? Colors.white10 : AppColors.border,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(9),
                  ],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: '6 XX XXX XXX',
                    hintStyle: TextStyle(
                      color: isDark ? Colors.white24 : AppColors.textHint,
                      fontSize: 16,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 16),
            ],
          ),
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.15, end: 0),

        const SizedBox(height: 32),

        PayamButton(
          label: 'Continue',
          onPressed: _phoneController.text.length >= 9 ? _nextStep : null,
        ).animate().fadeIn(delay: 300.ms),

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildAmountStep(bool isDark, dynamic user) {
    final quickAmounts = [1000, 2000, 5000, 10000, 20000, 50000];

    return Column(
      key: const ValueKey('amount'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),

        _StepIndicator(currentStep: 2, totalSteps: 3, isDark: isDark),

        const SizedBox(height: 24),

        Container(
          width: 64,
          height: 64,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? AppColors.primary.withOpacity(0.15) : AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            Icons.account_balance_wallet_rounded,
            color: AppColors.primary,
            size: 28,
          ),
        ).animate().fadeIn().scale(begin: Offset(0.5, 0.5), end: Offset(1, 1)),

        const SizedBox(height: 20),

        Text(
          'Enter amount',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : AppColors.textPrimary,
            height: 1.2,
          ),
        ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2, end: 0),

        const SizedBox(height: 8),

        Text(
          'Top up via ${_selectedProvider == 'bank' ? 'Bank Transfer' : (_selectedProvider == 'mtn' ? 'MTN MoMo' : 'Orange Money')}',
          style: TextStyle(
            fontSize: 15,
            color: isDark ? Colors.white60 : AppColors.textSecondary,
          ),
        ).animate().fadeIn(delay: 150.ms),

        const SizedBox(height: 28),

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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: [
              Text(
                'XAF',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white60 : AppColors.textSecondary,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 4),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                  height: 1.1,
                ),
                decoration: InputDecoration(
                  hintText: '0',
                  hintStyle: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white12 : AppColors.textHint,
                    height: 1.1,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (_) => setState(() {}),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.15, end: 0),

        const SizedBox(height: 20),

        Text(
          'Quick amounts',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white60 : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 10),

        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: quickAmounts.map((amount) {
            final isSelected = _amountController.text == amount.toString();
            return GestureDetector(
              onTap: () {
                setState(() {
                  _amountController.text = amount.toString();
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : (isDark ? const Color(0xFF1A1A1A) : Colors.white),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : (isDark ? AppColors.darkBorder : AppColors.border),
                    width: isSelected ? 1.5 : 1,
                  ),
                  boxShadow: isSelected ? AppColors.primaryShadow : null,
                ),
                child: Text(
                  CurrencyFormatter.formatCompact(amount.toDouble()),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? Colors.white
                        : (isDark ? Colors.white70 : AppColors.textPrimary),
                  ),
                ),
              ),
            );
          }).toList(),
        ).animate().fadeIn(delay: 250.ms),

        const SizedBox(height: 28),

        PayamButton(
          label: 'Top Up ${_selectedProvider == 'bank' ? 'Bank Transfer' : (_selectedProvider == 'mtn' ? 'MTN MoMo' : 'Orange Money')}',
          onPressed: _amountController.text.isNotEmpty ? _processTopup : null,
          icon: Icons.arrow_forward_rounded,
        ).animate().fadeIn(delay: 350.ms),

        const SizedBox(height: 24),
      ],
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final bool isDark;

  const _StepIndicator({
    required this.currentStep,
    required this.totalSteps,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (index) {
        final isCompleted = index < currentStep;
        final isCurrent = index == currentStep;
        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(right: index < totalSteps - 1 ? 8 : 0),
            decoration: BoxDecoration(
              color: isCompleted || isCurrent
                  ? AppColors.primary
                  : (isDark ? Colors.white12 : AppColors.border),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}

class _ProviderCard extends StatelessWidget {
  final String name;
  final String imagePath;
  final String subtitle;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _ProviderCard({
    required this.name,
    required this.imagePath,
    required this.subtitle,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.primary.withOpacity(0.12) : AppColors.primarySurface)
              : (isDark ? const Color(0xFF1A1A1A) : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : (isDark ? AppColors.darkBorder : AppColors.border),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? (isDark ? null : [BoxShadow(color: AppColors.primary.withOpacity(0.15), blurRadius: 12, offset: Offset(0, 4))])
              : (isDark ? null : AppColors.shadowSm),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 52,
                height: 52,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2A2A2A) : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2A2A2A) : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.account_balance_wallet_rounded,
                      color: isSelected ? AppColors.primary : (isDark ? Colors.white54 : AppColors.textSecondary),
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? AppColors.primary
                          : (isDark ? Colors.white : AppColors.textPrimary),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white54 : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppColors.primary : (isDark ? Colors.white24 : AppColors.border),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Icon(Icons.check_rounded, size: 16, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}