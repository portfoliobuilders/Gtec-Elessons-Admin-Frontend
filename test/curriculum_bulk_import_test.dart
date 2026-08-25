import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gtec_admin/core/utils/curriculum_bulk_import.dart';
import 'package:gtec_admin/models/admin/admin_models.dart';

/// Builds a minimal `.xlsx` in-memory with [header] as row 1 and [rows] as
/// the data rows, mirroring exactly what a real Excel file picked via
/// `file_picker` would decode to.
Uint8List _buildWorkbook(List<String> header, List<List<Object?>> rows) {
  final excel = Excel.createExcel();
  final sheet = excel.getDefaultSheet()!;
  excel.appendRow(sheet, [for (final h in header) TextCellValue(h)]);
  for (final row in rows) {
    excel.appendRow(sheet, [
      for (final cell in row)
        switch (cell) {
          null => null,
          int v => IntCellValue(v),
          double v => DoubleCellValue(v),
          bool v => BoolCellValue(v),
          _ => TextCellValue(cell.toString()),
        },
    ]);
  }
  return Uint8List.fromList(excel.encode()!);
}

void main() {
  group('parseChapterExcel', () {
    test('groups rows sharing the same name into one chapter with multiple regional prices', () {
      final bytes = _buildWorkbook(kChapterExcelHeaders, [
        ['Matter', 'Introduction', 1, 'IN', 'INR', 999, 'RECORDED', 365],
        ['Matter', 'Introduction', 1, 'AE', 'AED', 149, 'RECORDED', 365],
        ['Heat', 'Heat concepts', 2, 'IN', 'INR', 799, 'RECORDED', 365],
      ]);

      final result = parseChapterExcel(bytes);

      expect(result.errors, isEmpty);
      expect(result.chapters, hasLength(2));

      final matter = result.chapters.firstWhere((c) => c.name == 'Matter');
      expect(matter.description, 'Introduction');
      expect(matter.order, 1);
      expect(matter.prices, hasLength(2));
      expect(matter.prices.map((p) => p.region), containsAll(['IN', 'AE']));
      expect(matter.prices.firstWhere((p) => p.region == 'IN').amount, 999);
      expect(matter.prices.firstWhere((p) => p.region == 'AE').currency, 'AED');
      expect(matter.prices.first.format, 'RECORDED');
      expect(matter.prices.first.accessDays, 365);

      final heat = result.chapters.firstWhere((c) => c.name == 'Heat');
      expect(heat.prices, hasLength(1));
      expect(heat.prices.single.amount, 799);
    });

    test('flags a duplicate chapter+region as a row error and drops the dup', () {
      final bytes = _buildWorkbook(kChapterExcelHeaders, [
        ['Matter', 'Introduction', 1, 'IN', 'INR', 999, null, null],
        ['Matter', 'Introduction', 1, 'IN', 'INR', 1099, null, null],
      ]);

      final result = parseChapterExcel(bytes);

      expect(result.hasErrors, isTrue);
      expect(result.errors.single.message, contains('Duplicate regional price'));
      final matter = result.chapters.single;
      expect(matter.prices, hasLength(1)); // only the first IN price kept
    });

    test('rejects a currency that does not match the region', () {
      final bytes = _buildWorkbook(kChapterExcelHeaders, [
        ['Matter', null, null, 'IN', 'AED', 999, null, null],
      ]);

      final result = parseChapterExcel(bytes);

      expect(result.hasErrors, isTrue);
      expect(result.errors.single.message, contains('uses currency INR'));
      expect(result.chapters.single.prices, isEmpty);
    });

    test('requires a name', () {
      final bytes = _buildWorkbook(kChapterExcelHeaders, [
        [null, 'desc', 1, null, null, null, null, null],
      ]);

      final result = parseChapterExcel(bytes);

      expect(result.hasErrors, isTrue);
      expect(result.errors.single.message, contains('"name" is required'));
      expect(result.chapters, isEmpty);
    });

    test('a chapter row with no pricing columns is still valid (no prices)', () {
      final bytes = _buildWorkbook(kChapterExcelHeaders, [
        ['Matter', 'Introduction', 1, null, null, null, null, null],
      ]);

      final result = parseChapterExcel(bytes);

      expect(result.errors, isEmpty);
      expect(result.chapters.single.prices, isEmpty);
    });

    test('rejects a mismatched header row', () {
      final bytes = _buildWorkbook(['title', 'description'], [
        ['Matter', 'x'],
      ]);

      final result = parseChapterExcel(bytes);

      expect(result.hasErrors, isTrue);
      expect(result.errors.single.message, contains('Expected column 1 to be "name"'));
    });
  });

  group('parseLessonExcel', () {
    test('parses one lesson per row, including youtubeUrl', () {
      final bytes = _buildWorkbook(kLessonExcelHeaders, [
        ['Introduction', 'Basic introduction', 1, true, true, 'https://youtu.be/xvT1jH8B9AM'],
        ['Matter', 'What is matter?', 2, false, true, 'https://www.youtube.com/watch?v=abc123'],
      ]);

      final result = parseLessonExcel(bytes);

      expect(result.errors, isEmpty);
      expect(result.lessons, hasLength(2));
      expect(result.lessons[0].title, 'Introduction');
      expect(result.lessons[0].isFreePreview, true);
      expect(result.lessons[0].isPublished, true);
      expect(result.lessons[0].youtubeUrl, 'https://youtu.be/xvT1jH8B9AM');
      expect(result.lessons[1].isFreePreview, false);
      expect(result.lessons[1].youtubeUrl, 'https://www.youtube.com/watch?v=abc123');
    });

    test('flags an invalid youtubeUrl', () {
      final bytes = _buildWorkbook(kLessonExcelHeaders, [
        ['Introduction', null, null, null, null, 'not-a-url'],
      ]);

      final result = parseLessonExcel(bytes);

      expect(result.hasErrors, isTrue);
      expect(result.errors.single.message, contains('youtubeUrl'));
    });

    test('flags a non-boolean isPublished value', () {
      final bytes = _buildWorkbook(kLessonExcelHeaders, [
        ['Introduction', null, null, null, 'maybe', null],
      ]);

      final result = parseLessonExcel(bytes);

      expect(result.hasErrors, isTrue);
      expect(result.errors.single.message, contains('isPublished'));
    });

    test('requires a title', () {
      final bytes = _buildWorkbook(kLessonExcelHeaders, [
        [null, 'desc', null, null, null, null],
      ]);

      final result = parseLessonExcel(bytes);

      expect(result.hasErrors, isTrue);
      expect(result.errors.single.message, contains('"title" is required'));
    });
  });

  group('batchForBulkImport', () {
    test('splits 250 chapters into 100/100/50, never splitting a chapter', () {
      final rows = <List<Object?>>[];
      for (int i = 1; i <= 250; i++) {
        rows.add(['Chapter $i', null, i, 'IN', 'INR', 100 + i, null, null]);
      }
      final bytes = _buildWorkbook(kChapterExcelHeaders, rows);
      final result = parseChapterExcel(bytes);
      expect(result.errors, isEmpty);
      expect(result.chapters, hasLength(250));

      final batches = batchForBulkImport(result.chapters);
      expect(batches.map((b) => b.length).toList(), [100, 100, 50]);
      // every chapter's prices stayed with it — batching operates on whole
      // chapters, never splits a chapter's prices[] across batches.
      for (final batch in batches) {
        for (final c in batch) {
          expect(c.prices, hasLength(1));
        }
      }
      // no chapter lost or duplicated across batches
      final allNames = batches.expand((b) => b.map((c) => c.name)).toSet();
      expect(allNames, hasLength(250));
    });

    test('splits 350 lessons into 100/100/100/50', () {
      final rows = <List<Object?>>[];
      for (int i = 1; i <= 350; i++) {
        rows.add(['Lesson $i', null, i, null, null, null]);
      }
      final bytes = _buildWorkbook(kLessonExcelHeaders, rows);
      final result = parseLessonExcel(bytes);
      expect(result.errors, isEmpty);
      expect(result.lessons, hasLength(350));

      final batches = batchForBulkImport(result.lessons);
      expect(batches.map((b) => b.length).toList(), [100, 100, 100, 50]);
    });

    test('a count under the batch size is a single batch', () {
      final batches = batchForBulkImport(List.generate(37, (i) => i));
      expect(batches, hasLength(1));
      expect(batches.single, hasLength(37));
    });
  });

  group('JSON shape (only JSON ever leaves the app)', () {
    test('BulkCreateChaptersRequest.toJson matches the documented contract', () {
      const request = BulkCreateChaptersRequest([
        BulkChapterItemRequest(name: 'Matter', description: 'Introduction', order: 1, prices: [
          BulkChapterPriceRequest(region: 'IN', currency: 'INR', amount: 999, format: 'RECORDED', accessDays: 365),
        ]),
      ]);

      expect(request.toJson(), {
        'chapters': [
          {
            'name': 'Matter',
            'description': 'Introduction',
            'order': 1,
            'prices': [
              {'region': 'IN', 'currency': 'INR', 'amount': 999, 'format': 'RECORDED', 'accessDays': 365},
            ],
          },
        ],
      });
    });

    test('BulkCreateLessonsRequest.toJson sends youtubeUrl (not youtubeId)', () {
      const request = BulkCreateLessonsRequest([
        BulkLessonItemRequest(
          title: 'Introduction',
          isFreePreview: true,
          isPublished: true,
          youtubeUrl: 'https://youtu.be/xvT1jH8B9AM',
        ),
      ]);

      final json = request.toJson();
      expect(json['lessons'][0]['youtubeUrl'], 'https://youtu.be/xvT1jH8B9AM');
      expect(json['lessons'][0].containsKey('youtubeId'), isFalse);
    });
  });
}
