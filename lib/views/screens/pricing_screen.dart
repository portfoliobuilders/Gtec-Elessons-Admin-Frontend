import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/pricing_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/app_buttons.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_inputs.dart';
import '../../core/widgets/grid_table.dart';
import '../../models/admin/admin_models.dart';
import '../../routes/app_routes.dart';
import '../layouts/admin_shell.dart';
import '../widgets/curriculum/curriculum_tints.dart';
import '../widgets/nav_presets.dart';
import '../widgets/pricing/pricing_money.dart';
import '../widgets/pricing/product_type.dart';
import '../widgets/shared_widgets.dart';

const List<double> _productFlexes = [2.2, 1, 1, 1.4];

const List<String?> _typeFilters = [null, 'FULL_CLASS', 'SUBJECT', 'MODULE'];

String _typeFilterLabel(String? type) => type == null ? 'All' : productTypeLabel(type);

/// Global Pricing (Phase 9) — "what do we sell" overview across every
/// Product, backed by the same `GET /admin/pricing` Curriculum's per-item
/// pricing already uses. Real fields only — no fabricated columns.
class PricingScreen extends StatefulWidget {
  const PricingScreen({super.key});

  @override
  State<PricingScreen> createState() => _PricingScreenState();
}

class _PricingScreenState extends State<PricingScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PricingController>().loadProducts();
  }

  void _openProduct(BuildContext context, AdminProductModel product) {
    context.read<PricingController>().selectProduct(product.id);
    Navigator.of(context).pushNamed(AppRoutes.pricingProductDetail);
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PricingController>();
    final bool desktop = Responsive.isDesktop(context);

    return AdminShell(
      navItems: NavPresets.admin,
      activeIndex: 2,
      user: NavPresets.gtecAdmin,
      titleWidget: Text.rich(
        TextSpan(
          text: 'Pricing ',
          style: AppTextStyles.pageTitle,
          children: [
            TextSpan(
              text: '· ${controller.products.length}',
              style: AppTextStyles.jakarta(size: 14, weight: FontWeight.w600, color: AppColors.grey),
            ),
          ],
        ),
      ),
      actions: [
        if (desktop) AppSearchField(hint: 'Search products…', width: 260, onChanged: controller.setSearch),
        OutlineButtonX(label: 'Refresh', iconPaths: AppIcons.arrowRight, onTap: controller.refreshProducts),
      ],
      body: PageBody(
        topPadding: 24,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!desktop) ...[
              AppSearchField(hint: 'Search products…', onChanged: controller.setSearch),
              const SizedBox(height: 16),
            ],
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final t in _typeFilters)
                  AppFilterChip(
                    label: _typeFilterLabel(t),
                    active: controller.typeFilter == t,
                    onTap: () => controller.setTypeFilter(t),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            _ProductsBody(controller: controller, desktop: desktop, onTap: (p) => _openProduct(context, p)),
          ],
        ),
      ),
    );
  }
}

class _ProductsBody extends StatelessWidget {
  const _ProductsBody({required this.controller, required this.desktop, required this.onTap});

  final PricingController controller;
  final bool desktop;
  final ValueChanged<AdminProductModel> onTap;

  @override
  Widget build(BuildContext context) {
    switch (controller.status) {
      case PricingLoadStatus.initial:
      case PricingLoadStatus.loading:
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 60),
          child: Center(
            child: SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 2.6, color: AppColors.navy)),
          ),
        );
      case PricingLoadStatus.error:
        return AppCard(
          padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Unable to load pricing.',
                    style: AppTextStyles.jakarta(size: 14.5, weight: FontWeight.w800, color: AppColors.ink)),
                const SizedBox(height: 6),
                Text(controller.error ?? 'Please try again.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.jakarta(size: 12.5, weight: FontWeight.w600, color: AppColors.grey)),
                const SizedBox(height: 16),
                OutlineButtonX(label: 'Retry', iconPaths: AppIcons.arrowRight, onTap: () => controller.loadProducts()),
              ],
            ),
          ),
        );
      case PricingLoadStatus.loaded:
        final products = controller.filteredProducts;
        if (products.isEmpty) {
          return InfoBanner(
            text: controller.search.trim().isEmpty ? 'No priced products yet.' : 'No products match "${controller.search.trim()}".',
          );
        }
        return desktop ? _ProductsTable(products: products, onTap: onTap) : _ProductsCards(products: products, onTap: onTap);
    }
  }
}

