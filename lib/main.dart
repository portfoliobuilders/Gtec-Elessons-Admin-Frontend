import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'controllers/assessment_controller.dart';
import 'controllers/auth_controller.dart';
import 'controllers/curriculum_controller.dart';
import 'controllers/dashboard_controller.dart';
import 'controllers/growth_controller.dart';
import 'controllers/notifications_controller.dart';
import 'controllers/orders_controller.dart';
import 'controllers/pricing_controller.dart';
import 'controllers/scheduler_controller.dart';
import 'controllers/students_controller.dart';
import 'controllers/teacher_controller.dart';
import 'controllers/team_controller.dart';
import 'core/network/api_client.dart';
import 'core/services/admin_curriculum_service.dart';
import 'core/services/admin_dashboard_service.dart';
import 'core/services/admin_enrollments_service.dart';
import 'core/services/admin_orders_service.dart';
import 'core/services/admin_pricing_service.dart';
import 'core/services/admin_students_service.dart';
import 'core/services/admin_team_service.dart';
import 'core/services/auth_service.dart';
import 'core/services/auth_storage.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_router.dart';
import 'routes/app_routes.dart';

void main() {
  // Wired here (not inside a widget) so there is exactly one ApiClient and
  // one AuthService/AuthStorage pair for the whole app — every future
  // Admin service takes the same ApiClient instance via Provider instead of
  // constructing its own.
  final authStorage = AuthStorage();
  late final AuthService authService;
  late final AuthController authController;

  final apiClient = ApiClient(
    tokenGetter: authStorage.getAccessToken,
    // Exactly one refresh attempt per 401; concurrent 401s are coalesced by
    // ApiClient itself. Returns whether the retry should proceed.
    onUnauthorized: () async {
      final refreshToken = await authStorage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) return false;
      try {
        final pair = await authService.refresh(refreshToken);
        if (pair.accessToken.isEmpty) return false;
        await authStorage.saveTokens(accessToken: pair.accessToken, refreshToken: pair.refreshToken);
        return true;
      } catch (_) {
        return false;
      }
    },
    // Refresh already failed by the time this fires — nothing left to
    // revoke server-side, just drop the local session.
    onSessionExpired: () => authController.logout(callBackend: false),
  );

  authService = AuthService(apiClient: apiClient);
  authController = AuthController(authService: authService, authStorage: authStorage);

  runApp(GtecAdminApp(apiClient: apiClient, authController: authController));
}

/// G-TEC Education · Admin Console.
/// Pixel-perfect Flutter recreation of the web design — MVC architecture:
/// models/ (data), controllers/ (ChangeNotifier state), views/ (UI).
class GtecAdminApp extends StatelessWidget {
  const GtecAdminApp({super.key, required this.apiClient, required this.authController});

  final ApiClient apiClient;
  final AuthController authController;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiClient>.value(value: apiClient),
        ChangeNotifierProvider<AuthController>.value(value: authController),
        ChangeNotifierProvider(
          create: (context) => DashboardController(AdminDashboardService(context.read<ApiClient>())),
        ),
        ChangeNotifierProvider(
          create: (context) => CurriculumController(
            AdminCurriculumService(context.read<ApiClient>()),
            AdminPricingService(context.read<ApiClient>()),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => PricingController(AdminPricingService(context.read<ApiClient>())),
        ),
        ChangeNotifierProvider(create: (_) => AssessmentController()),
        ChangeNotifierProvider(
          create: (context) => TeamController(
            AdminTeamService(context.read<ApiClient>()),
            AdminStudentsService(context.read<ApiClient>()),
          ),
        ),
        ChangeNotifierProvider(create: (_) => TeacherController()),
        ChangeNotifierProvider(
          create: (context) => StudentsController(
            AdminStudentsService(context.read<ApiClient>()),
            AdminEnrollmentsService(context.read<ApiClient>()),
          ),
        ),
        ChangeNotifierProvider(create: (_) => SchedulerController()),
        ChangeNotifierProvider(create: (_) => NotificationsController()),
        ChangeNotifierProvider(create: (_) => GrowthController()),
        ChangeNotifierProvider(
          create: (context) => OrdersController(AdminOrdersService(context.read<ApiClient>())),
        ),
      ],
      child: MaterialApp(
        title: 'G-TEC Admin Console',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        initialRoute: AppRoutes.splash,
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
  }
}
