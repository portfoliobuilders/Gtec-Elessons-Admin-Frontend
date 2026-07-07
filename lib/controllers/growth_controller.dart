import 'package:flutter/foundation.dart';

import '../models/models.dart';

/// Growth & Insights — sales / marketing / service analytics.
class GrowthController extends ChangeNotifier {
  final List<KpiModel> kpis = const [
    KpiModel(caption: 'Visitor → paid', value: '3.4%', delta: '▲ 0.6'),
    KpiModel(caption: 'Avg. order value', value: '₹6,180', delta: '▲ 9%'),
    KpiModel(caption: 'Avg. course rating', value: '4.8★', delta: '▲ 0.1'),
    KpiModel(
        caption: 'Refund rate',
        value: '1.2%',
        delta: '▲ 0.3',
        deltaPositive: false),
  ];

  /// label, value, width fraction — matching the funnel widths in the design.
  final List<(String, String, double)> funnel = const [
    ('Visitors', '82,400', 1.0),
    ('Signed up', '11,900', 0.62),
    ('Started free trial', '5,240', 0.40),
    ('Added to cart', '2,840', 0.26),
    ('Paid', '612', 0.14),
  ];

  final List<CourseModel> needsAttention = const [
    CourseModel(
        code: '',
        name: 'Social Science · 10',
        dropOff: '38%',
        dropOffCritical: true,
        rating: '4.1★',
        refunds: '3.2%'),
    CourseModel(
        code: '',
        name: 'English · 9',
        dropOff: '31%',
        dropOffCritical: true,
        rating: '4.3★',
        refunds: '2.0%'),
    CourseModel(
        code: '',
        name: 'Maths · 11',
        dropOff: '26%',
        rating: '4.6★',
        refunds: '1.1%'),
    CourseModel(
        code: '',
        name: 'Science · 8',
        dropOff: '24%',
        rating: '4.7★',
        refunds: '0.8%'),
  ];

  final List<TeacherStatModel> teacherActivity = const [
    TeacherStatModel(
        monogram: 'RM',
        name: 'R. Menon',
        live: '12',
        graded: '148',
        sla: '2.1h',
        slaGood: true,
        rating: '4.9★',
        ratingGood: true),
    TeacherStatModel(
        monogram: 'SI',
        name: 'S. Iyer',
        live: '9',
        graded: '132',
        sla: '3.0h',
        slaGood: true,
        rating: '4.8★',
        ratingGood: true),
    TeacherStatModel(
        monogram: 'KR',
        name: 'K. Rao',
        live: '5',
        graded: '71',
        sla: '9.4h',
        slaGood: false,
        rating: '4.2★',
        ratingGood: false),
  ];

  final List<ReviewModel> reviews = const [
    ReviewModel(
        author: 'Diya · Science',
        rating: '5★',
        ratingGood: true,
        text:
            '"The live doubt classes are the best part. Concepts finally click."'),
    ReviewModel(
        author: 'Aarav · Maths',
        rating: '5★',
        ratingGood: true,
        text: '"Mock tests are exactly board level. Score jumped 14 marks."'),
    ReviewModel(
        author: 'Ishaan · Social',
        rating: '3★',
        ratingGood: false,
        text:
            '"Good notes but some videos feel rushed — needs more examples."'),
  ];
}
