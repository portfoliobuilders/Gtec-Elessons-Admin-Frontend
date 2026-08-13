// Backend-aligned Student models. The list and detail endpoints return
// genuinely different shapes (AdminStudentsService.list vs .detail), so
// they're two separate models rather than one forced into both.

/// One row of `GET /admin/students`.
class StudentListItemModel {
  const StudentListItemModel({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    required this.status,
    required this.createdAt,
    this.board,
    this.gradeName,
    this.enrollmentCount = 0,
  });

  final String id;
  final String? name;
  final String? email;
  final String? phone;

  /// Backend enum `UserStatus`: ACTIVE | SUSPENDED.
  final String status;
  final DateTime createdAt;
  final String? board;
  final String? gradeName;
  final int enrollmentCount;

  factory StudentListItemModel.fromJson(Map<String, dynamic> json) {
    final profile = json['studentProfile'] as Map<String, dynamic>?;
    final grade = profile?['grade'] as Map<String, dynamic>?;
    return StudentListItemModel(
      id: json['id'] as String,
      name: json['name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      status: json['status'] as String? ?? 'ACTIVE',
      createdAt: DateTime.parse(json['createdAt'] as String),
      board: profile?['board'] as String?,
      gradeName: grade?['name'] as String?,
      enrollmentCount: (json['_count'] as Map<String, dynamic>?)?['enrollments'] as int? ?? 0,
    );
  }
}

/// `GET /admin/students/:id`. NOTE: the backend fetches this row without a
/// Prisma `select`, so the raw response also includes `passwordHash`,
/// `googleId`, `appleId`, etc. — deliberately not modeled here (never parse
/// or display those); only the fields actually useful to an admin screen.
class StudentDetailModel {
  const StudentDetailModel({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.avatarUrl,
    required this.role,
    required this.status,
    required this.createdAt,
    this.board,
    this.region,
    this.currency,
    this.gradeId,
    this.gradeName,
    this.onboarded = false,
    this.enrollments = const [],
    this.orders = const [],
    this.attempts = const [],
  });

  final String id;
  final String? name;
  final String? email;
  final String? phone;
  final String? avatarUrl;
  final String role;
  final String status;
  final DateTime createdAt;
  final String? board;
  final String? region;
  final String? currency;
  final String? gradeId;
  final String? gradeName;
  final bool onboarded;
  final List<StudentEnrollmentRefModel> enrollments;
  final List<StudentOrderRefModel> orders;
  final List<StudentAttemptRefModel> attempts;

