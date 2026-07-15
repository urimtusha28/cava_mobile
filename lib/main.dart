import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:cava_ecommerce/l10n/app_localizations.dart';

import 'core/firebase/firebase_initializer.dart';
import 'core/locale/locale_controller.dart';
import 'core/locale/locale_scope.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'firebase_options.dart';

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  await FirebaseInitializer.initialize(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final localeController = LocaleController();
  await localeController.load();

  runApp(CavaPremiumApp(localeController: localeController));
}

class CavaPremiumApp extends StatelessWidget {
  const CavaPremiumApp({super.key, required this.localeController});

  final LocaleController localeController;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: localeController,
      builder: (context, _) {
        return MaterialApp.router(
          title: 'Cava Premium',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          routerConfig: appRouter,
          locale: localeController.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          localeResolutionCallback: (locale, supported) {
            if (locale == null) return LocaleController.defaultLocale;
            for (final supportedLocale in supported) {
              if (supportedLocale.languageCode == locale.languageCode) {
                return supportedLocale;
              }
            }
            return LocaleController.defaultLocale;
          },
          builder: (context, child) {
            return LocaleScope(
              controller: localeController,
              child: child ?? const SizedBox.shrink(),
            );
          },
        );
      },
    );
  }
}
