import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/post_auth_navigator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../account/presentation/controllers/auth_controller.dart';
import '../../../notifications/presentation/controllers/notifications_unread_notifier.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const _brandColor = Color(0xFFF1EAE2);
  static const _minVisible = Duration(milliseconds: 1200);
  static const _splashImage = 'assets/icons/asd.png';

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      FlutterNativeSplash.remove();
      _navigateWhenReady();
    });
  }

  Future<void> _navigateWhenReady() async {
    final started = DateTime.now();
    configureDependencies();
    final authController = createAuthController();
    await authController.load();
    ensureNotificationsBadgeListening();

    final elapsed = DateTime.now().difference(started);
    final remaining = _minVisible - elapsed;
    if (remaining > Duration.zero) {
      await Future<void>.delayed(remaining);
    }

    if (!mounted) return;
    context.go(PostAuthNavigator.homeLocationForCurrentSession());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.burgundy,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.burgundyDark,
              AppColors.burgundy,
              Color(0xFF7A2433),
            ],
            stops: [0, 0.55, 1],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  _splashImage,
                  width: 120,
                  height: 120,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Cava Premium',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _brandColor,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                    fontFamily: 'DMSans',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
