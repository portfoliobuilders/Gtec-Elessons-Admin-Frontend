/// Backend-aligned Live Class model — mirrors the raw `LiveClass` Prisma row
/// returned by `POST /admin/live-classes` and `POST
/// /admin/live-classes/:id/status`.
///
/// IMPORTANT: there is no `GET /admin/live-classes` (admin listing) endpoint
/// on the backend today — only the student-facing `GET /live-classes`
/// (filtered to SCHEDULED/LIVE, adds student-specific fields like
/// `hasLiveAccess`). An admin list/history view (including ENDED/CANCELLED
/// classes) needs that backend endpoint added first; see the Phase 2 report.
class AdminLiveClassModel {
  const AdminLiveClassModel({
    required this.id,
    required this.title,
    this.description,
    this.gradeId,
    this.subjectId,
    required this.mentorName,
    this.youtubeUrl,
    this.youtubeId,
    required this.startsAt,
    this.endsAt,
    this.status = 'SCHEDULED',
    this.watchingCount = 0,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String? description;
  final String? gradeId;
  final String? subjectId;
  final String mentorName;
  final String? youtubeUrl;
  final String? youtubeId;
  final DateTime startsAt;
  final DateTime? endsAt;

  /// Backend enum `LiveClassStatus`: SCHEDULED | LIVE | ENDED | CANCELLED.
  final String status;
  final int watchingCount;
  final DateTime createdAt;

  factory AdminLiveClassModel.fromJson(Map<String, dynamic> json) => AdminLiveClassModel(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String?,
        gradeId: json['gradeId'] as String?,
        subjectId: json['subjectId'] as String?,
        mentorName: json['mentorName'] as String,
        youtubeUrl: json['youtubeUrl'] as String?,
        youtubeId: json['youtubeId'] as String?,
        startsAt: DateTime.parse(json['startsAt'] as String),
        endsAt: json['endsAt'] == null ? null : DateTime.parse(json['endsAt'] as String),
        status: json['status'] as String? ?? 'SCHEDULED',
        watchingCount: json['watchingCount'] as int? ?? 0,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
