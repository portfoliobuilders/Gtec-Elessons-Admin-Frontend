import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/hatch_avatar.dart';
import '../../models/models.dart';

/// Dark sidebar — `width:240; background:#0E1424; padding:24px 16px`.
/// Nav sets and user identity differ per screen (per the design), so both
/// are injected. Active item: navy pill `#16244A`, white 700 text.
class AppSidebar extends StatelessWidget {
  const AppSidebar({
    super.key,
    required this.brandSuffix,
    required this.items,
    required this.activeIndex,
    required this.user,
    this.onItemTap,
  });

  final String brandSuffix; // 'admin' or 'teacher'
  final List<NavItemModel> items;
  final int activeIndex;
  final SidebarUser user;
  final ValueChanged<NavItemModel>? onItemTap;

  Color get _roleColor => switch (user.roleColorKey) {
        SidebarRoleColor.superAdmin => AppColors.roleSuperAdmin,
        SidebarRoleColor.admin => AppColors.roleAdmin,
        SidebarRoleColor.teacher => AppColors.roleTeacher,
        SidebarRoleColor.muted => AppColors.sidebarMuted,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.sidebarWidth,
      color: AppColors.sidebarBg,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Brand lockup.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(9),
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
                const SizedBox(width: 10),
                Text.rich(
                  TextSpan(
                    text: 'G-TEC ',
                    style: AppTextStyles.jakarta(
                      size: 16,
                      weight: FontWeight.w800,
                      color: AppColors.white,
                      letterSpacing: -0.3,
                    ),
                    children: [
                      TextSpan(
                        text: brandSuffix,
                        style: AppTextStyles.jakarta(
                          size: 12,
                          weight: FontWeight.w600,
                          color: AppColors.sidebarMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),

          // Nav items.
          for (int i = 0; i < items.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: _SidebarItem(
                item: items[i],
                active: i == activeIndex,
                onTap: onItemTap == null ? null : () => onItemTap!(items[i]),
              ),
            ),

          const Spacer(),

          // User card.
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                HatchAvatar(
                    label: user.monogram, size: 34, radius: 10, dark: true),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.jakarta(
                          size: 12.5,
                          weight: FontWeight.w700,
                          color: AppColors.white,
                        ),
                      ),
                      Text(
                        user.role,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.jakarta(
                          size: 10.5,
                          weight: user.roleColorKey == SidebarRoleColor.muted
                              ? FontWeight.w500
                              : FontWeight.w700,
                          color: _roleColor,
                        ),
                      ),
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

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({required this.item, required this.active, this.onTap});

  final NavItemModel item;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: active ? AppColors.navy : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Row(
            children: [
              AppIcon(
                item.iconPaths,
                size: 19,
                color: active ? AppColors.white : AppColors.sidebarItem,
                strokeWidth: 1.8,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.label,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.jakarta(
                    size: 13.5,
                    weight: active ? FontWeight.w700 : FontWeight.w600,
                    color: active ? AppColors.white : AppColors.sidebarItem,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
