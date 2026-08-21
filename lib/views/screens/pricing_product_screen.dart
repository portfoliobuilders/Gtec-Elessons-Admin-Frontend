import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/pricing_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_buttons.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/confirm_dialog.dart';
import '../../models/admin/admin_models.dart';
import '../layouts/admin_shell.dart';
import '../widgets/curriculum/regional_pricing_section.dart' show regionLabelFor;
import '../widgets/nav_presets.dart';
import '../widgets/pricing/pricing_money.dart';
import '../widgets/pricing/product_type.dart';
import '../widgets/pricing/regional_price_dialog.dart';
import '../widgets/shared_widgets.dart';

/// Product Pricing detail (Phase 9) — opened from the global Pricing page.
/// Same product/prices Curriculum's per-Grade/Subject/Chapter pricing form
/// edits — a change made here is visible there and vice versa, since both
/// read/write the same `GET/POST/PATCH/DELETE /admin/pricing...` endpoints.
class PricingProductScreen extends StatelessWidget {
  const PricingProductScreen({super.key});

  Future<void> _addPrice(BuildContext context, AdminProductModel product) async {
    final usedRegions = {for (final p in product.prices) p.region};
    final ok = await showRegionalPriceDialog(context, productId: product.id, usedRegions: usedRegions);
    if (!context.mounted) return;
    if (ok) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Regional price added.')));
  }

  Future<void> _editPrice(BuildContext context, AdminProductModel product, AdminProductPriceModel price) async {
    final ok = await showRegionalPriceDialog(context, productId: product.id, existing: price, usedRegions: {});
    if (!context.mounted) return;
    if (ok) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Regional price updated.')));
  }

  Future<void> _deletePrice(BuildContext context, AdminProductModel product, AdminProductPriceModel price) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete ${regionLabelFor(price.region)} price?',
      message: 'This will remove the ${price.currency} price for this product.',
    );
    if (!confirmed || !context.mounted) return;

    final controller = context.read<PricingController>();
    final ok = await controller.deleteRegionalPrice(product.id, price.priceId!);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Regional price deleted.' : controller.priceError ?? 'Unable to delete this price.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PricingController>();
    final product = controller.selectedProduct;
    final notFound = product.id.isEmpty;

    return AdminShell(
      navItems: NavPresets.admin,
      activeIndex: 2,
      user: NavPresets.gtecAdmin,
      title: 'Product Pricing',
      actions: [
        OutlineButtonX(label: 'Back', iconPaths: AppIcons.chevronLeft, onTap: () => Navigator.of(context).pop()),
      ],
      body: PageBody(
        topPadding: 26,
        child: notFound
            ? AppCard(
                padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
                child: Center(
                  child: Text('This product could not be found.',
                      style: AppTextStyles.jakarta(size: 14.5, weight: FontWeight.w800, color: AppColors.ink)),
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(product.title,
                                  style: AppTextStyles.jakarta(size: 17, weight: FontWeight.w800, color: AppColors.ink)),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: product.isActive ? AppColors.greenBg : AppColors.greyChipBg,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                product.isActive ? 'ACTIVE' : 'INACTIVE',
                                style: AppTextStyles.jakarta(
                                  size: 11,
                                  weight: FontWeight.w800,
                                  color: product.isActive ? AppColors.green : AppColors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 32,
                          runSpacing: 16,
                          children: [
                            _InfoStat(label: 'Type', value: productTypeLabel(product.type)),
                            _InfoStat(label: 'Format', value: product.format == 'LIVE_AND_RECORDED' ? 'Live + Recorded' : 'Recorded'),
                            _InfoStat(label: 'Access', value: '${product.accessDays} days'),
                            _InfoStat(label: 'Regional prices', value: '${product.prices.length}'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Text('Regional Prices', style: AppTextStyles.eyebrow),
                      const Spacer(),
                      PrimaryButton(
                        label: 'Add Regional Price',
                        iconPaths: AppIcons.plus,
                        height: 38,
                        fontSize: 12.5,
                        onTap: () => _addPrice(context, product),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (product.prices.isEmpty)
                    const InfoBanner(text: 'No regional prices configured for this product yet.')
                  else
                    Column(
                      children: [
                        for (int i = 0; i < product.prices.length; i++)
                          Padding(
                            padding: EdgeInsets.only(bottom: i == product.prices.length - 1 ? 0 : 10),
                            child: _RegionalPriceRow(
                              price: product.prices[i],
                              onEdit: () => _editPrice(context, product, product.prices[i]),
                              onDelete: () => _deletePrice(context, product, product.prices[i]),
                            ),
                          ),
                      ],
                    ),
                  const SizedBox(height: 24),
                ],
              ),
      ),
    );
  }
}

class _RegionalPriceRow extends StatelessWidget {
  const _RegionalPriceRow({required this.price, required this.onEdit, required this.onDelete});

  final AdminProductPriceModel price;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(regionLabelFor(price.region),
                    style: AppTextStyles.jakarta(size: 13.5, weight: FontWeight.w800, color: AppColors.ink)),
                const SizedBox(height: 2),
                Text(price.currency, style: AppTextStyles.jakarta(size: 11.5, weight: FontWeight.w600, color: AppColors.grey)),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Text(formatPricingAmount(price.amount, price.currency),
                    style: AppTextStyles.jakarta(size: 14, weight: FontWeight.w800, color: AppColors.ink)),
                if (price.compareAt != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    formatPricingAmount(price.compareAt!, price.currency),
                    style: AppTextStyles.jakarta(size: 12, weight: FontWeight.w600, color: AppColors.grey)
                        .copyWith(decoration: TextDecoration.lineThrough),
                  ),
                ],
              ],
            ),
          ),
          OutlineButtonX(label: 'Edit', iconPaths: AppIcons.edit, onTap: onEdit),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onDelete,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(color: AppColors.red.withValues(alpha: 0.08), shape: BoxShape.circle),
                child: const Center(child: AppIcon(AppIcons.trash, size: 15, color: AppColors.red, strokeWidth: 1.9)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoStat extends StatelessWidget {
  const _InfoStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.jakarta(size: 11.5, weight: FontWeight.w700, color: AppColors.grey)),
        const SizedBox(height: 4),
        Text(value, style: AppTextStyles.jakarta(size: 13.5, weight: FontWeight.w700, color: AppColors.ink)),
      ],
    );
  }
}
