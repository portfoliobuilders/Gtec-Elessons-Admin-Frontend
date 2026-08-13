import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'app_buttons.dart';

/// Destructive-action confirmation dialog — picks up `AppTheme.light`'s
/// `dialogTheme` (white, cardRadius, themed title style) automatically via
/// `showDialog`. Returns true if the user confirmed, false/null otherwise.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Delete',
  String cancelLabel = 'Cancel',
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(
        message,
        style: AppTextStyles.jakarta(size: 13.5, weight: FontWeight.w600, color: AppColors.muted, height: 1.5),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      actions: [
        OutlineButtonX(label: cancelLabel, onTap: () => Navigator.of(context).pop(false)),
        const SizedBox(width: 10),
        PrimaryButton(label: confirmLabel, background: AppColors.red, onTap: () => Navigator.of(context).pop(true)),
      ],
    ),
  );
  return result ?? false;
}
