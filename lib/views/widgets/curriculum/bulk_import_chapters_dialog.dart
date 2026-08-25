import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/curriculum_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/curriculum_bulk_import.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/grid_table.dart';
import '../../../models/admin/admin_models.dart';

/// Bulk-create chapters from a locally-parsed `.xlsx` workbook — the file
/// itself is never sent to the backend; only the parsed JSON goes through
/// the existing `POST /admin/subjects/:subjectId/chapters/bulk` endpoint,
/// via `CurriculumController.bulkCreateChapters` (Screen → Controller →
/// Service → ApiClient, same as every other curriculum mutation). Returns
/// `true` if at least one chapter was actually created (so the caller
/// knows to show a success/partial-success message) — the dialog itself
/// already refreshes the curriculum tree before closing.
Future<bool> showBulkImportChaptersDialog(BuildContext context, {required String subjectId}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => _BulkImportChaptersDialog(subjectId: subjectId),
  );
  return result ?? false;
}

enum _Stage { pickFile, preview, importing, done }

class _BulkImportChaptersDialog extends StatefulWidget {
  const _BulkImportChaptersDialog({required this.subjectId});

  final String subjectId;

  @override
  State<_BulkImportChaptersDialog> createState() => _BulkImportChaptersDialogState();
}

class _BulkImportChaptersDialogState extends State<_BulkImportChaptersDialog> {
  _Stage _stage = _Stage.pickFile;
  String? _fileName;
  ChapterImportResult? _result;

  int _processed = 0;
  int _currentBatch = 0;
  int _totalBatches = 0;
  String? _batchError;
  bool _pickErrored = false;

  Future<void> _pickFile() async {
    setState(() => _pickErrored = false);
    // Pinned to `file_picker: 11.0.3` — same version/rationale already
    // established for CoverImageUploader (12.0.0's federated web split
    // breaks release web builds); its `PlatformFile.bytes` is synchronous.
    final result = await FilePicker.pickFiles(type: FileType.custom, allowedExtensions: ['xlsx'], withData: true);
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    final bytes = file.bytes;
    if (bytes == null) {
      setState(() => _pickErrored = true);
      return;
    }
    final parsed = parseChapterExcel(bytes);
    if (!mounted) return;
    setState(() {
      _fileName = file.name;
      _result = parsed;
      _stage = _Stage.preview;
    });
  }

  Future<void> _import() async {
    final result = _result;
    if (result == null || result.chapters.isEmpty) return;

    final batches = batchForBulkImport(result.chapters);
    setState(() {
      _stage = _Stage.importing;
      _processed = 0;
      _totalBatches = batches.length;
      _currentBatch = 0;
      _batchError = null;
    });

    final controller = context.read<CurriculumController>();
    for (int i = 0; i < batches.length; i++) {
      setState(() => _currentBatch = i + 1);
      try {
        await controller.bulkCreateChapters(widget.subjectId, batches[i]);
      } on ApiException catch (e) {
        setState(() => _batchError = e.message);
        break;
      } catch (_) {
        setState(() => _batchError = 'Unable to reach the server. Please try again.');
        break;
      }
      if (!mounted) return;
      setState(() => _processed += batches[i].length);
    }

    // Refresh whatever actually made it in, whether this run fully
    // succeeded or stopped partway — a partial import still changed real
    // data and must be reflected, not hidden behind a failure message.
    if (_processed > 0) {
      await controller.loadCurriculum();
    }
    if (!mounted) return;
    setState(() => _stage = _Stage.done);
  }

  void _close() => Navigator.of(context).pop(_processed > 0);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Import Chapters'),
      content: SizedBox(width: 640, child: _buildBody()),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      actions: _buildActions(),
    );
  }

  Widget _buildBody() {
    switch (_stage) {
      case _Stage.pickFile:
        return _PickFileBody(
          description: 'Columns: name, description, order, region, currency, amount, format, accessDays. '
              'Rows sharing the same "name" become one chapter with multiple regional prices.',
          onPick: _pickFile,
          errored: _pickErrored,
        );
      case _Stage.preview:
        return _ChapterPreviewBody(fileName: _fileName!, result: _result!);
      case _Stage.importing:
        return _ImportingBody(
          label: 'Creating chapters',
          processed: _processed,
          total: _result!.chapters.length,
          batch: _currentBatch,
          totalBatches: _totalBatches,
        );
      case _Stage.done:
        return _DoneBody(
          processed: _processed,
          total: _result!.chapters.length,
          noun: _processed == 1 ? 'chapter' : 'chapters',
          batchError: _batchError,
          batch: _currentBatch,
          totalBatches: _totalBatches,
        );
    }
  }

  List<Widget> _buildActions() {
    switch (_stage) {
      case _Stage.pickFile:
        return [OutlineButtonX(label: 'Cancel', onTap: () => Navigator.of(context).pop(false))];
      case _Stage.preview:
        final count = _result!.chapters.length;
        return [
          OutlineButtonX(label: 'Cancel', onTap: () => Navigator.of(context).pop(false)),
          const SizedBox(width: 10),
          PrimaryButton(
            label: count == 0 ? 'No valid chapters' : 'Import $count ${count == 1 ? 'Chapter' : 'Chapters'}',
            iconPaths: AppIcons.upload,
            onTap: count == 0 ? null : _import,
          ),
        ];
      case _Stage.importing:
        return const [];
      case _Stage.done:
        return [PrimaryButton(label: 'Close', iconPaths: AppIcons.check, onTap: _close)];
    }
  }
}

