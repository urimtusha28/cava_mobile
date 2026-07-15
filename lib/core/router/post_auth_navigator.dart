import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../auth/app_session_notifier.dart';
import 'app_routes.dart';

/// Role-based navigation after login/register. No delays, no Home flash.
abstract final class PostAuthNavigator {
  /// Owners go to the owner dashboard immediately.
  /// Customers stay on the current screen (profile/checkout/etc.).
  static void navigateIfOwner(BuildContext context) {
    if (!context.mounted) {
      return;
    }
    if (AppSessionNotifier.instance.isOwner) {
      context.go(AppRoutes.ownerDashboard);
    }
  }

  static String homeLocationForCurrentSession() {
    if (AppSessionNotifier.instance.isOwner) {
      return AppRoutes.ownerDashboard;
    }
    return AppRoutes.home;
  }
}
