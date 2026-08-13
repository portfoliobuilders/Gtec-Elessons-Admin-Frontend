/// Backend-aligned Assignment model — mirrors `GET /admin/assignments`.
class AssignmentModel {
  const AssignmentModel({
    required this.id,
    required this.title,
    this.description,
    required this.teacherId,
    this.teacherName,
    this.teacherEmail,
    this.subjectId,
    this.subjectName,
    this.dueDate,
    this.totalMarks = 100,
    this.isPublished = true,
    this.submissionCount = 0,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String? description;
  final String teacherId;
  final String? teacherName;
  final String? teacherEmail;
  final String? subjectId;
  final String? subjectName;
  final DateTime? dueDate;
  final int totalMarks;
  final bool isPublished;
  final int submissionCount;
  final DateTime createdAt;

  factory AssignmentModel.fromJson(Map<String, dynamic> json) => AssignmentModel(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String?,
        teacherId: json['teacherId'] as String,
        teacherName: (json['teacher'] as Map<String, dynamic>?)?['name'] as String?,
        teacherEmail: (json['teacher'] as Map<String, dynamic>?)?['email'] as String?,
        subjectId: json['subjectId'] as String?,
        subjectName: (json['subject'] as Map<String, dynamic>?)?['name'] as String?,
        dueDate: json['dueDate'] == null ? null : DateTime.parse(json['dueDate'] as String),
        totalMarks: json['totalMarks'] as int? ?? 100,
        isPublished: json['isPublished'] as bool? ?? true,
        submissionCount: (json['_count'] as Map<String, dynamic>?)?['submissions'] as int? ?? 0,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

/// `GET /admin/assignments/:assignmentId/submissions`.
/// Backend enum `AssignmentSubmissionStatus`: SUBMITTED | GRADED.
class AssignmentSubmissionModel {
  const AssignmentSubmissionModel({
    required this.id,
    required this.assignmentId,
    required this.studentId,
    this.studentName,
    this.studentEmail,
    this.answers = const {},
    this.score,
    this.feedback,
    this.status = 'SUBMITTED',
    this.submittedAt,
    required this.createdAt,
  });

  final String id;
  final String assignmentId;
  final String studentId;
  final String? studentName;
  final String? studentEmail;
  final Map<String, dynamic> answers;
  final int? score;
  final String? feedback;
  final String status;
  final DateTime? submittedAt;
  final DateTime createdAt;

  factory AssignmentSubmissionModel.fromJson(Map<String, dynamic> json) => AssignmentSubmissionModel(
        id: json['id'] as String,
        assignmentId: json['assignmentId'] as String,
        studentId: json['studentId'] as String,
        studentName: (json['student'] as Map<String, dynamic>?)?['name'] as String?,
        studentEmail: (json['student'] as Map<String, dynamic>?)?['email'] as String?,
        answers: json['answers'] as Map<String, dynamic>? ?? const {},
        score: json['score'] as int?,
        feedback: json['feedback'] as String?,
        status: json['status'] as String? ?? 'SUBMITTED',
        submittedAt: json['submittedAt'] == null ? null : DateTime.parse(json['submittedAt'] as String),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
