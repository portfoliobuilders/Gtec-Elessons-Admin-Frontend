import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'controllers/assessment_controller.dart';
import 'controllers/curriculum_controller.dart';
import 'controllers/dashboard_controller.dart';
import 'controllers/growth_controller.dart';
import 'controllers/notifications_controller.dart';
import 'controllers/payments_controller.dart';
import 'controllers/pricing_controller.dart';
import 'controllers/scheduler_controller.dart';
import 'controllers/students_controller.dart';
import 'controllers/teacher_controller.dart';
import 'controllers/team_controller.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_router.dart';
import 'routes/app_routes.dart';

void main() {
  runApp(const GtecAdminApp());
}

/// G-TEC Education · Admin Console.
/// Pixel-perfect Flutter recreation of the web design — MVC architecture:
/// models/ (data), controllers/ (ChangeNotifier state), views/ (UI).
class GtecAdminApp extends StatelessWidget {
  const GtecAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DashboardController()),
        ChangeNotifierProvider(create: (_) => CurriculumController()),
        ChangeNotifierProvider(create: (_) => PricingController()),
        ChangeNotifierProvider(create: (_) => AssessmentController()),
        ChangeNotifierProvider(create: (_) => TeamController()),
        ChangeNotifierProvider(create: (_) => TeacherController()),
        ChangeNotifierProvider(create: (_) => StudentsController()),
        ChangeNotifierProvider(create: (_) => SchedulerController()),
        ChangeNotifierProvider(create: (_) => NotificationsController()),
        ChangeNotifierProvider(create: (_) => PaymentsController()),
        ChangeNotifierProvider(create: (_) => GrowthController()),
      ],
      child: MaterialApp(
        title: 'G-TEC Admin Console',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        initialRoute: AppRoutes.dashboard,
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
  }
}
