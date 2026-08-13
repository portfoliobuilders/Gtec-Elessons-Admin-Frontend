import 'package:flutter/material.dart';

import '../../../core/widgets/app_inputs.dart';

/// `FieldLabel` + [AppTextField] in one call — the standard text field used
/// across every "Add …" form in the Curriculum flow.
class LabeledTextField extends StatelessWidget {
  const LabeledTextField(
    this.label, {
    super.key,
    required this.controller,
    this.hint,
    this.required = false,
    this.keyboardType,
    this.maxLines = 1,
    this.trailing,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final bool required;
  final TextInputType? keyboardType;
  final int maxLines;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(label, suffix: required ? '*' : null),
        AppTextField(
          controller: controller,
          hint: hint,
          keyboardType: keyboardType,
          maxLines: maxLines,
          trailing: trailing,
        ),
      ],
    );
  }
}

/// `FieldLabel` + [AppDropdownField] in one call.
class LabeledDropdownField<T> extends StatelessWidget {
  const LabeledDropdownField(
    this.label, {
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.itemLabel,
    this.hint,
    this.required = false,
  });

  final String label;
  final T? value;
  final List<T> items;
  final ValueChanged<T?> onChanged;
  final String Function(T)? itemLabel;
  final String? hint;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(label, suffix: required ? '*' : null),
        AppDropdownField<T>(
          value: value,
          items: items,
          itemLabel: itemLabel ?? (v) => v.toString(),
          onChanged: onChanged,
          hint: hint,
        ),
      ],
    );
  }
}
