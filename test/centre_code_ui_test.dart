import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:gtec_admin/models/admin/student_models.dart';
import 'package:gtec_admin/models/admin/order_models.dart';
import 'package:gtec_admin/controllers/students_controller.dart';
import 'package:gtec_admin/controllers/orders_controller.dart';
import 'package:gtec_admin/controllers/auth_controller.dart';
import 'package:gtec_admin/controllers/curriculum_controller.dart';
import 'package:gtec_admin/controllers/video_upload_manager.dart';
import 'package:gtec_admin/core/services/admin_students_service.dart';
import 'package:gtec_admin/core/services/admin_enrollments_service.dart';
import 'package:gtec_admin/core/services/admin_orders_service.dart';
import 'package:gtec_admin/core/services/admin_curriculum_service.dart';
import 'package:gtec_admin/core/services/admin_pricing_service.dart';
import 'package:gtec_admin/core/services/auth_service.dart';
import 'package:gtec_admin/core/services/auth_storage.dart';
import 'package:gtec_admin/core/network/api_client.dart';
import 'package:gtec_admin/views/screens/student_detail_screen.dart';
import 'package:gtec_admin/views/screens/order_detail_screen.dart';

void main() {
  late ApiClient apiClient;
  late AuthStorage authStorage;
  late AuthService authService;
  late AuthController authController;
  late AdminStudentsService studentsService;
  late AdminEnrollmentsService enrollmentsService;
  late AdminOrdersService ordersService;
  late AdminCurriculumService curriculumService;
  late AdminPricingService pricingService;

  setUp(() {
    authStorage = AuthStorage();
    apiClient = ApiClient();
    authService = AuthService(apiClient: apiClient);
    authController = AuthController(authService: authService, authStorage: authStorage);
    studentsService = AdminStudentsService(apiClient);
    enrollmentsService = AdminEnrollmentsService(apiClient);
    ordersService = AdminOrdersService(apiClient);
    curriculumService = AdminCurriculumService(apiClient);
    pricingService = AdminPricingService(apiClient);
  });

  void setDesktopSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  group('StudentDetailScreen Centre Code display', () {
    testWidgets('renders Centre Code with value when present', (tester) async {
      setDesktopSize(tester);
      final studentsController = StudentsController(studentsService, enrollmentsService);
      studentsController.selectedStudent = StudentDetailModel(
        id: 'student-1',
        name: 'Test Student',
        role: 'STUDENT',
        status: 'ACTIVE',
        createdAt: DateTime.parse('2026-01-01T00:00:00.000Z'),
        centreCode: 'ABC123',
      );
      studentsController.detailStatus = StudentsLoadStatus.loaded;

      final curriculumController = CurriculumController(curriculumService, pricingService);
      curriculumController.curriculumStatus = CurriculumLoadStatus.loaded;

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: studentsController),
            ChangeNotifierProvider.value(value: authController),
            ChangeNotifierProvider.value(value: curriculumController),
            ChangeNotifierProvider.value(value: VideoUploadManager(ApiVideoUploadTransport(apiClient))),
          ],
          child: const MaterialApp(
            home: StudentDetailScreen(),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Centre Code'), findsOneWidget);
      expect(find.text('ABC123'), findsOneWidget);
    });

    testWidgets('renders Not set when Centre Code is null or empty', (tester) async {
      setDesktopSize(tester);
      final studentsController = StudentsController(studentsService, enrollmentsService);
      studentsController.selectedStudent = StudentDetailModel(
        id: 'student-2',
        name: 'Test Student 2',
        role: 'STUDENT',
        status: 'ACTIVE',
        createdAt: DateTime.parse('2026-01-01T00:00:00.000Z'),
        centreCode: null,
      );
      studentsController.detailStatus = StudentsLoadStatus.loaded;

      final curriculumController = CurriculumController(curriculumService, pricingService);
      curriculumController.curriculumStatus = CurriculumLoadStatus.loaded;

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: studentsController),
            ChangeNotifierProvider.value(value: authController),
            ChangeNotifierProvider.value(value: curriculumController),
            ChangeNotifierProvider.value(value: VideoUploadManager(ApiVideoUploadTransport(apiClient))),
          ],
          child: const MaterialApp(
            home: StudentDetailScreen(),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Centre Code'), findsOneWidget);
      expect(find.text('Not set'), findsWidgets);
    });
  });

  group('OrderDetailScreen Centre Code display', () {
    testWidgets('renders Centre Code with order billingCentreCode', (tester) async {
      setDesktopSize(tester);
      final ordersController = OrdersController(ordersService);
      ordersController.selectedOrder = AdminOrderDetailModel(
        id: 'order-1',
        orderNumber: 'ORD-999',
        status: 'PAID',
        region: 'IN',
        currency: 'INR',
        subtotalCents: 1000,
        discountCents: 0,
        taxCents: 180,
        totalCents: 1180,
        createdAt: DateTime.parse('2026-01-01T00:00:00.000Z'),
        updatedAt: DateTime.parse('2026-01-01T00:00:00.000Z'),
        billingCentreCode: 'BILL_CTR_456',
      );
      ordersController.detailStatus = OrdersLoadStatus.loaded;

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: ordersController),
            ChangeNotifierProvider.value(value: StudentsController(studentsService, enrollmentsService)),
            ChangeNotifierProvider.value(value: authController),
            ChangeNotifierProvider.value(value: VideoUploadManager(ApiVideoUploadTransport(apiClient))),
          ],
          child: const MaterialApp(
            home: OrderDetailScreen(),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Centre Code'), findsOneWidget);
      expect(find.text('BILL_CTR_456'), findsOneWidget);
    });

    testWidgets('renders Not set when order billingCentreCode is null', (tester) async {
      setDesktopSize(tester);
      final ordersController = OrdersController(ordersService);
      ordersController.selectedOrder = AdminOrderDetailModel(
        id: 'order-2',
        orderNumber: 'ORD-1000',
        status: 'PAID',
        region: 'IN',
        currency: 'INR',
        subtotalCents: 1000,
        discountCents: 0,
        taxCents: 180,
        totalCents: 1180,
        createdAt: DateTime.parse('2026-01-01T00:00:00.000Z'),
        updatedAt: DateTime.parse('2026-01-01T00:00:00.000Z'),
        billingCentreCode: null,
      );
      ordersController.detailStatus = OrdersLoadStatus.loaded;

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: ordersController),
            ChangeNotifierProvider.value(value: StudentsController(studentsService, enrollmentsService)),
            ChangeNotifierProvider.value(value: authController),
            ChangeNotifierProvider.value(value: VideoUploadManager(ApiVideoUploadTransport(apiClient))),
          ],
          child: const MaterialApp(
            home: OrderDetailScreen(),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Centre Code'), findsOneWidget);
      expect(find.text('Not set'), findsWidgets);
    });
  });
}
