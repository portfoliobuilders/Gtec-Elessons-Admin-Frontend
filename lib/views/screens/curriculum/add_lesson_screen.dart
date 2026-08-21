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
import '../../widgets/curriculum/save_action_bar.dart';
import '../../widgets/nav_presets.dart';
import '../../widgets/shared_widgets.dart';

/// Add/Edit Lesson — dedicated page inside the existing AdminShell, mirroring
/// add_chapter_screen.dart's pattern. Fields match CreateLessonDto/
/// UpdateLessonDto exactly — `durationSeconds` only appears in edit mode
/// (create doesn't accept it) and the YouTube video is a genuinely separate
/// save action (`POST /admin/lessons/:id/video`), only available once the
/// lesson exists.
///
/// `batchIds` is on both DTOs but deliberately not exposed here — there is
/// no batch list/data source anywhere in this app yet (no AdminBatchesService),
/// so a selector would have to offer fake ids. Documented, not worked around.
class AddLessonScreen extends StatefulWidget {
  const AddLessonScreen({super.key});

  @override
  State<AddLessonScreen> createState() => _AddLessonScreenState();
}

class _AddLessonScreenState extends State<AddLessonScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _displayOrderController;
  late final TextEditingController _durationController;
  late final TextEditingController _youtubeController;
  bool _isFreePreview = false;
  bool _isPublished = true;
  bool _saving = false;
  bool _savingVideo = false;

  AdminLessonModel? _existing;

  @override
  void initState() {
    super.initState();
    final controller = context.read<CurriculumController>();
    _existing = controller.selectedCurriculumLessonId != null ? controller.selectedCurriculumLesson : null;

    _titleController = TextEditingController(text: _existing?.title ?? '');
    _descriptionController = TextEditingController(text: _existing?.description ?? '');
    _displayOrderController = TextEditingController(text: _existing?.order.toString() ?? '');
    _durationController = TextEditingController(text: _existing?.durationSeconds?.toString() ?? '');
    _youtubeController = TextEditingController(text: _existing?.youtubeId ?? '');
    _isFreePreview = _existing?.isFreePreview ?? false;
    _isPublished = _existing?.isPublished ?? true;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _displayOrderController.dispose();
    _durationController.dispose();
    _youtubeController.dispose();
    super.dispose();
  }

  bool get _isEditing => _existing != null;

  void _goBack() => Navigator.of(context).pushReplacementNamed(AppRoutes.curriculumChapterDetail);

  void _showMessage(String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      _showMessage('Lesson title is required.');
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

    int? durationSeconds;
    if (_isEditing) {
      final durationText = _durationController.text.trim();
      if (durationText.isNotEmpty) {
        durationSeconds = int.tryParse(durationText);
        if (durationSeconds == null) {
          _showMessage('Duration must be a whole number of seconds.');
          return;
        }
      }
    }

    final description = _descriptionController.text.trim();

    setState(() => _saving = true);
    final controller = context.read<CurriculumController>();
    final bool ok;
    if (_isEditing) {
      ok = await controller.updateLesson(
        _existing!.id,
        UpdateLessonRequest(
          title: title,
          description: description.isEmpty ? null : description,
          order: order,
          isFreePreview: _isFreePreview,
          isPublished: _isPublished,
          durationSeconds: durationSeconds,
        ),
      );
    } else {
      ok = await controller.createLesson(
        controller.selectedCurriculumChapter.id,
        CreateLessonRequest(
          title: title,
          description: description.isEmpty ? null : description,
          order: order,
          isFreePreview: _isFreePreview,
          isPublished: _isPublished,
        ),
      );
    }
    if (!mounted) return;
    setState(() => _saving = false);

    if (ok) {
      _goBack();
      _showMessage(_isEditing ? 'Lesson updated.' : 'Lesson created.');
    } else {
      _showMessage(controller.lessonError ?? 'Something went wrong. Please try again.');
    }
  }

  /// The backend now accepts a bare video id or a full YouTube URL and
  /// extracts/validates the id itself — Flutter sends whatever was typed
  /// as-is (still the existing `youtubeId` field) and only checks it isn't
  /// empty. After a successful save, the text field is updated to the
  /// backend-normalized id from the refreshed lesson (see
  /// CurriculumController.setLessonVideo, which reloads the lesson list).
  Future<void> _saveVideo() async {
    final raw = _youtubeController.text.trim();
    if (raw.isEmpty) {
      _showMessage('Enter a YouTube video URL or id.');
      return;
    }

    setState(() => _savingVideo = true);
    final controller = context.read<CurriculumController>();
    final ok = await controller.setLessonVideo(_existing!.id, raw);
    if (!mounted) return;
    setState(() => _savingVideo = false);
    if (ok) _youtubeController.text = controller.selectedCurriculumLesson.youtubeId ?? raw;
    _showMessage(ok ? 'Video updated.' : controller.lessonError ?? 'Unable to set video.');
  }

  @override
  Widget build(BuildContext context) {
    final chapter = context.watch<CurriculumController>().selectedCurriculumChapter;

    return AdminShell(
      navItems: NavPresets.admin,
      activeIndex: 1,
      user: NavPresets.gtecAdmin,
      titleWidget: CurriculumBreadcrumb(
        segments: [
          CrumbSegment('Curriculum', onTap: () => Navigator.of(context).pushReplacementNamed(AppRoutes.curriculum)),
          CrumbSegment(chapter.name, onTap: _goBack),
          CrumbSegment(_isEditing ? 'Edit Lesson' : 'Add Lesson'),
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
              title: _isEditing ? 'Edit Lesson' : 'Add Lesson',
              subtitle: _isEditing
                  ? 'Update the details for "${_existing!.title}".'
                  : 'Create a new lesson for ${chapter.name}.',
            ),
            const SizedBox(height: 24),
            CurriculumFormCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FormSection(
                    icon: AppIcons.play,
                    title: 'Basic Information',
                    subtitle: 'Enter the basic details of the lesson.',
                    children: [
                      LabeledTextField('Lesson Title',
                          required: true,
                          controller: _titleController,
                          hint: 'Enter lesson title (e.g., Introduction to Algebra)'),
                      const SizedBox(height: 18),
                      FlexRow(
                        items: [
                          (1, LabeledTextField('Display Order',
                              controller: _displayOrderController,
                              hint: 'Enter display order (e.g., 1)',
                              keyboardType: TextInputType.number)),
                          if (_isEditing)
                            (1, LabeledTextField('Duration (seconds)',
                                controller: _durationController,
                                hint: 'e.g., 754 for 12:34',
                                keyboardType: TextInputType.number)),
                        ],
                      ),
                      const SizedBox(height: 18),
                      LabeledTextField('Description',
                          controller: _descriptionController,
                          hint: 'Enter a short description of this lesson… (optional)',
                          maxLines: 4),
                      const SizedBox(height: 18),
                      Container(height: 1, color: AppColors.hairline),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Free preview', style: AppTextStyles.cell),
                          AppToggle(value: _isFreePreview, onChanged: (v) => setState(() => _isFreePreview = v)),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Published', style: AppTextStyles.cell),
                          AppToggle(value: _isPublished, onChanged: (v) => setState(() => _isPublished = v)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 26),
                  SaveActionBar(
                    onCancel: _goBack,
                    onSave: _saving ? () {} : _save,
                    saveLabel: _saving ? 'Saving…' : (_isEditing ? 'Save Changes' : 'Save Lesson'),
                  ),
                ],
              ),
            ),
            if (_isEditing) ...[
              const SizedBox(height: 24),
              CurriculumFormCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FormSection(
                      icon: AppIcons.play,
                      title: 'Video',
                      subtitle: 'Paste the full YouTube URL, or just the video id — the backend accepts either.',
                      children: [
                        LabeledTextField('YouTube Video URL',
                            controller: _youtubeController, hint: 'https://youtu.be/xvT1jH8B9AM'),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerRight,
                      child: PrimaryButton(
                        label: _savingVideo ? 'Saving…' : 'Set Video',
                        iconPaths: AppIcons.check,
                        onTap: _savingVideo ? () {} : _saveVideo,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
