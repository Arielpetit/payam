import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/providers/app_providers.dart';

class MainShell extends ConsumerWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(currentNavIndexProvider);

    return Scaffold(
      body: child,
      bottomNavigationBar: _PayamBottomNav(currentIndex: currentIndex),
    );
  }
}

class _PayamBottomNav extends ConsumerWidget {
  final int currentIndex;
  const _PayamBottomNav({required this.currentIndex});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        border: isDark ? Border(top: BorderSide(color: AppColors.darkBorder, width: 0.5)) : null,
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_rounded,
                label: 'Home',
                isActive: currentIndex == 0,
                isDark: isDark,
                onTap: () {
                  ref.read(currentNavIndexProvider.notifier).state = 0;
                  context.go('/home');
                },
              ),
              _NavItem(
                icon: Icons.account_balance_wallet_rounded,
                label: 'Wallet',
                isActive: currentIndex == 1,
                isDark: isDark,
                onTap: () {
                  ref.read(currentNavIndexProvider.notifier).state = 1;
                  context.go('/wallet');
                },
              ),
              _ScanButton(
                isDark: isDark,
                onTap: () => context.push('/merchant'),
              ),
              _NavItem(
                icon: Icons.receipt_long_rounded,
                label: 'History',
                isActive: currentIndex == 3,
                isDark: isDark,
                onTap: () {
                  ref.read(currentNavIndexProvider.notifier).state = 3;
                  context.go('/transactions');
                },
              ),
              _NavItem(
                icon: Icons.person_rounded,
                label: 'Profile',
                isActive: currentIndex == 4,
                isDark: isDark,
                onTap: () {
                  ref.read(currentNavIndexProvider.notifier).state = 4;
                  context.go('/profile');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final bool isDark;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = isDark ? AppColors.primaryLight : AppColors.primary;
    final inactiveColor = isDark ? AppColors.darkTextHint : AppColors.textHint;
    final activeBgColor = isDark ? AppColors.primary.withOpacity(0.15) : AppColors.primarySurface;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? activeBgColor : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isActive ? activeColor : inactiveColor,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScanButton extends StatelessWidget {
  final bool isDark;
  final VoidCallback onTap;
  const _ScanButton({required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [AppColors.primaryLight, AppColors.primary]
                : [AppColors.primary, AppColors.primaryDark],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isDark ? null : AppColors.primaryShadow,
        ),
        child: const Icon(
          Icons.qr_code_scanner_rounded,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }
}