class _PickFileBody extends StatelessWidget {
  const _PickFileBody({required this.description, required this.onPick, required this.errored});

  final String description;
  final VoidCallback onPick;
  final bool errored;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(description, style: AppTextStyles.jakarta(size: 13, weight: FontWeight.w600, color: AppColors.muted, height: 1.5)),
        const SizedBox(height: 20),
        Center(
          child: OutlineButtonX(label: 'Choose Excel File (.xlsx)', iconPaths: AppIcons.upload, onTap: onPick),
        ),
        if (errored) ...[
          const SizedBox(height: 12),
          Text('Could not read that file. Please try again.',
              style: AppTextStyles.jakarta(size: 12.5, weight: FontWeight.w600, color: AppColors.red)),
        ],
      ],
    );
  }
}

class _ChapterPreviewBody extends StatelessWidget {
  const _ChapterPreviewBody({required this.fileName, required this.result});

  final String fileName;
  final ChapterImportResult result;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(fileName, style: AppTextStyles.jakarta(size: 12.5, weight: FontWeight.w700, color: AppColors.grey)),
        const SizedBox(height: 6),
        Text(
          '${result.rowCount} row(s) → ${result.chapters.length} chapter(s) ready to import'
          '${result.hasErrors ? ' — ${result.errors.length} row(s) have issues.' : '.'}',
          style: AppTextStyles.jakarta(size: 13, weight: FontWeight.w700, color: AppColors.ink),
        ),
        if (result.hasErrors) ...[
          const SizedBox(height: 10),
          _ErrorList(errors: result.errors),
        ],
        if (result.chapters.isNotEmpty) ...[
          const SizedBox(height: 14),
          _ChapterTable(chapters: result.chapters),
        ],
      ],
    );
  }
}

class _ChapterTable extends StatelessWidget {
  const _ChapterTable({required this.chapters});

  final List<BulkChapterItemRequest> chapters;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const GridHeaderRow(flexes: [2.2, 1, 0.8, 1.2], labels: ['Name', 'Description', 'Order', 'Prices']),
          SizedBox(
            height: 220,
            child: ListView.builder(
              itemCount: chapters.length,
              itemBuilder: (context, i) {
                final c = chapters[i];
                return GridRow(
                  flexes: const [2.2, 1, 0.8, 1.2],
                  bottomBorder: i != chapters.length - 1,
                  cells: [
                    Text(c.name, overflow: TextOverflow.ellipsis, style: AppTextStyles.cellStrong),
                    Text(c.description ?? '—', overflow: TextOverflow.ellipsis, style: AppTextStyles.cellSub),
                    Text(c.order?.toString() ?? '—', style: AppTextStyles.cell),
                    Text('${c.prices.length}', style: AppTextStyles.cell),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorList extends StatelessWidget {
  const _ErrorList({required this.errors});

  final List<BulkImportRowError> errors;

  @override
  Widget build(BuildContext context) {
    const int cap = 30;
    return Container(
      constraints: const BoxConstraints(maxHeight: 160),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.redBg, borderRadius: BorderRadius.circular(12)),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final e in errors.take(cap))
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(e.toString(), style: AppTextStyles.jakarta(size: 12, weight: FontWeight.w600, color: AppColors.red)),
              ),
            if (errors.length > cap)
              Text('…and ${errors.length - cap} more issue(s).',
                  style: AppTextStyles.jakarta(size: 12, weight: FontWeight.w700, color: AppColors.red)),
          ],
        ),
      ),
    );
  }
}

class _ImportingBody extends StatelessWidget {
  const _ImportingBody({
    required this.label,
    required this.processed,
    required this.total,
    required this.batch,
    required this.totalBatches,
  });

  final String label;
  final int processed;
  final int total;
  final int batch;
  final int totalBatches;

  @override
  Widget build(BuildContext context) {
    final double progress = total == 0 ? 0 : processed / total;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.hairline,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 14),
          Text('$label: $processed / $total',
              style: AppTextStyles.jakarta(size: 13.5, weight: FontWeight.w800, color: AppColors.ink)),
          const SizedBox(height: 4),
          Text('Batch $batch of $totalBatches',
              style: AppTextStyles.jakarta(size: 12, weight: FontWeight.w600, color: AppColors.grey)),
        ],
      ),
    );
  }
}

class _DoneBody extends StatelessWidget {
  const _DoneBody({
    required this.processed,
    required this.total,
    required this.noun,
    required this.batchError,
    required this.batch,
    required this.totalBatches,
  });

  final int processed;
  final int total;
  final String noun;
  final String? batchError;
  final int batch;
  final int totalBatches;

  @override
  Widget build(BuildContext context) {
    final bool failed = batchError != null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(color: failed ? AppColors.redBg : AppColors.greenBg, shape: BoxShape.circle),
            child: Center(
              child: AppIcon(failed ? AppIcons.info : AppIcons.check,
                  size: 24, color: failed ? AppColors.red : AppColors.green, strokeWidth: 1.8),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            failed ? 'Import stopped — batch $batch of $totalBatches failed.' : 'Import complete.',
            textAlign: TextAlign.center,
            style: AppTextStyles.jakarta(size: 15, weight: FontWeight.w800, color: AppColors.ink),
          ),
          const SizedBox(height: 6),
          Text(
            failed
                ? '$processed of $total $noun were created before the failure.\n${batchError!}'
                : '$processed $noun created.',
            textAlign: TextAlign.center,
            style: AppTextStyles.jakarta(size: 12.5, weight: FontWeight.w600, color: AppColors.grey),
          ),
        ],
      ),
    );
  }
}
