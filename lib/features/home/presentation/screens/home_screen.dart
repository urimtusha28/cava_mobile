import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/cava_app_bar.dart';
import '../../../../core/widgets/search_bar.dart';
import '../../../../core/widgets/category_chip_bar.dart';
import '../../../../core/widgets/visit_store_banner.dart';
import '../../../../core/widgets/product_section.dart';
import '../../../categories/data/repositories/catalog_repository.dart';
import '../../../products/presentation/home_products_query.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static final _catalog = CatalogFacade();

  @override
  Widget build(BuildContext context) {
    final categories = _catalog.categories.getAll();
    final recommended = HomeProductsQuery.recommended();
    final bestSellers = HomeProductsQuery.bestSellers();
    final offers = HomeProductsQuery.offers();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CavaAppBar(isLogo: true),
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.screen,
                AppSpacing.md,
                AppSpacing.screen,
                0,
              ),
              child: CavaSearchBar(),
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
                title: 'Të rekomanduara',
                products: recommended,
                seeAllRoute: '/category/wines',
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
            SliverToBoxAdapter(
              child: ProductSection(
                title: 'Më të shiturat',
                products: bestSellers,
                seeAllRoute: '/category/spirits',
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
            SliverToBoxAdapter(
              child: ProductSection(
                title: 'Oferta',
                products: offers,
                seeAllRoute: '/category/wines',
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxxl)),
        ],
      ),
    );
  }
}
