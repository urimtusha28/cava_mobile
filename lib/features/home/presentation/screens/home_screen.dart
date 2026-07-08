import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/cava_app_bar.dart';
import '../../../../core/widgets/cava_loading_overlay.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/search_bar.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/widgets/category_chip_bar.dart';
import '../../../../core/widgets/visit_store_banner.dart';
import '../../../../core/widgets/product_section.dart';
import '../../domain/entities/home_section_entity.dart';
import '../controllers/home_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeController _controller;
  late final Future<void> _loadFuture;

  @override
  void initState() {
    super.initState();
    _controller = createHomeController();
    _loadFuture = _controller.load();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loadFuture,
      builder: (context, snapshot) {
        return ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            final categories = _controller.categories;
            final recommended = _controller.sectionByType(
                  HomeSectionType.recommended,
                ) ??
                _fallbackSection(
                  title: 'Të rekomanduara',
                  type: HomeSectionType.recommended,
                  seeAllRoute: '/category/wines',
                );
            final bestSellers = _controller.sectionByType(
                  HomeSectionType.bestSellers,
                ) ??
                _fallbackSection(
                  title: 'Më të shiturat',
                  type: HomeSectionType.bestSellers,
                  seeAllRoute: '/category/spirits',
                );
            final offers = _controller.sectionByType(HomeSectionType.offers) ??
                _fallbackSection(
                  title: 'Oferta',
                  type: HomeSectionType.offers,
                  seeAllRoute: '/category/wines',
                );

            return Scaffold(
              backgroundColor: AppColors.background,
              appBar: const CavaAppBar(isLogo: true),
              body: CavaLoadingOverlay(
                isLoading: _controller.isLoading,
                child: CustomScrollView(
                  slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.screen,
                        AppSpacing.md,
                        AppSpacing.screen,
                        0,
                      ),
                      child: CavaSearchBar(
                        onTap: () => context.push(AppRoutes.search),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
                  SliverToBoxAdapter(
                    child: CategoryChipBar(
                      categories: categories,
                      showAllProducts: true,
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
                  const SliverToBoxAdapter(child: VisitStoreBanner()),
                  const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
                  SliverToBoxAdapter(
                    child: ProductSection(
                      title: recommended.title,
                      products: recommended.products,
                      seeAllRoute: recommended.seeAllRoute,
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
                  SliverToBoxAdapter(
                    child: ProductSection(
                      title: bestSellers.title,
                      products: bestSellers.products,
                      seeAllRoute: bestSellers.seeAllRoute,
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
                  SliverToBoxAdapter(
                    child: ProductSection(
                      title: offers.title,
                      products: offers.products,
                      seeAllRoute: offers.seeAllRoute,
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: AppSpacing.xxxl),
                  ),
                ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  HomeSectionEntity _fallbackSection({
    required String title,
    required HomeSectionType type,
    required String seeAllRoute,
  }) {
    return HomeSectionEntity(
      id: type.name,
      title: title,
      type: type,
      seeAllRoute: seeAllRoute,
      products: const [],
    );
  }
}
