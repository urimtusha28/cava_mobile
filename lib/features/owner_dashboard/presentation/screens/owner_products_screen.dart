import 'package:flutter/material.dart';

import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/cava_app_bar.dart';
import '../controllers/owner_dashboard_controller.dart';

class OwnerProductsScreen extends StatefulWidget {
  const OwnerProductsScreen({super.key});

  @override
  State<OwnerProductsScreen> createState() => _OwnerProductsScreenState();
}

class _OwnerProductsScreenState extends State<OwnerProductsScreen> {
  late final OwnerDashboardController _controller;
  late final Future<void> _loadFuture;

  @override
  void initState() {
    super.initState();
    _controller = createOwnerDashboardController();
    _loadFuture = _controller.load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CavaAppBar(title: 'Produktet', showBack: false),
      body: FutureBuilder<void>(
        future: _loadFuture,
        builder: (context, _) {
          return ListenableBuilder(
            listenable: _controller,
            builder: (context, _) {
              if (_controller.status == OwnerDashboardViewStatus.loading ||
                  _controller.status == OwnerDashboardViewStatus.initial) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.burgundy),
                );
              }
              if (_controller.status == OwnerDashboardViewStatus.error) {
                return Center(
                  child: Text(
                    _controller.sectionError ?? 'Gabim',
                    style: AppTextStyles.body,
                  ),
                );
              }
              final snap = _controller.snapshot;
              final s = snap?.summary;
              final low = snap?.lowStockProducts ?? const [];
              return ListView(
                padding: const EdgeInsets.all(AppSpacing.screen),
                children: [
                  Text(
                    'Agregatet nga stats/productsSummary (si web).',
                    style: AppTextStyles.bodySmall,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _CountRow(label: 'Në stok (≥10)', value: '${s?.inStockCount ?? 0}'),
                  _CountRow(label: 'Stok i ulët (1–9)', value: '${s?.lowStockCount ?? 0}'),
                  _CountRow(label: 'Jashtë stoku', value: '${s?.outOfStockCount ?? 0}'),
                  const SizedBox(height: AppSpacing.xl),
                  Text('Lista stok i ulët', style: AppTextStyles.h3),
                  const SizedBox(height: AppSpacing.md),
                  if (low.isEmpty)
                    Text(
                      'Nuk ka rreshta për listë.',
                      style: AppTextStyles.bodySmall,
                    )
                  else
                    ...low.map(
                      (p) => Container(
                        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(p.name, style: AppTextStyles.body),
                            ),
                            Text(
                              '${p.stock}',
                              style: AppTextStyles.h3.copyWith(
                                color: AppColors.burgundy,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'Top selling: nuk ekziston në admin web — pa të dhëna.',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _CountRow extends StatelessWidget {
  const _CountRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTextStyles.body)),
          Text(
            value,
            style: AppTextStyles.h3.copyWith(color: AppColors.burgundy),
          ),
        ],
      ),
    );
  }
}
