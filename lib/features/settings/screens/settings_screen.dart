import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/providers/hce_payment_provider.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/widgets/payam_button.dart';
import '../../../shared/widgets/payam_text_field.dart';
import '../../debug/screens/nfc_debug_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _pushEnabled = true;
  bool _emailEnabled = false;
  bool _biometricEnabled = true;

  void _showLanguageSelector(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF121212) : AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.loc('language'),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Text('🇺🇸', style: TextStyle(fontSize: 24)),
                  title: Text(
                    'English',
                    style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary),
                  ),
                  trailing: ref.read(localeProvider).languageCode == 'en'
                      ? Icon(Icons.check, color: isDark ? Colors.white : AppColors.primary)
                      : null,
                  onTap: () {
                    ref.read(localeProvider.notifier).state = const Locale('en');
                    Navigator.pop(context);
                  },
                ),
                Divider(color: isDark ? const Color(0xFF2D2D2D) : AppColors.border),
                ListTile(
                  leading: const Text('🇫🇷', style: TextStyle(fontSize: 24)),
                  title: Text(
                    'Français',
                    style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary),
                  ),
                  trailing: ref.read(localeProvider).languageCode == 'fr'
                      ? Icon(Icons.check, color: isDark ? Colors.white : AppColors.primary)
                      : null,
                  onTap: () {
                    ref.read(localeProvider.notifier).state = const Locale('fr');
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showNfcInfoDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF121212) : AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.nfc_rounded, color: AppColors.primary),
            const SizedBox(width: 12),
            Text(
              'NFC Payments',
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNfcInfoStep('1', 'Sender enters amount', isDark),
            const SizedBox(height: 12),
            _buildNfcInfoStep('2', 'Phones tap together (< 4cm)', isDark),
            const SizedBox(height: 12),
            _buildNfcInfoStep('3', 'Payment transfers instantly', isDark),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.info.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.info, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Enable Auto-receive to accept payments without opening the receive screen.',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white70 : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Got it',
              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNfcInfoStep(String number, String text, bool isDark) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: TextStyle(
            fontSize: 15,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  void _showChangePinSheet(BuildContext context, bool isDark) {
    final currentPinController = TextEditingController();
    final newPinController = TextEditingController();
    final confirmPinController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF121212) : AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
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
                Text(
                  context.loc('change_pin'),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 20),
                PayamTextField(
                  label: 'Current PIN',
                  hint: '••••',
                  obscureText: true,
                  controller: currentPinController,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  validator: (v) => (v == null || v.length < 4) ? 'Enter 4-digit PIN' : null,
                ),
                const SizedBox(height: 16),
                PayamTextField(
                  label: 'New PIN',
                  hint: '••••',
                  obscureText: true,
                  controller: newPinController,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  validator: (v) => (v == null || v.length < 4) ? 'Enter 4-digit PIN' : null,
                ),
                const SizedBox(height: 16),
                PayamTextField(
                  label: 'Confirm New PIN',
                  hint: '••••',
                  obscureText: true,
                  controller: confirmPinController,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  validator: (v) {
                    if (v != newPinController.text) return 'PINs do not match';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                PayamButton(
                  label: 'Save PIN',
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('PIN changed successfully'),
                          backgroundColor: isDark ? Colors.white : AppColors.primary,
                        ),
                      );
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
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final locale = ref.watch(localeProvider);

    return Scaffold(
      backgroundColor: isDark ? Colors.black : AppColors.background,
      appBar: AppBar(
        title: Text(context.loc('settings')),
        backgroundColor: isDark ? Colors.black : AppColors.background,
        iconTheme: IconThemeData(color: isDark ? Colors.white : AppColors.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle(context.loc('preferences'), isDark),
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF121212) : AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: isDark ? Border.all(color: const Color(0xFF1E1E1E)) : null,
                boxShadow: isDark ? null : AppColors.cardShadow,
              ),
              child: Column(
                children: [
                  _SettingsSwitch(
                    title: context.loc('dark_mode'),
                    icon: Icons.dark_mode_rounded,
                    value: isDark,
                    isDark: isDark,
                    onChanged: (v) {
                      ref.read(themeModeProvider.notifier).state =
                          v ? ThemeMode.dark : ThemeMode.light;
                    },
                  ),
                  Divider(height: 1, indent: 56, color: isDark ? const Color(0xFF1E1E1E) : AppColors.border),
                  _SettingsTile(
                    title: context.loc('language'),
                    subtitle: locale.languageCode == 'fr' ? 'Français' : 'English',
                    icon: Icons.language_rounded,
                    isDark: isDark,
                    onTap: () => _showLanguageSelector(context, isDark),
                  ),
                ],
              ),
            ).animate().fadeIn().slideY(begin: 0.1),
            
            const SizedBox(height: 32),
            _SectionTitle(context.loc('security'), isDark),
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF121212) : AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: isDark ? Border.all(color: const Color(0xFF1E1E1E)) : null,
                boxShadow: isDark ? null : AppColors.cardShadow,
              ),
              child: Column(
                children: [
                  _SettingsTile(
                    title: context.loc('change_pin'),
                    icon: Icons.password_rounded,
                    isDark: isDark,
                    onTap: () => _showChangePinSheet(context, isDark),
                  ),
                  Divider(height: 1, indent: 56, color: isDark ? const Color(0xFF1E1E1E) : AppColors.border),
                  _SettingsSwitch(
                    title: context.loc('biometrics'),
                    icon: Icons.fingerprint_rounded,
                    value: _biometricEnabled,
                    isDark: isDark,
                    onChanged: (v) => setState(() => _biometricEnabled = v),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),

            const SizedBox(height: 32),
            _SectionTitle('NFC Payments', isDark),
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF121212) : AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: isDark ? Border.all(color: const Color(0xFF1E1E1E)) : null,
                boxShadow: isDark ? null : AppColors.cardShadow,
              ),
              child: Column(
                children: [
_SettingsTile(
                    title: 'NFC Auto-Receive',
                    subtitle: 'Always enabled - receive payments instantly',
                    icon: Icons.nfc_rounded,
                    isDark: isDark,
                    onTap: () {
                      // No action - always on
                    },
                  ),
                  Divider(height: 1, indent: 56, color: isDark ? const Color(0xFF1E1E1E) : AppColors.border),
                  _SettingsTile(
                    title: 'How NFC payments work',
                    subtitle: 'Learn about tap-to-pay',
                    icon: Icons.help_outline_rounded,
                    isDark: isDark,
                    onTap: () => _showNfcInfoDialog(context, isDark),
                  ),
                  Divider(height: 1, indent: 56, color: isDark ? const Color(0xFF1E1E1E) : AppColors.border),
                  _SettingsTile(
                    title: 'NFC Debug Logs',
                    subtitle: 'View NFC communication logs',
                    icon: Icons.bug_report_rounded,
                    isDark: isDark,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const NfcDebugScreen()),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.1),

            const SizedBox(height: 32),
            _SectionTitle(context.loc('notifications'), isDark),
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF121212) : AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: isDark ? Border.all(color: const Color(0xFF1E1E1E)) : null,
                boxShadow: isDark ? null : AppColors.cardShadow,
              ),
              child: Column(
                children: [
                  _SettingsSwitch(
                    title: context.loc('push_notifications'),
                    icon: Icons.notifications_rounded,
                    value: _pushEnabled,
                    isDark: isDark,
                    onChanged: (v) => setState(() => _pushEnabled = v),
                  ),
                  Divider(height: 1, indent: 56, color: isDark ? const Color(0xFF1E1E1E) : AppColors.border),
                  _SettingsSwitch(
                    title: context.loc('email_notifications'),
                    icon: Icons.email_rounded,
                    value: _emailEnabled,
                    isDark: isDark,
                    onChanged: (v) => setState(() => _emailEnabled = v),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
            
            const SizedBox(height: 32),
            _SectionTitle(context.loc('about'), isDark),
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF121212) : AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: isDark ? Border.all(color: const Color(0xFF1E1E1E)) : null,
                boxShadow: isDark ? null : AppColors.cardShadow,
              ),
              child: Column(
                children: [
                  _SettingsTile(
                    title: context.loc('terms_of_service'),
                    icon: Icons.description_rounded,
                    isDark: isDark,
                    onTap: () {},
                  ),
                  Divider(height: 1, indent: 56, color: isDark ? const Color(0xFF1E1E1E) : AppColors.border),
                  _SettingsTile(
                    title: context.loc('privacy_policy'),
                    icon: Icons.privacy_tip_rounded,
                    isDark: isDark,
                    onTap: () {},
                  ),
                  Divider(height: 1, indent: 56, color: isDark ? const Color(0xFF1E1E1E) : AppColors.border),
                  _SettingsTile(
                    title: context.loc('app_version'),
                    subtitle: 'v1.0.0 (Build 42)',
                    icon: Icons.info_outline_rounded,
                    isDark: isDark,
                    showArrow: false,
                    onTap: () {},
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
            
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final bool isDark;
  const _SectionTitle(this.title, this.isDark);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.white60 : AppColors.textSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final bool showArrow;
  final bool isDark;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.title,
    this.subtitle,
    required this.icon,
    this.showArrow = true,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isDark ? Colors.white : AppColors.textPrimary,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: isDark ? Colors.white : AppColors.textPrimary,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: TextStyle(
                color: isDark ? Colors.white60 : AppColors.textSecondary,
                fontSize: 13,
              ),
            )
          : null,
      trailing: showArrow
          ? Icon(
              Icons.chevron_right_rounded,
              color: isDark ? Colors.white38 : AppColors.textHint,
            )
          : null,
      onTap: onTap,
    );
  }
}

class _SettingsSwitch extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final bool value;
  final bool isDark;
  final ValueChanged<bool> onChanged;

  const _SettingsSwitch({
    required this.title,
    this.subtitle,
    required this.icon,
    required this.value,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isDark ? Colors.white : AppColors.textPrimary,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: isDark ? Colors.white : AppColors.textPrimary,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: TextStyle(
                color: isDark ? Colors.white60 : AppColors.textSecondary,
                fontSize: 12,
              ),
            )
          : null,
      value: value,
      onChanged: onChanged,
      activeColor: isDark ? Colors.white : AppColors.primary,
    );
  }
}
