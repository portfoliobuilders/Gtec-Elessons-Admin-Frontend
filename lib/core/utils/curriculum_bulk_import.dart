import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:excel/excel.dart';

import '../../models/admin/admin_models.dart';
import '../../views/widgets/curriculum/regional_pricing_section.dart' show kRegionCurrency;

/// Excel → JSON parsing/validation for the Curriculum "Import Chapters" /
/// "Import Lessons" bulk-create flows. The workbook is only ever read
/// locally (bytes already picked by `file_picker`, never uploaded) — this
/// file turns those bytes into the same request models the existing
/// `POST /admin/subjects/:id/chapters/bulk` and
/// `POST /admin/chapters/:id/lessons/bulk` JSON contracts expect. No widget
/// and no API call lives here; screens call these functions, then hand the
/// result to `CurriculumController`.

const int kBulkImportBatchSize = 100;

/// Splits [items] into sequential batches of at most [kBulkImportBatchSize]
/// — for chapters, [items] is already one entry per *chapter* (each
/// carrying its own full `prices` list), so a chapter's regional prices can
/// never be split across two batches.
List<List<T>> batchForBulkImport<T>(List<T> items, {int batchSize = kBulkImportBatchSize}) {
  final batches = <List<T>>[];
  for (int i = 0; i < items.length; i += batchSize) {
    final end = (i + batchSize < items.length) ? i + batchSize : items.length;
    batches.add(items.sublist(i, end));
  }
  return batches;
}

/// One flagged problem found while parsing — [rowNumber] is 1-based and
/// counts the header row as row 1 (i.e. matches what a human sees if they
/// open the sheet), so "Row 5: ..." always points at the right line.
class BulkImportRowError {
  const BulkImportRowError(this.rowNumber, this.message);

  final int rowNumber;
  final String message;

  @override
  String toString() => 'Row $rowNumber: $message';
}

const List<String> kProductFormats = ['RECORDED', 'LIVE_AND_RECORDED'];

// ── Chapters ────────────────────────────────────────────────────────────

const List<String> kChapterExcelHeaders = [
  'name',
  'description',
  'order',
  'region',
  'currency',
  'amount',
  'format',
  'accessDays',
];

class ChapterImportResult {
  const ChapterImportResult({required this.chapters, required this.errors, required this.rowCount});

  /// One entry per distinct chapter name, each with its grouped `prices`.
  final List<BulkChapterItemRequest> chapters;
  final List<BulkImportRowError> errors;

  /// Total data rows read (excluding the header) — used for the "N records"
  /// summary even when some of them failed validation.
  final int rowCount;

  bool get hasErrors => errors.isNotEmpty;
}

