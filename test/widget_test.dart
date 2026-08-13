// Basic Flutter widget test for the G-TEC Admin Console.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:gtec_admin/controllers/auth_controller.dart';
import 'package:gtec_admin/core/network/api_client.dart';
import 'package:gtec_admin/core/services/auth_service.dart';
import 'package:gtec_admin/core/services/auth_storage.dart';
import 'package:gtec_admin/main.dart';

void main() {
  testWidgets('Dashboard renders KPI data', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    final authStorage = AuthStorage();
    final apiClient = ApiClient(tokenGetter: authStorage.getAccessToken);
    final authController = AuthController(
      authService: AuthService(apiClient: apiClient),
      authStorage: authStorage,
    );
    await tester.pumpWidget(GtecAdminApp(apiClient: apiClient, authController: authController));
    await tester.pumpAndSettle();

    // Verify the dashboard shows a known KPI value.
    expect(find.text('Active enrollments'), findsOneWidget);
  });
}
