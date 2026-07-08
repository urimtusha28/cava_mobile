import 'package:cava_ecommerce/core/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> pumpTestRouter(WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp.router(
      routerConfig: appRouter,
    ),
  );
  await tester.pumpAndSettle();
}