/// Parses the first worksheet of a `.xlsx` workbook using the Chapter
/// column layout (Section "CHAPTER EXCEL"). Multiple rows sharing the same
/// `name` are grouped into one chapter, each row contributing one entry to
/// that chapter's `prices[]` (skipped entirely for a row with no
/// region/currency/amount at all — a chapter with no pricing yet).
ChapterImportResult parseChapterExcel(Uint8List bytes) {
  final List<List<Data?>> rows;
  try {
    rows = _readRows(bytes);
  } on _XlsxDecodeException catch (e) {
    return ChapterImportResult(chapters: const [], errors: [BulkImportRowError(1, e.message)], rowCount: 0);
  }
  if (rows.isEmpty) {
    return const ChapterImportResult(chapters: [], errors: [BulkImportRowError(1, 'The sheet is empty.')], rowCount: 0);
  }

  final headerError = _checkHeaders(rows.first, kChapterExcelHeaders);
  if (headerError != null) {
    return ChapterImportResult(chapters: const [], errors: [BulkImportRowError(1, headerError)], rowCount: 0);
  }

  final dataRows = rows.skip(1).toList();
  final errors = <BulkImportRowError>[];

  // name → (description, order, prices, first-seen row for error messages)
  final chapterOrder = <String>[]; // preserves first-seen order
  final descriptions = <String, String?>{};
  final orders = <String, int?>{};
  final prices = <String, List<BulkChapterPriceRequest>>{};
  final priceRegionRows = <String, Map<String, int>>{}; // chapter -> region -> row (dup detection)

  for (int i = 0; i < dataRows.length; i++) {
    final rowNumber = i + 2; // +1 for 0-index, +1 for the header row
    final row = dataRows[i];
    if (_isBlankRow(row)) continue;

    final name = _cellText(row, 0);
    if (name.isEmpty) {
      errors.add(BulkImportRowError(rowNumber, '"name" is required.'));
      continue;
    }

    final description = _cellText(row, 1);
    final orderText = _cellText(row, 2);
    int? order;
    if (orderText.isNotEmpty) {
      order = int.tryParse(orderText);
      if (order == null) {
        errors.add(BulkImportRowError(rowNumber, '"order" must be a whole number (got "$orderText").'));
        continue;
      }
    }

    if (!chapterOrder.contains(name)) {
      chapterOrder.add(name);
      prices[name] = [];
      priceRegionRows[name] = {};
    }
    // First non-empty description/order seen for this chapter name wins —
    // later rows for the same chapter are normally price-only variants.
    descriptions.putIfAbsent(name, () => description.isEmpty ? null : description);
    if (descriptions[name] == null && description.isNotEmpty) descriptions[name] = description;
    orders.putIfAbsent(name, () => order);
    orders[name] ??= order;

    final region = _cellText(row, 3).toUpperCase();
    final currency = _cellText(row, 4).toUpperCase();
    final amountText = _cellText(row, 5);
    final format = _cellText(row, 6).toUpperCase();
    final accessDaysText = _cellText(row, 7);

    // A row with no pricing fields at all is just chapter identity — valid,
    // nothing to add to `prices[]`.
    if (region.isEmpty && currency.isEmpty && amountText.isEmpty) continue;

    if (region.isEmpty || currency.isEmpty || amountText.isEmpty) {
      errors.add(BulkImportRowError(
          rowNumber, 'A regional price needs "region", "currency" and "amount" all set (or leave all three blank).'));
      continue;
    }

    if (!kRegionCurrency.containsKey(region)) {
      errors.add(BulkImportRowError(rowNumber, 'Unknown region "$region".'));
      continue;
    }
    if (kRegionCurrency[region] != currency) {
      errors.add(BulkImportRowError(
          rowNumber, '"$region" uses currency ${kRegionCurrency[region]}, not "$currency".'));
      continue;
    }

    final amount = num.tryParse(amountText);
    if (amount == null || amount <= 0) {
      errors.add(BulkImportRowError(rowNumber, '"amount" must be a positive number (got "$amountText").'));
      continue;
    }

    String? formatValue;
    if (format.isNotEmpty) {
      if (!kProductFormats.contains(format)) {
        errors.add(BulkImportRowError(
            rowNumber, '"format" must be one of ${kProductFormats.join(', ')} (got "$format").'));
        continue;
      }
      formatValue = format;
    }

    int? accessDays;
    if (accessDaysText.isNotEmpty) {
      accessDays = int.tryParse(accessDaysText);
      if (accessDays == null || accessDays <= 0) {
        errors.add(BulkImportRowError(rowNumber, '"accessDays" must be a positive whole number (got "$accessDaysText").'));
        continue;
      }
    }

    final seenRows = priceRegionRows[name]!;
    if (seenRows.containsKey(region)) {
      errors.add(BulkImportRowError(
          rowNumber, 'Duplicate regional price — "$name" already has a $region price at row ${seenRows[region]}.'));
      continue;
    }
    seenRows[region] = rowNumber;

    prices[name]!.add(BulkChapterPriceRequest(
      region: region,
      currency: currency,
      amount: amount,
      format: formatValue,
      accessDays: accessDays,
    ));
  }

  final chapters = [
    for (final name in chapterOrder)
      BulkChapterItemRequest(
        name: name,
        description: descriptions[name],
        order: orders[name],
        prices: prices[name] ?? const [],
      ),
  ];

  return ChapterImportResult(chapters: chapters, errors: errors, rowCount: dataRows.where((r) => !_isBlankRow(r)).length);
}

// ── Lessons ─────────────────────────────────────────────────────────────

const List<String> kLessonExcelHeaders = [
  'title',
  'description',
  'order',
  'isFreePreview',
  'isPublished',
  'youtubeUrl',
];

