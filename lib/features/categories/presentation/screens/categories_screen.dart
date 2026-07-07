import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/cava_app_bar.dart';
import '../../../../core/widgets/cava_loading_overlay.dart';
import '../../../../core/widgets/search_bar.dart';
import '../../../../core/widgets/subcategory_chip_bar.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/category_card.dart';
import '../../../../core/widgets/product_grid_card.dart';
import '../../domain/entities/subcategory_entity.dart';
import '../../domain/subcategory_filter.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../controllers/categories_controller.dart';
import '../controllers/category_products_controller.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  late final CategoriesController _controller;
  late final Future<void> _loadFuture;

  @override
  void initState() {
    super.initState();
    _controller = createCategoriesController();
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

            return Scaffold(
              backgroundColor: AppColors.background,
              appBar: const CavaAppBar(title: 'Kategoritë'),
              body: GridView.builder(
                padding: const EdgeInsets.all(AppSpacing.screen),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: AppSpacing.lg,
                  mainAxisSpacing: AppSpacing.lg,
                  childAspectRatio: 1.1,
                ),
                itemCount: categories.length,
                itemBuilder: (_, i) => CategoryCard(category: categories[i]),
              ),
            );
          },
        );
      },
    );
  }
}

class CategoryProductsScreen extends StatefulWidget {
  const CategoryProductsScreen({super.key, required this.categoryId});

  final String categoryId;

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  late final CategoryProductsController _controller;
  late final Future<void> _loadFuture;

  final _searchController = TextEditingController();
  String _selectedSubId = 'all';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _controller = createCategoryProductsController();
    _loadFuture = _controller.load(widget.categoryId);
  }
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ProductEntity> _filteredProducts(
    List<ProductEntity> products,
    SubcategoryEntity selectedSub,
  ) {
    return products.where((product) {
      return SubcategoryFilter.matches(product, selectedSub) &&
          SubcategoryFilter.matchesSearch(product, _searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loadFuture,
      builder: (context, snapshot) {
        return ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            final isAllProducts = widget.categoryId == 'all';
            final category = _controller.category;
            final products = _controller.products;
            final subcategories = _controller.subcategories;
            final selectedSub = subcategories.isEmpty
                ? const SubcategoryEntity(id: 'all', label: 'All')
                : subcategories.firstWhere(
                    (sub) => sub.id == _selectedSubId,
                    orElse: () => subcategories.first,
                  );
            final filteredProducts = _filteredProducts(products, selectedSub);

            return Scaffold(
              backgroundColor: AppColors.background,
              appBar: CavaAppBar(
                title: isAllProducts ? 'All Products' : category?.label ?? 'Produktet',
                showBack: true,
              ),
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screen,
                      AppSpacing.md,
                      AppSpacing.screen,
                      AppSpacing.sm,
                    ),
                    child: CavaSearchBar(
                      hint: isAllProducts
                          ? 'Kërko të gjitha produktet…'
                          : 'Kërko në ${category?.label ?? 'kategori'}…',
                      controller: _searchController,
                      onChanged: (value) => setState(() => _searchQuery = value),
                    ),
                  ),
                  if (subcategories.length > 1) ...[
                    SubcategoryChipBar(
                      subcategories: subcategories,
                      selectedId: _selectedSubId,
                      parentBadgeColor: category?.badgeColor,
                      onSelected: (id) => setState(() => _selectedSubId = id),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  Expanded(
                    child: CavaLoadingOverlay(
                      isLoading: _controller.isLoading,
                      child: _buildProductsBody(filteredProducts),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProductsBody(List<ProductEntity> filteredProducts) {
    if (_controller.isLoading) {
      return const SizedBox.expand();
    }

    if (_controller.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screen),
          child: Text(
            _controller.errorMessage!,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (filteredProducts.isEmpty) {
      return Center(
        child: Text(
          'Nuk u gjet asnjë produkt.',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screen,
        0,
        AppSpacing.screen,
        AppSpacing.screen,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: ProductGridCard.gridChildAspectRatio,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
      ),
      itemCount: filteredProducts.length,
      itemBuilder: (_, i) =>
          ProductGridCard(product: filteredProducts[i]),
    );
  }
}
