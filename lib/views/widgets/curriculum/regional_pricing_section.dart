import 'package:flutter/material.dart';

import '../../../controllers/curriculum_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_card.dart';
import '../../../models/admin/admin_models.dart';
import 'curriculum_form_fields.dart';
import 'curriculum_tints.dart';
import 'save_action_bar.dart';

/// The known business regions (Section 6/16/17) — a price configuration
/// list, not an exchange-rate table. New regions can be added here later
/// without touching any of the CRUD/reconciliation logic below.
const Map<String, String> kRegionCurrency = {
  'IN': 'INR',
  'AE': 'AED',
  'OM': 'OMR',
  'BH': 'BHD',
  'QA': 'QAR',
  'SA': 'SAR',
  'KW': 'KWD',
  'US': 'USD',
};

const Map<String, String> kRegionLabel = {
  'IN': 'India',
  'AE': 'UAE',
  'OM': 'Oman',
  'BH': 'Bahrain',
  'QA': 'Qatar',
  'SA': 'Saudi Arabia',
  'KW': 'Kuwait',
  'US': 'United States',
};

const Map<String, String> kCurrencySymbol = {
  'INR': '₹',
  'AED': 'AED',
  'OMR': 'OMR',
  'BHD': 'BHD',
  'QAR': 'QAR',
  'SAR': 'SAR',
  'KWD': 'KWD',
  'USD': r'$',
};

String regionLabelFor(String region) => kRegionLabel[region] ?? region;

String currencySymbolFor(String currency) => kCurrencySymbol[currency] ?? currency;

/// A single regional price row as edited in a form — mirrors
/// [AdminProductPriceModel] but mutable and UI-only. `priceId == null`
/// means this row hasn't been saved to the backend yet.
class PriceRow {
  PriceRow({this.priceId, required this.region, required this.currency, required this.amount, this.compareAt});

  final String? priceId;
  final String region;
  final String currency;
  final num amount;
  final num? compareAt;

  PriceRow copyWith({String? region, String? currency, num? amount, num? compareAt, bool clearCompareAt = false}) =>
      PriceRow(
        priceId: priceId,
        region: region ?? this.region,
        currency: currency ?? this.currency,
        amount: amount ?? this.amount,
        compareAt: clearCompareAt ? null : (compareAt ?? this.compareAt),
      );
}

List<PriceRow> priceRowsFrom(List<AdminProductPriceModel> models) => [
      for (final m in models)
        PriceRow(priceId: m.priceId, region: m.region, currency: m.currency, amount: m.amount, compareAt: m.compareAt),
    ];

/// Reconciles an edited [current] list of price rows against what was
/// originally loaded ([original]), issuing exactly one API call per
/// added/changed/removed row — never resending the whole list (Section 14).
/// Returns an error message on failure, or null on success (including when
/// there was nothing to do).
Future<String?> reconcileRegionalPrices(
  CurriculumController controller, {
  required String? productId,
  required List<PriceRow> original,
  required List<PriceRow> current,
}) async {
  final originalById = {for (final r in original) if (r.priceId != null) r.priceId!: r};
  final currentIds = {for (final r in current) if (r.priceId != null) r.priceId!};

  for (final id in originalById.keys) {
    if (currentIds.contains(id)) continue;
    final ok = await controller.deleteProductPrice(productId!, id);
    if (!ok) return controller.curriculumError ?? 'Unable to remove a regional price.';
  }

  for (final row in current) {
    if (row.priceId == null) {
      if (productId == null) {
        return 'This item has no pricing product yet, so a new region can\'t be saved here — regional pricing '
            'currently has to be set when the item is first created.';
      }
      final ok = await controller.createProductPrice(
        productId,
        CreatePriceRequest(region: row.region, currency: row.currency, amount: row.amount, compareAt: row.compareAt),
      );
      if (!ok) return controller.curriculumError ?? 'Unable to add a regional price.';
      continue;
    }

    final orig = originalById[row.priceId];
    if (orig == null) continue;

    if (orig.region != row.region || orig.currency != row.currency) {
      final delOk = await controller.deleteProductPrice(productId!, row.priceId!);
      if (!delOk) return controller.curriculumError ?? 'Unable to update a regional price.';
      final createOk = await controller.createProductPrice(
        productId,
        CreatePriceRequest(region: row.region, currency: row.currency, amount: row.amount, compareAt: row.compareAt),
      );
      if (!createOk) return controller.curriculumError ?? 'Unable to update a regional price.';
    } else if (orig.amount != row.amount || orig.compareAt != row.compareAt) {
      final ok = await controller.updateProductPrice(
        productId!,
        row.priceId!,
        UpdateProductPriceRequest(amount: row.amount, compareAt: row.compareAt),
      );
      if (!ok) return controller.curriculumError ?? 'Unable to update a regional price.';
    }
  }
  return null;
}

