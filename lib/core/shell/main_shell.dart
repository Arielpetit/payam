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
        color: isDark ? const Color(0xFF0A0A0A) : Colors.white,
        border: isDark 
            ? Border(top: BorderSide(color: const Color(0xFF1A1A1A), width: 0.5))
            : Border(top: BorderSide(color: AppColors.border.withOpacity(0.5), width: 0.5)),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 16,
                  offset: const Offset(0, -2),
                ),
              ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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
                icon: Icons.qr_code_scanner_rounded,
                label: 'Scan',
                isActive: currentIndex == 1,
                isDark: isDark,
                onTap: () {
                  ref.read(currentNavIndexProvider.notifier).state = 1;
                  context.push('/merchant');
                },
              ),
              _NavItem(
                icon: Icons.receipt_long_rounded,
                label: 'History',
                isActive: currentIndex == 2,
                isDark: isDark,
                onTap: () {
                  ref.read(currentNavIndexProvider.notifier).state = 2;
                  context.go('/transactions');
                },
              ),
              _NavItem(
                icon: Icons.person_rounded,
                label: 'Profile',
                isActive: currentIndex == 3,
                isDark: isDark,
                onTap: () {
                  ref.read(currentNavIndexProvider.notifier).state = 3;
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
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isActive 
                ? (isDark ? AppColors.primary.withOpacity(0.15) : AppColors.primary.withOpacity(0.1))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 24,
                color: isActive 
                    ? AppColors.primary
                    : (isDark ? Colors.white : Colors.black),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  color: isActive 
                      ? AppColors.primary
                      : (isDark ? Colors.white : Colors.black),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}