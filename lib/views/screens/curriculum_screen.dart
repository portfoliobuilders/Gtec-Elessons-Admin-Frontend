import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/curriculum_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/app_buttons.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_inputs.dart';
import '../../core/widgets/grid_table.dart';
import '../../core/widgets/hatch_avatar.dart';
import '../../core/widgets/status_badge.dart';
import '../../models/models.dart';
import '../layouts/admin_shell.dart';
import '../widgets/nav_presets.dart';
import '../widgets/shared_widgets.dart';

/// 02 · Curriculum Builder — CMS.
class CurriculumScreen extends StatelessWidget {
  const CurriculumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CurriculumController>();
    final bool desktop = Responsive.isDesktop(context);

    final tree = _ModuleTree(controller: controller);
    final panel = _RightPanel(controller: controller);

    return AdminShell(
      navItems: NavPresets.contentAdmin,
      activeIndex: 1,
      user: NavPresets.riyaContentAdmin,
      scrollable: !desktop,
      titleWidget: _Breadcrumb(parts: controller.breadcrumb),
      actions: const [
        PrimaryButton(label: 'Add module', iconPaths: AppIcons.plus),
      ],
      body: desktop
          ? Padding(
              padding: const EdgeInsets.fromLTRB(30, 26, 30, 26),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ScrollConfiguration(
                      behavior: ScrollConfiguration.of(context)
                          .copyWith(scrollbars: false),
                      child: SingleChildScrollView(child: tree),
                    ),
                  ),
                  const SizedBox(width: 24),
                  SizedBox(
                    width: 340,
                    child: ScrollConfiguration(
                      behavior: ScrollConfiguration.of(context)
                          .copyWith(scrollbars: false),
                      child: SingleChildScrollView(child: panel),
                    ),
                  ),
                ],
              ),
            )
          : PageBody(
              topPadding: 26,
              child: Column(children: [tree, const SizedBox(height: 24), panel]),
            ),
    );
  }
}

class _Breadcrumb extends StatelessWidget {
  const _Breadcrumb({required this.parts});

  final List<String> parts;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < parts.length; i++) ...[
          Text(
            parts[i],
            style: AppTextStyles.jakarta(
              size: 14,
              weight: FontWeight.w700,
              color: i == parts.length - 1 ? AppColors.ink : AppColors.grey,
            ),
          ),
          if (i != parts.length - 1)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: AppIcon(AppIcons.chevronRight,
                  size: 14, color: AppColors.chevron, strokeWidth: 2),
            ),
        ],
      ],
    );
  }
}

class _ModuleTree extends StatelessWidget {
  const _ModuleTree({required this.controller});

