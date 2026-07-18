import 'package:flutter/material.dart';
import 'package:cava_ecommerce/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/cava_app_bar.dart';
import '../../../account/domain/entities/order_entity.dart';
import '../../../account/presentation/utils/order_formatters.dart';
import '../../../account/presentation/widgets/order_detail_bottom_sheet.dart';
import '../../domain/entities/owner_dashboard_entities.dart';
import '../controllers/owner_dashboard_controller.dart';
import '../utils/owner_order_status_l10n.dart';
import '../utils/owner_orders_grouping.dart';

class OwnerOrdersScreen extends StatefulWidget {
  const OwnerOrdersScreen({super.key});

  @override
  State<OwnerOrdersScreen> createState() => _OwnerOrdersScreenState();
}

class _OwnerOrdersScreenState extends State<OwnerOrdersScreen>
    with SingleTickerProviderStateMixin {
  late final OwnerDashboardController _controller;
  late final Future<void> _loadFuture;
  late final TabController _tabController;
  final Map<String, OrderEntity> _orderOverrides = {};

  @override
  void initState() {
    super.initState();
    _controller = createOwnerDashboardController();
    _loadFuture = _controller.load();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CavaAppBar(title: l10n.ownerOrdersTitle, showBack: false),
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
                    _controller.sectionError ?? l10n.errorGeneric,
                    style: AppTextStyles.body,
                  ),
                );
              }

              final allOrders = _controller.snapshot?.recentOrders ?? const [];
              if (allOrders.isEmpty) {
                return Center(
                  child: Text(
                    l10n.ownerNoRecentOrders,
                    style: AppTextStyles.emptyState,
                  ),
                );
              }

              return Column(
                children: [
                  TabBar(
                    controller: _tabController,
                    labelColor: AppColors.burgundy,
                    unselectedLabelColor: AppColors.textSecondary,
                    indicatorColor: AppColors.burgundy,
                    indicatorWeight: 2.5,
                    dividerColor: AppColors.border,
                    labelStyle: AppTextStyles.body,
                    unselectedLabelStyle: AppTextStyles.body,
                    tabs: [
                      Tab(text: l10n.ownerOrdersTabStore),
                      Tab(text: l10n.ownerOrdersTabCourier),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _OrdersTabList(
                          orders: allOrders,
                          tab: OwnerOrdersListTab.store,
                          emptyLabel: l10n.ownerNoStoreOrders,
                          statusOf: _statusOf,
                          paymentMethodOf: _paymentMethodOf,
                          paymentStatusOf: _paymentStatusOf,
                          totalOf: _totalOf,
                          onTap: _openOrder,
                        ),
                        _OrdersTabList(
                          orders: allOrders,
                          tab: OwnerOrdersListTab.courier,
                          emptyLabel: l10n.ownerNoCourierOrders,
                          statusOf: _statusOf,
                          paymentMethodOf: _paymentMethodOf,
                          paymentStatusOf: _paymentStatusOf,
                          totalOf: _totalOf,
                          onTap: _openOrder,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  String _statusOf(OwnerRecentOrder o) {
    final override = _orderOverrides[o.id];
    return override?.fulfillmentStatus ??
        override?.status ??
        o.statusLabel;
  }

  String _paymentMethodOf(OwnerRecentOrder o) =>
      _orderOverrides[o.id]?.paymentMethod ?? o.paymentMethod;

  String _paymentStatusOf(OwnerRecentOrder o) =>
      _orderOverrides[o.id]?.paymentStatus ?? o.paymentStatus;

  double _totalOf(OwnerRecentOrder o) =>
      _orderOverrides[o.id]?.total ?? o.total;

  void _openOrder(OwnerRecentOrder o) {
    final override = _orderOverrides[o.id];
    showOrderDetailBottomSheet(
      context: context,
      order: OrderEntity(
        id: o.id,
        orderNumber: o.orderNumber,
        status: override?.status ?? o.statusLabel,
        fulfillmentStatus: override?.fulfillmentStatus ?? o.statusLabel,
        paymentMethod: override?.paymentMethod ?? o.paymentMethod,
        paymentStatus: override?.paymentStatus ?? o.paymentStatus,
        total: override?.total ?? o.total,
        itemCount: override?.itemCount ?? 0,
        customer: override?.customer,
        createdAt: override?.createdAt ?? o.createdAt,
        items: override?.items ?? const [],
        totals: override?.totals,
      ),
      onOrderUpdated: _replaceOrder,
    );
  }

  void _replaceOrder(OrderEntity updatedOrder) {
    setState(() {
      _orderOverrides[updatedOrder.id] = updatedOrder;
    });
  }
}

class _OrdersTabList extends StatelessWidget {
  const _OrdersTabList({
    required this.orders,
    required this.tab,
    required this.emptyLabel,
    required this.statusOf,
    required this.paymentMethodOf,
    required this.paymentStatusOf,
    required this.totalOf,
    required this.onTap,
  });

  final List<OwnerRecentOrder> orders;
  final OwnerOrdersListTab tab;
  final String emptyLabel;
  final String Function(OwnerRecentOrder) statusOf;
  final String Function(OwnerRecentOrder) paymentMethodOf;
  final String Function(OwnerRecentOrder) paymentStatusOf;
  final double Function(OwnerRecentOrder) totalOf;
  final void Function(OwnerRecentOrder) onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final filtered = filterOrdersForTab(orders, tab, statusOf: statusOf);
    if (filtered.isEmpty) {
      return Center(
        child: Text(emptyLabel, style: AppTextStyles.emptyState),
      );
    }

    final groups = groupOrdersByMonthAndDay(filtered);
    final monthFormat = DateFormat.yMMMM(locale);
    final dayFormat = DateFormat.yMMMMd(locale);

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screen,
        AppSpacing.md,
        AppSpacing.screen,
        AppSpacing.xxxl,
      ),
      itemCount: groups.length,
      itemBuilder: (context, monthIndex) {
        final monthGroup = groups[monthIndex];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (monthIndex > 0) const SizedBox(height: AppSpacing.lg),
            Text(
              _capitalize(monthFormat.format(monthGroup.month)),
              style: AppTextStyles.h3.copyWith(color: AppColors.burgundy),
            ),
            const SizedBox(height: AppSpacing.sm),
            for (final dayGroup in monthGroup.days) ...[
              Padding(
                padding: const EdgeInsets.only(
                  top: AppSpacing.sm,
                  bottom: AppSpacing.xs,
                ),
                child: Text(
                  _dayLabel(dayGroup.day, dayFormat),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              for (var i = 0; i < dayGroup.orders.length; i++) ...[
                if (i > 0) const SizedBox(height: AppSpacing.sm),
                _OrderCard(
                  order: dayGroup.orders[i],
                  statusLabel: OwnerOrderStatusL10n.labelOf(
                    l10n,
                    statusOf(dayGroup.orders[i]),
                  ),
                  paymentSummary: formatPaymentSummary(
                    method: paymentMethodOf(dayGroup.orders[i]),
                    paymentStatus: paymentStatusOf(dayGroup.orders[i]),
                    l10n: l10n,
                  ),
                  total: totalOf(dayGroup.orders[i]),
                  onTap: () => onTap(dayGroup.orders[i]),
                ),
              ],
            ],
          ],
        );
      },
    );
  }

  static String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }

  static String _dayLabel(DateTime day, DateFormat dayFormat) {
    if (day.millisecondsSinceEpoch == 0) {
      return '—';
    }
    return _capitalize(dayFormat.format(day));
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.order,
    required this.statusLabel,
    required this.paymentSummary,
    required this.total,
    required this.onTap,
  });

  final OwnerRecentOrder order;
  final String statusLabel;
  final String paymentSummary;
  final double total;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('#${order.orderNumber}', style: AppTextStyles.body),
                    Text(
                      '${order.customerName} · $statusLabel',
                      style: AppTextStyles.bodySmall,
                    ),
                    Text(paymentSummary, style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
              Text(
                Formatters.currency(total),
                style: AppTextStyles.h3.copyWith(color: AppColors.burgundy),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
