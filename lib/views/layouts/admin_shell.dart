import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../models/models.dart';
import '../../routes/app_routes.dart';
import '../widgets/app_sidebar.dart';
import '../widgets/app_top_bar.dart';

/// Screen scaffold: dark sidebar + white top bar + `#F7F9FC` content.
/// On desktop the sidebar is fixed at 240px (as designed); below the
/// tablet breakpoint it collapses into a drawer without altering styling.
class AdminShell extends StatelessWidget {
  const AdminShell({
    super.key,
    required this.navItems,
    required this.activeIndex,
    required this.user,
    required this.body,
    this.brandSuffix = 'admin',
    this.title,
    this.titleWidget,
    this.actions = const [],
    this.scrollable = true,
  });

  final List<NavItemModel> navItems;
  final int activeIndex;
  final SidebarUser user;
  final String brandSuffix;
  final String? title;
  final Widget? titleWidget;
  final List<Widget> actions;

  /// true → content scrolls (most screens); false → content manages its own
  /// layout/scrolling (split-pane screens like Curriculum & Assessments).
  final bool scrollable;
  final Widget body;

  void _navigate(BuildContext context, NavItemModel item) {
    if (item.route == null) return;
    if (ModalRoute.of(context)?.settings.name == item.route) return;
    Navigator.of(context).pushReplacementNamed(item.route!);
  }

  void _logout(BuildContext context) {
    context.read<AuthController>().logout();
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.login,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool desktop = Responsive.isDesktop(context);

    final sidebar = AppSidebar(
      brandSuffix: brandSuffix,
      items: navItems,
      activeIndex: activeIndex,
      user: user,
      onItemTap: (item) => _navigate(context, item),
      onLogout: () => _logout(context),
    );

    final content = Column(
      children: [
        Builder(
          builder: (context) => AppTopBar(
            title: title,
            titleWidget: titleWidget,
            actions: actions,
            showMenuButton: !desktop,
          ),
        ),
        Expanded(
          child: scrollable
              ? ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context)
                      .copyWith(scrollbars: false),
                  child: SingleChildScrollView(child: body),
                )
              : body,
        ),
      ],
    );

    return Scaffold(
      backgroundColor: AppColors.pageBg,
      drawer: desktop ? null : Drawer(width: 240, child: sidebar),
      body: desktop
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [sidebar, Expanded(child: content)],
            )
          : content,
    );
  }
}
