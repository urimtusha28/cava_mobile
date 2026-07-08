import 'package:flutter/material.dart' hide SearchController;
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/cava_loading_overlay.dart';
import '../../../../core/widgets/product_grid_card.dart';
import '../../../../core/widgets/search_bar.dart';
import '../../../products/domain/entities/product_entity.dart';
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
      ),
      body: CavaLoadingOverlay(
        isLoading: _controller.isSearching && !_controller.hasLoadedProducts,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildSearchField() {
    return Row(
      children: [
        Expanded(
          child: CavaSearchBar(
            hint: 'Kërko produktet e Cava Premium…',
            controller: _textController,
            onChanged: _controller.updateQuery,
          ),
        ),
        if (_controller.query.isNotEmpty)
          TextButton(
            onPressed: () {
              _textController.clear();
              _controller.updateQuery('');
            },
            child: Text(
              'Fshij',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
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
          child: Text(
            'Nuk u gjet asnjë produkt.',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
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
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
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

