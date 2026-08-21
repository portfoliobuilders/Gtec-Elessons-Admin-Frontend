import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/curriculum_controller.dart';
import '../../controllers/students_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_buttons.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_inputs.dart';
import '../../core/widgets/confirm_dialog.dart';
import '../../core/widgets/hatch_avatar.dart';
import '../../core/widgets/status_badge.dart';
import '../../models/admin/admin_models.dart';
import '../layouts/admin_shell.dart';
import '../widgets/curriculum/curriculum_form_fields.dart';
import '../widgets/curriculum/form_section.dart';
import '../widgets/nav_presets.dart';
import '../widgets/shared_widgets.dart';
import 'students_screen.dart' show studentMonogram;

/// STUDENT | TEACHER | ADMIN only — matches `SetStudentRoleRequest` exactly;
/// SUPER_ADMIN is never offered (backend-enforced, promotion is a manual DB
/// operation only).
const List<String> _assignableRoles = ['STUDENT', 'TEACHER', 'ADMIN'];

String _roleLabel(String role) => switch (role) {
      'STUDENT' => 'Student',
      'TEACHER' => 'Teacher',
      'ADMIN' => 'Admin',
      'SUPER_ADMIN' => 'Super Admin',
      _ => role,
    };

BadgeStatus _roleBadge(String role) => switch (role) {
      'SUPER_ADMIN' => BadgeStatus.superAdmin,
      'ADMIN' => BadgeStatus.admin,
      'TEACHER' => BadgeStatus.teacher,
      _ => BadgeStatus.inactive,
    };

const List<String> _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

/// `d MMM yyyy` without pulling in `package:intl` — no new packages.
String _formatJoinedDate(DateTime date) => '${date.day} ${_months[date.month - 1]} ${date.year}';

/// Student Detail — Phase 6A (profile/contact/role/status) plus Phase 6B
/// (Enrollments: real existing enrollments + granting a subject). No
/// orders/payments/assessment history yet — those stay a placeholder.
class StudentDetailScreen extends StatefulWidget {
  const StudentDetailScreen({super.key});

