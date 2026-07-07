import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/teacher_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_buttons.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/hatch_avatar.dart';
import '../layouts/admin_shell.dart';
import '../widgets/nav_presets.dart';
import '../widgets/shared_widgets.dart';

/// 06 · Teacher Console — tutor role.
class TeacherScreen extends StatelessWidget {
  const TeacherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<TeacherController>();

    return AdminShell(
      navItems: NavPresets.teacher,
      activeIndex: 0,
      user: NavPresets.menonTeacher,
      brandSuffix: 'teacher',
      title: controller.greeting,
      actions: const [
        OutlineButtonX(
            label: 'New assignment',
            iconPaths: AppIcons.plus,
            color: AppColors.ink),
        PrimaryButton(
          label: 'Start live class',
          iconPaths: AppIcons.play,
          iconFilled: true,
          background: AppColors.red,
          glow: true,
        ),
      ],
      body: PageBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            KpiGrid(
              children: [
                for (final kpi in controller.kpis) KpiPlainCard(kpi: kpi),
              ],
            ),
            const SizedBox(height: 24),
            FlexRow(
              gap: 24,
              items: [
                (14, _SubmissionsCard(controller: controller)),
                (10, _UpcomingCard(controller: controller)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SubmissionsCard extends StatelessWidget {
  const _SubmissionsCard({required this.controller});

  final TeacherController controller;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Submissions to grade', style: AppTextStyles.cardTitle),
              Text('View all',
                  style: AppTextStyles.jakarta(
                      size: 12.5,
                      weight: FontWeight.w700,
                      color: AppColors.navy)),
            ],
          ),
          const SizedBox(height: 3),
          for (int i = 0; i < controller.submissions.length; i++)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 11),
              decoration: BoxDecoration(
                border: i == controller.submissions.length - 1
                    ? null
                    : const Border(
                        bottom:
                            BorderSide(color: AppColors.divider, width: 1)),
              ),
              child: Row(
                children: [
                  const HatchAvatar(label: '', size: 34, radius: 10),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(controller.submissions[i].student,
                            style: AppTextStyles.jakarta(
                                size: 13,
                                weight: FontWeight.w700,
                                color: AppColors.ink)),
                        Text(controller.submissions[i].task,
                            style: AppTextStyles.cellSub),
                      ],
                    ),
                  ),
                  const PrimaryButton(
                      label: 'Grade', height: 32, fontSize: 12),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _UpcomingCard extends StatelessWidget {
  const _UpcomingCard({required this.controller});

  final TeacherController controller;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Upcoming live', style: AppTextStyles.cardTitle),
          const SizedBox(height: 3),
          for (int i = 0; i < controller.upcoming.length; i++)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 11),
              decoration: BoxDecoration(
                border: i == controller.upcoming.length - 1
                    ? null
                    : const Border(
                        bottom:
                            BorderSide(color: AppColors.divider, width: 1)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    decoration: BoxDecoration(
                      color: AppColors.infoBg,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Column(
                      children: [
                        Text(controller.upcoming[i].day,
                            style: AppTextStyles.jakarta(
                                size: 10,
                                weight: FontWeight.w700,
                                color: AppColors.navy)),
                        Text(controller.upcoming[i].date,
                            style: AppTextStyles.jakarta(
                                size: 16,
                                weight: FontWeight.w800,
                                color: AppColors.navy,
                                height: 1)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(controller.upcoming[i].title,
                            style: AppTextStyles.jakarta(
                                size: 13,
                                weight: FontWeight.w700,
                                color: AppColors.ink)),
                        Text(controller.upcoming[i].meta,
                            style: AppTextStyles.cellSub),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