/// Reusable "Pricing" form section — shows every configured regional price
/// as a card, "+ Add Region" opens [RegionalPriceEditor] to add/edit one
/// row. Used identically by Add Grade/Subject/Chapter (Section 10) — the
/// parent screen owns the row list and gets it back via [onChanged].
class RegionalPricingSection extends StatelessWidget {
  const RegionalPricingSection({super.key, required this.rows, required this.onChanged, this.loading = false});

  final List<PriceRow> rows;
  final ValueChanged<List<PriceRow>> onChanged;
  final bool loading;

  Future<void> _addRegion(BuildContext context) async {
    final row = await showRegionalPriceEditor(context, existingRegions: rows.map((r) => '${r.region}/${r.currency}'));
    if (row != null) onChanged([...rows, row]);
  }

  Future<void> _editRegion(BuildContext context, int index) async {
    final row = await showRegionalPriceEditor(
      context,
      initial: rows[index],
      existingRegions: [for (int i = 0; i < rows.length; i++) if (i != index) '${rows[i].region}/${rows[i].currency}'],
    );
    if (row != null) {
      final next = [...rows];
      next[index] = row;
      onChanged(next);
    }
  }

  void _removeRegion(int index) {
    final next = [...rows]..removeAt(index);
    onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Configure a price per region. Leave empty if this item isn\'t sold on its own.',
                style: AppTextStyles.jakarta(size: 12.5, weight: FontWeight.w600, color: AppColors.grey),
              ),
            ),
            OutlineButtonX(label: 'Add Region', iconPaths: AppIcons.plus, onTap: () => _addRegion(context)),
          ],
        ),
        const SizedBox(height: 16),
        if (loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.4, color: AppColors.navy),
              ),
            ),
          )
        else if (rows.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
            decoration: BoxDecoration(color: AppColors.searchBg, borderRadius: BorderRadius.circular(12)),
            child: Text(
              'No regional prices configured yet.',
              style: AppTextStyles.jakarta(size: 12.5, weight: FontWeight.w600, color: AppColors.grey),
            ),
          )
        else
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (int i = 0; i < rows.length; i++)
                SizedBox(
                  width: 260,
                  child: RegionalPriceCard(
                    row: rows[i],
                    tintIndex: i,
                    onEdit: () => _editRegion(context, i),
                    onRemove: () => _removeRegion(i),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

/// One regional price, shown as a compact card — reused verbatim wherever
/// the Regional Pricing section appears (Grade/Subject/Chapter forms).
class RegionalPriceCard extends StatelessWidget {
  const RegionalPriceCard({super.key, required this.row, required this.tintIndex, this.onEdit, this.onRemove});

  final PriceRow row;
  final int tintIndex;
  final VoidCallback? onEdit;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final tint = tintForIndex(tintIndex);
    final symbol = currencySymbolFor(row.currency);

    return GestureDetector(
      onTap: onEdit,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AppCard(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(color: tint.bg, borderRadius: BorderRadius.circular(9)),
                    child: Center(
                      child: Text(row.region,
                          style: AppTextStyles.jakarta(size: 10.5, weight: FontWeight.w800, color: tint.accent)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(regionLabelFor(row.region),
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.jakarta(size: 13, weight: FontWeight.w800, color: AppColors.ink)),
                  ),
                  if (onRemove != null)
                    GestureDetector(
                      onTap: onRemove,
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration:
                              BoxDecoration(color: AppColors.red.withValues(alpha: 0.08), shape: BoxShape.circle),
                          child: const Center(
                            child: AppIcon(AppIcons.close, size: 11, color: AppColors.red, strokeWidth: 2.2),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text('$symbol ${row.amount}',
                      style: AppTextStyles.jakarta(size: 15, weight: FontWeight.w800, color: AppColors.ink)),
                  if (row.compareAt != null) ...[
                    const SizedBox(width: 8),
                    Text('$symbol ${row.compareAt}',
                        style: AppTextStyles.jakarta(size: 12, weight: FontWeight.w600, color: AppColors.grey)
                            .copyWith(decoration: TextDecoration.lineThrough)),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(row.currency, style: AppTextStyles.jakarta(size: 11, weight: FontWeight.w600, color: AppColors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Add/Edit one regional price — shown as a dialog. `existingRegions` (as
/// `"REGION/CURRENCY"` strings) is used to reject a duplicate combination
/// (Section 15); the row being edited is excluded from that set by the
/// caller so re-saving it unchanged is never treated as a duplicate.
Future<PriceRow?> showRegionalPriceEditor(
  BuildContext context, {
  PriceRow? initial,
  Iterable<String> existingRegions = const [],
}) {
  return showDialog<PriceRow>(
    context: context,
    builder: (context) => _RegionalPriceEditorDialog(initial: initial, existingRegions: existingRegions.toSet()),
  );
}

class _RegionalPriceEditorDialog extends StatefulWidget {
  const _RegionalPriceEditorDialog({this.initial, required this.existingRegions});

  final PriceRow? initial;
  final Set<String> existingRegions;

  @override
  State<_RegionalPriceEditorDialog> createState() => _RegionalPriceEditorDialogState();
}

class _RegionalPriceEditorDialogState extends State<_RegionalPriceEditorDialog> {
  late String _region = widget.initial?.region ?? kRegionCurrency.keys.first;
  late final TextEditingController _amountController =
      TextEditingController(text: widget.initial == null ? '' : '${widget.initial!.amount}');
  late final TextEditingController _compareAtController =
      TextEditingController(text: widget.initial?.compareAt == null ? '' : '${widget.initial!.compareAt}');

  @override
  void dispose() {
    _amountController.dispose();
    _compareAtController.dispose();
    super.dispose();
  }

  void _showMessage(String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

  void _save() {
    final currency = kRegionCurrency[_region]!;
    if (widget.existingRegions.contains('$_region/$currency')) {
      _showMessage('A price for ${regionLabelFor(_region)} ($currency) is already in this list.');
      return;
    }

    final amount = num.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      _showMessage('Enter a valid price.');
      return;
    }

    num? compareAt;
    final compareAtText = _compareAtController.text.trim();
    if (compareAtText.isNotEmpty) {
      compareAt = num.tryParse(compareAtText);
      if (compareAt == null || compareAt <= 0) {
        _showMessage('Compare-at price must be a valid number.');
        return;
      }
    }

    Navigator.of(context).pop(
      (widget.initial ?? PriceRow(region: _region, currency: currency, amount: amount)).copyWith(
        region: _region,
        currency: currency,
        amount: amount,
        compareAt: compareAt,
        clearCompareAt: compareAt == null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currency = kRegionCurrency[_region]!;
    return AlertDialog(
      title: Text(widget.initial == null ? 'Add Region' : 'Edit Region'),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LabeledDropdownField<String>(
              'Region',
              value: _region,
              items: kRegionCurrency.keys.toList(),
              itemLabel: (r) => '${regionLabelFor(r)} (${kRegionCurrency[r]})',
              onChanged: (v) => setState(() => _region = v ?? _region),
              required: true,
            ),
            const SizedBox(height: 16),
            LabeledTextField('Price ($currency)',
                required: true,
                controller: _amountController,
                hint: 'e.g., 12000',
                keyboardType: const TextInputType.numberWithOptions(decimal: true)),
            const SizedBox(height: 16),
            LabeledTextField('Compare at ($currency)',
                controller: _compareAtController,
                hint: 'Optional — shown struck through',
                keyboardType: const TextInputType.numberWithOptions(decimal: true)),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      actions: [
        SaveActionBar(onCancel: () => Navigator.of(context).pop(), onSave: _save, saveLabel: 'Save'),
      ],
    );
  }
}
