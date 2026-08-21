import 'package:flutter/material.dart';

import '../views/screens/assessment_screen.dart';
import '../views/screens/curriculum/add_chapter_screen.dart';
import '../views/screens/curriculum/add_grade_screen.dart';
import '../views/screens/curriculum/add_lesson_screen.dart';
import '../views/screens/curriculum/add_subject_screen.dart';
import '../views/screens/curriculum/chapter_detail_screen.dart';
import '../views/screens/curriculum/grade_detail_screen.dart';
import '../views/screens/curriculum/grade_selection_screen.dart';
import '../views/screens/curriculum/lesson_detail_screen.dart';
import '../views/screens/curriculum/subject_detail_screen.dart';
import '../views/screens/dashboard_screen.dart';
import '../views/screens/growth_screen.dart';
import '../views/screens/login_screen.dart';
import '../views/screens/notifications_screen.dart';
import '../views/screens/order_detail_screen.dart';
import '../views/screens/orders_screen.dart';
import '../views/screens/payments_screen.dart';
import '../views/screens/pricing_product_screen.dart';
import '../views/screens/pricing_screen.dart';
import '../views/screens/scheduler_screen.dart';
import '../views/screens/splash_screen.dart';
import '../views/screens/student_detail_screen.dart';
import '../views/screens/students_screen.dart';
import '../views/screens/teacher_screen.dart';
import '../views/screens/team_screen.dart';
import 'app_routes.dart';

class AppRouter {
  AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final Widget screen = switch (settings.name) {
      AppRoutes.splash => const SplashScreen(),
      AppRoutes.login => const LoginScreen(),
      AppRoutes.dashboard => const DashboardScreen(),
      AppRoutes.curriculum => const GradeSelectionScreen(),
      AppRoutes.curriculumGradeDetail => const GradeDetailScreen(),
      AppRoutes.curriculumSubjects => const SubjectDetailScreen(),
      AppRoutes.curriculumChapterDetail => const ChapterDetailScreen(),
      AppRoutes.curriculumLessonDetail => const LessonDetailScreen(),
      AppRoutes.curriculumAddGrade => const AddGradeScreen(),
      AppRoutes.curriculumAddSubject => const AddSubjectScreen(),
      AppRoutes.curriculumAddChapter => const AddChapterScreen(),
      AppRoutes.curriculumAddLesson => const AddLessonScreen(),
      AppRoutes.pricing => const PricingScreen(),
      AppRoutes.pricingProductDetail => const PricingProductScreen(),
      AppRoutes.assessments => const AssessmentScreen(),
      AppRoutes.team => const TeamScreen(),
      AppRoutes.teacher => const TeacherScreen(),
      AppRoutes.students => const StudentsScreen(),
      AppRoutes.studentDetail => const StudentDetailScreen(),
      AppRoutes.scheduler => const SchedulerScreen(),
      AppRoutes.notifications => const NotificationsScreen(),
      AppRoutes.payments => const PaymentsScreen(),
      AppRoutes.growth => const GrowthScreen(),
      AppRoutes.orders => const OrdersScreen(),
      AppRoutes.orderDetail => const OrderDetailScreen(),
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
