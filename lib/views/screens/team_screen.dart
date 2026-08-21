import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/team_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/app_buttons.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_inputs.dart';
import '../../core/widgets/confirm_dialog.dart';
import '../../core/widgets/grid_table.dart';
import '../../core/widgets/status_badge.dart';
import '../../models/admin/admin_models.dart';
import '../layouts/admin_shell.dart';
import '../widgets/nav_presets.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/team/invite_member_dialog.dart';
import '../widgets/team/team_role.dart';
import 'students_screen.dart' show studentMonogram;

const List<double> _memberFlexes = [2, 1, 1.1, 1.3];
const List<double> _inviteFlexes = [2, 1, 1.2, 1, 0.9];

const List<String> _roleFilters = ['All', 'ADMIN', 'TEACHER'];

String _roleFilterLabel(String f) => f == 'All' ? 'All' : (f == 'ADMIN' ? 'Admins' : 'Teachers');

const List<String> _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String _shortDate(DateTime date) => '${date.day} ${_months[date.month - 1]} ${date.year}';

/// Team & Roles (Phase 8) — real ADMIN/TEACHER roster (`GET /me/users?role=`,
/// there is no dedicated `/admin/team` endpoint) + real invitations
/// (`GET`/`POST /admin/team-invites`). Role changes reuse the exact Phase 6A
/// endpoint (`PATCH /admin/students/:id/role`) — no duplicate role API.
class TeamScreen extends StatefulWidget {
  const TeamScreen({super.key});

  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {
  String _roleFilter = 'All';

  @override
  void initState() {
    super.initState();
    final controller = context.read<TeamController>();
    controller.loadRoster();
    controller.loadInvites();
  }

  Future<void> _invite(BuildContext context) async {
    final created = await showInviteMemberDialog(context);
    if (!context.mounted) return;
    if (created) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invitation sent.')));
    }
  }

  Future<void> _changeRole(BuildContext context, UserListItemModel member, String newRole) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Change role?',
      message:
          'Change ${member.name ?? member.email ?? 'this member'}\'s role from ${memberRoleLabel(member.role)} to '
          '${memberRoleLabel(newRole)}?',
      confirmLabel: 'Change role',
    );
    if (!confirmed || !context.mounted) return;

    final controller = context.read<TeamController>();
    final ok = await controller.changeMemberRole(member, newRole);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Role updated.' : controller.roleChangeError ?? 'Unable to change role.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<TeamController>();
    final currentUserId = context.watch<AuthController>().user?.id;
    final bool desktop = Responsive.isDesktop(context);

    final allMembers = [...controller.admins, ...controller.teachers];
    final visibleMembers = switch (_roleFilter) {
      'ADMIN' => controller.admins,
      'TEACHER' => controller.teachers,
      _ => allMembers,
    };

    return AdminShell(
      navItems: NavPresets.admin,
      activeIndex: 3,
      user: NavPresets.gtecAdmin,
      titleWidget: Text.rich(
        TextSpan(
          text: 'Team & Roles ',
          style: AppTextStyles.pageTitle,
          children: [
            TextSpan(
              text: '· ${allMembers.length}',
              style: AppTextStyles.jakarta(size: 14, weight: FontWeight.w600, color: AppColors.grey),
            ),
          ],
        ),
      ),
      actions: [
        if (desktop) AppSearchField(hint: 'Search name or email…', width: 260, onChanged: controller.setRosterSearch),
        OutlineButtonX(label: 'Refresh', iconPaths: AppIcons.arrowRight, onTap: controller.refreshRoster),
        PrimaryButton(label: 'Invite member', iconPaths: AppIcons.plus, onTap: () => _invite(context)),
      ],
      body: PageBody(
        topPadding: 24,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!desktop) ...[
              AppSearchField(hint: 'Search name or email…', onChanged: controller.setRosterSearch),
              const SizedBox(height: 16),
            ],
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final f in _roleFilters)
                  AppFilterChip(label: _roleFilterLabel(f), active: _roleFilter == f, onTap: () => setState(() => _roleFilter = f)),
              ],
            ),
            const SizedBox(height: 18),
            Text('Members', style: AppTextStyles.eyebrow),
            const SizedBox(height: 12),
            _MembersSection(
              controller: controller,
              members: visibleMembers,
              desktop: desktop,
              currentUserId: currentUserId,
              onChangeRole: (m, r) => _changeRole(context, m, r),
            ),
            const SizedBox(height: 26),
            Text('Invitations', style: AppTextStyles.eyebrow),
            const SizedBox(height: 12),
            _InvitesSection(controller: controller, desktop: desktop),
            const SizedBox(height: 26),
            const _RolePermissionsInfo(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _MembersSection extends StatelessWidget {
  const _MembersSection({
    required this.controller,
    required this.members,
    required this.desktop,
    required this.currentUserId,
    required this.onChangeRole,
  });

  final TeamController controller;
  final List<UserListItemModel> members;
  final bool desktop;
  final String? currentUserId;
  final void Function(UserListItemModel member, String newRole) onChangeRole;

  @override
  Widget build(BuildContext context) {
    switch (controller.rosterStatus) {
      case TeamLoadStatus.initial:
      case TeamLoadStatus.loading:
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Center(
            child: SizedBox(width: 26, height: 26, child: CircularProgressIndicator(strokeWidth: 2.6, color: AppColors.navy)),
          ),
        );
      case TeamLoadStatus.error:
        return AppCard(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Unable to load the team roster.',
                    style: AppTextStyles.jakarta(size: 14.5, weight: FontWeight.w800, color: AppColors.ink)),
                const SizedBox(height: 6),
                Text(controller.rosterError ?? 'Please try again.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.jakarta(size: 12.5, weight: FontWeight.w600, color: AppColors.grey)),
                const SizedBox(height: 16),
                OutlineButtonX(label: 'Retry', iconPaths: AppIcons.arrowRight, onTap: () => controller.loadRoster()),
              ],
            ),
          ),
        );
      case TeamLoadStatus.loaded:
        if (members.isEmpty) {
          return const InfoBanner(text: 'No admins or teachers found.');
        }
        return desktop
            ? _MembersTable(members: members, currentUserId: currentUserId, onChangeRole: onChangeRole)
            : _MembersCards(members: members, currentUserId: currentUserId, onChangeRole: onChangeRole);
    }
  }
}

