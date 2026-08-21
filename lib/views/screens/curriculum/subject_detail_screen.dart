import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/curriculum_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../models/admin/admin_models.dart';
import '../../../routes/app_routes.dart';
import '../../layouts/admin_shell.dart';
import '../../widgets/curriculum/chapter_card.dart';
import '../../widgets/curriculum/cover_image_uploader.dart';
import '../../widgets/curriculum/curriculum_breadcrumb.dart';
import '../../widgets/curriculum/curriculum_header.dart';
import '../../widgets/nav_presets.dart';
import '../../widgets/shared_widgets.dart';

/// Screen 2.5 · Subject detail. Shows the real subject record plus real
/// Chapter management (create/edit/delete) — chapters come from the
/// already-loaded `GET /admin/curriculum` tree, no extra request.
class SubjectDetailScreen extends StatelessWidget {
  const SubjectDetailScreen({super.key});

  void _goToCurriculum(BuildContext context) =>
      Navigator.of(context).pushReplacementNamed(AppRoutes.curriculum);

  void _goToGrade(BuildContext context) =>
      Navigator.of(context).pushReplacementNamed(AppRoutes.curriculumGradeDetail);

  void _editSubject(BuildContext context) =>
      Navigator.of(context).pushReplacementNamed(AppRoutes.curriculumAddSubject);

  void _addChapter(BuildContext context) {
    context.read<CurriculumController>().clearSelectedCurriculumChapter();
    Navigator.of(context).pushReplacementNamed(AppRoutes.curriculumAddChapter);
  }

  void _openChapter(BuildContext context, AdminChapterModel chapter) {
    context.read<CurriculumController>().selectCurriculumChapter(chapter.id);
    Navigator.of(context).pushReplacementNamed(AppRoutes.curriculumChapterDetail);
  }

  void _editChapter(BuildContext context, AdminChapterModel chapter) {
    context.read<CurriculumController>().selectCurriculumChapter(chapter.id);
    Navigator.of(context).pushReplacementNamed(AppRoutes.curriculumAddChapter);
  }

  Future<void> _deleteChapter(BuildContext context, AdminChapterModel chapter) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete chapter?',
      message: 'Delete "${chapter.name}"? This action cannot be undone.',
    );
    if (!confirmed || !context.mounted) return;
    final controller = context.read<CurriculumController>();
    final ok = await controller.deleteChapter(chapter.id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Chapter deleted.' : controller.curriculumError ?? 'Unable to delete chapter.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CurriculumController>();
    final grade = controller.selectedCurriculumGrade;
    final subject = controller.selectedCurriculumSubject;
    final chapters = subject.chapters ?? const [];

    return AdminShell(
      navItems: NavPresets.admin,
      activeIndex: 1,
      user: NavPresets.gtecAdmin,
      titleWidget: CurriculumBreadcrumb(
        segments: [
          CrumbSegment('Curriculum', onTap: () => _goToCurriculum(context)),
          CrumbSegment(grade.name, onTap: () => _goToGrade(context)),
          CrumbSegment(subject.name),
        ],
      ),
      actions: [
        OutlineButtonX(label: 'Back', iconPaths: AppIcons.chevronLeft, onTap: () => _goToGrade(context)),
        PrimaryButton(label: 'Edit subject', iconPaths: AppIcons.edit, onTap: () => _editSubject(context)),
      ],
      body: PageBody(
        topPadding: 26,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CurriculumHeader(
              title: subject.name,
              subtitle: subject.code == null ? grade.name : '${grade.name} · ${subject.code}',
            ),
            const SizedBox(height: 24),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (subject.iconUrl != null) ...[
                        CoverThumbnail(imageUrl: subject.iconUrl!, size: 40),
                        const SizedBox(width: 12),
                      ],
                      Text('Subject details',
                          style: AppTextStyles.jakarta(size: 14, weight: FontWeight.w800, color: AppColors.ink)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 32,
                    runSpacing: 16,
                    children: [
                      _InfoStat(label: 'Code', value: subject.code ?? '—'),
                      _InfoStat(label: 'Display order', value: '${subject.order}'),
                      _InfoStat(label: 'Chapters', value: '${chapters.length}'),
                    ],
                  ),
                  if (subject.description != null && subject.description!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(height: 1, color: AppColors.hairline),
                    const SizedBox(height: 16),
                    Text(subject.description!,
                        style: AppTextStyles.jakarta(
                            size: 13, weight: FontWeight.w600, color: AppColors.muted, height: 1.5)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Text('Chapters', style: AppTextStyles.eyebrow),
                const Spacer(),
                PrimaryButton(
                  label: 'Add Chapter',
                  iconPaths: AppIcons.plus,
                  height: 38,
                  fontSize: 12.5,
                  onTap: () => _addChapter(context),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (chapters.isEmpty)
              const InfoBanner(text: 'No chapters yet. Add a chapter to start building this subject.')
            else ...[
              ChapterList(
                chapters: chapters,
                onChapterTap: (c) => _openChapter(context, c),
                onEditChapter: (c) => _editChapter(context, c),
                onDeleteChapter: (c) => _deleteChapter(context, c),
              ),
              const SizedBox(height: 22),
              const InfoBanner(text: 'Click a chapter to manage its lessons.'),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoStat extends StatelessWidget {
  const _InfoStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.jakarta(size: 11.5, weight: FontWeight.w700, color: AppColors.grey)),
        const SizedBox(height: 4),
        Text(value, style: AppTextStyles.jakarta(size: 13.5, weight: FontWeight.w700, color: AppColors.ink)),
      ],
    );
  }
}
