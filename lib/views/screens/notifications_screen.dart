import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/notifications_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_inputs.dart';
import '../layouts/admin_shell.dart';
import '../widgets/nav_presets.dart';
import '../widgets/shared_widgets.dart';

/// 09 · Notifications / Broadcast.
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<NotificationsController>();
    final bool desktop = Responsive.isDesktop(context);

    final composer = _ComposerCard(controller: controller);
    final side = _SidePanel(controller: controller);

    return AdminShell(
      navItems: NavPresets.admin,
      activeIndex: 7,
      user: NavPresets.gtecAdmin,
      title: 'Notifications',
      body: PageBody(
        topPadding: 26,
        child: desktop
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: composer),
                  const SizedBox(width: 24),
                  SizedBox(width: 320, child: side),
                ],
              )
            : Column(children: [composer, const SizedBox(height: 24), side]),
      ),
    );
  }
}

class _ComposerCard extends StatelessWidget {
  const _ComposerCard({required this.controller});

  final NotificationsController controller;

  static const List<String> _channelIcons = [
    AppIcons.phone,
    AppIcons.send,
    AppIcons.bellPlain,
  ];

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('New broadcast',
              style: AppTextStyles.jakarta(
                  size: 17,
                  weight: FontWeight.w800,
                  color: AppColors.ink,
                  letterSpacing: -0.3)),
          const SizedBox(height: 18),

          // Channel chips.
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (int i = 0; i < controller.channels.length; i++)
                AppFilterChip(
                  label: controller.channels[i],
                  active: i == controller.selectedChannel,
                  onTap: () => controller.selectChannel(i),
                  height: 38,
                  radius: 11,
                  iconPaths: i == controller.selectedChannel
                      ? _channelIcons[i]
                      : null,
                ),
            ],
          ),
          const SizedBox(height: 18),

          const FieldLabel('Title'),
          InputBox(value: controller.title, focused: true, height: 46),
          const SizedBox(height: 14),

          const FieldLabel('Message'),
          Container(
            height: 96,
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border, width: 1.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              controller.message,
              style: AppTextStyles.jakarta(
                  size: 13.5,
                  weight: FontWeight.w500,
                  color: AppColors.body,
                  height: 1.5),
            ),
          ),
          const SizedBox(height: 16),

          const FieldLabel('Audience'),
          Row(
            children: [
              for (int i = 0; i < controller.audiences.length; i++) ...[
                if (i != 0) const SizedBox(width: 10),
                Expanded(
                  child: _AudienceChip(
                    label: controller.audiences[i],
                    selected: i == controller.selectedAudience,
                    onTap: () => controller.selectAudience(i),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _AudienceChip extends StatelessWidget {
  const _AudienceChip(
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
          decoration: BoxDecoration(
            color: selected ? AppColors.inputBg : Colors.transparent,
            border: Border.all(
              color: selected ? AppColors.navy : AppColors.border,
              width: selected ? 2 : 1.5,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.jakarta(
                size: 13,
                weight: selected ? FontWeight.w700 : FontWeight.w600,
                color: selected ? AppColors.ink : AppColors.body,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SidePanel extends StatelessWidget {
  const _SidePanel({required this.controller});

  final NotificationsController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Phone preview.
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('PREVIEW',
                  style: AppTextStyles.jakarta(
                      size: 12,
                      weight: FontWeight.w800,
                      color: AppColors.grey,
                      letterSpacing: 0.5)),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.sidebarBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: AppColors.red,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(controller.title,
                                style: AppTextStyles.jakarta(
                                    size: 12.5,
                                    weight: FontWeight.w800,
                                    color: AppColors.white)),
                            const SizedBox(height: 2),
                            Text(
                              '${controller.message.substring(0, 63)}…',
                              style: AppTextStyles.jakarta(
                                  size: 11,
                                  weight: FontWeight.w500,
                                  color: AppColors.notifBody,
                                  height: 1.4),
                            ),
                            const SizedBox(height: 6),
                            Text('G-TEC · now',
                                style: AppTextStyles.jakarta(
                                    size: 10,
                                    weight: FontWeight.w600,
                                    color: AppColors.notifMeta)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Reach + send.
        AppCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _row('Estimated reach', controller.estimatedReach),
              const SizedBox(height: 12),
              _row('Send', controller.sendTime),
              const SizedBox(height: 18),
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.navy,
                  borderRadius: BorderRadius.circular(13),
                  boxShadow: AppTheme.glow(const Color(0xFF16244A)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const AppIcon(AppIcons.send,
                        size: 17, color: AppColors.white, strokeWidth: 1.9),
                    const SizedBox(width: 9),
                    Text('Send broadcast',
                        style: AppTextStyles.jakarta(
                            size: 14.5,
                            weight: FontWeight.w700,
                            color: AppColors.white)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _row(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: AppTextStyles.jakarta(
                size: 13, weight: FontWeight.w600, color: AppColors.muted)),
        Text(value,
            style: AppTextStyles.jakarta(
                size: 13, weight: FontWeight.w800, color: AppColors.ink)),
      ],
    );
  }
}
