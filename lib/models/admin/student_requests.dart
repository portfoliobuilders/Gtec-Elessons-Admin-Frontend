/// `PATCH /admin/students/:id/status` — backend enum `UserStatus`:
/// ACTIVE | SUSPENDED.
class SetStudentStatusRequest {
  const SetStudentStatusRequest(this.status);

  final String status;

  Map<String, dynamic> toJson() => {'status': status};
}

/// `PATCH /admin/students/:id/role` — deliberately NOT the full `Role` enum:
/// SUPER_ADMIN can never be granted through this endpoint (backend-enforced;
/// promotion to SUPER_ADMIN is a manual DB operation only).
class SetStudentRoleRequest {
  const SetStudentRoleRequest(this.role);

  /// One of: STUDENT | TEACHER | ADMIN.
  final String role;

  Map<String, dynamic> toJson() => {'role': role};
}

/// `POST /admin/students/:studentId/subjects/:subjectId/enrollments` — both
/// ids are already in the URL path; the body itself is empty on the wire
/// (kept as a request type for symmetry/documentation, not because the
/// backend DTO requires a body).
class GrantEnrollmentRequest {
  const GrantEnrollmentRequest({required this.studentId, required this.subjectId});

  final String studentId;
  final String subjectId;
}
