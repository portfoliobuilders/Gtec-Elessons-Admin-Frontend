import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

/// A pastel background paired with its deeper "ink" accent — both values
/// are existing [AppColors] tokens, never new hex literals. Grade and
/// subject cards cycle through this list by index.
class CurriculumTint {
  const CurriculumTint(this.bg, this.accent);

  final Color bg;
  final Color accent;
}

const List<CurriculumTint> curriculumTints = [
  CurriculumTint(AppColors.navyChipBg, AppColors.navy),
  CurriculumTint(AppColors.amberBg, AppColors.amber),
  CurriculumTint(AppColors.greenBg, AppColors.green),
  CurriculumTint(AppColors.redBg, AppColors.red),
  CurriculumTint(AppColors.greenSelBg, AppColors.green),
];

CurriculumTint tintForIndex(int index) => curriculumTints[index % curriculumTints.length];