class LessonImportResult {
  const LessonImportResult({required this.lessons, required this.errors, required this.rowCount});

  final List<BulkLessonItemRequest> lessons;
  final List<BulkImportRowError> errors;
  final int rowCount;

  bool get hasErrors => errors.isNotEmpty;
}

/// Parses the first worksheet of a `.xlsx` workbook using the Lesson column
/// layout (Section "LESSON EXCEL") — one row is always one lesson, no
/// grouping.
LessonImportResult parseLessonExcel(Uint8List bytes) {
  final List<List<Data?>> rows;
  try {
    rows = _readRows(bytes);
  } on _XlsxDecodeException catch (e) {
    return LessonImportResult(lessons: const [], errors: [BulkImportRowError(1, e.message)], rowCount: 0);
  }
  if (rows.isEmpty) {
    return const LessonImportResult(lessons: [], errors: [BulkImportRowError(1, 'The sheet is empty.')], rowCount: 0);
  }

  final headerError = _checkHeaders(rows.first, kLessonExcelHeaders);
  if (headerError != null) {
    return LessonImportResult(lessons: const [], errors: [BulkImportRowError(1, headerError)], rowCount: 0);
  }

  final dataRows = rows.skip(1).toList();
  final errors = <BulkImportRowError>[];
  final lessons = <BulkLessonItemRequest>[];

  for (int i = 0; i < dataRows.length; i++) {
    final rowNumber = i + 2;
    final row = dataRows[i];
    if (_isBlankRow(row)) continue;

    final title = _cellText(row, 0);
    if (title.isEmpty) {
      errors.add(BulkImportRowError(rowNumber, '"title" is required.'));
      continue;
    }

    final description = _cellText(row, 1);
    final orderText = _cellText(row, 2);
    int? order;
    if (orderText.isNotEmpty) {
      order = int.tryParse(orderText);
      if (order == null) {
        errors.add(BulkImportRowError(rowNumber, '"order" must be a whole number (got "$orderText").'));
        continue;
      }
    }

    final freePreviewText = _cellText(row, 3);
    bool? isFreePreview;
    if (freePreviewText.isNotEmpty) {
      isFreePreview = _parseBool(freePreviewText);
      if (isFreePreview == null) {
        errors.add(BulkImportRowError(rowNumber, '"isFreePreview" must be true/false (got "$freePreviewText").'));
        continue;
      }
    }

    final publishedText = _cellText(row, 4);
    bool? isPublished;
    if (publishedText.isNotEmpty) {
      isPublished = _parseBool(publishedText);
      if (isPublished == null) {
        errors.add(BulkImportRowError(rowNumber, '"isPublished" must be true/false (got "$publishedText").'));
        continue;
      }
    }

    final youtubeUrl = _cellText(row, 5);
    if (youtubeUrl.isNotEmpty) {
      final uri = Uri.tryParse(youtubeUrl);
      final looksLikeYoutube = uri != null &&
          uri.hasScheme &&
          (uri.host.contains('youtube.com') || uri.host.contains('youtu.be'));
      if (!looksLikeYoutube) {
        errors.add(BulkImportRowError(rowNumber, '"youtubeUrl" is not a valid YouTube URL (got "$youtubeUrl").'));
        continue;
      }
    }

    lessons.add(BulkLessonItemRequest(
      title: title,
      description: description.isEmpty ? null : description,
      order: order,
      isFreePreview: isFreePreview,
      isPublished: isPublished,
      youtubeUrl: youtubeUrl.isEmpty ? null : youtubeUrl,
    ));
  }

  return LessonImportResult(lessons: lessons, errors: errors, rowCount: dataRows.where((r) => !_isBlankRow(r)).length);
}

// ── Shared Excel helpers ────────────────────────────────────────────────

/// Thrown when the picked file genuinely can't be read as a workbook —
/// distinct from a workbook that decodes fine but has zero data rows, so
/// callers never report a real decode failure as "the sheet is empty".
class _XlsxDecodeException implements Exception {
  const _XlsxDecodeException(this.message);
  final String message;
}

