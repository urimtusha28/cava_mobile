import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../auth/app_session_notifier.dart';
import 'app_routes.dart';
import 'shell_scaffold.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/categories/presentation/screens/categories_screen.dart';
import '../../features/products/presentation/screens/product_detail_screen.dart';
import '../../features/search/presentation/screens/search_screen.dart';
import '../../features/cart/presentation/screens/cart_screen.dart';
import '../../features/checkout/presentation/screens/checkout_screen.dart';
import '../../features/checkout/presentation/screens/order_success_screen.dart';
import '../../features/checkout/domain/entities/place_order_result_entity.dart';
import '../../features/messages/presentation/screens/messages_screen.dart';
import '../../features/wishlist/presentation/screens/wishlist_screen.dart';
import '../../features/account/presentation/screens/profile_screen.dart';
import '../../features/account/presentation/screens/orders_screen.dart';
import '../../features/account/presentation/screens/addresses_screen.dart';
import '../../features/account/presentation/screens/help_screen.dart';
import '../../features/account/presentation/screens/about_screen.dart';
import '../../features/account/presentation/screens/language_screen.dart';
import '../../features/account/presentation/screens/currency_screen.dart';
import '../../features/account/presentation/screens/terms_screen.dart';
import '../../features/account/presentation/screens/privacy_screen.dart';
import '../../features/onboarding/presentation/screens/splash_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/owner_dashboard/presentation/shell/owner_shell_scaffold.dart';
import '../../features/owner_dashboard/presentation/screens/owner_dashboard_screen.dart';
import '../../features/owner_dashboard/presentation/screens/owner_orders_screen.dart';
import '../../features/owner_dashboard/presentation/screens/owner_analytics_screen.dart';
import '../../features/owner_dashboard/presentation/screens/owner_products_screen.dart';
import '../../features/owner_dashboard/presentation/screens/owner_profile_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'shell');
final GlobalKey<NavigatorState> _ownerShellNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'ownerShell');

String? _roleRedirect(GoRouterState state) {
  final path = state.matchedLocation;
  if (path == '/') {
    return AppRoutes.splash;
  }

  // Customers (and guests) must not open owner routes.
  if (AppRoutes.isOwnerPath(path) && !AppSessionNotifier.instance.isOwner) {
    return AppRoutes.home;
  }

  return null;
}

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: AppRoutes.splash,
  refreshListenable: AppSessionNotifier.instance,
  redirect: (context, state) => _roleRedirect(state),
  routes: [
    GoRoute(path: '/', redirect: (_, _) => AppRoutes.splash),
    GoRoute(
      path: AppRoutes.splash,
      pageBuilder: (context, state) => NoTransitionPage(
        key: state.pageKey,
        child: const SplashScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.onboarding,
      pageBuilder: (context, state) => NoTransitionPage(
        key: state.pageKey,
        child: const OnboardingScreen(),
      ),
    ),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return ShellScaffold(
          location: state.matchedLocation,
          child: child,
        );
      },
      routes: [
        GoRoute(
          path: AppRoutes.home,
          pageBuilder: (context, state) => NoTransitionPage(
            key: state.pageKey,
            child: const HomeScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.wishlist,
          pageBuilder: (context, state) => NoTransitionPage(
            key: state.pageKey,
            child: const WishlistScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.cart,
          pageBuilder: (context, state) => NoTransitionPage(
            key: state.pageKey,
            child: const CartScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.profile,
          pageBuilder: (context, state) => NoTransitionPage(
            key: state.pageKey,
            child: const ProfileScreen(),
          ),
        ),
        GoRoute(
          path: '/category/:categoryId',
          pageBuilder: (context, state) => NoTransitionPage(
            key: state.pageKey,
            child: CategoryProductsScreen(
              categoryId: state.pathParameters['categoryId']!,
            ),
          ),
        ),
      ],
    ),
    ShellRoute(
      navigatorKey: _ownerShellNavigatorKey,
      builder: (context, state, child) {
        return OwnerShellScaffold(
          location: state.matchedLocation,
          child: child,
        );
      },
      routes: [
        GoRoute(
          path: AppRoutes.ownerDashboard,
          pageBuilder: (context, state) => NoTransitionPage(
            key: state.pageKey,
            child: const OwnerDashboardScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.ownerOrders,
          pageBuilder: (context, state) => NoTransitionPage(
            key: state.pageKey,
            child: const OwnerOrdersScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.ownerAnalytics,
          pageBuilder: (context, state) => NoTransitionPage(
            key: state.pageKey,
            child: const OwnerAnalyticsScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.ownerProducts,
          pageBuilder: (context, state) => NoTransitionPage(
            key: state.pageKey,
            child: const OwnerProductsScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.ownerProfile,
          pageBuilder: (context, state) => NoTransitionPage(
            key: state.pageKey,
            child: const OwnerProfileScreen(),
          ),
        ),
      ],
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: AppRoutes.search,
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const SearchScreen(),
      ),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/product/:productId',
      builder: (context, state) => ProductDetailScreen(
        productId: state.pathParameters['productId']!,
      ),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: AppRoutes.checkout,
      builder: (_, _) => const CheckoutScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: AppRoutes.messages,
      builder: (_, _) => const MessagesScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: AppRoutes.orderSuccess,
      builder: (context, state) {
        final result = state.extra as PlaceOrderResultEntity?;
        return OrderSuccessScreen(initialResult: result);
      },
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: AppRoutes.orders,
      builder: (_, _) => const OrdersScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: AppRoutes.addresses,
      builder: (_, _) => const AddressesScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: AppRoutes.help,
      builder: (_, _) => const HelpScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: AppRoutes.about,
      builder: (_, _) => const AboutScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: AppRoutes.language,
      builder: (_, _) => const LanguageScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: AppRoutes.currency,
      builder: (_, _) => const CurrencyScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: AppRoutes.terms,
      builder: (_, _) => const TermsScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: AppRoutes.privacy,
      builder: (_, _) => const PrivacyScreen(),
    ),
  ],
);