  @override
  State<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<StudentDetailScreen> {
  bool _updatingStatus = false;
  bool _updatingRole = false;
  bool _deleting = false;

  AdminGradeModel? _selectedGrade;
  AdminSubjectModel? _selectedSubject;
  bool _granting = false;

  @override
  void initState() {
    super.initState();
    // Reuse the existing Curriculum tree rather than a second fetch/second
    // API client — only load it if nothing has loaded it already.
    final curriculum = context.read<CurriculumController>();
    if (curriculum.curriculumStatus == CurriculumLoadStatus.initial) {
      curriculum.loadCurriculum();
    }
  }

  void _showMessage(String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

  Future<void> _toggleStatus(StudentDetailModel student) async {
    final newStatus = student.status == 'ACTIVE' ? 'SUSPENDED' : 'ACTIVE';
    setState(() => _updatingStatus = true);
    final controller = context.read<StudentsController>();
    final ok = await controller.updateStudentStatus(student.id, newStatus);
    if (!mounted) return;
    setState(() => _updatingStatus = false);
    _showMessage(ok ? 'Status updated.' : controller.detailError ?? 'Unable to update status.');
  }

  Future<void> _changeRole(StudentDetailModel student, String newRole) async {
    if (newRole == student.role) return;
    final confirmed = await showConfirmDialog(
      context,
      title: 'Change role?',
      message: 'Change ${student.name ?? 'this user'}\'s role to ${_roleLabel(newRole)}?',
      confirmLabel: 'Change role',
    );
    if (!confirmed || !mounted) return;

    setState(() => _updatingRole = true);
    final controller = context.read<StudentsController>();
    final ok = await controller.updateStudentRole(student.id, newRole);
    if (!mounted) return;
    setState(() => _updatingRole = false);
    _showMessage(ok ? 'Role updated.' : controller.detailError ?? 'Unable to update role.');
  }

  Future<void> _deleteStudent(StudentDetailModel student) async {
    if (_deleting) return;
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete this student?',
      message: 'This action permanently deletes the user if the account has no protected orders, '
          'enrollments, teaching assignments, or other related records.',
      confirmLabel: 'Delete',
    );
    if (!confirmed || !mounted) return;

    setState(() => _deleting = true);
    final controller = context.read<StudentsController>();
    final ok = await controller.deleteStudent(student.id);
    if (!mounted) return;
    setState(() => _deleting = false);

    if (ok) {
      // The success snackbar is shown by the Students list after this
      // screen's Scaffold is gone — showing it here would race the pop.
      Navigator.of(context).pop(true);
    } else {
      _showMessage(controller.deleteError ?? 'Unable to delete this student.');
    }
  }

  Future<void> _grantEnrollment(StudentDetailModel student) async {
    final subject = _selectedSubject;
    if (subject == null || _granting) return;

    setState(() => _granting = true);
    final controller = context.read<StudentsController>();
    final ok = await controller.grantSubjectEnrollment(student.id, subject.id);
    if (!mounted) return;
    setState(() {
      _granting = false;
      if (ok) {
        _selectedGrade = null;
        _selectedSubject = null;
      }
    });
    _showMessage(ok ? 'Enrolled in "${subject.name}".' : controller.enrollmentError ?? 'Unable to grant enrollment.');
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<StudentsController>();
    final student = controller.selectedStudent;
    // Frontend-only UX safeguard — the backend independently rejects (403)
    // deleting your own account regardless of this check.
    final isSelf = student != null && student.id == context.read<AuthController>().user?.id;

    return AdminShell(
      navItems: NavPresets.admin,
      activeIndex: 4,
      user: NavPresets.gtecAdmin,
      title: 'Student Details',
      actions: [
        OutlineButtonX(label: 'Back', iconPaths: AppIcons.chevronLeft, onTap: () => Navigator.of(context).pop()),
        if (student != null && !isSelf) ...[
          const SizedBox(width: 10),
          OutlineButtonX(
            label: _deleting ? 'Deleting…' : 'Delete Student',
            iconPaths: AppIcons.trash,
            color: AppColors.red,
            onTap: _deleting ? () {} : () => _deleteStudent(student),
          ),
        ],
      ],
      body: PageBody(
        topPadding: 26,
        child: _buildBody(controller, student),
      ),
    );
  }

  Widget _buildBody(StudentsController controller, StudentDetailModel? student) {
    if (controller.isDetailLoading || (student == null && controller.detailStatus != StudentsLoadStatus.error)) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 60),
        child: Center(
          child: SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 2.6, color: AppColors.navy)),
        ),
      );
    }

    if (controller.detailStatus == StudentsLoadStatus.error || student == null) {
      return AppCard(
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Unable to load this student.',
                  style: AppTextStyles.jakarta(size: 14.5, weight: FontWeight.w800, color: AppColors.ink)),
              const SizedBox(height: 6),
              Text(controller.detailError ?? 'Please try again.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.jakarta(size: 12.5, weight: FontWeight.w600, color: AppColors.grey)),
            ],
          ),
        ),
      );
    }

    final joined = _formatJoinedDate(student.createdAt);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCard(
          child: Row(
            children: [
              HatchAvatar(label: studentMonogram(student.name, student.email), size: 52, radius: 14, fontSize: 15),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(student.name ?? 'Unnamed',
                        style: AppTextStyles.jakarta(size: 17, weight: FontWeight.w800, color: AppColors.ink)),
                    const SizedBox(height: 4),
                    Text('Joined $joined',
                        style: AppTextStyles.jakarta(size: 12.5, weight: FontWeight.w600, color: AppColors.grey)),
                  ],
                ),
              ),
              StatusBadge.of(_roleBadge(student.role)),
              const SizedBox(width: 8),
              StatusBadge.of(student.status == 'ACTIVE' ? BadgeStatus.active : BadgeStatus.inactive),
            ],
          ),
        ),
        const SizedBox(height: 20),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Contact information',
                  style: AppTextStyles.jakarta(size: 14, weight: FontWeight.w800, color: AppColors.ink)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 32,
                runSpacing: 16,
                children: [
                  _InfoStat(label: 'Email', value: student.email ?? 'Not set'),
                  _InfoStat(label: 'Phone', value: student.phone ?? 'Not set'),
                  _InfoStat(label: 'Board', value: student.board ?? 'Not set'),
                  _InfoStat(label: 'Grade', value: student.gradeName ?? 'Not set'),
                  _InfoStat(label: 'Region', value: student.region ?? 'Not set'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Account status',
                          style: AppTextStyles.jakarta(size: 13.5, weight: FontWeight.w800, color: AppColors.ink)),
                      const SizedBox(height: 3),
                      Text('Suspended accounts cannot sign in.',
                          style: AppTextStyles.jakarta(size: 12, weight: FontWeight.w600, color: AppColors.grey)),
                    ],
                  ),
                  Row(
                    children: [
                      if (_updatingStatus) ...[
                        const SizedBox(
                            width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.navy)),
                        const SizedBox(width: 10),
                      ],
                      AppToggle(
                        value: student.status == 'ACTIVE',
                        onChanged: _updatingStatus ? null : (_) => _toggleStatus(student),
                      ),
                      const SizedBox(width: 10),
                      Text(student.status == 'ACTIVE' ? 'Active' : 'Suspended',
                          style: AppTextStyles.jakarta(
                              size: 13,
                              weight: FontWeight.w700,
                              color: student.status == 'ACTIVE' ? AppColors.green : AppColors.grey)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(height: 1, color: AppColors.hairline),
              const SizedBox(height: 20),
              Text('Role', style: AppTextStyles.jakarta(size: 13.5, weight: FontWeight.w800, color: AppColors.ink)),
              const SizedBox(height: 3),
              Text('Changes take effect immediately.',
                  style: AppTextStyles.jakarta(size: 12, weight: FontWeight.w600, color: AppColors.grey)),
              const SizedBox(height: 14),
              SizedBox(
                width: 260,
                child: LabeledDropdownField<String>(
                  'Assign role',
                  value: _assignableRoles.contains(student.role) ? student.role : null,
                  items: _assignableRoles,
                  itemLabel: _roleLabel,
                  hint: _roleLabel(student.role),
                  onChanged: _updatingRole ? (_) {} : (v) { if (v != null) _changeRole(student, v); },
                ),
              ),
              if (!_assignableRoles.contains(student.role)) ...[
                const SizedBox(height: 10),
                InfoBanner(text: '${_roleLabel(student.role)} accounts can\'t be changed through this screen.'),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),
        _EnrollmentsCard(
          student: student,
          selectedGrade: _selectedGrade,
          selectedSubject: _selectedSubject,
          granting: _granting,
          onGradeChanged: (g) => setState(() {
            _selectedGrade = g;
            _selectedSubject = null;
          }),
          onSubjectChanged: (s) => setState(() => _selectedSubject = s),
          onGrant: () => _grantEnrollment(student),
        ),
        const SizedBox(height: 20),
        const InfoBanner(text: 'Orders and assessment history will be added in a later phase.'),
        const SizedBox(height: 24),
      ],
    );
  }
}

