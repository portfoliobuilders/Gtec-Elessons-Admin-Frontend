import 'package:flutter/foundation.dart';

import '../models/models.dart';

/// Student Management — filterable roster.
class StudentsController extends ChangeNotifier {
  final String totalCount = '12,480';
  final List<String> filters = const ['All', 'Class 10', 'Active', 'Expiring'];
  int activeFilter = 0;
  int page = 1;

  final List<StudentModel> students = const [
    StudentModel(
        monogram: 'AS',
        name: 'Aarav Sharma',
        location: "Kochi · St. Xavier's",
        grade: '10 · CBSE',
        courses: 'Science +1',
        progress: '46%',
        status: 'ACTIVE'),
    StudentModel(
        monogram: 'DK',
        name: 'Diya Krishnan',
        location: 'Chennai · DAV',
        grade: '10 · CBSE',
        courses: 'Full year',
        progress: '71%',
        status: 'ACTIVE'),
    StudentModel(
        monogram: 'IR',
        name: 'Ishaan R.',
        location: 'Dubai · GIIS',
        grade: '9 · CBSE',
        courses: 'Mathematics',
        progress: '28%',
        status: 'EXPIRING'),
    StudentModel(
        monogram: 'MN',
        name: 'Meera Nair',
        location: "Kochi · St. Teresa's",
        grade: '12 · CBSE',
        courses: 'Full year',
        progress: '88%',
        status: 'ACTIVE'),
    StudentModel(
        monogram: 'RV',
        name: 'Rohan V.',
        location: 'Bengaluru · NPS',
        grade: '8 · CBSE',
        courses: 'Science',
        progress: '12%',
        status: 'INACTIVE'),
  ];

  void setFilter(int index) {
    activeFilter = index;
    notifyListeners();
  }

  void setPage(int value) {
    page = value;
    notifyListeners();
  }
}
