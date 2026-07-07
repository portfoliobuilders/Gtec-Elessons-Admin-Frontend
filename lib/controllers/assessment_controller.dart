import 'package:flutter/foundation.dart';

import '../models/models.dart';

/// Assessment Engine — mock test builder state.
class AssessmentController extends ChangeNotifier {
  final String testName = 'Acids & Bases — Chapter Test';
  final String subjectModule = 'Science · Module 2';
  final String totalQuestions = '25';
  final String duration = '60 minutes';

  final List<QuestionModel> questions = const [
    QuestionModel(
      prompt: 'What is the pH of a neutral solution at 25°C?',
      options: ['0', '7', '10', '14'],
      correctIndex: 1,
    ),
  ];

  bool negativeMarking = true;
  bool shuffleQuestions = true;

  final String correctMarks = '+4';
  final String wrongMarks = '−1';
  final String summary =
      '25 questions · 60 min · max 100 marks · negative marking on. '
      'Auto-graded on submit with instant student results.';

  void setNegativeMarking(bool value) {
    negativeMarking = value;
    notifyListeners();
  }

  void setShuffle(bool value) {
    shuffleQuestions = value;
    notifyListeners();
  }
}
