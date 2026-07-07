import '../../core/constants/app_icons.dart';
import '../../models/models.dart';
import '../../routes/app_routes.dart';

/// Sidebar navigation sets exactly as they appear per screen in the design.
class NavPresets {
  NavPresets._();

  // Content-admin persona (Dashboard / Curriculum / Pricing / Assessments).
  static const List<NavItemModel> contentAdmin = [
    NavItemModel(
        label: 'Dashboard',
        iconPaths: AppIcons.dashboard,
        route: AppRoutes.dashboard),
    NavItemModel(
        label: 'Curriculum',
        iconPaths: AppIcons.curriculum,
        route: AppRoutes.curriculum),
    NavItemModel(
        label: 'Pricing', iconPaths: AppIcons.pricing, route: AppRoutes.pricing),
    NavItemModel(
        label: 'Assessments',
        iconPaths: AppIcons.assessments,
        route: AppRoutes.assessments),
    NavItemModel(
        label: 'Students',
        iconPaths: AppIcons.students,
        route: AppRoutes.students),
  ];

  // Super-admin persona (Team & Roles).
  static const List<NavItemModel> superAdmin = [
    NavItemModel(
        label: 'Dashboard',
        iconPaths: AppIcons.dashboard,
        route: AppRoutes.dashboard),
    NavItemModel(
        label: 'Curriculum',
        iconPaths: AppIcons.curriculum,
        route: AppRoutes.curriculum),
    NavItemModel(
        label: 'Pricing', iconPaths: AppIcons.pricing, route: AppRoutes.pricing),
    NavItemModel(
        label: 'Assessments',
        iconPaths: AppIcons.assessments,
        route: AppRoutes.assessments),
    NavItemModel(
        label: 'Team & Roles',
        iconPaths: AppIcons.students,
        route: AppRoutes.team),
  ];

  // Teacher persona.
  static const List<NavItemModel> teacher = [
    NavItemModel(
        label: 'Dashboard',
        iconPaths: AppIcons.dashboard,
        route: AppRoutes.teacher),
    NavItemModel(label: 'My classes', iconPaths: AppIcons.book),
    NavItemModel(label: 'Upload lesson', iconPaths: AppIcons.upload),
    NavItemModel(label: 'Assignments', iconPaths: AppIcons.fileCorner),
    NavItemModel(label: 'Doubts', iconPaths: AppIcons.message),
  ];

  // Ops-admin persona (Students).
  static const List<NavItemModel> opsAdminStudents = [
    NavItemModel(
        label: 'Dashboard',
        iconPaths: AppIcons.dashboard,
        route: AppRoutes.dashboard),
    NavItemModel(
        label: 'Students',
        iconPaths: AppIcons.students,
        route: AppRoutes.students),
    NavItemModel(
        label: 'Live classes',
        iconPaths: AppIcons.assessments,
        route: AppRoutes.scheduler),
    NavItemModel(
        label: 'Notifications',
        iconPaths: AppIcons.bellPlain,
        route: AppRoutes.notifications),
    NavItemModel(
        label: 'Team & Roles',
        iconPaths: AppIcons.userGroup,
        route: AppRoutes.team),
  ];

  // Ops-admin persona (Scheduler / Notifications).
  static const List<NavItemModel> opsAdmin = [
    NavItemModel(
        label: 'Dashboard',
        iconPaths: AppIcons.dashboard,
        route: AppRoutes.dashboard),
    NavItemModel(
        label: 'Students',
        iconPaths: AppIcons.userGroup,
        route: AppRoutes.students),
    NavItemModel(
        label: 'Live classes',
        iconPaths: AppIcons.assessments,
        route: AppRoutes.scheduler),
    NavItemModel(
        label: 'Notifications',
        iconPaths: AppIcons.bellPlain,
        route: AppRoutes.notifications),
  ];

  // Payments persona (Super Admin).
  static const List<NavItemModel> payments = [
    NavItemModel(
        label: 'Dashboard',
        iconPaths: AppIcons.dashboard,
        route: AppRoutes.dashboard),
    NavItemModel(
        label: 'Students',
        iconPaths: AppIcons.userGroup,
        route: AppRoutes.students),
    NavItemModel(
        label: 'Payments & Leads',
        iconPaths: AppIcons.pricing,
        route: AppRoutes.payments),
    NavItemModel(
        label: 'Live classes',
        iconPaths: AppIcons.assessments,
        route: AppRoutes.scheduler),
    NavItemModel(
        label: 'Notifications',
        iconPaths: AppIcons.bellPlain,
        route: AppRoutes.notifications),
  ];

  // Growth persona (Super Admin).
  static const List<NavItemModel> growth = [
    NavItemModel(
        label: 'Growth',
        iconPaths: AppIcons.trendingUp,
        route: AppRoutes.growth),
    NavItemModel(
        label: 'Payments & Leads',
        iconPaths: AppIcons.pricing,
        route: AppRoutes.payments),
    NavItemModel(
        label: 'Students',
        iconPaths: AppIcons.userGroup,
        route: AppRoutes.students),
    NavItemModel(
        label: 'Curriculum',
        iconPaths: AppIcons.curriculum,
        route: AppRoutes.curriculum),
  ];

  // ── Sidebar users per persona ─────────────────────────────────────────────
  static const SidebarUser riyaContentAdmin = SidebarUser(
      monogram: 'RM', name: 'Riya Mathew', role: 'Content Admin');
  static const SidebarUser riyaSuperAdmin = SidebarUser(
      monogram: 'RM',
      name: 'Riya Mathew',
      role: 'Super Admin',
      roleColorKey: SidebarRoleColor.superAdmin);
  static const SidebarUser karthikAdmin = SidebarUser(
      monogram: 'KP',
      name: 'Karthik P.',
      role: 'Admin',
      roleColorKey: SidebarRoleColor.admin);
  static const SidebarUser menonTeacher = SidebarUser(
      monogram: 'RM',
      name: 'R. Menon',
      role: 'Teacher · Maths',
      roleColorKey: SidebarRoleColor.teacher);
}