class _MembersTable extends StatelessWidget {
  const _MembersTable({required this.members, required this.currentUserId, required this.onChangeRole});

  final List<UserListItemModel> members;
  final String? currentUserId;
  final void Function(UserListItemModel member, String newRole) onChangeRole;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration:
          BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16), boxShadow: AppTheme.cardShadow),
      child: Column(
        children: [
          const GridHeaderRow(flexes: _memberFlexes, labels: ['Member', 'Role', 'Joined', '']),
          for (int i = 0; i < members.length; i++)
            GridRow(
              flexes: _memberFlexes,
              bottomBorder: i != members.length - 1,
              cells: [
                EntityCell(
                  monogram: studentMonogram(members[i].name, members[i].email),
                  name: members[i].name ?? 'Unnamed',
                  subtitle: members[i].email ?? '—',
                ),
                StatusBadgeFor(role: members[i].role),
                Text(_shortDate(members[i].createdAt), style: AppTextStyles.cell),
                _RoleAction(member: members[i], isSelf: members[i].id == currentUserId, onChangeRole: onChangeRole),
              ],
            ),
        ],
      ),
    );
  }
}

class _MembersCards extends StatelessWidget {
  const _MembersCards({required this.members, required this.currentUserId, required this.onChangeRole});

  final List<UserListItemModel> members;
  final String? currentUserId;
  final void Function(UserListItemModel member, String newRole) onChangeRole;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < members.length; i++)
          Padding(
            padding: EdgeInsets.only(bottom: i == members.length - 1 ? 0 : 12),
            child: AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: EntityCell(
                          monogram: studentMonogram(members[i].name, members[i].email),
                          name: members[i].name ?? 'Unnamed',
                          subtitle: members[i].email ?? '—',
                        ),
                      ),
                      const SizedBox(width: 10),
                      StatusBadgeFor(role: members[i].role),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Joined ${_shortDate(members[i].createdAt)}',
                          style: AppTextStyles.jakarta(size: 12, weight: FontWeight.w600, color: AppColors.grey)),
                      _RoleAction(member: members[i], isSelf: members[i].id == currentUserId, onChangeRole: onChangeRole),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _RoleAction extends StatelessWidget {
  const _RoleAction({required this.member, required this.isSelf, required this.onChangeRole});

  final UserListItemModel member;
  final bool isSelf;
  final void Function(UserListItemModel member, String newRole) onChangeRole;

  @override
  Widget build(BuildContext context) {
    if (isSelf) {
      return Text('You', style: AppTextStyles.jakarta(size: 11.5, weight: FontWeight.w700, color: AppColors.grey));
    }
    // Only ADMIN/TEACHER are ever offered as a target — matches the
    // backend's SetStudentRoleRequest exactly; SUPER_ADMIN is never shown
    // as an action even if it somehow appeared as a role value here.
    if (member.role != 'ADMIN' && member.role != 'TEACHER') return const SizedBox.shrink();
    final target = member.role == 'ADMIN' ? 'TEACHER' : 'ADMIN';
    return OutlineButtonX(
      label: 'Make ${memberRoleLabel(target)}',
      onTap: () => onChangeRole(member, target),
    );
  }
}

class StatusBadgeFor extends StatelessWidget {
  const StatusBadgeFor({super.key, required this.role});

  final String role;

