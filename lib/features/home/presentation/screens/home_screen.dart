import 'package:flutter/material.dart';
import 'package:cava_ecommerce/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/cava_app_bar.dart';
import '../../../../core/widgets/cava_loading_overlay.dart';
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

  String _sectionTitle(AppLocalizations l10n, HomeSectionType type) {
    return switch (type) {
      HomeSectionType.recommended => l10n.homeSectionRecommended,
      HomeSectionType.bestSellers => l10n.homeSectionBestSellers,
      HomeSectionType.offers => l10n.homeSectionOffers,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

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
                  type: HomeSectionType.recommended,
                  seeAllRoute: '/category/wines',
                );
            final bestSellers = _controller.sectionByType(
                  HomeSectionType.bestSellers,
                ) ??
                _fallbackSection(
                  type: HomeSectionType.bestSellers,
                  seeAllRoute: '/category/spirits',
                );
            final offers = _controller.sectionByType(HomeSectionType.offers) ??
                _fallbackSection(
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
                        hint: l10n.searchHintDefault,
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
                      title: _sectionTitle(l10n, HomeSectionType.recommended),
                      products: recommended.products,
                      seeAllRoute: recommended.seeAllRoute,
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
                  SliverToBoxAdapter(
                    child: ProductSection(
                      title: _sectionTitle(l10n, HomeSectionType.bestSellers),
                      products: bestSellers.products,
                      seeAllRoute: bestSellers.seeAllRoute,
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
                  SliverToBoxAdapter(
                    child: ProductSection(
                      title: _sectionTitle(l10n, HomeSectionType.offers),
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
    required HomeSectionType type,
    required String seeAllRoute,
  }) {
    return HomeSectionEntity(
      id: type.name,
      title: '',
      type: type,
      seeAllRoute: seeAllRoute,
      products: const [],
    );
  }
}