  factory StudentDetailModel.fromJson(Map<String, dynamic> json) {
    final profile = json['studentProfile'] as Map<String, dynamic>?;
    final grade = profile?['grade'] as Map<String, dynamic>?;
    return StudentDetailModel(
      id: json['id'] as String,
      name: json['name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      role: json['role'] as String? ?? 'STUDENT',
      status: json['status'] as String? ?? 'ACTIVE',
      createdAt: DateTime.parse(json['createdAt'] as String),
      board: profile?['board'] as String?,
      region: profile?['region'] as String?,
      currency: profile?['currency'] as String?,
      gradeId: profile?['gradeId'] as String?,
      gradeName: grade?['name'] as String?,
      onboarded: profile?['onboarded'] as bool? ?? false,
      enrollments: (json['enrollments'] as List<dynamic>?)
              ?.map((e) => StudentEnrollmentRefModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      orders: (json['orders'] as List<dynamic>?)
              ?.map((e) => StudentOrderRefModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      attempts: (json['attempts'] as List<dynamic>?)
              ?.map((e) => StudentAttemptRefModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}

class StudentEnrollmentRefModel {
  const StudentEnrollmentRefModel({
    required this.id,
    required this.scopeType,
    required this.format,
    required this.status,
    required this.startsAt,
    this.expiresAt,
    this.productTitle,
  });

  final String id;

  /// Backend enum `ProductType`: FULL_CLASS | MENTORSHIP | SUBJECT | MODULE.
  final String scopeType;

  /// Backend enum `ProductFormat`: RECORDED | LIVE_AND_RECORDED.
  final String format;

  /// Backend enum `EnrollmentStatus`: ACTIVE | EXPIRED | CANCELLED.
  final String status;
  final DateTime startsAt;
  final DateTime? expiresAt;
  final String? productTitle;

  factory StudentEnrollmentRefModel.fromJson(Map<String, dynamic> json) => StudentEnrollmentRefModel(
        id: json['id'] as String,
        scopeType: json['scopeType'] as String,
        format: json['format'] as String? ?? 'RECORDED',
        status: json['status'] as String? ?? 'ACTIVE',
        startsAt: DateTime.parse(json['startsAt'] as String),
        expiresAt: json['expiresAt'] == null ? null : DateTime.parse(json['expiresAt'] as String),
        productTitle: (json['product'] as Map<String, dynamic>?)?['title'] as String?,
      );
}

/// Only PAID orders are included (see AdminStudentsService.detail).
class StudentOrderRefModel {
  const StudentOrderRefModel({
    required this.orderNumber,
    required this.totalCents,
    required this.currency,
    required this.createdAt,
    this.billingName,
    this.billingPhone,
    this.billingAddress,
    this.billingCity,
    this.billingState,
    this.billingPincode,
  });

  final String orderNumber;
  final int totalCents;
  final String currency;
  final DateTime createdAt;
  final String? billingName;
  final String? billingPhone;
  final String? billingAddress;
  final String? billingCity;
  final String? billingState;
  final String? billingPincode;

  factory StudentOrderRefModel.fromJson(Map<String, dynamic> json) => StudentOrderRefModel(
        orderNumber: json['orderNumber'] as String,
        totalCents: json['totalCents'] as int,
        currency: json['currency'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        billingName: json['billingName'] as String?,
        billingPhone: json['billingPhone'] as String?,
        billingAddress: json['billingAddress'] as String?,
        billingCity: json['billingCity'] as String?,
        billingState: json['billingState'] as String?,
        billingPincode: json['billingPincode'] as String?,
      );
}

/// Only SUBMITTED attempts are included. `scorePercent` is computed
/// server-side (`totalMarks` guard against divide-by-zero) — null when
/// `totalMarks` is 0/unset.
class StudentAttemptRefModel {
  const StudentAttemptRefModel({
    required this.id,
    this.score,
    this.totalMarks,
    this.correctCount,
    this.scorePercent,
    this.submittedAt,
    this.assessmentTitle,
  });

  final String id;
  final num? score;
  final int? totalMarks;
  final int? correctCount;
  final int? scorePercent;
  final DateTime? submittedAt;
  final String? assessmentTitle;

  factory StudentAttemptRefModel.fromJson(Map<String, dynamic> json) => StudentAttemptRefModel(
        id: json['id'] as String,
        score: json['score'] as num?,
        totalMarks: json['totalMarks'] as int?,
        correctCount: json['correctCount'] as int?,
        scorePercent: json['scorePercent'] as int?,
        submittedAt: json['submittedAt'] == null ? null : DateTime.parse(json['submittedAt'] as String),
        assessmentTitle: (json['assessment'] as Map<String, dynamic>?)?['title'] as String?,
      );
}

/// One row of `GET /me/users` — a generic user listing (any role, via
/// `?role=`), used for the Team roster since there's no dedicated
/// `/admin/team` roster endpoint. NOTE: this endpoint only requires being
/// logged in (`@UseGuards(JwtAuthGuard)` with no `@Roles`) — it is not
/// actually restricted to admins on the backend today.
class UserListItemModel {
  const UserListItemModel({
    required this.id,
    this.name,
    this.email,
    this.avatarUrl,
    required this.role,
    required this.createdAt,
    this.board,
    this.gradeId,
    this.gradeName,
  });

  final String id;
  final String? name;
  final String? email;
  final String? avatarUrl;
  final String role;
  final DateTime createdAt;
  final String? board;
  final String? gradeId;
  final String? gradeName;

  factory UserListItemModel.fromJson(Map<String, dynamic> json) {
    final profile = json['studentProfile'] as Map<String, dynamic>?;
    final grade = profile?['grade'] as Map<String, dynamic>?;
    return UserListItemModel(
      id: json['id'] as String,
      name: json['name'] as String?,
      email: json['email'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      role: json['role'] as String? ?? 'STUDENT',
      createdAt: DateTime.parse(json['createdAt'] as String),
      board: profile?['board'] as String?,
      gradeId: grade?['id'] as String?,
      gradeName: grade?['name'] as String?,
    );
  }
}
