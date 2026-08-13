import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/curriculum_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_inputs.dart';
import '../../../models/admin/admin_models.dart';
import '../../../routes/app_routes.dart';
import '../../layouts/admin_shell.dart';
import '../../widgets/curriculum/curriculum_breadcrumb.dart';
import '../../widgets/curriculum/curriculum_form_card.dart';
import '../../widgets/curriculum/curriculum_form_fields.dart';
import '../../widgets/curriculum/curriculum_header.dart';
import '../../widgets/curriculum/form_section.dart';
import '../../widgets/curriculum/regional_pricing_section.dart';
import '../../widgets/curriculum/save_action_bar.dart';
import '../../widgets/nav_presets.dart';
import '../../widgets/shared_widgets.dart';

final RegExp _youtubeIdPattern = RegExp(r'^[A-Za-z0-9_-]{11}$');

/// Add/Edit Grade — dedicated page (not a dialog) inside the existing
/// AdminShell. Fields mirror the backend's CreateGradeDto/UpdateGradeDto
/// exactly — `isActive` only appears in edit mode since CreateGradeDto
/// doesn't accept it. Saving calls the real `POST`/`PATCH /admin/grades`
/// endpoints and returns to Grade Selection.
class AddGradeScreen extends StatefulWidget {
  const AddGradeScreen({super.key});

  @override
  State<AddGradeScreen> createState() => _AddGradeScreenState();
}

