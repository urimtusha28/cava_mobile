import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/cava_app_bar.dart';
import '../../../../core/widgets/search_bar.dart';
import '../../../../core/widgets/subcategory_chip_bar.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/category_card.dart';
import '../../../../core/widgets/product_grid_card.dart';
import '../../data/mock/mock_subcategories.dart';
import '../../domain/entities/subcategory_entity.dart';
import '../../domain/subcategory_filter.dart';
import '../../data/repositories/catalog_repository.dart';
import '../../../products/domain/entities/product_entity.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  static final _repo = CategoryRepository();

  @override
  Widget build(BuildContext context) {
    final categories = _repo.getAll();

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
  }
}

class CategoryProductsScreen extends StatefulWidget {
  const CategoryProductsScreen({super.key, required this.categoryId});

  final String categoryId;

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  static final _catalog = CatalogFacade();

  final _searchController = TextEditingController();
  String _selectedSubId = 'all';
  String _searchQuery = '';

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
    final isAllProducts = widget.categoryId == 'all';
    final category = isAllProducts ? null : _catalog.categories.getById(widget.categoryId);
    final products = isAllProducts
        ? _catalog.products.getAll()
        : _catalog.products.getProductsByCategory(widget.categoryId);
    final subcategories = isAllProducts
        ? const [SubcategoryEntity(id: 'all', label: 'All Products')]
        : MockSubcategories.forCategory(widget.categoryId);
    final selectedSub = subcategories.firstWhere(
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
              onSelected: (id) => setState(() => _selectedSubId = id),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          Expanded(
            child: filteredProducts.isEmpty
                ? Center(
                    child: Text(
                      'Nuk u gjet asnjë produkt.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screen,
                      0,
                      AppSpacing.screen,
                      AppSpacing.screen,
                    ),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.62,
                      crossAxisSpacing: AppSpacing.md,
                      mainAxisSpacing: AppSpacing.md,
                    ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (_, i) =>
                        ProductGridCard(product: filteredProducts[i]),
                  ),
          ),
        ],
      ),
    );
  }
}
