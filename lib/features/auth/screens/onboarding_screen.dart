import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../shared/widgets/payam_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next(int pageCount) async {
    if (_currentPage < pageCount - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      // Mark onboarding as seen
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_seen_onboarding', true);
      if (mounted) context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _OnboardingData(
        icon: Icons.send_rounded,
        gradient: [AppColors.primary, AppColors.primaryLight],
        title: context.loc('onboarding_title_1'),
        subtitle: context.loc('onboarding_subtitle_1'),
      ),
      _OnboardingData(
        icon: Icons.shield_rounded,
        gradient: [AppColors.secondary, AppColors.secondaryLight],
        title: context.loc('onboarding_title_2'),
        subtitle: context.loc('onboarding_subtitle_2'),
      ),
      _OnboardingData(
        icon: Icons.trending_up_rounded,
        gradient: [AppColors.primaryDark, AppColors.primary],
        title: context.loc('onboarding_title_3'),
        subtitle: context.loc('onboarding_subtitle_3'),
      ),
    ];

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextButton(
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('has_seen_onboarding', true);
                    if (context.mounted) context.go('/login');
                  },
                  child: Text(
                    isDark ? 'SKIP' : 'Skip',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white60 : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: pages.length,
                itemBuilder: (context, i) => _OnboardingPage(data: pages[i]),
              ),
            ),
            // Bottom Section
            Container(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
              child: Column(
                children: [
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: pages.length,
                    effect: ExpandingDotsEffect(
                      activeDotColor: isDark ? Colors.white : AppColors.primary,
                      dotColor: isDark ? Colors.white24 : AppColors.border,
                      dotHeight: 8,
                      dotWidth: 8,
                      expansionFactor: 3,
                    ),
                  ),
                  const SizedBox(height: 32),
                  PayamButton(
                    label: _currentPage == pages.length - 1
                        ? context.loc('get_started')
                        : context.loc('continue'),
                    onPressed: () => _next(pages.length),
                    icon: _currentPage == pages.length - 1
                        ? Icons.arrow_forward_rounded
                        : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final _OnboardingData data;
  const _OnboardingPage({required this.data});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Illustration
          Expanded(
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Decorative background rings
                  Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      color: data.gradient.first.withOpacity(0.05),
                      shape: BoxShape.circle,
                    ),
                  )
                  .animate()
                  .scale(duration: 800.ms, curve: Curves.easeOutBack),
                  
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: data.gradient.first.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                  )
                  .animate()
                  .scale(delay: 100.ms, duration: 800.ms, curve: Curves.easeOutBack),

                  // Main Card Icon container
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: data.gradient,
                      ),
                      borderRadius: BorderRadius.circular(36),
                      boxShadow: [
                        BoxShadow(
                          color: data.gradient.first.withOpacity(isDark ? 0.15 : 0.3),
                          blurRadius: 32,
                          offset: const Offset(0, 16),
                        ),
                      ],
                    ),
                    child: Icon(
                      data.icon,
                      size: 64,
                      color: isDark ? Colors.black : Colors.white,
                    ),
                  )
                  .animate()
                  .scale(
                    begin: const Offset(0.8, 0.8),
                    end: const Offset(1, 1),
                    duration: 600.ms,
                    curve: Curves.elasticOut,
                  )
                  .fadeIn(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Text
          Text(
            data.title,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : AppColors.textPrimary,
              height: 1.2,
              letterSpacing: -0.8,
            ),
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(delay: 150.ms)
              .slideY(begin: 0.2, end: 0, delay: 150.ms, duration: 400.ms),
          const SizedBox(height: 16),
          Text(
            data.subtitle,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white60 : AppColors.textSecondary,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(delay: 250.ms)
              .slideY(begin: 0.2, end: 0, delay: 250.ms, duration: 400.ms),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _OnboardingData {
  final IconData icon;
  final List<Color> gradient;
  final String title;
  final String subtitle;

  const _OnboardingData({
    required this.icon,
    required this.gradient,
    required this.title,
    required this.subtitle,
  });
}
