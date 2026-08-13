// Backend-aligned Assessment models — mirrors AssessmentsService's admin
// methods (adminList/adminGet/create/addQuestion/publish).
// Backend enum AssessmentType: MOCK_TEST | PYQ | ASSIGNMENT | PRACTICE_QUIZ.

class QuestionOptionModel {
  const QuestionOptionModel({required this.id, required this.text});

  final String id;
  final String text;

  factory QuestionOptionModel.fromJson(Map<String, dynamic> json) =>
      QuestionOptionModel(id: json['id'] as String, text: json['text'] as String);
}

/// Admin-only shape — includes `correctOptionId`/`explanation`. The
/// student-facing `GET /assessments/:id` strips both (see
/// AssessmentsService.getForAttempt), so never reuse this model there.
class QuestionModel {
  const QuestionModel({
    required this.id,
    required this.assessmentId,
    required this.text,
    required this.options,
    required this.correctOptionId,
    this.explanation,
    this.marks = 1,
    this.order = 0,
  });

  final String id;
  final String assessmentId;
  final String text;
  final List<QuestionOptionModel> options;
  final String correctOptionId;
  final String? explanation;
  final int marks;
  final int order;

  factory QuestionModel.fromJson(Map<String, dynamic> json) => QuestionModel(
        id: json['id'] as String,
        assessmentId: json['assessmentId'] as String,
        text: json['text'] as String,
        options: (json['options'] as List<dynamic>)
            .map((e) => QuestionOptionModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        correctOptionId: json['correctOptionId'] as String,
        explanation: json['explanation'] as String?,
        marks: json['marks'] as int? ?? 1,
        order: json['order'] as int? ?? 0,
      );
}

/// One row of `GET /admin/assessments`.
class AdminAssessmentListItemModel {
  const AdminAssessmentListItemModel({
    required this.id,
    required this.type,
    required this.title,
    this.description,
    this.gradeId,
    this.gradeName,
    this.subjectId,
    this.subjectName,
    this.chapterId,
    this.chapterName,
    this.durationMinutes,
    this.passPercent,
    this.negativeMarking,
    this.shuffleQuestions = false,
    this.isPublished = false,
    this.questionCount = 0,
    required this.createdAt,
  });

  final String id;
  final String type;
  final String title;
  final String? description;
  final String? gradeId;
  final String? gradeName;
  final String? subjectId;
  final String? subjectName;
  final String? chapterId;
  final String? chapterName;
  final int? durationMinutes;
  final int? passPercent;
  final num? negativeMarking;
  final bool shuffleQuestions;
  final bool isPublished;
  final int questionCount;
  final DateTime createdAt;

  factory AdminAssessmentListItemModel.fromJson(Map<String, dynamic> json) => AdminAssessmentListItemModel(
        id: json['id'] as String,
        type: json['type'] as String,
        title: json['title'] as String,
        description: json['description'] as String?,
        gradeId: json['gradeId'] as String?,
        gradeName: (json['grade'] as Map<String, dynamic>?)?['name'] as String?,
        subjectId: json['subjectId'] as String?,
        subjectName: (json['subject'] as Map<String, dynamic>?)?['name'] as String?,
        chapterId: json['chapterId'] as String?,
        chapterName: (json['chapter'] as Map<String, dynamic>?)?['name'] as String?,
        durationMinutes: json['durationMinutes'] as int?,
        passPercent: json['passPercent'] as int?,
        negativeMarking: json['negativeMarking'] as num?,
        shuffleQuestions: json['shuffleQuestions'] as bool? ?? false,
        isPublished: json['isPublished'] as bool? ?? false,
        questionCount: (json['_count'] as Map<String, dynamic>?)?['questions'] as int? ?? 0,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

/// `GET /admin/assessments/:id` — full detail including every question's
/// correct answer (admin/owning-teacher only).
class AdminAssessmentDetailModel {
  const AdminAssessmentDetailModel({
    required this.id,
    required this.type,
    required this.title,
    this.description,
    this.gradeId,
    this.subjectId,
    this.chapterId,
    this.durationMinutes,
    this.passPercent,
    this.negativeMarking,
    this.shuffleQuestions = false,
    this.isPublished = false,
    this.questions = const [],
    required this.createdAt,
  });

  final String id;
  final String type;
  final String title;
  final String? description;
  final String? gradeId;
  final String? subjectId;
  final String? chapterId;
  final int? durationMinutes;
  final int? passPercent;
  final num? negativeMarking;
  final bool shuffleQuestions;
  final bool isPublished;
  final List<QuestionModel> questions;
  final DateTime createdAt;

  factory AdminAssessmentDetailModel.fromJson(Map<String, dynamic> json) => AdminAssessmentDetailModel(
        id: json['id'] as String,
        type: json['type'] as String,
        title: json['title'] as String,
        description: json['description'] as String?,
        gradeId: json['gradeId'] as String?,
        subjectId: json['subjectId'] as String?,
        chapterId: json['chapterId'] as String?,
        durationMinutes: json['durationMinutes'] as int?,
        passPercent: json['passPercent'] as int?,
        negativeMarking: json['negativeMarking'] as num?,
        shuffleQuestions: json['shuffleQuestions'] as bool? ?? false,
        isPublished: json['isPublished'] as bool? ?? false,
        questions: (json['questions'] as List<dynamic>?)
                ?.map((e) => QuestionModel.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

/// `GET /me/attempts` — a student's own submitted attempts. Not currently
/// surfaced through any /admin endpoint directly (only nested inside
/// [StudentDetailModel.attempts] as [StudentAttemptRefModel]); kept here for
/// when a dedicated admin attempts view is needed.
class AssessmentAttemptModel {
  const AssessmentAttemptModel({
    required this.id,
    required this.userId,
    required this.assessmentId,
    this.answers = const {},
    this.score,
    this.totalMarks,
    this.correctCount,
    required this.status,
    required this.startedAt,
    this.submittedAt,
  });

  final String id;
  final String userId;
  final String assessmentId;
  final Map<String, dynamic> answers;
  final num? score;
  final int? totalMarks;
  final int? correctCount;

  /// Backend enum `AttemptStatus`: IN_PROGRESS | SUBMITTED.
  final String status;
  final DateTime startedAt;
  final DateTime? submittedAt;

  factory AssessmentAttemptModel.fromJson(Map<String, dynamic> json) => AssessmentAttemptModel(
        id: json['id'] as String,
        userId: json['userId'] as String,
        assessmentId: json['assessmentId'] as String,
        answers: json['answers'] as Map<String, dynamic>? ?? const {},
        score: json['score'] as num?,
        totalMarks: json['totalMarks'] as int?,
        correctCount: json['correctCount'] as int?,
        status: json['status'] as String? ?? 'IN_PROGRESS',
        startedAt: DateTime.parse(json['startedAt'] as String),
        submittedAt: json['submittedAt'] == null ? null : DateTime.parse(json['submittedAt'] as String),
      );
}
