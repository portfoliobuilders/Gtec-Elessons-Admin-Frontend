import 'package:flutter/material.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/widgets/app_buttons.dart';

/// Right-aligned Cancel / Save row — the footer of every "Add …" form in
/// the Curriculum flow.
class SaveActionBar extends StatelessWidget {
  const SaveActionBar({
    super.key,
    required this.onCancel,
    required this.onSave,
    this.saveLabel = 'Save',
    this.cancelLabel = 'Cancel',
  });

  final VoidCallback onCancel;
  final VoidCallback onSave;
  final String saveLabel;
  final String cancelLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlineButtonX(label: cancelLabel, iconPaths: AppIcons.close, onTap: onCancel),
        const SizedBox(width: 12),
        PrimaryButton(label: saveLabel, iconPaths: AppIcons.save, onTap: onSave),
      ],
    );
  }
}
