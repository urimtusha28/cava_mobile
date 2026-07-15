import 'package:cava_ecommerce/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

const _localizationsDelegates = <LocalizationsDelegate<dynamic>>[
  AppLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

/// Wraps [home] (or a router) with MaterialApp + Albanian AppLocalizations.
Widget testApp({
  Widget? home,
  RouterConfig<Object>? routerConfig,
  Locale locale = const Locale('sq'),
}) {
  assert(
    (home != null) ^ (routerConfig != null),
    'Provide exactly one of home or routerConfig',
  );

  if (routerConfig != null) {
    return MaterialApp.router(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: _localizationsDelegates,
      routerConfig: routerConfig,
    );
  }

  return MaterialApp(
    locale: locale,
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: _localizationsDelegates,
    home: home,
  );
}

Future<void> pumpTestApp(
  WidgetTester tester, {
  Widget? home,
  RouterConfig<Object>? routerConfig,
  Locale locale = const Locale('sq'),
}) {
  return tester.pumpWidget(
    testApp(home: home, routerConfig: routerConfig, locale: locale),
  );
}
