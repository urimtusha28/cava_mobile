import 'package:flutter/material.dart' hide SearchController;
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/cava_loading_overlay.dart';
import '../../../../core/widgets/product_filter_bottom_sheet.dart';
import '../../../../core/widgets/product_filter_button.dart';
import '../../../../core/widgets/product_grid_card.dart';
import '../../../../core/widgets/search_bar.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../../../products/domain/filtering/product_filter_options.dart';
import '../controllers/search_controller.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final SearchController _controller;
  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = createSearchController();
    _controller.addListener(_onControllerChanged);
    _controller.loadInitial();
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {
        if (_textController.text != _controller.query) {
          _textController.value = _textController.value.copyWith(
            text: _controller.query,
            selection: TextSelection.collapsed(
              offset: _controller.query.length,
            ),
          );
        }
      });
    }
  }

  Future<void> _openFilters() async {
    final source = _controller.rawSearchResults;
    if (source.isEmpty) return;

    final options = ProductFilterOptions.fromProducts(source);
    final result = await showProductFilterSheet(
      context: context,
      initial: _controller.filter,
      options: options,
    );
    if (result != null) {
      _controller.applyFilter(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          color: AppColors.textPrimary,
          onPressed: () => context.pop(),
        ),
        titleSpacing: 0,
        title: _buildSearchField(),
        actions: [
          ProductFilterButton(
            activeCount: _controller.filter.activeCount,
            onPressed: _openFilters,
          ),
        ],
      ),
      body: CavaLoadingOverlay(
        isLoading: _controller.isSearching && !_controller.hasLoadedProducts,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildSearchField() {
    final hasQuery = _controller.query.isNotEmpty;

    return Row(
      children: [
        Expanded(
          child: CavaSearchBar(
            hint: 'Kërko produktet e Cava Premium…',
            controller: _textController,
            onChanged: _controller.updateQuery,
          ),
        ),
        TextButton(
          onPressed: hasQuery
              ? () {
                  _textController.clear();
                  _controller.updateQuery('');
                }
              : null,
          child: Text(
            'Fshij',
            style: AppTextStyles.bodySmall.copyWith(
              color: hasQuery
                  ? AppColors.textSecondary
                  : AppColors.textSecondary.withValues(alpha: 0.45),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (_controller.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screen),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _controller.errorMessage!,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              OutlinedButton(
                onPressed: () => _controller.loadInitial(),
                child: const Text('Provo përsëri'),
              ),
            ],
          ),
        ),
      );
    }

    if (_controller.query.isEmpty) {
      return _buildInitialState();
    }

    if (_controller.isSearching && !_controller.hasLoadedProducts) {
      return const SizedBox.shrink();
    }

    if (_controller.results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screen),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _controller.filter.isActive
                    ? 'Nuk u gjet asnjë produkt me këto filtra.'
                    : 'Nuk u gjet asnjë produkt.',
                style: AppTextStyles.emptyState,
                textAlign: TextAlign.center,
              ),
              if (_controller.filter.isActive) ...[
                const SizedBox(height: AppSpacing.md),
                OutlinedButton(
                  onPressed: _controller.clearFilter,
                  child: const Text('Pastro filtrat'),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return _buildResultsGrid(_controller.results);
  }

  Widget _buildInitialState() {
    if (_controller.recentSearches.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screen),
          child: Text(
            'Kërko produktet e Cava Premium.',
            style: AppTextStyles.emptyState,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screen,
        AppSpacing.md,
        AppSpacing.screen,
        AppSpacing.screen,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Kërkimet e fundit',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: _controller.clearRecentSearches,
                child: Text(
                  'Fshij të gjitha',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final q in _controller.recentSearches)
                ActionChip(
                  label: Text(
                    q,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  onPressed: () => _controller.selectRecentQuery(q),
                  backgroundColor: AppColors.surfaceMuted,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultsGrid(List<ProductEntity> products) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screen,
        AppSpacing.md,
        AppSpacing.screen,
        AppSpacing.screen,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: ProductGridCard.gridChildAspectRatio,
      ),
      itemCount: products.length,
      itemBuilder: (_, index) => ProductGridCard(product: products[index]),
    );
  }
}