String _regionSummary(AdminProductModel product) {
  if (product.prices.isEmpty) return 'No prices configured';
  final cheapest = product.prices.reduce((a, b) => a.amount < b.amount ? a : b);
  final count = product.prices.length;
  return '$count region${count == 1 ? '' : 's'} · from ${formatPricingAmount(cheapest.amount, cheapest.currency)}';
}

class _ProductsTable extends StatelessWidget {
  const _ProductsTable({required this.products, required this.onTap});

  final List<AdminProductModel> products;
  final ValueChanged<AdminProductModel> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16), boxShadow: AppTheme.cardShadow),
      child: Column(
        children: [
          const GridHeaderRow(flexes: _productFlexes, labels: ['Product', 'Type', 'Regions', 'Price']),
          for (int i = 0; i < products.length; i++)
            GestureDetector(
              onTap: () => onTap(products[i]),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GridRow(
                  flexes: _productFlexes,
                  bottomBorder: i != products.length - 1,
                  cells: [
                    _ProductCell(product: products[i], tintIndex: i),
                    Text(productTypeLabel(products[i].type), style: AppTextStyles.cell),
                    Text('${products[i].prices.length}', style: AppTextStyles.cell),
                    Text(_regionSummary(products[i]),
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.jakarta(size: 12.5, weight: FontWeight.w700, color: AppColors.ink)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ProductsCards extends StatelessWidget {
  const _ProductsCards({required this.products, required this.onTap});

  final List<AdminProductModel> products;
  final ValueChanged<AdminProductModel> onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < products.length; i++)
          Padding(
            padding: EdgeInsets.only(bottom: i == products.length - 1 ? 0 : 12),
            child: GestureDetector(
              onTap: () => onTap(products[i]),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ProductCell(product: products[i], tintIndex: i),
                      const SizedBox(height: 10),
                      Text('${productTypeLabel(products[i].type)} · ${_regionSummary(products[i])}',
                          style: AppTextStyles.jakarta(size: 12, weight: FontWeight.w600, color: AppColors.grey)),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ProductCell extends StatelessWidget {
  const _ProductCell({required this.product, required this.tintIndex});

  final AdminProductModel product;
  final int tintIndex;

  @override
  Widget build(BuildContext context) {
    final tint = tintForIndex(tintIndex);
    final relationship = _relationshipLine(product);
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(color: tint.bg, borderRadius: BorderRadius.circular(10)),
          child: Center(child: AppIcon(AppIcons.pricing, size: 15, color: tint.accent, strokeWidth: 1.8)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(product.title, overflow: TextOverflow.ellipsis, style: AppTextStyles.cellStrong),
              if (relationship != null)
                Text(relationship, overflow: TextOverflow.ellipsis, style: AppTextStyles.cellSub),
            ],
          ),
        ),
      ],
    );
  }
}

/// Only built from real ids the product actually carries (Section 15) — no
/// name reconstruction, and nothing shown at all for an orphaned product
/// (gradeId/subjectId/chapterId all null — can happen if the underlying
/// Grade/Subject/Chapter was deleted; the Product row isn't cascade-deleted
/// with it, confirmed live).
String? _relationshipLine(AdminProductModel product) {
  if (product.chapterId != null) return 'Chapter product';
  if (product.subjectId != null) return 'Subject product';
  if (product.gradeId != null) return 'Grade product';
  return null;
}
