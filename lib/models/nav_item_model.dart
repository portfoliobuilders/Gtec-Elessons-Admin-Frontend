/// Sidebar navigation entry. [route] is null for items with no screen yet.
class NavItemModel {
  const NavItemModel({
    required this.label,
    required this.iconPaths,
    this.route,
  });

  final String label;
  final String iconPaths;
  final String? route;
}

/// The signed-in identity shown at the bottom of the sidebar.
class SidebarUser {
  const SidebarUser({
    required this.monogram,
    required this.name,
    required this.role,
    this.roleColorKey = SidebarRoleColor.muted,
  });

  final String monogram;
  final String name;
  final String role;
  final SidebarRoleColor roleColorKey;
}

enum SidebarRoleColor { muted, superAdmin, admin, teacher }
