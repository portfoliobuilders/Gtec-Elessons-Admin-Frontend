import 'package:flutter/foundation.dart';

/// Live Class Scheduler — form + audience selection.
class SchedulerController extends ChangeNotifier {
  final String title = 'Trigonometry — Live Doubt Solving';
  final String subjectClass = 'Maths · Class 10';
  final String teacher = 'R. Menon';
  final String date = '01 Jul';
  final String time = '5:00 PM';
  final String duration = '60 min';
  final String streamLink = 'youtu.be/live/3xR-pHSc4le';

  final List<String> audiences = const [
    'All Class 10 students',
    'Specific batch',
    'Enrolled in Maths',
  ];
  int selectedAudience = 0;

  final String reach = '3,210 students';
  final String reachNote = 'Push + in-app reminder 30 min before.';

  void selectAudience(int index) {
    selectedAudience = index;
    notifyListeners();
  }
}
