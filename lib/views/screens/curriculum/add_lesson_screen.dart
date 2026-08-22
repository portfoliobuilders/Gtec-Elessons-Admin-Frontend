import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/curriculum_controller.dart';
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

/// Add/Edit Lesson — dedicated page inside the existing AdminShell. Fields
/// match CreateLessonDto/UpdateLessonDto exactly — `durationSeconds` only
/// appears in edit mode (create doesn't accept it).
///
/// The YouTube video field is available from the very first save, in both
/// create and edit mode — there is exactly one Video URL input on this
/// screen (Section 11 of the redesign spec: "not two copies"). Saving:
///  1. Calls the existing create/update lesson API.
///  2. Gets the lesson's real id back (the create response, or the
///     already-known id in edit mode).
///  3. If a video URL was entered, calls the existing
///     `POST /admin/lessons/:id/video` API via
///     `CurriculumController.setLessonVideo` — no new backend endpoint.
///  4/5. Reports success/failure with the app's existing snackbar pattern;
///     a video-step failure never claims the lesson itself failed to save.
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
    // Accepts a bare video id or a full YouTube URL — the backend extracts
    // and validates the id server-side, so Flutter only checks non-empty.
    final videoInput = _youtubeController.text.trim();

    setState(() => _saving = true);
    final controller = context.read<CurriculumController>();

    bool lessonOk;
    String? lessonId;
    if (_isEditing) {
      lessonId = _existing!.id;
      lessonOk = await controller.updateLesson(
        lessonId,
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
      final created = await controller.createLesson(
        controller.selectedCurriculumChapter.id,
        CreateLessonRequest(
          title: title,
          description: description.isEmpty ? null : description,
          order: order,
          isFreePreview: _isFreePreview,
          isPublished: _isPublished,
        ),
      );
      lessonOk = created != null;
      lessonId = created?.id;
    }

    if (!mounted) return;

    if (!lessonOk || lessonId == null) {
      setState(() => _saving = false);
      _showMessage(controller.lessonError ?? 'Something went wrong. Please try again.');
      return;
    }

    // The lesson itself is saved. A video-step failure from here on must
    // never be reported as if the lesson save itself failed — it didn't.
    if (videoInput.isEmpty) {
      setState(() => _saving = false);
      _goBack();
      _showMessage(_isEditing ? 'Lesson updated.' : 'Lesson created.');
      return;
    }

    final videoOk = await controller.setLessonVideo(lessonId, videoInput);
    if (!mounted) return;
    setState(() => _saving = false);

    if (videoOk) {
      _goBack();
      _showMessage(_isEditing ? 'Lesson updated.' : 'Lesson created.');
      return;
    }

    if (_isEditing) {
      _showMessage(
          '${'Lesson updated, but the video could not be saved.'} ${controller.lessonError ?? 'Please try again.'}');
    } else {
      _showMessage('Lesson created, but the video could not be saved. You can add it from Edit Lesson.');
      controller.selectCurriculumLesson(lessonId);
      Navigator.of(context).pushReplacementNamed(AppRoutes.curriculumAddLesson);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CurriculumController>();
    final grade = controller.selectedCurriculumGrade;
    final subject = controller.selectedCurriculumSubject;
    final chapter = controller.selectedCurriculumChapter;

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
                  : '${grade.name} · ${subject.name} · ${chapter.name}',
            ),
            const SizedBox(height: 24),
            CurriculumSplitLayout(
              left: CurriculumFormCard(
                maxWidth: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FormSection(
                      icon: AppIcons.play,
                      title: 'Lesson Information',
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
                      icon: AppIcons.info,
                      title: 'Publishing',
                      subtitle: 'Controls whether students can see this lesson.',
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Published', style: AppTextStyles.cell),
                            AppToggle(value: _isPublished, onChanged: (v) => setState(() => _isPublished = v)),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Free Preview', style: AppTextStyles.cell),
                            AppToggle(value: _isFreePreview, onChanged: (v) => setState(() => _isFreePreview = v)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 26),
                    FormSection(
                      icon: AppIcons.play,
                      title: 'Video',
                      subtitle: 'Paste the full YouTube URL, or just the video id — saved together with the lesson.',
                      children: [
                        LabeledTextField('YouTube Video URL',
                            controller: _youtubeController, hint: 'https://youtu.be/xvT1jH8B9AM (optional)'),
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
                  saveLabel: _saving ? 'Saving…' : (_isEditing ? 'Save Changes' : 'Save Lesson'),
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
