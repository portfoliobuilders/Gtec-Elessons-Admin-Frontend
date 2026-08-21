import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/assessment_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/app_buttons.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_inputs.dart';
import '../../core/widgets/grid_table.dart';
import '../../models/models.dart';
import '../layouts/admin_shell.dart';
import '../widgets/nav_presets.dart';
import '../widgets/shared_widgets.dart';

/// 04 · Assessment Engine — build mock test.
class AssessmentScreen extends StatelessWidget {
  const AssessmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AssessmentController>();
    final bool desktop = Responsive.isDesktop(context);

    final builder = _QuestionBuilder(controller: controller);
    final rules = _RulesPanel(controller: controller);

    return AdminShell(
      navItems: NavPresets.admin,
      activeIndex: 3,
      user: NavPresets.gtecAdmin,
      scrollable: !desktop,
      title: 'New Mock Test',
      actions: const [
        OutlineButtonX(label: 'Save draft'),
        PrimaryButton(
            label: 'Publish test', iconPaths: AppIcons.send, iconStroke: 1.9),
      ],
      body: desktop
          ? Padding(
              padding: const EdgeInsets.fromLTRB(30, 26, 30, 26),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ScrollConfiguration(
                      behavior: ScrollConfiguration.of(context)
                          .copyWith(scrollbars: false),
                      child: SingleChildScrollView(child: builder),
                    ),
                  ),
                  const SizedBox(width: 24),
                  SizedBox(
                    width: 330,
                    child: ScrollConfiguration(
                      behavior: ScrollConfiguration.of(context)
                          .copyWith(scrollbars: false),
                      child: SingleChildScrollView(child: rules),
                    ),
                  ),
                ],
              ),
            )
          : PageBody(
              topPadding: 26,
              child:
                  Column(children: [builder, const SizedBox(height: 24), rules]),
            ),
    );
  }
}

class _QuestionBuilder extends StatelessWidget {
  const _QuestionBuilder({required this.controller});

  final AssessmentController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Test details card.
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('TEST DETAILS', style: AppTextStyles.eyebrow),
              const SizedBox(height: 16),
              const FieldLabel('Test name'),
              InputBox(value: controller.testName, focused: true),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const FieldLabel('Subject / Module'),
                        DropdownBox(value: controller.subjectModule),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const FieldLabel('Total questions'),
                        InputBox(value: controller.totalQuestions),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Question cards.
        for (int q = 0; q < controller.questions.length; q++) ...[
          _QuestionCard(index: q + 1, question: controller.questions[q]),
          const SizedBox(height: 14),
        ],

        // Add question.
        DashedBorder(
          radius: 14,
          background: AppColors.white,
          child: SizedBox(
            height: 52,
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const AppIcon(AppIcons.plus,
                    size: 17, color: AppColors.navy, strokeWidth: 2.2),
                const SizedBox(width: 9),
                Text('Add question',
                    style: AppTextStyles.jakarta(
                        size: 13.5,
                        weight: FontWeight.w700,
                        color: AppColors.navy)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({required this.index, required this.question});

  final int index;
  final QuestionModel question;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.navyChipBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('QUESTION $index',
                    style: AppTextStyles.jakarta(
                        size: 12,
                        weight: FontWeight.w800,
                        color: AppColors.navy)),
              ),
              const Row(
                children: [
                  AppIcon(AppIcons.edit,
                      size: 17, color: AppColors.grey, strokeWidth: 1.8),
                  SizedBox(width: 12),
                  AppIcon(AppIcons.trash,
                      size: 17, color: AppColors.grey, strokeWidth: 1.8),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          InputBox(value: question.prompt),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, c) {
              final bool twoCols = c.maxWidth > 480;
              final double w =
                  twoCols ? (c.maxWidth - 12) / 2 : c.maxWidth;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (int i = 0; i < question.options.length; i++)
                    SizedBox(
                      width: w,
                      child: _OptionRow(
                        text: question.options[i],
                        correct: i == question.correctIndex,
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({required this.text, required this.correct});

  final String text;
  final bool correct;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: correct ? AppColors.greenSelBg : Colors.transparent,
        border: Border.all(
          color: correct ? AppColors.green : AppColors.border,
          width: correct ? 2 : 1.5,
        ),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        children: [
          if (correct)
            const RadioDot(selected: true, fill: AppColors.green)
          else
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border:
                    Border.all(color: AppColors.radioBorder, width: 2),
              ),
            ),
          const SizedBox(width: 11),
          Text(
            text,
            style: AppTextStyles.jakarta(
              size: 13.5,
              weight: correct ? FontWeight.w700 : FontWeight.w600,
              color: correct ? AppColors.ink : AppColors.body,
            ),
          ),
        ],
      ),
    );
  }
}

class _RulesPanel extends StatelessWidget {
  const _RulesPanel({required this.controller});

  final AssessmentController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Rules & scoring',
                  style: AppTextStyles.jakarta(
                      size: 13.5,
                      weight: FontWeight.w800,
                      color: AppColors.ink)),
              const SizedBox(height: 18),
              const FieldLabel('Duration timer'),
              InputBox(
                leading: const AppIcon(AppIcons.clock,
                    size: 17, color: AppColors.navy, strokeWidth: 1.8),
                child: Text(controller.duration,
                    style: AppTextStyles.jakarta(
                        size: 14,
                        weight: FontWeight.w700,
                        color: AppColors.ink)),
              ),
              const SizedBox(height: 18),
              _ToggleRow(
                title: 'Negative marking',
                subtitle: 'Penalise wrong answers',
                value: controller.negativeMarking,
                onChanged: controller.setNegativeMarking,
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _MarkBox(
                        label: 'Correct',
                        value: controller.correctMarks,
                        color: AppColors.green),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MarkBox(
                        label: 'Wrong',
                        value: controller.wrongMarks,
                        color: AppColors.red),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _ToggleRow(
                title: 'Shuffle questions',
                subtitle: 'Randomise per student',
                value: controller.shuffleQuestions,
                onChanged: controller.setShuffle,
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.infoBg,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const AppIcon(AppIcons.info,
                      size: 17, color: AppColors.navy, strokeWidth: 1.8),
                  const SizedBox(width: 9),
                  Text('Test summary',
                      style: AppTextStyles.jakarta(
                          size: 13,
                          weight: FontWeight.w800,
                          color: AppColors.navy)),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                controller.summary,
                style: AppTextStyles.jakarta(
                    size: 12.5,
                    weight: FontWeight.w500,
                    color: AppColors.body,
                    height: 1.6),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: AppTextStyles.jakarta(
                      size: 13.5,
                      weight: FontWeight.w700,
                      color: AppColors.ink)),
              Text(subtitle,
                  style: AppTextStyles.jakarta(
                      size: 11.5,
                      weight: FontWeight.w500,
                      color: AppColors.grey)),
            ],
          ),
        ),
        AppToggle(value: value, onChanged: onChanged),
      ],
    );
  }
}

class _MarkBox extends StatelessWidget {
  const _MarkBox(
      {required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(label),
        Container(
          height: 46,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border, width: 1.5),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Center(
            child: Text(value,
                style: AppTextStyles.jakarta(
                    size: 15, weight: FontWeight.w800, color: color)),
          ),
        ),
      ],
    );
  }
}
