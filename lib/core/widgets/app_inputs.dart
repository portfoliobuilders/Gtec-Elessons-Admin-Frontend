import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_icons.dart';
import '../theme/app_text_styles.dart';

/// Top-bar search box — `width:300; height:42; radius:11; bg:#F4F6FA`.
class AppSearchField extends StatelessWidget {
  const AppSearchField({
    super.key,
    this.hint = 'Search…',
    this.width = 300,
    this.onChanged,
  });

  final String hint;
  final double width;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.searchBg,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: AppColors.borderLight, width: 1.5),
      ),
      child: Row(
        children: [
          const AppIcon(AppIcons.search,
              size: 17, color: AppColors.grey, strokeWidth: 1.8),
          const SizedBox(width: 9),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              style: AppTextStyles.jakarta(
                  size: 13.5, weight: FontWeight.w500, color: AppColors.ink),
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                hintText: hint,
                hintStyle: AppTextStyles.jakarta(
                    size: 13.5, weight: FontWeight.w500, color: AppColors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// iOS-style toggle — on: navy 46×27, off: grey 42×25 (as in the design).
class AppToggle extends StatelessWidget {
  const AppToggle({super.key, required this.value, this.onChanged});

  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final double w = value ? 46 : 42;
    final double h = value ? 27 : 25;
    final double knob = value ? 21 : 19;
    return GestureDetector(
      onTap: onChanged == null ? null : () => onChanged!(!value),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          width: w,
          height: h,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: value ? AppColors.navy : AppColors.toggleOff,
            borderRadius: BorderRadius.circular(h / 2),
          ),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: knob,
              height: knob,
              decoration: const BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x33000000),
                    offset: Offset(0, 1),
                    blurRadius: 3,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Rounded filter pill — active: navy fill, inactive: white + border.
class AppFilterChip extends StatelessWidget {
  const AppFilterChip({
    super.key,
    required this.label,
    this.active = false,
    this.onTap,
    this.height = 36,
    this.radius = 10,
    this.iconPaths,
  });

  final String label;
  final bool active;
  final VoidCallback? onTap;
  final double height;
  final double radius;
  final String? iconPaths;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: active ? AppColors.navy : AppColors.white,
            border: active
                ? null
                : Border.all(color: AppColors.border, width: 1.5),
            borderRadius: BorderRadius.circular(radius),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (iconPaths != null) ...[
                AppIcon(iconPaths!,
                    size: 15,
                    color: active ? AppColors.white : AppColors.body,
                    strokeWidth: 1.8),
                const SizedBox(width: 7),
              ],
              Text(
                label,
                style: AppTextStyles.jakarta(
                  size: 13,
                  weight: active ? FontWeight.w700 : FontWeight.w600,
                  color: active ? AppColors.white : AppColors.body,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Segmented control on a grey track (Pricing header: Recorded / Live+Recorded).
class SegmentedControl extends StatelessWidget {
  const SegmentedControl({
    super.key,
    required this.segments,
    required this.selected,
    this.onChanged,
  });

  final List<String> segments;
  final int selected;
  final ValueChanged<int>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.chipTrackBg,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < segments.length; i++)
            GestureDetector(
              onTap: onChanged == null ? null : () => onChanged!(i),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
                  decoration: BoxDecoration(
                    color: i == selected ? AppColors.navy : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    segments[i],
                    style: AppTextStyles.jakarta(
                      size: 12.5,
                      weight: FontWeight.w700,
                      color: i == selected
                          ? AppColors.white
                          : AppColors.softGrey,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Small field label above inputs — `12/700 #6B7486`.
class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key, this.suffix});

  final String text;
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Text.rich(
        TextSpan(
          text: text,
          style: AppTextStyles.fieldLabel,
          children: [
            if (suffix != null)
              TextSpan(
                text: ' $suffix',
                style: AppTextStyles.jakarta(
                    size: 12, weight: FontWeight.w600, color: AppColors.grey),
              ),
          ],
        ),
      ),
    );
  }
}

/// Static styled input box (design shows pre-filled values, no live editing
/// is redesigned — box supports both display + editable modes).
class InputBox extends StatelessWidget {
  const InputBox({
    super.key,
    this.value,
    this.child,
    this.focused = false,
    this.height = 48,
    this.radius = 12,
    this.leading,
    this.trailing,
    this.padding = const EdgeInsets.symmetric(horizontal: 14),
    this.crossAlign = CrossAxisAlignment.center,
  });

  final String? value;
  final Widget? child;
  final bool focused;
  final double height;
  final double radius;
  final Widget? leading;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;
  final CrossAxisAlignment crossAlign;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: focused ? AppColors.inputBg : AppColors.white,
        border: Border.all(
          color: focused ? AppColors.navy : AppColors.border,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Row(
        crossAxisAlignment: crossAlign,
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 9)],
          Expanded(
            child: child ??
                Text(
                  value ?? '',
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.jakarta(
                    size: 14,
                    weight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Dropdown-styled box with a chevron.
class DropdownBox extends StatelessWidget {
  const DropdownBox({super.key, required this.value, this.height = 48});

  final String value;
  final double height;

  @override
  Widget build(BuildContext context) {
    return InputBox(
      value: value,
      height: height,
      trailing: const AppIcon(AppIcons.chevronDown,
          size: 15, color: AppColors.grey, strokeWidth: 2),
    );
  }
}

/// Round radio indicator (selected = filled navy/green with check).
class RadioDot extends StatelessWidget {
  const RadioDot({
    super.key,
    required this.selected,
    this.fill = AppColors.navy,
    this.size = 22,
  });

  final bool selected;
  final Color fill;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (!selected) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border, width: 2),
        ),
      );
    }
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: fill),
      child: Center(
        child: AppIcon(AppIcons.check,
            size: size * 0.55, color: AppColors.white, strokeWidth: 2.6),
      ),
    );
  }
}
