import 'package:flutter/material.dart';

import '../../../core/widgets/app_card.dart';

/// Large centered white form card used by every "Add …" screen in the
/// Curriculum flow — capped width so long-form fields stay readable on
/// wide desktop viewports.
class CurriculumFormCard extends StatelessWidget {
  const CurriculumFormCard({super.key, required this.child, this.maxWidth = 960});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: AppCard(
          padding: const EdgeInsets.all(28),
          child: child,
        ),
      ),
    );
  }
}
