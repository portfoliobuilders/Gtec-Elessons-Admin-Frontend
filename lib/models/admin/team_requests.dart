/// `POST /admin/team-invites`. `role` is one of TEACHER | ADMIN (deliberately
/// narrower than the storage enum — see TeamInviteModel.role).
class CreateTeamInviteRequest {
  const CreateTeamInviteRequest({required this.email, this.role, this.teamName});

  final String email;
  final String? role;
  final String? teamName;

  Map<String, dynamic> toJson() => {
        'email': email,
        if (role != null) 'role': role,
        if (teamName != null) 'teamName': teamName,
      };
}
