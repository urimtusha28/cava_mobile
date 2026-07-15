import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
    configureDependencies();
    final authController = createAuthController();
    await authController.load();
    ensureNotificationsBadgeListening();
    if (!mounted) return;
    context.go(PostAuthNavigator.homeLocationForCurrentSession());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.burgundyDark,
              AppColors.burgundy,
              const Color(0xFF7A2433),
            ],
            stops: const [0, 0.55, 1],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                'assets/icons/logo.svg',
                width: 88,
                height: 88,
              ),
              const SizedBox(height: 20),
              Text(
                'Cava Premium',
                style: TextStyle(
                  color: const Color(0xFFF1EAE2),
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                  fontFamily: 'DMSans',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
