/// Backend-aligned Team Invite model — mirrors `GET /admin/team-invites` /
/// `POST /admin/team-invites`.
///
/// NOTE: there's no separate "team roster" entity on the backend — the
/// actual member list is just `User` rows filtered by role, fetched via
/// `GET /me/users?role=ADMIN` or `?role=TEACHER` (see [UserListItemModel]
/// in student_models.dart). `TeamInvite` is an account-creation audit record.
class TeamInviteModel {
  const TeamInviteModel({
    required this.id,
    this.inviterId,
    this.inviterName,
    this.inviterEmail,
    required this.email,
    required this.role,
    this.teamName,
    this.createdUserId,
    required this.createdAt,
    this.accountCreated,
    this.mailSent,
  });

  final String id;
  final String? inviterId;
  final String? inviterName;
  final String? inviterEmail;
  final String email;

  /// The requested role: `TEACHER` or `ADMIN`.
  final String role;
  final String? teamName;

  /// The newly created user, or the existing user whose role was updated.
  final String? createdUserId;
  final DateTime createdAt;
  final bool? accountCreated;
  final bool? mailSent;

  factory TeamInviteModel.fromJson(Map<String, dynamic> json) {
    final rawInviter = json['inviter'];
    final inviter = rawInviter is Map ? Map<String, dynamic>.from(rawInviter) : null;
    return TeamInviteModel(
      id: json['id'] as String,
      inviterId: inviter?['id']?.toString() ?? json['inviterId']?.toString(),
      inviterName: inviter?['name']?.toString(),
      inviterEmail: inviter?['email']?.toString(),
      email: json['email'] as String,
      role: json['role'] as String? ?? 'TEACHER',
      teamName: json['teamName'] as String?,
      createdUserId: json['createdUserId']?.toString(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      accountCreated: json['accountCreated'] as bool?,
      mailSent: json['mailSent'] as bool?,
    );
  }
}