List<List<Data?>> _readRows(Uint8List bytes) {
  final Excel excel;
  try {
    excel = Excel.decodeBytes(_normalizeXlsxForPackageQuirk(bytes));
  } catch (e) {
    // Confirmed (diagnostic logging run against the real
    // GTEC_Bulk_*_Template.xlsx files, then removed): Excel.decodeBytes was
    // genuinely throwing — a null-check deep inside the excel package's own
    // parser — not returning an empty workbook. Surfaced as a real,
    // specific error rather than silently treated as "no rows".
    throw _XlsxDecodeException('Could not read this file as an Excel workbook (${e.runtimeType}). '
        'Make sure it is a valid, unprotected .xlsx file.');
  }
  if (excel.tables.isEmpty) return const [];
  return excel.tables.values.first.rows;
}

/// Works around a real parsing bug in the installed `excel` 4.0.6: when a
/// worksheet's relationship `Target` in `xl/_rels/workbook.xml.rels` is
/// written as a package-root-absolute path (e.g.
/// `Target="/xl/worksheets/sheet1.xml"` — valid per the OPC spec, and what
/// at least one real Excel-generating tool in the wild produces), this
/// package's parser unconditionally resolves it as `'xl/$target'`,
/// producing the non-existent path `xl//xl/worksheets/sheet1.xml` and
/// throwing a null-check error from deep inside `Parser._parseTable`
/// instead of the sheet's actual rows. Confirmed directly against the
/// failing `GTEC_Bulk_Chapters_Template.xlsx` / `GTEC_Bulk_Lessons_Template.xlsx`
/// files — both have exactly this `Target="/xl/worksheets/sheet1.xml"`
/// shape. Rewriting just that one relationship entry to the relative form
/// the parser actually expects (`Target="worksheets/sheet1.xml"`) fixes
/// decoding without touching the `excel` package itself. A no-op — returns
/// [bytes] unchanged — for any workbook that doesn't have this shape.
Uint8List _normalizeXlsxForPackageQuirk(Uint8List bytes) {
  final Archive archive;
  try {
    archive = ZipDecoder().decodeBytes(bytes);
  } catch (_) {
    return bytes; // not even a zip — let Excel.decodeBytes raise its own error
  }

  const relsPath = 'xl/_rels/workbook.xml.rels';
  final relsFile = archive.findFile(relsPath);
  if (relsFile == null) return bytes;

  final content = relsFile.content;
  final relsXml = utf8.decode(content is Uint8List ? content : Uint8List.fromList(content as List<int>));
  if (!relsXml.contains('Target="/xl/')) return bytes;

  final fixedXml = relsXml.replaceAll('Target="/xl/', 'Target="');
  final fixedBytes = Uint8List.fromList(utf8.encode(fixedXml));
  archive.addFile(ArchiveFile(relsPath, fixedBytes.length, fixedBytes));

  final reencoded = ZipEncoder().encode(archive);
  return reencoded == null ? bytes : Uint8List.fromList(reencoded);
}

/// Returns a human-readable error if [headerRow] doesn't contain
/// [expected]'s columns (case-insensitive, in order) — null if it matches.
String? _checkHeaders(List<Data?> headerRow, List<String> expected) {
  final actual = [for (int i = 0; i < expected.length; i++) _cellText(headerRow, i).toLowerCase()];
  for (int i = 0; i < expected.length; i++) {
    if (actual[i] != expected[i].toLowerCase()) {
      return 'Expected column ${i + 1} to be "${expected[i]}", found "${i < actual.length ? actual[i] : ''}". '
          'Expected headers: ${expected.join(', ')}.';
    }
  }
  return null;
}

bool _isBlankRow(List<Data?> row) => row.every((cell) => _valueText(cell?.value).isEmpty);

String _cellText(List<Data?> row, int index) {
  if (index >= row.length) return '';
  return _valueText(row[index]?.value);
}

String _valueText(CellValue? value) => value == null ? '' : value.toString().trim();

bool? _parseBool(String text) {
  switch (text.trim().toLowerCase()) {
    case 'true':
    case '1':
    case 'yes':
      return true;
    case 'false':
    case '0':
    case 'no':
      return false;
    default:
      return null;
  }
}
