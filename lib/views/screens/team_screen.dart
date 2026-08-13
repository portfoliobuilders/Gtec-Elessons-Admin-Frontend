import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/team_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_buttons.dart';
import '../../core/widgets/grid_table.dart';
import '../../core/widgets/status_badge.dart';
import '../../models/models.dart';
import '../layouts/admin_shell.dart';
import '../widgets/nav_presets.dart';
import '../widgets/shared_widgets.dart';

/// 05 · Team & Roles — Super Admin.
class TeamScreen extends StatelessWidget {
  const TeamScreen({super.key});

  static const List<double> _memberFlexes = [2, 1.2, 1.4, 1];
  static const List<double> _permFlexes = [2.2, 1, 1, 1];

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<TeamController>();

    return AdminShell(
      navItems: NavPresets.admin,
      activeIndex: 4,
      user: NavPresets.riyaSuperAdmin,
      title: 'Team & Roles',
      actions: const [
        PrimaryButton(label: 'Invite member', iconPaths: AppIcons.plus),
      ],
      body: PageBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Members table.
            _TableCard(
              child: Column(
                children: [
                  const GridHeaderRow(
                    flexes: _memberFlexes,
                    gap: 14,
                    labels: ['Member', 'Role', 'Scope', 'Status'],
                  ),
                  for (int i = 0; i < controller.members.length; i++)
                    _MemberRow(
                      member: controller.members[i],
                      isLast: i == controller.members.length - 1,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Permissions matrix.
            _TableCard(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 22, vertical: 18),
                    decoration: const BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              color: AppColors.borderLight, width: 1.5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Permissions', style: AppTextStyles.cardTitle),
                        const SizedBox(height: 2),
                        Text('What each role can do across app & web',
                            style: AppTextStyles.jakarta(
                                size: 12,
                                weight: FontWeight.w500,
                                color: AppColors.grey)),
                      ],
                    ),
                  ),
                  const GridHeaderRow(
                    flexes: _permFlexes,
                    gap: 14,
                    padding:
                        EdgeInsets.symmetric(horizontal: 22, vertical: 13),
                    labels: ['Capability', 'Super Admin', 'Admin', 'Teacher'],
                    centered: {1, 2, 3},
                  ),
                  for (int i = 0; i < controller.permissions.length; i++)
                    _PermissionRow(
                      permission: controller.permissions[i],
                      isLast: i == controller.permissions.length - 1,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TableCard extends StatelessWidget {
  const _TableCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
      ),
      child: child,
    );
  }
}

class _MemberRow extends StatelessWidget {
  const _MemberRow({required this.member, required this.isLast});

  final TeamMemberModel member;
  final bool isLast;

  BadgeStatus get _roleBadge => switch (member.role) {
        'SUPER ADMIN' => BadgeStatus.superAdmin,
        'ADMIN' => BadgeStatus.admin,
        _ => BadgeStatus.teacher,
      };

  @override
  Widget build(BuildContext context) {
    return GridRow(
      flexes: TeamScreen._memberFlexes,
      gap: 14,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
      bottomBorder: !isLast,
      cells: [
        EntityCell(
          monogram: member.monogram,
          name: member.name,
          subtitle: member.email,
          avatarSize: 36,
          avatarRadius: 10,
          monoSize: 10,
        ),
        StatusBadge.of(_roleBadge, fontSize: 11, horizontal: 10),
        Text(member.scope,
            overflow: TextOverflow.ellipsis, style: AppTextStyles.cell),
        StatusBadge.of(
          member.status == 'ACTIVE' ? BadgeStatus.active : BadgeStatus.invited,
          fontSize: 11,
          horizontal: 10,
        ),
      ],
    );
  }
}

class _PermissionRow extends StatelessWidget {
  const _PermissionRow({required this.permission, required this.isLast});

  final PermissionModel permission;
  final bool isLast;

  Widget _mark(bool allowed) => Container(
        width: double.infinity,
        alignment: Alignment.center,
        child: allowed
            ? const AppIcon(AppIcons.check,
                size: 18, color: AppColors.green, strokeWidth: 2.4)
            : Container(
                width: 16,
                height: 2.5,
                decoration: BoxDecoration(
                  color: AppColors.radioBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
      );

  @override
  Widget build(BuildContext context) {
    return GridRow(
      flexes: TeamScreen._permFlexes,
      gap: 14,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
      bottomBorder: !isLast,
      cells: [
        Text(permission.capability, style: AppTextStyles.cell),
        _mark(permission.superAdmin),
        _mark(permission.admin),
        _mark(permission.teacher),
      ],
    );
  }
}
