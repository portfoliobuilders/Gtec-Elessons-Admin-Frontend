/// Backend-aligned Team Invite model — mirrors `GET /admin/team-invites` /
/// `POST /admin/team-invites`.
///
/// NOTE: there's no separate "team roster" entity on the backend — the
/// actual member list is just `User` rows filtered by role, fetched via
/// `GET /me/users?role=ADMIN` or `?role=TEACHER` (see [UserListItemModel]
/// in student_models.dart). `TeamInvite` only tracks pending/past invites.
class TeamInviteModel {
  const TeamInviteModel({
    required this.id,
    this.inviterId,
    this.inviterName,
    this.inviterEmail,
    required this.email,
    required this.role,
    this.teamName,
    this.token,
    required this.expiresAt,
    this.usedAt,
    required this.createdAt,
  });

  final String id;
  final String? inviterId;
  final String? inviterName;
  final String? inviterEmail;
  final String email;

  /// Backend enum `TeamInviteRole` (storage value): OWNER | ADMIN | MEMBER.
  /// `POST /admin/team-invites` only ever writes ADMIN or MEMBER (MEMBER
  /// stands for a teacher invite) — OWNER is never created through the API.
  final String role;
  final String? teamName;

  /// Present on both the list and create responses today (the backend does
  /// not strip it) — treat as sensitive, don't display it verbatim in a
  /// shared/exported view.
  final String? token;
  final DateTime expiresAt;
  final DateTime? usedAt;
  final DateTime createdAt;

  bool get isUsed => usedAt != null;
  bool get isExpired => !isUsed && expiresAt.isBefore(DateTime.now());

  factory TeamInviteModel.fromJson(Map<String, dynamic> json) {
    final inviter = json['inviter'] as Map<String, dynamic>?;
    return TeamInviteModel(
      id: json['id'] as String,
      inviterId: inviter?['id'] as String? ?? json['inviterId'] as String?,
      inviterName: inviter?['name'] as String?,
      inviterEmail: inviter?['email'] as String?,
      email: json['email'] as String,
      role: json['role'] as String? ?? 'MEMBER',
      teamName: json['teamName'] as String?,
      token: json['token'] as String?,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      usedAt: json['usedAt'] == null ? null : DateTime.parse(json['usedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
