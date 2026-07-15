import 'package:flutter/material.dart';
import 'package:cava_ecommerce/l10n/app_localizations.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../account/domain/entities/address_entity.dart';
import '../../../account/presentation/controllers/addresses_controller.dart';
import '../../../account/presentation/widgets/add_address_bottom_sheet.dart';
import '../controllers/checkout_controller.dart';

Future<void> showCheckoutAddressSelectorBottomSheet({
  required BuildContext context,
  required CheckoutController checkoutController,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
        ),
        child: DraggableScrollableSheet(
          initialChildSize: 0.72,
          minChildSize: 0.45,
          maxChildSize: 0.92,
          expand: false,
          builder: (context, scrollController) {
            return _CheckoutAddressSelectorSheet(
              checkoutController: checkoutController,
              scrollController: scrollController,
            );
          },
        ),
      );
    },
  );
}

class _CheckoutAddressSelectorSheet extends StatefulWidget {
  const _CheckoutAddressSelectorSheet({
    required this.checkoutController,
    required this.scrollController,
  });

  final CheckoutController checkoutController;
  final ScrollController scrollController;

  @override
  State<_CheckoutAddressSelectorSheet> createState() =>
      _CheckoutAddressSelectorSheetState();
}

class _CheckoutAddressSelectorSheetState
    extends State<_CheckoutAddressSelectorSheet> {
  late final AddressesController _addressesController;

  @override
  void initState() {
    super.initState();
    _addressesController = createAddressesController();
    _addressesController.load();
  }

  Future<void> _handleSelect(AddressEntity address) async {
    await widget.checkoutController.selectAddress(address);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _handleAddAddress() async {
    await showAddAddressBottomSheet(
      context: context,
      controller: _addressesController,
    );
    await _addressesController.load();
    await widget.checkoutController.refreshAddresses();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textPrimary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(AppLocalizations.of(context).deliveryAddressTitle, style: AppTextStyles.h3),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: ListenableBuilder(
                listenable: Listenable.merge([
                  widget.checkoutController,
                  _addressesController,
                ]),
                builder: (context, _) {
                  final addresses = widget.checkoutController.addresses;
                  final selectedId = widget.checkoutController.selectedAddress?.id;

                  if (addresses.isEmpty) {
                    return _EmptyAddresses(onAddAddress: _handleAddAddress);
                  }

                  return ListView.separated(
                    controller: widget.scrollController,
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screen,
                      0,
                      AppSpacing.screen,
                      AppSpacing.lg,
                    ),
                    itemCount: addresses.length + 1,
                    separatorBuilder: (_, index) {
                      if (index == addresses.length - 1) {
                        return const SizedBox(height: AppSpacing.lg);
                      }
                      return const SizedBox(height: AppSpacing.md);
                    },
                    itemBuilder: (context, index) {
                      if (index == addresses.length) {
                        return _AddAddressButton(onPressed: _handleAddAddress);
                      }

                      final address = addresses[index];
                      final isSelected = address.id == selectedId;

                      return _AddressOptionCard(
                        address: address,
                        isSelected: isSelected,
                        onTap: () => _handleSelect(address),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddressOptionCard extends StatelessWidget {
  const _AddressOptionCard({
    required this.address,
    required this.isSelected,
    required this.onTap,
  });

  final AddressEntity address;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected
          ? AppColors.surfaceMuted
          : AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppColors.burgundy : AppColors.border,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      address.label.isNotEmpty ? address.label : AppLocalizations.of(context).addressFallbackLabel,
                      style: AppTextStyles.h3,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(address.displayLine, style: AppTextStyles.body),
                    const SizedBox(height: 4),
                    Text(address.city, style: AppTextStyles.bodySmall),
                    const SizedBox(height: 4),
                    Text(address.phone, style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: AppColors.burgundy,
                  size: 22,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddAddressButton extends StatelessWidget {
  const _AddAddressButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.add, color: AppColors.burgundy),
      label: Text(
        AppLocalizations.of(context).addNewAddress,
        style: AppTextStyles.body.copyWith(
          color: AppColors.burgundy,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _EmptyAddresses extends StatelessWidget {
  const _EmptyAddresses({required this.onAddAddress});

  final VoidCallback onAddAddress;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_on_outlined,
              size: 48,
              color: AppColors.textPrimary.withValues(alpha: 0.35),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              AppLocalizations.of(context).noAddressYet,
              style: AppTextStyles.body,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            OutlinedButton(
              onPressed: onAddAddress,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.burgundy,
                side: const BorderSide(color: AppColors.burgundy),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
              ),
              child: Text(AppLocalizations.of(context).addAddress, style: AppTextStyles.bodySmall),
            ),
          ],
        ),
      ),
    );
  }
}