class _AddGradeScreenState extends State<AddGradeScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _boardController;
  late final TextEditingController _syllabusController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _displayOrderController;
  late final TextEditingController _trailerYoutubeIdController;
  late final TextEditingController _thumbnailUrlController;
  bool _active = true;
  bool _saving = false;

  AdminGradeModel? _existing;

  // Regional pricing — `_originalPrices`/`_productId` are hydrated
  // asynchronously in edit mode (the curriculum tree's own `prices` don't
  // carry a price id, only `AdminPricingService.list()` does — see
  // CurriculumController.findProductFor). `_prices` is what the form
  // actually edits; reconciled against `_originalPrices` on save.
  List<PriceRow> _prices = [];
  List<PriceRow> _originalPrices = [];
  String? _productId;
  bool _pricingLoading = false;

  @override
  void initState() {
    super.initState();
    final controller = context.read<CurriculumController>();
    _existing = controller.selectedCurriculumGradeId != null ? controller.selectedCurriculumGrade : null;

    _nameController = TextEditingController(text: _existing?.name ?? '');
    _boardController = TextEditingController(text: _existing?.board ?? 'CBSE');
    _syllabusController = TextEditingController(text: _existing?.syllabus ?? '');
    _descriptionController = TextEditingController(text: _existing?.description ?? '');
    _displayOrderController = TextEditingController(text: _existing?.order.toString() ?? '');
    _trailerYoutubeIdController = TextEditingController(text: _existing?.trailerYoutubeId ?? '');
    _thumbnailUrlController = TextEditingController(text: _existing?.trailerThumbnailUrl ?? '');
    _active = _existing?.isActive ?? true;

    if (_existing != null) _loadPricing();
  }

  Future<void> _loadPricing() async {
    setState(() => _pricingLoading = true);
    final product = await context.read<CurriculumController>().findProductFor(gradeId: _existing!.id);
    if (!mounted) return;
    setState(() {
      _productId = product?.id;
      _originalPrices = priceRowsFrom(product?.prices ?? const []);
      _prices = List.of(_originalPrices);
      _pricingLoading = false;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _boardController.dispose();
    _syllabusController.dispose();
    _descriptionController.dispose();
    _displayOrderController.dispose();
    _trailerYoutubeIdController.dispose();
    _thumbnailUrlController.dispose();
    super.dispose();
  }

  bool get _isEditing => _existing != null;

  void _goBack() => Navigator.of(context).pushReplacementNamed(AppRoutes.curriculum);

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _showMessage('Grade name is required.');
      return;
    }

    final orderText = _displayOrderController.text.trim();
    int? order;
    if (orderText.isNotEmpty) {
      order = int.tryParse(orderText);
      if (order == null) {
        _showMessage('Display order must be a whole number.');
        return;
      }
    }

    final trailerYoutubeId = _trailerYoutubeIdController.text.trim();
    if (trailerYoutubeId.isNotEmpty && !_youtubeIdPattern.hasMatch(trailerYoutubeId)) {
      _showMessage('Trailer YouTube ID must be exactly 11 characters (the video id, not the full URL).');
      return;
    }

    final seenRegions = <String>{};
    for (final row in _prices) {
      final key = '${row.region}/${row.currency}';
      if (!seenRegions.add(key)) {
        _showMessage('${regionLabelFor(row.region)} ($key) is configured more than once. Remove the duplicate first.');
        return;
      }
    }

    final board = _boardController.text.trim();
    final syllabus = _syllabusController.text.trim();
    final description = _descriptionController.text.trim();
    final thumbnailUrl = _thumbnailUrlController.text.trim();

    setState(() => _saving = true);
    final controller = context.read<CurriculumController>();
    final bool ok;
    String? priceError;
    if (_isEditing) {
      ok = await controller.updateGrade(
        _existing!.id,
        UpdateGradeRequest(
          name: name,
          board: board.isEmpty ? null : board,
          syllabus: syllabus.isEmpty ? null : syllabus,
          description: description.isEmpty ? null : description,
          trailerYoutubeId: trailerYoutubeId.isEmpty ? null : trailerYoutubeId,
          thumbnailUrl: thumbnailUrl.isEmpty ? null : thumbnailUrl,
          order: order,
          isActive: _active,
        ),
      );
      if (ok) {
        priceError =
            await reconcileRegionalPrices(controller, productId: _productId, original: _originalPrices, current: _prices);
      }
    } else {
      ok = await controller.createGrade(
        CreateGradeRequest(
          name: name,
          board: board.isEmpty ? null : board,
          syllabus: syllabus.isEmpty ? null : syllabus,
          description: description.isEmpty ? null : description,
          trailerYoutubeId: trailerYoutubeId.isEmpty ? null : trailerYoutubeId,
          thumbnailUrl: thumbnailUrl.isEmpty ? null : thumbnailUrl,
          order: order,
          prices: _prices.isEmpty
              ? null
              : [for (final r in _prices) CreatePriceRequest(region: r.region, currency: r.currency, amount: r.amount, compareAt: r.compareAt)],
        ),
      );
    }
    if (!mounted) return;
    setState(() => _saving = false);

    if (ok && priceError != null) {
      _showMessage(priceError);
      return;
    }

    if (ok) {
      _goBack();
      _showMessage(_isEditing ? 'Grade updated.' : 'Grade created.');
    } else {
      _showMessage(controller.curriculumError ?? 'Something went wrong. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      navItems: NavPresets.admin,
      activeIndex: 1,
      user: NavPresets.riyaContentAdmin,
      titleWidget: CurriculumBreadcrumb(
        segments: [
          CrumbSegment('Curriculum', onTap: _goBack),
          CrumbSegment(_isEditing ? 'Edit Grade' : 'Add Grade'),
        ],
      ),
      actions: [
        OutlineButtonX(label: 'Back', iconPaths: AppIcons.chevronLeft, onTap: _goBack),
      ],
      body: PageBody(
        topPadding: 26,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CurriculumHeader(
              title: _isEditing ? 'Edit Grade' : 'Add Grade',
              subtitle: _isEditing
                  ? 'Update the details for "${_existing!.name}".'
                  : 'Create a new grade to organize subjects, chapters and lessons.',
            ),
            const SizedBox(height: 24),
            CurriculumFormCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FormSection(
                    icon: AppIcons.book,
                    title: 'Basic Information',
                    subtitle: 'Enter the basic details of the grade.',
                    children: [
                      FlexRow(
                        items: [
                          (1, LabeledTextField('Grade Name',
                              required: true,
                              controller: _nameController,
                              hint: 'Enter grade name (e.g., Grade XI)')),
                          (1, LabeledTextField('Board', controller: _boardController, hint: 'e.g., CBSE')),
                        ],
                      ),
                      const SizedBox(height: 18),
                      FlexRow(
                        items: [
                          (1, LabeledTextField('Syllabus',
                              controller: _syllabusController, hint: 'e.g., NCERT 2025-26 (optional)')),
                          (1, LabeledTextField('Display Order',
                              controller: _displayOrderController,
                              hint: 'Enter display order (e.g., 11)',
                              keyboardType: TextInputType.number)),
                        ],
                      ),
                      const SizedBox(height: 18),
                      LabeledTextField('Description',
                          controller: _descriptionController,
                          hint: 'Enter a short description about this grade… (optional)',
                          maxLines: 4),
                    ],
                  ),
                  const SizedBox(height: 26),
                  FormSection(
                    icon: AppIcons.play,
                    title: 'Media',
                    subtitle: 'Optional trailer shown on the storefront.',
                    children: [
                      FlexRow(
                        items: [
                          (1, LabeledTextField('Trailer YouTube ID',
                              controller: _trailerYoutubeIdController,
                              hint: '11-character video id (optional)')),
                          (1, LabeledTextField('Thumbnail URL',
                              controller: _thumbnailUrlController,
                              hint: 'Defaults to the YouTube thumbnail (optional)')),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 26),
                  FormSection(
                    icon: AppIcons.calculator,
                    title: 'Pricing',
                    subtitle: 'Regional prices for this grade\'s full-class bundle.',
                    children: [
                      RegionalPricingSection(
                        rows: _prices,
                        loading: _pricingLoading,
                        onChanged: (next) => setState(() => _prices = next),
                      ),
                    ],
                  ),
                  if (_isEditing) ...[
                    const SizedBox(height: 22),
                    Container(height: 1, color: AppColors.hairline),
                    const SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Status',
                                  style: AppTextStyles.jakarta(
                                      size: 13.5, weight: FontWeight.w800, color: AppColors.ink)),
                              const SizedBox(height: 3),
                              Text('Inactive grades are hidden from students.',
                                  style: AppTextStyles.jakarta(
                                      size: 12, weight: FontWeight.w600, color: AppColors.grey)),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            AppToggle(value: _active, onChanged: (v) => setState(() => _active = v)),
                            const SizedBox(width: 10),
                            Text(_active ? 'Active' : 'Inactive',
                                style: AppTextStyles.jakarta(
                                    size: 13,
                                    weight: FontWeight.w700,
                                    color: _active ? AppColors.green : AppColors.grey)),
                          ],
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 26),
                  SaveActionBar(
                    onCancel: _goBack,
                    onSave: _saving ? () {} : _save,
                    saveLabel: _saving ? 'Saving…' : (_isEditing ? 'Save Changes' : 'Save Grade'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
