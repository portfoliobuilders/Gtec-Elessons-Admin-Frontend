import 'package:flutter/widgets.dart';

import '../constants/app_sizes.dart';

/// Breakpoint helper — the design targets a 1440px desktop canvas.
/// Below [AppSizes.tablet] the sidebar collapses into a drawer and
/// grids reflow, preserving the original proportions where possible.
class Responsive {
  Responsive._();

  static double width(BuildContext context) =>
      MediaQuery.sizeOf(context).width;

  static bool isDesktop(BuildContext context) =>
      width(context) >= AppSizes.tablet;

  static bool isTablet(BuildContext context) =>
      width(context) >= AppSizes.phone && width(context) < AppSizes.tablet;

  static bool isPhone(BuildContext context) =>
      width(context) < AppSizes.phone;

  /// KPI grid columns: 4 → 2 → 1.
  static int kpiColumns(BuildContext context) =>
      isDesktop(context) ? 4 : (isTablet(context) ? 2 : 1);
}
