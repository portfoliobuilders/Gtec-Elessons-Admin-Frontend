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

/// Add/Edit Chapter — dedicated page inside the existing AdminShell,
/// mirroring add_subject_screen.dart's pattern. Fields match
/// CreateChapterDto/UpdateChapterDto exactly — no pricing (out of scope
/// this phase) and no Status toggle (`Chapter` has no `isActive` field at
/// all on the backend, same situation as `Subject`).
class AddChapterScreen extends StatefulWidget {
  const AddChapterScreen({super.key});

  @override
  State<AddChapterScreen> createState() => _AddChapterScreenState();
}

class _AddChapterScreenState extends State<AddChapterScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _displayOrderController;
  late final TextEditingController _trailerYoutubeIdController;
  late final TextEditingController _thumbnailUrlController;
  bool _saving = false;

  AdminChapterModel? _existing;

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
    _existing = controller.selectedCurriculumChapterId != null ? controller.selectedCurriculumChapter : null;

    _nameController = TextEditingController(text: _existing?.name ?? '');
    _descriptionController = TextEditingController(text: _existing?.description ?? '');
    _displayOrderController = TextEditingController(text: _existing?.order.toString() ?? '');
    _trailerYoutubeIdController = TextEditingController(text: _existing?.trailerYoutubeId ?? '');
    _thumbnailUrlController = TextEditingController(text: _existing?.trailerThumbnailUrl ?? '');

    if (_existing != null) _loadPricing();
  }

  Future<void> _loadPricing() async {
    setState(() => _pricingLoading = true);
    final product = await context.read<CurriculumController>().findProductFor(chapterId: _existing!.id);
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
    _descriptionController.dispose();
    _displayOrderController.dispose();
    _trailerYoutubeIdController.dispose();
    _thumbnailUrlController.dispose();
    super.dispose();
  }

  bool get _isEditing => _existing != null;

  void _goBack() => Navigator.of(context).pushReplacementNamed(AppRoutes.curriculumSubjects);

  void _showMessage(String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _showMessage('Chapter name is required.');
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

    final description = _descriptionController.text.trim();
    final thumbnailUrl = _thumbnailUrlController.text.trim();

    setState(() => _saving = true);
    final controller = context.read<CurriculumController>();

    if (_isEditing) {
      final ok = await controller.updateChapter(
        _existing!.id,
        UpdateChapterRequest(
          name: name,
          description: description.isEmpty ? null : description,
          trailerYoutubeId: trailerYoutubeId.isEmpty ? null : trailerYoutubeId,
          thumbnailUrl: thumbnailUrl.isEmpty ? null : thumbnailUrl,
          order: order,
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
        _showMessage('Chapter updated.');
      } else {
        _showMessage(controller.curriculumError ?? 'Something went wrong. Please try again.');
      }
      return;
    }

    // Create mode.
    final created = await controller.createChapter(
      controller.selectedCurriculumSubject.id,
      CreateChapterRequest(
        name: name,
        description: description.isEmpty ? null : description,
        trailerYoutubeId: trailerYoutubeId.isEmpty ? null : trailerYoutubeId,
        thumbnailUrl: thumbnailUrl.isEmpty ? null : thumbnailUrl,
        order: order,
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
      _showMessage('Chapter created.');
      return;
    }

    final uploaded = await controller.uploadChapterCover(created.id, _pendingCoverBytes!, _pendingCoverFilename!);
    if (!mounted) return;
    setState(() => _saving = false);
    if (uploaded) {
      _goBack();
      _showMessage('Chapter created.');
    } else {
      _showMessage('Chapter created, but the cover image could not be uploaded. You can add it from Edit Chapter.');
      controller.selectCurriculumChapter(created.id);
      Navigator.of(context).pushReplacementNamed(AppRoutes.curriculumAddChapter);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watched (not just read) so the Cover Image box reflects the fresh
    // `iconUrl` after `loadCurriculum()` refreshes post-upload — `_existing`
    // itself is a frozen snapshot from initState and never re-derived.
    final curriculumController = context.watch<CurriculumController>();
    final subject = curriculumController.selectedCurriculumSubject;
    final currentChapter = _isEditing ? curriculumController.selectedCurriculumChapter : null;

    return AdminShell(
      navItems: NavPresets.admin,
      activeIndex: 1,
      user: NavPresets.gtecAdmin,
      titleWidget: CurriculumBreadcrumb(
        segments: [
          CrumbSegment('Curriculum', onTap: () => Navigator.of(context).pushReplacementNamed(AppRoutes.curriculum)),
          CrumbSegment(subject.name, onTap: _goBack),
          CrumbSegment(_isEditing ? 'Edit Chapter' : 'Add Chapter'),
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
              title: _isEditing ? 'Edit Chapter' : 'Add Chapter',
              subtitle: _isEditing
                  ? 'Update the details for "${_existing!.name}".'
                  : 'Create a new chapter for ${subject.name}.',
            ),
            const SizedBox(height: 24),
            CurriculumSplitLayout(
              left: CurriculumFormCard(
                maxWidth: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FormSection(
                      icon: AppIcons.fileCorner,
                      title: 'Basic Information',
                      subtitle: 'Enter the basic details of the chapter.',
                      children: [
                        LabeledTextField('Chapter Name',
                            required: true,
                            controller: _nameController,
                            hint: 'Enter chapter name (e.g., Real Numbers)'),
                        const SizedBox(height: 18),
                        LabeledTextField('Display Order',
                            controller: _displayOrderController,
                            hint: 'Enter display order (e.g., 1)',
                            keyboardType: TextInputType.number),
                        const SizedBox(height: 18),
                        LabeledTextField('Description',
                            controller: _descriptionController,
                            hint: 'Enter a short description about this chapter… (optional)',
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
                      title: 'Cover Image',
                      subtitle: 'Shown wherever this chapter is displayed.',
                      children: [
                        if (_isEditing)
                          CoverImageUploader(
                            currentImageUrl: currentChapter!.iconUrl,
                            uploading: curriculumController.isUploadingCover,
                            onUpload: (bytes, filename) =>
                                curriculumController.uploadChapterCover(_existing!.id, bytes, filename),
                            onRemove: currentChapter.iconUrl == null
                                ? null
                                : () => curriculumController.removeChapterCover(_existing!.id),
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
                      subtitle: 'Optional — regional prices if this chapter is sold on its own.',
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
                  saveLabel: _saving ? 'Saving…' : (_isEditing ? 'Save Changes' : 'Save Chapter'),
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
