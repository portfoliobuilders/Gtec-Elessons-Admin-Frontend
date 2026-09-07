import '../../../core/widgets/status_badge.dart';

/// The real backend `Role` enum value on a roster member
/// (STUDENT | TEACHER | ADMIN | SUPER_ADMIN — Team only ever shows the
/// middle two, but SUPER_ADMIN/STUDENT are mapped defensively).
String memberRoleLabel(String role) => switch (role) {
      'ADMIN' => 'Admin',
      'TEACHER' => 'Teacher',
      'SUPER_ADMIN' => 'Super Admin',
      'STUDENT' => 'Student',
      _ => role,
    };

BadgeStatus memberRoleBadge(String role) => switch (role) {
      'SUPER_ADMIN' => BadgeStatus.superAdmin,
      'ADMIN' => BadgeStatus.admin,
      _ => BadgeStatus.teacher, // TEACHER (and any unexpected value)
    };

/// Invitation roles returned by the current backend.
String inviteRoleLabel(String role) => switch (role) {
      'ADMIN' => 'Admin',
      'TEACHER' => 'Teacher',
      'MEMBER' => 'Teacher',
      'OWNER' => 'Owner',
      _ => role,
    };
