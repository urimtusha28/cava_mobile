import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/bottom_navigation.dart';
import 'app_routes.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/categories/presentation/screens/categories_screen.dart';
import '../../features/products/presentation/screens/product_detail_screen.dart';
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

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'shell');

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: AppRoutes.splash,
  redirect: (context, state) {
    final path = state.matchedLocation;
    if (path == '/') return AppRoutes.splash;
    return null;
  },
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
        final isCart = state.matchedLocation == AppRoutes.cart;
        return Scaffold(
          extendBody: true,
          body: Padding(
            padding: EdgeInsets.only(bottom: isCart ? 0 : 88),
            child: child,
          ),
          bottomNavigationBar: isCart
              ? null
              : BottomNavigation(
                  currentIndex: bottomNavIndexForLocation(state.matchedLocation),
                  onTap: (i) => navigateToBottomNavTab(context, i),
                ),
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
