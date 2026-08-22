import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/curriculum_controller.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../models/admin/admin_models.dart';
import '../../../routes/app_routes.dart';
import '../../layouts/admin_shell.dart';
import '../../widgets/curriculum/curriculum_breadcrumb.dart';
import '../../widgets/curriculum/curriculum_form_card.dart';
import '../../widgets/curriculum/curriculum_form_fields.dart';
import '../../widgets/curriculum/curriculum_header.dart';
import '../../widgets/curriculum/cover_image_uploader.dart';
import '../../widgets/curriculum/form_section.dart';
import '../../widgets/curriculum/regional_pricing_section.dart';
import '../../widgets/curriculum/save_action_bar.dart';
import '../../widgets/nav_presets.dart';
import '../../widgets/shared_widgets.dart';

/// Add/Edit Subject — dedicated page inside the existing AdminShell, mirroring
/// add_grade_screen.dart's pattern. Fields match CreateSubjectDto/
/// UpdateSubjectDto exactly — no Teacher field (the backend never returns
/// teacherId/teacherName on any admin subject response, so assigning one
/// from this form would silently do nothing) and no Status toggle (`Subject`
/// has no `isActive` field on the backend at all, unlike `Grade`).
class AddSubjectScreen extends StatefulWidget {
  const AddSubjectScreen({super.key});

  @override
  State<AddSubjectScreen> createState() => _AddSubjectScreenState();
}

