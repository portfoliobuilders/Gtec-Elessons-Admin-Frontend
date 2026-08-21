import '../../core/constants/app_icons.dart';
import '../../models/models.dart';
import '../../routes/app_routes.dart';

/// Sidebar navigation sets exactly as they appear per screen in the design.
class NavPresets {
  NavPresets._();

  // Admin persona — every admin-facing screen shares this exact list so the
  // sidebar never gains/loses items when navigating; only `activeIndex`
  // (passed per screen) changes which entry is highlighted.
  //
  // Assessments / Live classes / Notifications are commented out rather than
  // deleted — their screens/controllers/routes still exist, but none of them
  // are wired to a real backend service yet (AssessmentController,
  // SchedulerController, NotificationsController are all still hardcoded
  // mock data), so they're hidden from the sidebar until that's true.
  // Payments & Leads and Orders used to be two separate nav entries for the
  // same underlying data (order/payment transactions) — merged into one:
  // "Payments & Leads" now shows the real `GET /admin/orders` data (via
  // OrdersController) in the Payments screen's layout; the old Orders nav
  // entry is redundant and removed. `orders_screen.dart`/`AppRoutes.orders`
  // still exist (order-detail navigation reuses them) but are no longer
  // reachable from the sidebar.
  static const List<NavItemModel> admin = [
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
    // NavItemModel(
    //     label: 'Assessments',
    //     iconPaths: AppIcons.assessments,
    //     route: AppRoutes.assessments),
    NavItemModel(
        label: 'Team & Roles',
        iconPaths: AppIcons.userGroup,
        route: AppRoutes.team),
    NavItemModel(
        label: 'Students',
        iconPaths: AppIcons.students,
        route: AppRoutes.students),
    // NavItemModel(
    //     label: 'Live classes',
    //     iconPaths: AppIcons.assessments,
    //     route: AppRoutes.scheduler),
    // NavItemModel(
    //     label: 'Notifications',
    //     iconPaths: AppIcons.bellPlain,
    //     route: AppRoutes.notifications),
    NavItemModel(
        label: 'Payments & Leads',
        iconPaths: AppIcons.pricing,
        route: AppRoutes.payments),
    // NavItemModel(
    //     label: 'Orders',
    //     iconPaths: AppIcons.fileCorner,
    //     route: AppRoutes.orders),
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

  // ── Sidebar users per persona ─────────────────────────────────────────────
  // A single fixed identity for every admin screen — the design used to vary
  // this per screen (Riya Mathew as Content Admin here, Super Admin there,
  // Karthik P. as Admin elsewhere), which read as if the signed-in user
  // changed depending on which page you were on. Every admin screen now
  // passes this one constant instead.
  static const SidebarUser gtecAdmin = SidebarUser(
      monogram: 'GA',
      name: 'GTEC Admin',
      role: 'Administrator',
      roleColorKey: SidebarRoleColor.admin);
  static const SidebarUser menonTeacher = SidebarUser(
      monogram: 'RM',
      name: 'R. Menon',
      role: 'Teacher · Maths',
      roleColorKey: SidebarRoleColor.teacher);
}
