/// Team & Roles member row.
class TeamMemberModel {
  const TeamMemberModel({
    required this.monogram,
    required this.name,
    required this.email,
    required this.role,
    required this.scope,
    required this.status,
  });

  final String monogram;
  final String name;
  final String email;
  final String role; // SUPER ADMIN / ADMIN / TEACHER
  final String scope;
  final String status; // ACTIVE / INVITED
}

/// Permission matrix row: capability + allowed per role.
class PermissionModel {
  const PermissionModel({
    required this.capability,
    required this.superAdmin,
    required this.admin,
    required this.teacher,
  });

  final String capability;
  final bool superAdmin;
  final bool admin;
  final bool teacher;
}
