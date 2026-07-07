import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/responsive.dart';

/// White top bar — `height:70; border-bottom:1px #EDF0F5; padding:0 30px`.
class AppTopBar extends StatelessWidget {
  const AppTopBar({
    super.key,
    this.title,
    this.titleWidget,
    this.actions = const [],
    this.showMenuButton = false,
  });

  final String? title;
  final Widget? titleWidget;
  final List<Widget> actions;
  final bool showMenuButton;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizes.topBarHeight,
      padding: EdgeInsets.symmetric(
          horizontal: Responsive.isPhone(context) ? 16 : AppSizes.pagePaddingH),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.borderLight, width: 1),
        ),
      ),
      child: Row(
        children: [
          if (showMenuButton) ...[
            GestureDetector(
              onTap: () => Scaffold.of(context).openDrawer(),
              child: const Padding(
                padding: EdgeInsets.only(right: 14),
                child: Icon(Icons.menu_rounded, color: AppColors.ink, size: 22),
              ),
            ),
          ],
          Expanded(
            child: titleWidget ??
                Text(
                  title ?? '',
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.pageTitle,
                ),
          ),
          ..._spaced(actions),
        ],
      ),
    );
  }

  List<Widget> _spaced(List<Widget> widgets) {
    final out = <Widget>[];
    for (int i = 0; i < widgets.length; i++) {
      out.add(widgets[i]);
      if (i != widgets.length - 1) out.add(const SizedBox(width: 12));
    }
    return out;
  }
}

/// Bell with red dot — used in the Dashboard top bar.
class NotificationBell extends StatelessWidget {
  const NotificationBell({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 24,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Center(
            child: AppIcon(AppIcons.bell,
                size: 21, color: AppColors.ink, strokeWidth: 1.7),
          ),
          Positioned(
            top: -1,
            right: -1,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.red,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.white, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
