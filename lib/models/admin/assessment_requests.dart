/// `type` must be one of the backend `AssessmentType` enum values:
/// MOCK_TEST | PYQ | ASSIGNMENT | PRACTICE_QUIZ.
class CreateAssessmentRequest {
  const CreateAssessmentRequest({
    required this.type,
    required this.title,
    this.description,
    this.gradeId,
    this.subjectId,
    this.chapterId,
    this.durationMinutes,
    this.passPercent,
    this.negativeMarking,
    this.shuffleQuestions,
    this.isPublished,
  });

  final String type;
  final String title;
  final String? description;
  final String? gradeId;
  final String? subjectId;
  final String? chapterId;
  final int? durationMinutes;
  final int? passPercent;
  final num? negativeMarking;
  final bool? shuffleQuestions;
  final bool? isPublished;

  Map<String, dynamic> toJson() => {
        'type': type,
        'title': title,
        if (description != null) 'description': description,
        if (gradeId != null) 'gradeId': gradeId,
        if (subjectId != null) 'subjectId': subjectId,
        if (chapterId != null) 'chapterId': chapterId,
        if (durationMinutes != null) 'durationMinutes': durationMinutes,
        if (passPercent != null) 'passPercent': passPercent,
        if (negativeMarking != null) 'negativeMarking': negativeMarking,
        if (shuffleQuestions != null) 'shuffleQuestions': shuffleQuestions,
        if (isPublished != null) 'isPublished': isPublished,
      };
}

class QuestionOptionRequest {
  const QuestionOptionRequest({required this.id, required this.text});

  final String id;
  final String text;

  Map<String, dynamic> toJson() => {'id': id, 'text': text};
}

class AddQuestionRequest {
  const AddQuestionRequest({
    required this.text,
    required this.options,
    required this.correctOptionId,
    this.explanation,
    this.marks,
    this.order,
  });

  final String text;
  final List<QuestionOptionRequest> options;

  /// Must match one of [options]' `id`.
  final String correctOptionId;
  final String? explanation;
  final int? marks;
  final int? order;

  Map<String, dynamic> toJson() => {
        'text': text,
        'options': options.map((e) => e.toJson()).toList(),
        'correctOptionId': correctOptionId,
        if (explanation != null) 'explanation': explanation,
        if (marks != null) 'marks': marks,
        if (order != null) 'order': order,
      };
}
