class CreateAssignmentRequest {
  const CreateAssignmentRequest({
    required this.title,
    this.description,
    required this.teacherId,
    this.subjectId,
    this.dueDate,
    this.totalMarks,
    this.isPublished,
  });

  final String title;
  final String? description;
  final String teacherId;
  final String? subjectId;

  /// ISO-8601 date string.
  final String? dueDate;
  final int? totalMarks;
  final bool? isPublished;

  Map<String, dynamic> toJson() => {
        'title': title,
        if (description != null) 'description': description,
        'teacherId': teacherId,
        if (subjectId != null) 'subjectId': subjectId,
        if (dueDate != null) 'dueDate': dueDate,
        if (totalMarks != null) 'totalMarks': totalMarks,
        if (isPublished != null) 'isPublished': isPublished,
      };
}

class UpdateAssignmentRequest {
  const UpdateAssignmentRequest({
    this.title,
    this.description,
    this.teacherId,
    this.subjectId,
    this.dueDate,
    this.totalMarks,
    this.isPublished,
  });

  final String? title;
  final String? description;
  final String? teacherId;
  final String? subjectId;
  final String? dueDate;
  final int? totalMarks;
  final bool? isPublished;

  Map<String, dynamic> toJson() => {
        if (title != null) 'title': title,
        if (description != null) 'description': description,
        if (teacherId != null) 'teacherId': teacherId,
        if (subjectId != null) 'subjectId': subjectId,
        if (dueDate != null) 'dueDate': dueDate,
        if (totalMarks != null) 'totalMarks': totalMarks,
        if (isPublished != null) 'isPublished': isPublished,
      };
}

class GradeSubmissionRequest {
  const GradeSubmissionRequest({this.score, this.feedback});

  final int? score;
  final String? feedback;

  Map<String, dynamic> toJson() => {
        if (score != null) 'score': score,
        if (feedback != null) 'feedback': feedback,
      };
}