  @override
  Widget build(BuildContext context) => StatusBadge.of(memberRoleBadge(role), fontSize: 11, horizontal: 10);
}

class _InvitesSection extends StatelessWidget {
  const _InvitesSection({required this.controller, required this.desktop});

  final TeamController controller;
  final bool desktop;

  @override
  Widget build(BuildContext context) {
    switch (controller.invitesStatus) {
      case TeamLoadStatus.initial:
      case TeamLoadStatus.loading:
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Center(
            child: SizedBox(width: 26, height: 26, child: CircularProgressIndicator(strokeWidth: 2.6, color: AppColors.navy)),
          ),
        );
      case TeamLoadStatus.error:
        return AppCard(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Unable to load invitations.',
                    style: AppTextStyles.jakarta(size: 14.5, weight: FontWeight.w800, color: AppColors.ink)),
                const SizedBox(height: 6),
                Text(controller.invitesError ?? 'Please try again.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.jakarta(size: 12.5, weight: FontWeight.w600, color: AppColors.grey)),
                const SizedBox(height: 16),
                OutlineButtonX(label: 'Retry', iconPaths: AppIcons.arrowRight, onTap: () => controller.loadInvites()),
              ],
            ),
          ),
        );
      case TeamLoadStatus.loaded:
        if (controller.invites.isEmpty) {
          return const InfoBanner(text: 'No invitations sent yet.');
        }
        return desktop ? _InvitesTable(invites: controller.invites) : _InvitesCards(invites: controller.invites);
    }
  }
}

class _InvitesTable extends StatelessWidget {
  const _InvitesTable({required this.invites});

  final List<TeamInviteModel> invites;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration:
          BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16), boxShadow: AppTheme.cardShadow),
      child: Column(
        children: [
          const GridHeaderRow(flexes: _inviteFlexes, labels: ['Email', 'Role', 'Team', 'Invited', 'Status']),
          for (int i = 0; i < invites.length; i++)
            GridRow(
              flexes: _inviteFlexes,
              bottomBorder: i != invites.length - 1,
              cells: [
                Text(invites[i].email, overflow: TextOverflow.ellipsis, style: AppTextStyles.cell),
                Text(inviteRoleLabel(invites[i].role), style: AppTextStyles.cell),
                Text(invites[i].teamName ?? '—', overflow: TextOverflow.ellipsis, style: AppTextStyles.cell),
                Text(_shortDate(invites[i].createdAt), style: AppTextStyles.cell),
                inviteStatusBadge(inviteStatusOf(invites[i])),
              ],
            ),
        ],
      ),
    );
  }
}

class _InvitesCards extends StatelessWidget {
  const _InvitesCards({required this.invites});

  final List<TeamInviteModel> invites;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < invites.length; i++)
          Padding(
            padding: EdgeInsets.only(bottom: i == invites.length - 1 ? 0 : 12),
            child: AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(invites[i].email,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.jakarta(size: 13.5, weight: FontWeight.w800, color: AppColors.ink)),
                      ),
                      inviteStatusBadge(inviteStatusOf(invites[i])),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${inviteRoleLabel(invites[i].role)}'
                    '${invites[i].teamName != null ? ' · ${invites[i].teamName}' : ''} · Invited ${_shortDate(invites[i].createdAt)}',
                    style: AppTextStyles.jakarta(size: 12, weight: FontWeight.w600, color: AppColors.grey),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Replaces the old mock permission matrix (Section 16) — the backend has
/// no dynamic permission-matrix endpoint, only `RolesGuard`/`@Roles`
/// checks, so nothing here claims a specific capability per role.
class _RolePermissionsInfo extends StatelessWidget {
  const _RolePermissionsInfo();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Role permissions', style: AppTextStyles.jakarta(size: 14, weight: FontWeight.w800, color: AppColors.ink)),
          const SizedBox(height: 4),
          Text('Access is controlled entirely by backend role guards, not by this screen.',
              style: AppTextStyles.jakarta(size: 12, weight: FontWeight.w600, color: AppColors.grey)),
          const SizedBox(height: 16),
          const _RoleFact(role: 'Admin', text: 'Administrative access according to backend role guards.'),
          const SizedBox(height: 12),
          const _RoleFact(role: 'Teacher', text: 'Teacher-scoped access according to backend role guards.'),
          const SizedBox(height: 12),
          const _RoleFact(
              role: 'Super Admin', text: 'Highest administrative role; assignment is not available from this UI.'),
        ],
      ),
    );
  }
}

class _RoleFact extends StatelessWidget {
  const _RoleFact({required this.role, required this.text});

  final String role;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(role, style: AppTextStyles.jakarta(size: 12.5, weight: FontWeight.w800, color: AppColors.ink)),
        ),
        Expanded(
          child: Text(text, style: AppTextStyles.jakarta(size: 12.5, weight: FontWeight.w600, color: AppColors.grey)),
        ),
      ],
    );
  }
}