  final CurriculumController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('MODULE STRUCTURE · DRAG TO REORDER',
            style: AppTextStyles.eyebrow),
        const SizedBox(height: 14),
        for (int i = 0; i < controller.modules.length; i++)
          Padding(
            padding: EdgeInsets.only(
                bottom: i == controller.modules.length - 1 ? 0 : 13),
            child: _ModuleCard(
              module: controller.modules[i],
              onToggle: () => controller.toggleModule(i),
            ),
          ),
      ],
    );
  }
}

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({required this.module, required this.onToggle});

  final ModuleModel module;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final header = GestureDetector(
      onTap: onToggle,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: module.expanded
            ? const BoxDecoration(
                color: AppColors.inputBg,
                border: Border(
                    bottom:
                        BorderSide(color: AppColors.borderLight, width: 1)),
              )
            : null,
        child: Row(
          children: [
            const AppIcon(AppIcons.dragDots,
                size: 16, color: AppColors.chevron, strokeWidth: 2),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(module.title,
                      style: AppTextStyles.jakarta(
                          size: 14,
                          weight: FontWeight.w800,
                          color: AppColors.ink)),
                  const SizedBox(height: 2),
                  Text(module.subtitle,
                      style: AppTextStyles.jakarta(
                          size: 11.5,
                          weight: FontWeight.w600,
                          color: AppColors.grey)),
                ],
              ),
            ),
            StatusBadge.of(
                module.isDraft ? BadgeStatus.draft : BadgeStatus.live),
            const SizedBox(width: 13),
            AppIcon(
              module.expanded ? AppIcons.chevronUp : AppIcons.chevronDown,
              size: 18,
              color: AppColors.grey,
              strokeWidth: 2,
            ),
          ],
        ),
      ),
    );

    final body = AnimatedSize(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      alignment: Alignment.topCenter,
      child: !module.expanded
          ? const SizedBox(width: double.infinity)
          : Column(
              children: [
                for (final lesson in module.lessons)
                  Container(
                    padding: const EdgeInsets.fromLTRB(44, 12, 16, 12),
                    decoration: const BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              color: AppColors.divider, width: 1)),
                    ),
                    child: Row(
                      children: [
                        const AppIcon(AppIcons.play,
                            size: 15, color: AppColors.navy, strokeWidth: 1.8),
                        const SizedBox(width: 12),
                        Expanded(
                            child: Text(lesson.title,
                                style: AppTextStyles.cell)),
                        Text(lesson.duration,
                            style: AppTextStyles.jakarta(
                                size: 11,
                                weight: FontWeight.w600,
                                color: AppColors.grey)),
                      ],
                    ),
                  ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(44, 12, 16, 12),
                  child: Row(
                    children: [
                      const AppIcon(AppIcons.plus,
                          size: 15, color: AppColors.navy, strokeWidth: 2.2),
                      const SizedBox(width: 9),
                      Text('Add lesson',
                          style: AppTextStyles.jakarta(
                              size: 12.5,
                              weight: FontWeight.w700,
                              color: AppColors.navy)),
                    ],
                  ),
                ),
              ],
            ),
    );

    final content = Column(children: [header, body]);

    if (module.isDraft) {
      return DashedBorder(
        radius: 14,
        background: AppColors.white,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: content,
        ),
      );
    }

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.cardBorder, width: 1.5),
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66141A2A), // rgba(20,26,42,0.4)
            offset: Offset(0, 10),
            blurRadius: 22,
            spreadRadius: -18,
          ),
        ],
      ),
      child: content,
    );
  }
}

class _RightPanel extends StatelessWidget {
  const _RightPanel({required this.controller});

  final CurriculumController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _LessonVideoCard(controller: controller),
        const SizedBox(height: 18),
        _ModuleSettingsCard(controller: controller),
      ],
    );
  }
}

class _LessonVideoCard extends StatelessWidget {
  const _LessonVideoCard({required this.controller});

