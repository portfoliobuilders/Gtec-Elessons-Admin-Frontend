import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/curriculum_controller.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_inputs.dart';
import '../../../models/admin/admin_models.dart';
import '../shared_widgets.dart';
import 'curriculum_form_fields.dart';
import 'resource_card.dart';
import 'save_action_bar.dart';

const List<String> _resourceTypes = ['NOTE', 'PYQ', 'RESOURCE'];
const int _maxPdfBytes = 20 * 1024 * 1024;

enum _ResourceSource { file, link }

/// Adds one resource to either scope. Links use JSON; PDFs use the same
/// endpoint with multipart field `file`.
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
  _ResourceSource _source = _ResourceSource.link;
  Uint8List? _pdfBytes;
  String? _pdfFilename;
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

  bool _hasPdfHeader(Uint8List bytes) {
    const signature = [0x25, 0x50, 0x44, 0x46, 0x2D]; // %PDF-
    final lastStart = bytes.length - signature.length;
    final limit = lastStart < 1024 ? lastStart : 1024;
    for (var start = 0; start <= limit; start++) {
      var matches = true;
      for (var index = 0; index < signature.length; index++) {
        if (bytes[start + index] != signature[index]) {
          matches = false;
          break;
        }
      }
      if (matches) return true;
    }
    return false;
  }

  /// Version 11.0.3 exposes selected bytes but not a MIME type, so extension
  /// validation is backed by checking the PDF signature in those bytes.
  Future<void> _pickPdf() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    final bytes = file.bytes;
    if (file.extension?.toLowerCase() != 'pdf' || bytes == null || !_hasPdfHeader(bytes)) {
      _showMessage('Please select a valid PDF file.');
      return;
    }
    if (bytes.lengthInBytes > _maxPdfBytes) {
      _showMessage('PDF files must be 20 MB or smaller.');
      return;
    }
    if (!mounted) return;
    setState(() {
      _pdfBytes = bytes;
      _pdfFilename = file.name;
    });
  }

  Future<void> _save() async {
    if (_saving) return;

    final title = _titleController.text.trim();
    if (title.isEmpty) {
      _showMessage('Resource title is required.');
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
    if (_source == _ResourceSource.link) {
      final sizeText = _sizeController.text.trim();
      if (sizeText.isNotEmpty) {
        sizeBytes = int.tryParse(sizeText);
        if (sizeBytes == null) {
          _showMessage('Size must be a whole number of bytes.');
          return;
        }
      }
      if (_fileKeyController.text.trim().isEmpty) {
        _showMessage('File / resource URL is required.');
        return;
      }
    } else {
      final bytes = _pdfBytes;
      if (bytes == null || _pdfFilename == null || !_hasPdfHeader(bytes)) {
        _showMessage('Please select a valid PDF file.');
        return;
      }
      if (bytes.lengthInBytes > _maxPdfBytes) {
        _showMessage('PDF files must be 20 MB or smaller.');
        return;
      }
    }

    setState(() => _saving = true);
    final controller = context.read<CurriculumController>();
    final bool ok;
    if (_source == _ResourceSource.file) {
      final request = CreateResourceFileRequest(
        title: title,
        type: _type,
        pageCount: pageCount,
        isDownloadable: _isDownloadable,
      );
      ok = widget.lessonId != null
          ? await controller.createLessonResourceFile(widget.lessonId!, request, _pdfBytes!, _pdfFilename!)
          : await controller.createChapterResourceFile(widget.chapterId!, request, _pdfBytes!, _pdfFilename!);
    } else {
      final request = CreateResourceRequest(
        title: title,
        fileKey: _fileKeyController.text.trim(),
        type: _type,
        pageCount: pageCount,
        sizeBytes: sizeBytes,
        isDownloadable: _isDownloadable,
      );
      ok = widget.lessonId != null
          ? await controller.createLessonResource(widget.lessonId!, request)
          : await controller.createChapterResource(widget.chapterId!, request);
    }

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
    final isFile = _source == _ResourceSource.file;
    final selectedFileSize = formatResourceSize(_pdfBytes?.lengthInBytes);

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
              Text('Resource Source', style: AppTextStyles.cell),
              const SizedBox(height: 8),
              SegmentedControl(
                segments: const ['File', 'Link'],
                selected: isFile ? 0 : 1,
                onChanged: _saving
                    ? null
                    : (index) => setState(() => _source = index == 0 ? _ResourceSource.file : _ResourceSource.link),
              ),
              const SizedBox(height: 16),
              if (isFile) ...[
                Row(
                  children: [
                    OutlineButtonX(
                      label: _pdfBytes == null ? 'Choose PDF' : 'Change PDF',
                      height: 40,
                      onTap: _saving ? null : _pickPdf,
                    ),
                    if (_pdfBytes != null) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_pdfFilename!, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.cell),
                            if (selectedFileSize != null)
                              Text(selectedFileSize, style: AppTextStyles.jakarta(size: 12, weight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                LabeledTextField('Page Count', controller: _pageCountController, hint: 'Optional', keyboardType: TextInputType.number),
              ] else ...[
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
              ],
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Downloadable', style: AppTextStyles.cell),
                  AppToggle(value: _isDownloadable, onChanged: _saving ? null : (v) => setState(() => _isDownloadable = v)),
                ],
              ),
            ],
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      actions: [
        SaveActionBar(
          onCancel: _saving ? () {} : () => Navigator.of(context).pop(false),
          onSave: _saving ? () {} : _save,
          saveLabel: _saving ? 'Saving…' : 'Save Resource',
        ),
      ],
    );
  }
}
