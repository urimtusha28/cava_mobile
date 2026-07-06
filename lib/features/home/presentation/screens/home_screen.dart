import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/cava_app_bar.dart';
import '../../../../core/widgets/search_bar.dart';
import '../../../../core/widgets/category_chip_bar.dart';
import '../../../../core/widgets/visit_store_banner.dart';
import '../../../../core/widgets/product_section.dart';
import '../../../categories/presentation/categories_query.dart';
import '../../domain/entities/home_section_entity.dart';
import '../home_sections_query.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = CategoriesQuery.getAll();
    final sections = HomeSectionsQuery.getSections();
    final recommended =
        sections.firstWhere((s) => s.type == HomeSectionType.recommended);
    final bestSellers =
        sections.firstWhere((s) => s.type == HomeSectionType.bestSellers);
    final offers =
        sections.firstWhere((s) => s.type == HomeSectionType.offers);

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
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxxl)),
        ],
      ),
    );
  }
}
