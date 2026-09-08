import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/curriculum_controller.dart';
import '../../../controllers/video_upload_manager.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/network/browser_video_upload.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_inputs.dart';
import '../../../core/widgets/confirm_dialog.dart';
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
/// YouTube and local upload are independent. Save the lesson first, then
/// save each changed source. Successful steps are retained for retries.
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
  bool _allowOffline = true;
  bool _saving = false;
  BrowserVideoFile? _selectedVideo;
  late String _savedYoutubeInput;
  bool get _youtubeChanged =>
      _youtubeController.text.trim() != _savedYoutubeInput;

  AdminLessonModel? _existing;

  @override
  void initState() {
    super.initState();
    final controller = context.read<CurriculumController>();
    _existing = controller.selectedCurriculumLessonId != null
        ? controller.selectedCurriculumLesson
        : null;

    _titleController = TextEditingController(text: _existing?.title ?? '');
    _descriptionController =
        TextEditingController(text: _existing?.description ?? '');
    _displayOrderController =
        TextEditingController(text: _existing?.order.toString() ?? '');
    _durationController = TextEditingController(
        text: _existing?.durationSeconds?.toString() ?? '');
    _savedYoutubeInput = (_existing?.youtubeId?.trim().isNotEmpty ?? false)
        ? _existing!.youtubeId!.trim()
        : (_existing?.youtubeUrl ?? '').trim();
    _youtubeController = TextEditingController(text: _savedYoutubeInput);
    _isFreePreview = _existing?.isFreePreview ?? false;
    _isPublished = _existing?.isPublished ?? true;
    _allowOffline = _existing?.allowOffline ?? true;
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

  void _goBack() => Navigator.of(context)
      .pushReplacementNamed(AppRoutes.curriculumChapterDetail);

  void _showMessage(String message) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(message)));

  String _formatFileSize(int bytes) {
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    var size = bytes.toDouble();
    var index = 0;
    while (size >= 1024 && index < units.length - 1) {
      size /= 1024;
      index++;
    }
    return index == 0
        ? '${size.toStringAsFixed(0)} ${units[index]}'
        : '${size.toStringAsFixed(2)} ${units[index]}';
  }

  Future<void> _pickVideo() async {
    if (_saving) return;
    final file = await pickBrowserVideoFile();
    if (!mounted || file == null) return;

    final extension =
        file.name.contains('.') ? file.name.split('.').last.toLowerCase() : '';
    if (!const {'mp4', 'webm', 'mov'}.contains(extension)) {
      _showMessage('Please select an MP4, WebM, or MOV video.');
      return;
    }
    if (file.name.trim().isEmpty || file.size <= 0) {
      _showMessage('Please select a non-empty video file.');
      return;
    }
    setState(() => _selectedVideo = file);
  }

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
    final shouldSetYoutube = videoInput.isNotEmpty && _youtubeChanged;

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
          allowOffline: _allowOffline,
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
          allowOffline: _allowOffline,
        ),
      );
      lessonOk = created != null;
      lessonId = created?.id;
    }

    if (!mounted) return;

    if (!lessonOk || lessonId == null) {
      setState(() => _saving = false);
      _showMessage(
          controller.lessonError ?? 'Something went wrong. Please try again.');
      return;
    }

    // The lesson itself is saved. A video-step failure from here on must
    // never be reported as if the lesson save itself failed — it didn't.
    final wasEditing = _isEditing;
    // Keep the created lesson id on failure so retry never creates a duplicate.
    _existing ??= controller.chapterLessons.firstWhere(
        (lesson) => lesson.id == lessonId,
        orElse: () => AdminLessonModel(
            id: lessonId!,
            title: title,
            chapterId: controller.selectedCurriculumChapter.id));
    final video = _selectedVideo;
    final shouldUploadVideo = video != null;

    if (!shouldSetYoutube && !shouldUploadVideo) {
      setState(() => _saving = false);
      _goBack();
      _showMessage(wasEditing ? 'Lesson updated.' : 'Lesson created.');
      return;
    }

    if (shouldSetYoutube) {
      final youtubeOk = await controller.setLessonVideo(lessonId, videoInput);
      if (!mounted) return;
      if (youtubeOk) {
        _savedYoutubeInput = videoInput;
      } else {
        setState(() => _saving = false);
        _showMessage(
            'Lesson saved, but YouTube could not be saved: ${controller.lessonError ?? 'Please try again.'}');
        return;
      }
    }
    if (shouldUploadVideo) {
      final uploads = context.read<VideoUploadManager>();
      var submission =
          uploads.submit(lessonId: lessonId, lessonTitle: title, file: video);
      if (submission.admission == VideoUploadAdmission.lessonConflict) {
        final replace = await showConfirmDialog(
          context,
          title: 'Replace uploading video?',
          message: 'A video is already uploading for this lesson.',
          confirmLabel: 'Cancel & Replace',
          cancelLabel: 'Keep Current',
        );
        if (!mounted) return;
        if (!replace) {
          setState(() => _saving = false);
          _showMessage('The current video upload is still running.');
          return;
        }
        submission = await uploads.cancelAndReplace(
            lessonId: lessonId, lessonTitle: title, file: video);
      }
      if (!submission.accepted) {
        setState(() => _saving = false);
        _showMessage(submission.message ?? 'Video upload could not be added.');
        return;
      }
      _selectedVideo = null;
    }
    if (!mounted) return;
    setState(() {
      _saving = false;
      for (final lesson in controller.chapterLessons) {
        if (lesson.id == lessonId) _existing = lesson;
      }
    });

    _goBack();
    _showMessage(shouldUploadVideo
        ? '${wasEditing ? 'Lesson updated' : 'Lesson created'}. Video upload is managed in Upload Center.'
        : (wasEditing ? 'Lesson updated.' : 'Lesson created.'));
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
          CrumbSegment('Curriculum',
              onTap: () => Navigator.of(context)
                  .pushReplacementNamed(AppRoutes.curriculum)),
          CrumbSegment(chapter.name, onTap: _goBack),
          CrumbSegment(_isEditing ? 'Edit Lesson' : 'Add Lesson'),
        ],
      ),
      actions: [
        OutlineButtonX(
            label: 'Back', iconPaths: AppIcons.chevronLeft, onTap: _goBack),
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
                            hint:
                                'Enter lesson title (e.g., Introduction to Algebra)'),
                        const SizedBox(height: 18),
                        FlexRow(
                          items: [
                            (
                              1,
                              LabeledTextField('Display Order',
                                  controller: _displayOrderController,
                                  hint: 'Enter display order (e.g., 1)',
                                  keyboardType: TextInputType.number)
                            ),
                            if (_isEditing)
                              (
                                1,
                                LabeledTextField('Duration (seconds)',
                                    controller: _durationController,
                                    hint: 'e.g., 754 for 12:34',
                                    keyboardType: TextInputType.number)
                              ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        LabeledTextField('Description',
                            controller: _descriptionController,
                            hint:
                                'Enter a short description of this lesson… (optional)',
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
                      subtitle:
                          'Controls whether students can see this lesson.',
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Published', style: AppTextStyles.cell),
                            AppToggle(
                                value: _isPublished,
                                onChanged: (v) =>
                                    setState(() => _isPublished = v)),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Free Preview', style: AppTextStyles.cell),
                            AppToggle(
                                value: _isFreePreview,
                                onChanged: (v) =>
                                    setState(() => _isFreePreview = v)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 26),
                    FormSection(
                      icon: AppIcons.play,
                      title: 'Video',
                      subtitle:
                          'Add either or both videos. Uploaded video takes playback priority.',
                      children: [
                        Text('YouTube Video', style: AppTextStyles.cell),
                        const SizedBox(height: 16),
                        LabeledTextField('YouTube Video URL',
                            controller: _youtubeController,
                            hint: 'https://youtu.be/xvT1jH8B9AM (optional)'),
                        const SizedBox(height: 26),
                        Text('Local Uploaded Video', style: AppTextStyles.cell),
                        const SizedBox(height: 16),
                        _buildVideoUploadFields(),
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
                  saveLabel: _saving
                      ? 'Saving…'
                      : (_isEditing ? 'Save Changes' : 'Save Lesson'),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoUploadFields() {
    final selected = _selectedVideo;
    final existingIsUpload = [
          _existing?.videoUrl,
          _existing?.videoFileName,
          _existing?.videoMimeType
        ].any((value) => value?.trim().isNotEmpty ?? false) ||
        _existing?.videoSizeBytes != null;
    final existingName = _existing?.videoFileName;
    final uploadTask = _existing == null
        ? null
        : context.watch<VideoUploadManager>().taskForLesson(_existing!.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Video File', style: AppTextStyles.cell),
        const SizedBox(height: 8),
        Row(
          children: [
            OutlineButtonX(
              label: selected == null
                  ? (existingIsUpload ? 'Replace Video' : 'Choose Video')
                  : 'Change',
              iconPaths: AppIcons.upload,
              onTap: _saving ? null : _pickVideo,
            ),
            if (selected != null || existingIsUpload) ...[
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selected?.name ?? existingName ?? 'Local Video',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.cell,
                    ),
                    Text(
                      selected != null
                          ? _formatFileSize(selected.size)
                          : (_existing?.videoSizeBytes == null
                              ? 'Connected'
                              : _formatFileSize(_existing!.videoSizeBytes!)),
                      style: AppTextStyles.jakarta(
                          size: 12, weight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        if (selected == null && existingIsUpload) ...[
          const SizedBox(height: 10),
          Text('✓ Local video connected',
              style: AppTextStyles.jakarta(size: 12, weight: FontWeight.w700)),
        ] else if (selected == null) ...[
          const SizedBox(height: 10),
          Text('No video connected',
              style: AppTextStyles.jakarta(size: 12, weight: FontWeight.w600)),
        ],
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Allow Offline Download', style: AppTextStyles.cell),
                  const SizedBox(height: 4),
                  Text(
                    'Allow students to download this uploaded video for offline viewing.',
                    style: AppTextStyles.jakarta(
                        size: 11.5, weight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            AppToggle(
                value: _allowOffline,
                onChanged: _saving
                    ? null
                    : (value) => setState(() => _allowOffline = value)),
          ],
        ),
        if (uploadTask != null &&
            (uploadTask.status == VideoUploadStatus.uploading ||
                uploadTask.status == VideoUploadStatus.queued)) ...[
          const SizedBox(height: 16),
          Text(
              uploadTask.status == VideoUploadStatus.queued
                  ? 'Video queued for upload'
                  : 'Uploading video… ${(uploadTask.progress * 100).round()}%',
              style: AppTextStyles.cell),
          const SizedBox(height: 8),
          LinearProgressIndicator(
              value: uploadTask.status == VideoUploadStatus.uploading
                  ? uploadTask.progress
                  : null),
        ],
        const SizedBox(height: 6),
        Text(
            'MP4, WebM, or MOV. Large files upload directly from the browser file handle.',
            style: AppTextStyles.jakarta(size: 11.5, weight: FontWeight.w600)),
      ],
    );
  }
}