  final CurriculumController controller;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Lesson video',
              style: AppTextStyles.jakarta(
                  size: 13.5, weight: FontWeight.w800, color: AppColors.ink)),
          const SizedBox(height: 6),
          Text(
            'Streamed from YouTube — no video stored on G-TEC servers.',
            style: AppTextStyles.jakarta(
                size: 11.5,
                weight: FontWeight.w600,
                color: AppColors.grey,
                height: 1.45),
          ),
          const SizedBox(height: 14),
          const FieldLabel('YouTube link', suffix: '· unlisted'),
          Container(
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: 11),
            decoration: BoxDecoration(
              color: AppColors.inputBg,
              border: Border.all(color: AppColors.navy, width: 1.5),
              borderRadius: BorderRadius.circular(11),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x6616244A), // rgba(22,36,74,0.4)
                  offset: Offset(0, 4),
                  blurRadius: 12,
                  spreadRadius: -8,
                ),
              ],
            ),
            child: Row(
              children: [
                const _YouTubeChip(),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    controller.youtubeLink,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    style: AppTextStyles.jakarta(
                        size: 12.5,
                        weight: FontWeight.w600,
                        color: AppColors.ink),
                  ),
                ),
                Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                      color: AppColors.greenBg, shape: BoxShape.circle),
                  child: const Center(
                    child: AppIcon(AppIcons.check,
                        size: 12, color: AppColors.green, strokeWidth: 2.6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Video thumbnail.
          SizedBox(
            height: 120,
            width: double.infinity,
            child: HatchBox(
              radius: 11,
              stripe: 9,
              child: Stack(
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Color(0xC70A0E17), // rgba(10,14,23,0.78)
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: AppIcon(AppIcons.play,
                            size: 18, color: AppColors.white, filled: true),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.92),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text('UNLISTED',
                          style: AppTextStyles.jakarta(
                              size: 9.5,
                              weight: FontWeight.w800,
                              color: AppColors.ink,
                              letterSpacing: 0.4)),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xD10A0E17), // rgba(10,14,23,0.82)
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(controller.videoDuration,
                          style: AppTextStyles.jakarta(
                              size: 10,
                              weight: FontWeight.w700,
                              color: AppColors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              const AppIcon(AppIcons.shieldCheck,
                  size: 13, color: AppColors.green, strokeWidth: 1.9),
              const SizedBox(width: 7),
              Text('Link verified · embeddable',
                  style: AppTextStyles.jakarta(
                      size: 11,
                      weight: FontWeight.w700,
                      color: AppColors.green)),
            ],
          ),
          const SizedBox(height: 16),
          Container(height: 1, color: AppColors.hairline),
          const SizedBox(height: 15),
          const FieldLabel('Study materials', suffix: '· PDF uploaded'),
          const SizedBox(height: 2),
          DashedBorder(
            radius: 11,
            background: AppColors.uploadBg,
            child: Padding(
              padding: const EdgeInsets.all(13),
              child: Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: AppColors.navyChipBg,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: const Center(
                      child: AppIcon(AppIcons.upload,
                          size: 16, color: AppColors.navy, strokeWidth: 1.8),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text('Drop notes & PYQs · PDF, up to 50 MB',
                        style: AppTextStyles.jakarta(
                            size: 12,
                            weight: FontWeight.w600,
                            color: AppColors.softGrey)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.redIconBg,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Center(
                  child: AppIcon(AppIcons.file,
                      size: 15, color: AppColors.red, strokeWidth: 1.8),
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(controller.uploadedPdf,
                        style: AppTextStyles.jakarta(
                            size: 12,
                            weight: FontWeight.w700,
                            color: AppColors.ink)),
                    const SizedBox(height: 5),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: Container(
                        height: 4,
                        color: AppColors.toggleOff,
                        child: const FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: 1.0,
                          child: ColoredBox(color: AppColors.green),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _YouTubeChip extends StatelessWidget {
  const _YouTubeChip();

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}

class _ModuleSettingsCard extends StatelessWidget {
  const _ModuleSettingsCard({required this.controller});

  final CurriculumController controller;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Module settings',
              style: AppTextStyles.jakarta(
                  size: 13.5, weight: FontWeight.w800, color: AppColors.ink)),
          const SizedBox(height: 14),
          const FieldLabel('Visibility'),
          Row(
            children: [
              Expanded(
                child: _VisibilityButton(
                  label: 'Published',
                  active: controller.published,
                  onTap: () => controller.setPublished(true),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _VisibilityButton(
                  label: 'Draft',
                  active: !controller.published,
                  onTap: () => controller.setPublished(false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Free preview module', style: AppTextStyles.cell),
              AppToggle(
                value: controller.freePreview,
                onChanged: controller.setFreePreview,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VisibilityButton extends StatelessWidget {
  const _VisibilityButton(
      {required this.label, required this.active, required this.onTap});

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 40,
          decoration: BoxDecoration(
            color: active ? AppColors.navy : Colors.transparent,
            border: active
                ? null
                : Border.all(color: AppColors.border, width: 1.5),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.jakarta(
                size: 12.5,
                weight: FontWeight.w700,
                color: active ? AppColors.white : AppColors.muted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
