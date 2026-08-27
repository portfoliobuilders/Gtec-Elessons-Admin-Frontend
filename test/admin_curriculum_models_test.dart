import 'package:flutter_test/flutter_test.dart';
import 'package:gtec_admin/models/admin/curriculum_models.dart';

void main() {
  group('AdminGradeModel.fromJson', () {
    test('loads a nested curriculum item when optional prices are empty', () {
      final grade = AdminGradeModel.fromJson({
        'id': 'grade-1',
        'name': 'Grade 1',
        'board': 'CBSE',
        'subjects': [
          {
            'id': 'subject-1',
            'name': 'Maths',
            'gradeId': 'grade-1',
            'prices': [],
            'chapters': [
              {
                'id': 'chapter-1',
                'name': 'Numbers',
                'subjectId': 'subject-1',
                'prices': [],
                '_count': {'lessons': 0},
              },
            ],
          },
        ],
        'prices': [],
        'products': [
          {
            'id': 'product-1',
            'type': 'FULL_CLASS',
            'title': 'Grade 1',
            'prices': [],
          },
        ],
      });

      expect(grade.prices, isEmpty);
      expect(grade.products.single.prices, isEmpty);
      expect(grade.subjects, hasLength(1));
      expect(grade.subjects!.single.prices, isEmpty);
      expect(grade.subjects!.single.chapters!.single.prices, isEmpty);
    });

    test('keeps the hierarchy when an optional price row is unsupported', () {
      final grade = AdminGradeModel.fromJson({
        'id': 'grade-1',
        'name': 'Grade 1',
        'prices': [
          {'region': 'IN'},
        ],
      });

      expect(grade.id, 'grade-1');
      expect(grade.prices, isEmpty);
    });
  });
}
