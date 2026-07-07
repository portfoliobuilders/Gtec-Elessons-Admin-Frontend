import 'package:flutter/material.dart';

import '../views/screens/assessment_screen.dart';
import '../views/screens/curriculum_screen.dart';
import '../views/screens/dashboard_screen.dart';
import '../views/screens/growth_screen.dart';
import '../views/screens/notifications_screen.dart';
import '../views/screens/payments_screen.dart';
import '../views/screens/pricing_screen.dart';
import '../views/screens/scheduler_screen.dart';
import '../views/screens/students_screen.dart';
import '../views/screens/teacher_screen.dart';
import '../views/screens/team_screen.dart';
import 'app_routes.dart';

class AppRouter {
  AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final Widget screen = switch (settings.name) {
      AppRoutes.dashboard => const DashboardScreen(),
      AppRoutes.curriculum => const CurriculumScreen(),
      AppRoutes.pricing => const PricingScreen(),
      AppRoutes.assessments => const AssessmentScreen(),
      AppRoutes.team => const TeamScreen(),
      AppRoutes.teacher => const TeacherScreen(),
      AppRoutes.students => const StudentsScreen(),
      AppRoutes.scheduler => const SchedulerScreen(),
      AppRoutes.notifications => const NotificationsScreen(),
      AppRoutes.payments => const PaymentsScreen(),
      AppRoutes.growth => const GrowthScreen(),
      _ => const DashboardScreen(),
    };

    // Light cross-fade between admin sections (sidebar stays visually fixed).
    return PageRouteBuilder(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 180),
      reverseTransitionDuration: const Duration(milliseconds: 140),
      pageBuilder: (_, __, ___) => screen,
      transitionsBuilder: (_, animation, __, child) =>
          FadeTransition(opacity: animation, child: child),
    );
  }
}
