import 'package:flutter/foundation.dart';

import '../models/models.dart';

/// Teacher Console — tutor-role dashboard.
class TeacherController extends ChangeNotifier {
  final String greeting = 'Good morning, R. Menon';

  final List<KpiModel> kpis = const [
    KpiModel(caption: 'My students', value: '3,210'),
    KpiModel(caption: 'Live this week', value: '4'),
    KpiModel(caption: 'To grade', value: '28', accent: true),
    KpiModel(caption: 'Open doubts', value: '11'),
  ];

  final List<SubmissionModel> submissions = const [
    SubmissionModel(
        student: 'Aarav Sharma', task: 'Trigonometry — Problem Set 1'),
    SubmissionModel(
        student: 'Diya Krishnan', task: 'Quadratic Equations — Set 2'),
    SubmissionModel(student: 'Ishaan R.', task: 'Trigonometry — Problem Set 1'),
  ];

  final List<LiveClassModel> upcoming = const [
    LiveClassModel(
        day: 'TUE',
        date: '01',
        title: 'Trigonometry Doubts',
        meta: '5:00 PM · Class 10'),
    LiveClassModel(
        day: 'THU',
        date: '03',
        title: 'Quadratic Masterclass',
        meta: '6:00 PM · Class 10'),
  ];
}
