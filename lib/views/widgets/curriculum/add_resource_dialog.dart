import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/curriculum_controller.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_inputs.dart';
import '../../../models/admin/admin_models.dart';
import '../shared_widgets.dart';
import 'curriculum_form_fields.dart';
import 'resource_card.dart';
import 'save_action_bar.dart';

/// Backend enum `ResourceType`: NOTE | PYQ | RESOURCE — exact wire values.
const List<String> _resourceTypes = ['NOTE', 'PYQ', 'RESOURCE'];

/// Add-Resource form, shown as a dialog rather than a dedicated route —
/// resources are a lightweight sub-item of a lesson or chapter, not their
/// own navigable level in the Grade → Subject → Chapter → Lesson hierarchy.
/// Provide exactly one of [lessonId] (submits via
/// `CurriculumController.createLessonResource()`) or [chapterId] (submits
/// via `createChapterResource()`) — same form, same fields either way, per
/// the shared `CreateResourceDto` the backend takes for both scopes.
/// Returns true if a resource was created.
Future<bool> showAddResourceDialog(BuildContext context, {String? lessonId, String? chapterId}) async {
  assert((lessonId != null) != (chapterId != null), 'Provide exactly one of lessonId or chapterId.');
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => _AddResourceDialog(lessonId: lessonId, chapterId: chapterId),
  );
  return result ?? false;
}

class _AddResourceDialog extends StatefulWidget {
  const _AddResourceDialog({this.lessonId, this.chapterId});

  final String? lessonId;
  final String? chapterId;

  @override
  State<_AddResourceDialog> createState() => _AddResourceDialogState();
}

class _AddResourceDialogState extends State<_AddResourceDialog> {
  late final TextEditingController _titleController = TextEditingController();
  late final TextEditingController _fileKeyController = TextEditingController();
  late final TextEditingController _pageCountController = TextEditingController();
  late final TextEditingController _sizeController = TextEditingController();
  String _type = _resourceTypes.first;
  bool _isDownloadable = true;
  bool _saving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _fileKeyController.dispose();
    _pageCountController.dispose();
    _sizeController.dispose();
    super.dispose();
  }

  void _showMessage(String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      _showMessage('Resource title is required.');
      return;
    }
    final fileKey = _fileKeyController.text.trim();
    if (fileKey.isEmpty) {
      _showMessage('File / resource URL is required.');
      return;
    }

    int? pageCount;
    final pageCountText = _pageCountController.text.trim();
    if (pageCountText.isNotEmpty) {
      pageCount = int.tryParse(pageCountText);
      if (pageCount == null) {
        _showMessage('Page count must be a whole number.');
        return;
      }
    }

    int? sizeBytes;
    final sizeText = _sizeController.text.trim();
    if (sizeText.isNotEmpty) {
      sizeBytes = int.tryParse(sizeText);
      if (sizeBytes == null) {
        _showMessage('Size must be a whole number of bytes.');
        return;
      }
    }

    setState(() => _saving = true);
    final controller = context.read<CurriculumController>();
    final request = CreateResourceRequest(
      title: title,
      fileKey: fileKey,
      type: _type,
      pageCount: pageCount,
      sizeBytes: sizeBytes,
      isDownloadable: _isDownloadable,
    );
    final ok = widget.lessonId != null
        ? await controller.createLessonResource(widget.lessonId!, request)
        : await controller.createChapterResource(widget.chapterId!, request);
    if (!mounted) return;
    setState(() => _saving = false);

    if (ok) {
      Navigator.of(context).pop(true);
    } else {
      final error = widget.lessonId != null ? controller.lessonError : controller.chapterResourceError;
      _showMessage(error ?? 'Unable to add resource. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Resource'),
      content: SizedBox(
        width: 460,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LabeledDropdownField<String>(
                'Resource Type',
                value: _type,
                items: _resourceTypes,
                itemLabel: resourceTypeLabel,
                onChanged: (v) => setState(() => _type = v ?? _type),
                required: true,
              ),
              const SizedBox(height: 16),
              LabeledTextField('Title', required: true, controller: _titleController, hint: 'e.g., Chapter Notes'),
              const SizedBox(height: 16),
              LabeledTextField(
                'File / Resource URL',
                required: true,
                controller: _fileKeyController,
                hint: 'https://drive.google.com/… or a signed cloud URL',
              ),
              const SizedBox(height: 16),
              FlexRow(
                items: [
                  (1, LabeledTextField('Page Count', controller: _pageCountController, hint: 'Optional', keyboardType: TextInputType.number)),
                  (1, LabeledTextField('Size (bytes)', controller: _sizeController, hint: 'Optional', keyboardType: TextInputType.number)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Downloadable', style: AppTextStyles.cell),
                  AppToggle(value: _isDownloadable, onChanged: (v) => setState(() => _isDownloadable = v)),
                ],
              ),
            ],
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      actions: [
        SaveActionBar(
          onCancel: () => Navigator.of(context).pop(false),
          onSave: _saving ? () {} : _save,
          saveLabel: _saving ? 'Saving…' : 'Save Resource',
        ),
      ],
    );
  }
}
