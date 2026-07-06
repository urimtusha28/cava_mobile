import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/onboarding_content.dart';
import '../../data/onboarding_storage.dart';
import '../../domain/entities/onboarding_page.dart';
import '../widgets/onboarding_footer.dart';
import '../widgets/onboarding_page_view.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final PageController _pageController;
  int _page = 0;
  double _pageProgress = 0;

  List<OnboardingPage> get _pages => OnboardingContent.pages;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    _pageController = PageController();
    _pageController.addListener(() {
      if (!_pageController.hasClients) return;
      final page = _pageController.page ?? _page.toDouble();
      setState(() => _pageProgress = page - page.floor());
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool get _isLastPage => _page == _pages.length - 1;

  Future<void> _finish() async {
    await OnboardingStorage.markComplete();
    if (!mounted) return;
    context.go(AppRoutes.home);
  }

  void _next() {
    if (_isLastPage) {
      _finish();
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 480),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screen,
                AppSpacing.sm,
                AppSpacing.screen,
                0,
              ),
              child: Align(
                alignment: Alignment.centerRight,
                child: OnboardingSkipButton(onPressed: _finish),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) => setState(() => _page = index),
                itemBuilder: (context, index) {
                  return AnimatedBuilder(
                    animation: _pageController,
                    builder: (context, child) {
                      double offset = 0;
                      if (_pageController.position.haveDimensions) {
                        offset =
                            (_pageController.page ?? index.toDouble()) - index;
                      }
                      return OnboardingPageView(
                        page: _pages[index],
                        isActive: _page == index,
                        pageOffset: offset,
                      );
                    },
                  );
                },
              ),
            ),
            OnboardingFooter(
              pageCount: _pages.length,
              currentIndex: _page,
              pageProgress: _pageProgress,
              isLastPage: _isLastPage,
              onNext: _next,
            ),
          ],
        ),
      ),
    );
  }
}