/// Real existing enrollments (read-only — the backend only exposes a grant
/// endpoint, no revoke/edit) plus the Grant Subject Enrollment form. Grades
/// and subjects come from the already-loaded `CurriculumController` tree —
/// no mock data, no second curriculum fetch.
class _EnrollmentsCard extends StatelessWidget {
  const _EnrollmentsCard({
    required this.student,
    required this.selectedGrade,
    required this.selectedSubject,
    required this.granting,
    required this.onGradeChanged,
    required this.onSubjectChanged,
    required this.onGrant,
  });

  final StudentDetailModel student;
  final AdminGradeModel? selectedGrade;
  final AdminSubjectModel? selectedSubject;
  final bool granting;
  final ValueChanged<AdminGradeModel?> onGradeChanged;
  final ValueChanged<AdminSubjectModel?> onSubjectChanged;
  final VoidCallback onGrant;

  @override
  Widget build(BuildContext context) {
    final curriculum = context.watch<CurriculumController>();
    final grades = curriculum.curriculumGrades;
    final subjects = selectedGrade?.subjects ?? const <AdminSubjectModel>[];

    final enrolledSubjectIds = {
      for (final e in student.enrollments)
        if (e.scopeType == 'SUBJECT' && e.status == 'ACTIVE' && e.subjectId != null) e.subjectId!,
    };

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Enrollments', style: AppTextStyles.jakarta(size: 14, weight: FontWeight.w800, color: AppColors.ink)),
          const SizedBox(height: 16),
          if (student.enrollments.isEmpty)
            InfoBanner(text: '${student.name ?? 'This student'} has no enrollments yet.')
          else
            Column(
              children: [
                for (int i = 0; i < student.enrollments.length; i++)
                  Padding(
                    padding: EdgeInsets.only(bottom: i == student.enrollments.length - 1 ? 0 : 10),
                    child: _EnrollmentRow(enrollment: student.enrollments[i]),
                  ),
              ],
            ),
          const SizedBox(height: 22),
          Container(height: 1, color: AppColors.hairline),
          const SizedBox(height: 22),
          FormSection(
            icon: AppIcons.graduationCap,
            title: 'Grant Subject Enrollment',
            subtitle: 'Select a grade, then a subject, to grant this student access to it.',
            children: [
              if (curriculum.isCurriculumLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.2, color: AppColors.navy),
                  ),
                )
              else ...[
                FlexRow(
                  items: [
                    (
                      1,
                      LabeledDropdownField<AdminGradeModel>(
                        'Grade',
                        value: selectedGrade,
                        items: grades,
                        itemLabel: (g) => g.name,
                        hint: 'Select a grade',
                        required: true,
                        onChanged: onGradeChanged,
                      ),
                    ),
                    (
                      1,
                      LabeledDropdownField<AdminSubjectModel>(
                        'Subject',
                        value: selectedSubject,
                        items: subjects,
                        itemLabel: (s) =>
                            enrolledSubjectIds.contains(s.id) ? '${s.name} (already enrolled)' : s.name,
                        hint: selectedGrade == null ? 'Select a grade first' : 'Select a subject',
                        required: true,
                        onChanged: onSubjectChanged,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: PrimaryButton(
                    label: granting ? 'Granting…' : 'Grant Enrollment',
                    iconPaths: AppIcons.check,
                    onTap: (granting || selectedSubject == null) ? () {} : onGrant,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _EnrollmentRow extends StatelessWidget {
  const _EnrollmentRow({required this.enrollment});

  final StudentEnrollmentRefModel enrollment;

  BadgeStatus get _status => switch (enrollment.status) {
        'ACTIVE' => BadgeStatus.active,
        'EXPIRED' => BadgeStatus.inactive,
        _ => BadgeStatus.failed,
      };

  @override
  Widget build(BuildContext context) {
    final starts = _formatJoinedDate(enrollment.startsAt);
    final expires = enrollment.expiresAt == null ? 'No expiry' : 'Expires ${_formatJoinedDate(enrollment.expiresAt!)}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: AppColors.searchBg, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(enrollment.productTitle ?? enrollment.scopeType,
                    style: AppTextStyles.jakarta(size: 13.5, weight: FontWeight.w700, color: AppColors.ink)),
                const SizedBox(height: 3),
                Text('Since $starts · $expires',
                    style: AppTextStyles.jakarta(size: 11.5, weight: FontWeight.w600, color: AppColors.grey)),
              ],
            ),
          ),
          StatusBadge.of(_status),
        ],
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
