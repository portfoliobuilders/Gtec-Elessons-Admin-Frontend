import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../models/admin/admin_models.dart';

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

/// `TeamInviteModel.role` is the *storage* enum (`TeamInviteRole`:
/// OWNER | ADMIN | MEMBER), not the real `Role` enum above — confirmed
/// live: creating an invite with `role: "TEACHER"` comes back as
/// `role: "MEMBER"`. Never render this raw value; always go through here.
String inviteRoleLabel(String role) => switch (role) {
      'ADMIN' => 'Admin',
      'MEMBER' => 'Teacher',
      'OWNER' => 'Owner',
      _ => role,
    };

enum InviteStatus { pending, used, expired }

InviteStatus inviteStatusOf(TeamInviteModel invite) {
  if (invite.isUsed) return InviteStatus.used;
  if (invite.isExpired) return InviteStatus.expired;
  return InviteStatus.pending;
}

/// Built directly (not via `StatusBadge.of`) since none of the shared
/// `BadgeStatus` labels say "PENDING/USED/EXPIRED" verbatim — reuses the
/// same color tokens the rest of the app already uses for these semantics.
StatusBadge inviteStatusBadge(InviteStatus status) => switch (status) {
      InviteStatus.pending =>
        const StatusBadge('PENDING', color: AppColors.amber, background: AppColors.amberBg),
      InviteStatus.used => const StatusBadge('USED', color: AppColors.green, background: AppColors.greenBg),
      InviteStatus.expired =>
        const StatusBadge('EXPIRED', color: AppColors.grey, background: AppColors.greyChipBg),
    };
