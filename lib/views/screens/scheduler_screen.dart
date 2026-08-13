import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/scheduler_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/app_buttons.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_inputs.dart';
import '../layouts/admin_shell.dart';
import '../widgets/nav_presets.dart';
import '../widgets/shared_widgets.dart';

/// 08 · Live Class Scheduler.
class SchedulerScreen extends StatelessWidget {
  const SchedulerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SchedulerController>();
    final bool desktop = Responsive.isDesktop(context);

    final form = _ClassDetailsCard(controller: controller);
    final audience = _AudienceCard(controller: controller);

    return AdminShell(
      navItems: NavPresets.admin,
      activeIndex: 6,
      user: NavPresets.karthikAdmin,
      title: 'Schedule a live class',
      actions: const [
        OutlineButtonX(label: 'Save draft'),
        PrimaryButton(
            label: 'Schedule & notify',
            iconPaths: AppIcons.bellPlain,
            iconStroke: 1.8),
      ],
      body: PageBody(
        topPadding: 26,
        child: desktop
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: form),
                  const SizedBox(width: 24),
                  SizedBox(width: 300, child: audience),
                ],
              )
            : Column(children: [form, const SizedBox(height: 24), audience]),
      ),
    );
  }
}

class _ClassDetailsCard extends StatelessWidget {
  const _ClassDetailsCard({required this.controller});

  final SchedulerController controller;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('CLASS DETAILS',
              style: AppTextStyles.jakarta(
                  size: 12,
                  weight: FontWeight.w800,
                  color: AppColors.grey,
                  letterSpacing: 0.5)),
          const SizedBox(height: 16),
          const FieldLabel('Title'),
          InputBox(value: controller.title, focused: true),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const FieldLabel('Subject · Class'),
                    DropdownBox(value: controller.subjectClass),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const FieldLabel('Teacher'),
                    DropdownBox(value: controller.teacher),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const FieldLabel('Date'),
                    InputBox(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      leading: const AppIcon(AppIcons.calendar,
                          size: 15, color: AppColors.grey, strokeWidth: 1.8),
                      child: Text(controller.date,
                          style: AppTextStyles.jakarta(
                              size: 13.5,
                              weight: FontWeight.w600,
                              color: AppColors.ink)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const FieldLabel('Time'),
                    InputBox(
                      child: Text(controller.time,
                          style: AppTextStyles.jakarta(
                              size: 13.5,
                              weight: FontWeight.w600,
                              color: AppColors.ink)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const FieldLabel('Duration'),
                    InputBox(
                      child: Text(controller.duration,
                          style: AppTextStyles.jakarta(
                              size: 13.5,
                              weight: FontWeight.w600,
                              color: AppColors.ink)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const FieldLabel('Stream link', suffix: '· YouTube live / Meet'),
          InputBox(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            leading: Container(
              width: 26,
              height: 19,
              decoration: BoxDecoration(
                color: AppColors.red,
                borderRadius: BorderRadius.circular(5),
              ),
              child: const Center(
                child: AppIcon(AppIcons.play,
                    size: 11, color: AppColors.white, filled: true),
              ),
            ),
            child: Text(controller.streamLink,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.jakarta(
                    size: 13.5,
                    weight: FontWeight.w600,
                    color: AppColors.ink)),
          ),
        ],
      ),
    );
  }
}

class _AudienceCard extends StatelessWidget {
  const _AudienceCard({required this.controller});

  final SchedulerController controller;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('AUDIENCE',
              style: AppTextStyles.jakarta(
                  size: 12,
                  weight: FontWeight.w800,
                  color: AppColors.grey,
                  letterSpacing: 0.5)),
          const SizedBox(height: 16),
          for (int i = 0; i < controller.audiences.length; i++)
            Padding(
              padding: EdgeInsets.only(
                  bottom: i == controller.audiences.length - 1 ? 18 : 10),
              child: _AudienceOption(
                label: controller.audiences[i],
                selected: i == controller.selectedAudience,
                onTap: () => controller.selectAudience(i),
              ),
            ),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.infoBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Reach',
                    style: AppTextStyles.jakarta(
                        size: 12,
                        weight: FontWeight.w700,
                        color: AppColors.navy)),
                const SizedBox(height: 6),
                Text(controller.reach,
                    style: AppTextStyles.jakarta(
                        size: 22,
                        weight: FontWeight.w800,
                        color: AppColors.navy,
                        letterSpacing: -0.4)),
                const SizedBox(height: 4),
                Text(controller.reachNote,
                    style: AppTextStyles.jakarta(
                        size: 11.5,
                        weight: FontWeight.w500,
                        color: AppColors.reachSub)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AudienceOption extends StatelessWidget {
  const _AudienceOption(
      {required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: selected ? AppColors.inputBg : Colors.transparent,
            border: Border.all(
              color: selected ? AppColors.navy : AppColors.border,
              width: selected ? 2 : 1.5,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.jakarta(
                    size: 13.5,
                    weight: selected ? FontWeight.w700 : FontWeight.w600,
                    color: selected ? AppColors.ink : AppColors.body,
                  ),
                ),
              ),
              RadioDot(selected: selected),
            ],
          ),
        ),
      ),
    );
  }
}
