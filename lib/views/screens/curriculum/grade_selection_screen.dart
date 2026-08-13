import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/curriculum_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_inputs.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../models/admin/admin_models.dart';
import '../../../routes/app_routes.dart';
import '../../layouts/admin_shell.dart';
import '../../widgets/curriculum/curriculum_breadcrumb.dart';
import '../../widgets/curriculum/curriculum_header.dart';
import '../../widgets/curriculum/grade_card.dart';
import '../../widgets/nav_presets.dart';
import '../../widgets/shared_widgets.dart';

/// Screen 1 · Grade selection — top level of the Curriculum flow.
/// Backed by real data: `GET /admin/curriculum` via CurriculumController.
class GradeSelectionScreen extends StatefulWidget {
  const GradeSelectionScreen({super.key});

  @override
  State<GradeSelectionScreen> createState() => _GradeSelectionScreenState();
}

class _GradeSelectionScreenState extends State<GradeSelectionScreen> {
  @override
  void initState() {
    super.initState();
    final controller = context.read<CurriculumController>();
    if (controller.curriculumStatus == CurriculumLoadStatus.initial) {
      controller.loadCurriculum();
    }
  }

  void _openGrade(BuildContext context, AdminGradeModel grade) {
    context.read<CurriculumController>().selectCurriculumGrade(grade.id);
    Navigator.of(context).pushReplacementNamed(AppRoutes.curriculumGradeDetail);
  }

  void _addGrade(BuildContext context) {
    context.read<CurriculumController>().clearSelectedCurriculumGrade();
    Navigator.of(context).pushReplacementNamed(AppRoutes.curriculumAddGrade);
  }

  void _editGrade(BuildContext context, AdminGradeModel grade) {
    context.read<CurriculumController>().selectCurriculumGrade(grade.id);
    Navigator.of(context).pushReplacementNamed(AppRoutes.curriculumAddGrade);
  }

  Future<void> _deleteGrade(BuildContext context, AdminGradeModel grade) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete grade?',
      message: 'Delete "${grade.name}"? This action cannot be undone.',
    );
    if (!confirmed || !context.mounted) return;
    final controller = context.read<CurriculumController>();
    final ok = await controller.deleteGrade(grade.id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Grade deleted.' : controller.curriculumError ?? 'Unable to delete grade.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CurriculumController>();

    return AdminShell(
      navItems: NavPresets.admin,
      activeIndex: 1,
      user: NavPresets.riyaContentAdmin,
      titleWidget: const CurriculumBreadcrumb(
        segments: [CrumbSegment('Curriculum', icon: AppIcons.home)],
      ),
      actions: [
        PrimaryButton(label: 'Add grade', iconPaths: AppIcons.plus, onTap: () => _addGrade(context)),
      ],
      body: PageBody(
        topPadding: 26,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CurriculumHeader(
              title: 'Curriculum',
              subtitle: 'Manage grades, subjects, chapters and lessons.',
              trailing: AppSearchField(
                hint: 'Search grade…',
                width: 260,
                onChanged: controller.setCurriculumGradeSearch,
              ),
            ),
            const SizedBox(height: 24),
            _CurriculumBody(
              controller: controller,
              onGradeTap: (g) => _openGrade(context, g),
              onAddGrade: () => _addGrade(context),
              onEditGrade: (g) => _editGrade(context, g),
              onDeleteGrade: (g) => _deleteGrade(context, g),
            ),
          ],
        ),
      ),
    );
  }
}

class _CurriculumBody extends StatelessWidget {
  const _CurriculumBody({
    required this.controller,
    required this.onGradeTap,
    required this.onAddGrade,
    required this.onEditGrade,
    required this.onDeleteGrade,
  });

  final CurriculumController controller;
  final ValueChanged<AdminGradeModel> onGradeTap;
  final VoidCallback onAddGrade;
  final ValueChanged<AdminGradeModel> onEditGrade;
  final ValueChanged<AdminGradeModel> onDeleteGrade;

  @override
  Widget build(BuildContext context) {
    switch (controller.curriculumStatus) {
      case CurriculumLoadStatus.initial:
      case CurriculumLoadStatus.loading:
        return const _CurriculumLoading();
      case CurriculumLoadStatus.error:
        return _CurriculumError(
          message: controller.curriculumError ?? 'Unable to load curriculum. Please try again.',
          onRetry: () => context.read<CurriculumController>().loadCurriculum(),
        );
      case CurriculumLoadStatus.loaded:
        final grades = controller.filteredCurriculumGrades;
        if (controller.curriculumGrades.isEmpty) {
          return _CurriculumEmpty(onAddGrade: onAddGrade);
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GradeGrid(
              grades: grades,
              onGradeTap: onGradeTap,
              onAddGrade: onAddGrade,
              onEditGrade: onEditGrade,
              onDeleteGrade: onDeleteGrade,
            ),
            const SizedBox(height: 22),
            const InfoBanner(text: 'Click a grade to view and manage its subjects.'),
          ],
        );
    }
  }
}

class _CurriculumLoading extends StatelessWidget {
  const _CurriculumLoading();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 80),
      child: Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(strokeWidth: 2.6, color: AppColors.navy),
        ),
      ),
    );
  }
}

class _CurriculumEmpty extends StatelessWidget {
  const _CurriculumEmpty({required this.onAddGrade});

  final VoidCallback onAddGrade;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(color: AppColors.navyChipBg, shape: BoxShape.circle),
              child: const Center(
                child: AppIcon(AppIcons.book, size: 24, color: AppColors.navy, strokeWidth: 1.8),
              ),
            ),
            const SizedBox(height: 16),
            Text('No grades yet',
                style: AppTextStyles.jakarta(size: 16, weight: FontWeight.w800, color: AppColors.ink)),
            const SizedBox(height: 6),
            Text(
              'Create your first grade to start building the curriculum.',
              style: AppTextStyles.jakarta(size: 13, weight: FontWeight.w600, color: AppColors.grey),
            ),
            const SizedBox(height: 20),
            PrimaryButton(label: 'Add Grade', iconPaths: AppIcons.plus, onTap: onAddGrade),
          ],
        ),
      ),
    );
  }
}

class _CurriculumError extends StatelessWidget {
  const _CurriculumError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(color: AppColors.redBg, shape: BoxShape.circle),
              child: const Center(
                child: AppIcon(AppIcons.info, size: 24, color: AppColors.red, strokeWidth: 1.8),
              ),
            ),
            const SizedBox(height: 16),
            Text('Unable to load curriculum.',
                style: AppTextStyles.jakarta(size: 16, weight: FontWeight.w800, color: AppColors.ink)),
            const SizedBox(height: 6),
            Text(message,
                textAlign: TextAlign.center,
                style: AppTextStyles.jakarta(size: 13, weight: FontWeight.w600, color: AppColors.grey)),
            const SizedBox(height: 20),
            OutlineButtonX(label: 'Retry', iconPaths: AppIcons.arrowRight, onTap: onRetry),
          ],
        ),
      ),
    );
  }
}
