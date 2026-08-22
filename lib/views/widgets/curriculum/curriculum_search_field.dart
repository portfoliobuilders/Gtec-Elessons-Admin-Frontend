import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/responsive.dart';

/// Local-filter search box shared by Subject Detail (chapter search) and
/// Chapter Detail (lesson search) — same visual language as
/// [AppSearchField] (shared_widgets' Dashboard/Payments search), just with
/// its own controller/clear-button/responsive-width behavior those screens
/// need and `AppSearchField` doesn't currently offer.
///
/// Purely a local-filter input — [onChanged] fires on every keystroke so the
/// caller can filter its already-loaded list; this widget never makes a
/// network request itself.
class CurriculumSearchField extends StatefulWidget {
  const CurriculumSearchField({super.key, required this.hint, required this.onChanged});

  final String hint;
  final ValueChanged<String> onChanged;

  @override
  State<CurriculumSearchField> createState() => _CurriculumSearchFieldState();
}

class _CurriculumSearchFieldState extends State<CurriculumSearchField> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _hasText = false;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_handleTextChange);
    _focusNode.addListener(_handleFocusChange);
  }

  void _handleTextChange() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText != _hasText) setState(() => _hasText = hasText);
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus != _focused) setState(() => _focused = _focusNode.hasFocus);
  }

  void _clear() {
    _controller.clear();
    widget.onChanged('');
  }

  @override
  void dispose() {
    _controller.removeListener(_handleTextChange);
    _focusNode.removeListener(_handleFocusChange);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Desktop: compact, fixed width — sits above the grid without
        // stretching. Tablet: a wider percentage of the available content
        // width. Mobile: full width, matching the rest of the page content.
        final double width = Responsive.isPhone(context)
            ? constraints.maxWidth
            : Responsive.isDesktop(context)
                ? 320
                : constraints.maxWidth * 0.6;

        return Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: width,
            child: Container(
              height: 42,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.searchBg,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(
                  color: _focused ? AppColors.navy : AppColors.borderLight,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  const AppIcon(AppIcons.search, size: 17, color: AppColors.grey, strokeWidth: 1.8),
                  const SizedBox(width: 9),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      onChanged: widget.onChanged,
                      style: AppTextStyles.jakarta(size: 13.5, weight: FontWeight.w500, color: AppColors.ink),
                      decoration: InputDecoration(
                        isCollapsed: true,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                        hintText: widget.hint,
                        hintStyle: AppTextStyles.jakarta(size: 13.5, weight: FontWeight.w500, color: AppColors.softGrey),
                      ),
                    ),
                  ),
                  if (_hasText) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _clear,
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(color: AppColors.chipTrackBg, shape: BoxShape.circle),
                          child: const Center(
                            child: AppIcon(AppIcons.close, size: 10, color: AppColors.grey, strokeWidth: 2.2),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
