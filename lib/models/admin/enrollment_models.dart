/// Backend-aligned Enrollment model — the raw `Enrollment` Prisma row,
/// as returned inside `POST /admin/students/:studentId/subjects/:subjectId/enrollments`.
class AdminEnrollmentModel {
  const AdminEnrollmentModel({
    required this.id,
    required this.userId,
    required this.productId,
    required this.scopeType,
    this.gradeId,
    this.subjectId,
    this.chapterId,
    this.format = 'RECORDED',
    this.status = 'ACTIVE',
    required this.startsAt,
    this.expiresAt,
    this.orderItemId,
  });

  final String id;
  final String userId;
  final String productId;

  /// Backend enum `ProductType`: FULL_CLASS | MENTORSHIP | SUBJECT | MODULE.
  final String scopeType;
  final String? gradeId;
  final String? subjectId;
  final String? chapterId;

  /// Backend enum `ProductFormat`: RECORDED | LIVE_AND_RECORDED.
  final String format;

  /// Backend enum `EnrollmentStatus`: ACTIVE | EXPIRED | CANCELLED.
  final String status;
  final DateTime startsAt;
  final DateTime? expiresAt;
  final String? orderItemId;

  factory AdminEnrollmentModel.fromJson(Map<String, dynamic> json) => AdminEnrollmentModel(
        id: json['id'] as String,
        userId: json['userId'] as String,
        productId: json['productId'] as String,
        scopeType: json['scopeType'] as String,
        gradeId: json['gradeId'] as String?,
        subjectId: json['subjectId'] as String?,
        chapterId: json['chapterId'] as String?,
        format: json['format'] as String? ?? 'RECORDED',
        status: json['status'] as String? ?? 'ACTIVE',
        startsAt: DateTime.parse(json['startsAt'] as String),
        expiresAt: json['expiresAt'] == null ? null : DateTime.parse(json['expiresAt'] as String),
        orderItemId: json['orderItemId'] as String?,
      );
}

/// `POST /admin/students/:studentId/subjects/:subjectId/enrollments` — grants
/// (or renews) a student's access to a subject, creating a hidden
/// `isActive: false` Product behind the scenes if the subject never had one.
class GrantEnrollmentResultModel {
  const GrantEnrollmentResultModel({
    required this.studentId,
    this.studentEmail,
    required this.subjectId,
    required this.subjectName,
    required this.productId,
    required this.enrollment,
  });

  final String studentId;
  final String? studentEmail;
  final String subjectId;
  final String subjectName;
  final String productId;
  final AdminEnrollmentModel enrollment;

  factory GrantEnrollmentResultModel.fromJson(Map<String, dynamic> json) => GrantEnrollmentResultModel(
        studentId: (json['student'] as Map<String, dynamic>)['id'] as String,
        studentEmail: (json['student'] as Map<String, dynamic>)['email'] as String?,
        subjectId: (json['subject'] as Map<String, dynamic>)['id'] as String,
        subjectName: (json['subject'] as Map<String, dynamic>)['name'] as String,
        productId: (json['product'] as Map<String, dynamic>)['id'] as String,
        enrollment: AdminEnrollmentModel.fromJson(json['enrollment'] as Map<String, dynamic>),
      );
}