class _AddSubjectScreenState extends State<AddSubjectScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _codeController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _displayOrderController;
  late final TextEditingController _iconUrlController;
  late final TextEditingController _trailerYoutubeIdController;
  late final TextEditingController _thumbnailUrlController;
  bool _saving = false;

  AdminSubjectModel? _existing;

  // See add_grade_screen.dart's identical block for why this is hydrated
  // asynchronously and reconciled separately from the core fields.
  List<PriceRow> _prices = [];
  List<PriceRow> _originalPrices = [];
  String? _productId;
  bool _pricingLoading = false;

  // See add_grade_screen.dart's identical block.
  Uint8List? _pendingCoverBytes;
  String? _pendingCoverFilename;

  @override
  void initState() {
    super.initState();
    final controller = context.read<CurriculumController>();
    _existing = controller.selectedCurriculumSubjectId != null ? controller.selectedCurriculumSubject : null;

    _nameController = TextEditingController(text: _existing?.name ?? '');
    _codeController = TextEditingController(text: _existing?.code ?? '');
    _descriptionController = TextEditingController(text: _existing?.description ?? '');
    _displayOrderController = TextEditingController(text: _existing?.order.toString() ?? '');
    _iconUrlController = TextEditingController(text: _existing?.iconUrl ?? '');
    _trailerYoutubeIdController = TextEditingController(text: _existing?.trailerYoutubeId ?? '');
    _thumbnailUrlController = TextEditingController(text: _existing?.trailerThumbnailUrl ?? '');

    if (_existing != null) _loadPricing();
  }

  Future<void> _loadPricing() async {
    setState(() => _pricingLoading = true);
    final product = await context.read<CurriculumController>().findProductFor(subjectId: _existing!.id);
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
    _codeController.dispose();
    _descriptionController.dispose();
    _displayOrderController.dispose();
    _iconUrlController.dispose();
    _trailerYoutubeIdController.dispose();
    _thumbnailUrlController.dispose();
    super.dispose();
  }

  bool get _isEditing => _existing != null;

  void _goBack() => Navigator.of(context).pushReplacementNamed(AppRoutes.curriculumGradeDetail);

  void _showMessage(String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _showMessage('Subject name is required.');
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

    // Accepts a bare video id or a full YouTube URL — the backend extracts
    // and validates the id server-side, so Flutter only checks non-empty.
    final trailerYoutubeId = _trailerYoutubeIdController.text.trim();

    final seenRegions = <String>{};
    for (final row in _prices) {
      final key = '${row.region}/${row.currency}';
      if (!seenRegions.add(key)) {
        _showMessage('${regionLabelFor(row.region)} ($key) is configured more than once. Remove the duplicate first.');
        return;
      }
    }

    final code = _codeController.text.trim();
    final description = _descriptionController.text.trim();
    final iconUrl = _iconUrlController.text.trim();
    final thumbnailUrl = _thumbnailUrlController.text.trim();

    setState(() => _saving = true);
    final controller = context.read<CurriculumController>();

    if (_isEditing) {
      final ok = await controller.updateSubject(
        _existing!.id,
        UpdateSubjectRequest(
          name: name,
          code: code.isEmpty ? null : code,
          description: description.isEmpty ? null : description,
          trailerYoutubeId: trailerYoutubeId.isEmpty ? null : trailerYoutubeId,
          thumbnailUrl: thumbnailUrl.isEmpty ? null : thumbnailUrl,
          order: order,
          iconUrl: iconUrl.isEmpty ? null : iconUrl,
        ),
      );
      String? priceError;
      if (ok) {
        priceError =
            await reconcileRegionalPrices(controller, productId: _productId, original: _originalPrices, current: _prices);
      }
      if (!mounted) return;
      setState(() => _saving = false);

      if (ok && priceError != null) {
        _showMessage(priceError);
        return;
      }
      if (ok) {
        _goBack();
        _showMessage('Subject updated.');
      } else {
        _showMessage(controller.curriculumError ?? 'Something went wrong. Please try again.');
      }
      return;
    }

    // Create mode.
    final created = await controller.createSubject(
      controller.selectedCurriculumGrade.id,
      CreateSubjectRequest(
        name: name,
        code: code.isEmpty ? null : code,
        description: description.isEmpty ? null : description,
        trailerYoutubeId: trailerYoutubeId.isEmpty ? null : trailerYoutubeId,
        thumbnailUrl: thumbnailUrl.isEmpty ? null : thumbnailUrl,
        order: order,
        iconUrl: iconUrl.isEmpty ? null : iconUrl,
        prices: _prices.isEmpty
            ? null
            : [for (final r in _prices) CreatePriceRequest(region: r.region, currency: r.currency, amount: r.amount, compareAt: r.compareAt)],
      ),
    );
    if (!mounted) return;

    if (created == null) {
      setState(() => _saving = false);
      _showMessage(controller.curriculumError ?? 'Something went wrong. Please try again.');
      return;
    }

    if (_pendingCoverBytes == null) {
      setState(() => _saving = false);
      _goBack();
      _showMessage('Subject created.');
      return;
    }

    final uploaded = await controller.uploadSubjectCover(created.id, _pendingCoverBytes!, _pendingCoverFilename!);
    if (!mounted) return;
    setState(() => _saving = false);
    if (uploaded) {
      _goBack();
      _showMessage('Subject created.');
    } else {
      _showMessage('Subject created, but the cover image could not be uploaded. You can add it from Edit Subject.');
      controller.selectCurriculumSubject(created.id);
      Navigator.of(context).pushReplacementNamed(AppRoutes.curriculumAddSubject);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watched (not just read) so the Cover Image box reflects the fresh
    // `iconUrl` after `loadCurriculum()` refreshes post-upload — `_existing`
    // itself is a frozen snapshot from initState and never re-derived.
    final curriculumController = context.watch<CurriculumController>();
    final grade = curriculumController.selectedCurriculumGrade;
    final currentSubject = _isEditing ? curriculumController.selectedCurriculumSubject : null;

    return AdminShell(
      navItems: NavPresets.admin,
      activeIndex: 1,
      user: NavPresets.gtecAdmin,
      titleWidget: CurriculumBreadcrumb(
        segments: [
          CrumbSegment('Curriculum', onTap: () => Navigator.of(context).pushReplacementNamed(AppRoutes.curriculum)),
          CrumbSegment(grade.name, onTap: _goBack),
          CrumbSegment(_isEditing ? 'Edit Subject' : 'Add Subject'),
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
              title: _isEditing ? 'Edit Subject' : 'Add Subject',
              subtitle: _isEditing
                  ? 'Update the details for "${_existing!.name}".'
                  : 'Create a new subject for ${grade.name}.',
            ),
            const SizedBox(height: 24),
            CurriculumSplitLayout(
              left: CurriculumFormCard(
                maxWidth: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FormSection(
                      icon: AppIcons.book,
                      title: 'Basic Information',
                      subtitle: 'Enter the basic details of the subject.',
                      children: [
                        FlexRow(
                          items: [
                            (1, LabeledTextField('Subject Name',
                                required: true,
                                controller: _nameController,
                                hint: 'Enter subject name (e.g., Physics)')),
                            (1, LabeledTextField('Subject Code',
                                controller: _codeController, hint: 'e.g., PHY11 (optional)')),
                          ],
                        ),
                        const SizedBox(height: 18),
                        LabeledTextField('Display Order',
                            controller: _displayOrderController,
                            hint: 'Enter display order (e.g., 1)',
                            keyboardType: TextInputType.number),
                        const SizedBox(height: 18),
                        LabeledTextField('Description',
                            controller: _descriptionController,
                            hint: 'Enter a short description about this subject… (optional)',
                            maxLines: 4),
                      ],
                    ),
                    const SizedBox(height: 26),
                    FormSection(
                      icon: AppIcons.play,
                      title: 'Media',
                      subtitle: 'Optional icon and trailer shown on the storefront.',
                      children: [
                        LabeledTextField('Icon URL',
                            controller: _iconUrlController, hint: 'URL to an icon image (optional)'),
                        const SizedBox(height: 18),
                        FlexRow(
                          items: [
                            (1, LabeledTextField('Trailer YouTube URL',
                                controller: _trailerYoutubeIdController,
                                hint: 'https://youtu.be/xvT1jH8B9AM (optional)')),
                            (1, LabeledTextField('Thumbnail URL',
                                controller: _thumbnailUrlController,
                                hint: 'Defaults to the YouTube thumbnail (optional)')),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              right: CurriculumFormCard(
                maxWidth: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FormSection(
                      icon: AppIcons.upload,
                      title: 'Cover / Preview',
                      subtitle: 'Shown wherever this subject is displayed.',
                      children: [
                        if (_isEditing)
                          CoverImageUploader(
                            currentImageUrl: currentSubject!.iconUrl,
                            uploading: curriculumController.isUploadingCover,
                            onUpload: (bytes, filename) =>
                                curriculumController.uploadSubjectCover(_existing!.id, bytes, filename),
                            onRemove: currentSubject.iconUrl == null
                                ? null
                                : () => curriculumController.removeSubjectCover(_existing!.id),
                          )
                        else
                          CoverImageUploader(
                            pendingBytes: _pendingCoverBytes,
                            onPendingImageSelected: (bytes, filename) => setState(() {
                              _pendingCoverBytes = bytes;
                              _pendingCoverFilename = filename;
                            }),
                          ),
                      ],
                    ),
                    const SizedBox(height: 26),
                    FormSection(
                      icon: AppIcons.calculator,
                      title: 'Pricing',
                      subtitle: 'Regional prices for this subject — independent of the grade\'s pricing.',
                      children: [
                        RegionalPricingSection(
                          rows: _prices,
                          loading: _pricingLoading,
                          onChanged: (next) => setState(() => _prices = next),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1240),
                child: SaveActionBar(
                  onCancel: _goBack,
                  onSave: _saving ? () {} : _save,
                  saveLabel: _saving ? 'Saving…' : (_isEditing ? 'Save Changes' : 'Save Subject'),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
