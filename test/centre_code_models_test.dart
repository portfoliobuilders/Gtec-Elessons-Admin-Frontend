import 'package:flutter_test/flutter_test.dart';
import 'package:gtec_admin/models/admin/student_models.dart';
import 'package:gtec_admin/models/admin/order_models.dart';

void main() {
  group('StudentDetailModel.centreCode', () {
    test('parses normal string centreCode from studentProfile', () {
      final model = StudentDetailModel.fromJson({
        'id': 'student-1',
        'name': 'Alice',
        'role': 'STUDENT',
        'status': 'ACTIVE',
        'createdAt': '2026-01-01T00:00:00.000Z',
        'studentProfile': {
          'centreCode': 'ABC123',
          'board': 'CBSE',
        },
      });

      expect(model.centreCode, equals('ABC123'));
    });

    test('handles null centreCode without errors', () {
      final model = StudentDetailModel.fromJson({
        'id': 'student-2',
        'name': 'Bob',
        'role': 'STUDENT',
        'status': 'ACTIVE',
        'createdAt': '2026-01-01T00:00:00.000Z',
        'studentProfile': {
          'centreCode': null,
        },
      });

      expect(model.centreCode, isNull);
    });

    test('handles missing studentProfile without errors', () {
      final model = StudentDetailModel.fromJson({
        'id': 'student-3',
        'name': 'Charlie',
        'role': 'STUDENT',
        'status': 'ACTIVE',
        'createdAt': '2026-01-01T00:00:00.000Z',
      });

      expect(model.centreCode, isNull);
    });

    test('handles empty string centreCode without errors', () {
      final model = StudentDetailModel.fromJson({
        'id': 'student-4',
        'name': 'Diana',
        'role': 'STUDENT',
        'status': 'ACTIVE',
        'createdAt': '2026-01-01T00:00:00.000Z',
        'studentProfile': {
          'centreCode': '',
        },
      });

      expect(model.centreCode, equals(''));
    });

    test('handles non-string centreCode (e.g. numeric) safely', () {
      final model = StudentDetailModel.fromJson({
        'id': 'student-5',
        'name': 'Evan',
        'role': 'STUDENT',
        'status': 'ACTIVE',
        'createdAt': '2026-01-01T00:00:00.000Z',
        'studentProfile': {
          'centreCode': 998877,
        },
      });

      expect(model.centreCode, equals('998877'));
    });

    test('copyWith updates or preserves centreCode', () {
      final initial = StudentDetailModel(
        id: 'student-6',
        name: 'Frank',
        role: 'STUDENT',
        status: 'ACTIVE',
        createdAt: DateTime.parse('2026-01-01T00:00:00.000Z'),
        centreCode: 'INIT01',
      );

      final preserved = initial.copyWith(status: 'SUSPENDED');
      expect(preserved.centreCode, equals('INIT01'));
      expect(preserved.status, equals('SUSPENDED'));

      final updated = initial.copyWith(centreCode: 'NEW02');
      expect(updated.centreCode, equals('NEW02'));
    });
  });

  group('AdminOrderDetailModel.billingCentreCode', () {
    test('parses billingCentreCode correctly', () {
      final model = AdminOrderDetailModel.fromJson({
        'id': 'order-1',
        'orderNumber': 'ORD-1001',
        'status': 'PAID',
        'createdAt': '2026-01-01T00:00:00.000Z',
        'updatedAt': '2026-01-01T00:00:00.000Z',
        'billingCentreCode': 'ORD_CENTRE_99',
      });

      expect(model.billingCentreCode, equals('ORD_CENTRE_99'));
    });

    test('handles null and empty billingCentreCode', () {
      final nullModel = AdminOrderDetailModel.fromJson({
        'id': 'order-2',
        'orderNumber': 'ORD-1002',
        'status': 'PAID',
        'createdAt': '2026-01-01T00:00:00.000Z',
        'updatedAt': '2026-01-01T00:00:00.000Z',
        'billingCentreCode': null,
      });
      expect(nullModel.billingCentreCode, isNull);

      final emptyModel = AdminOrderDetailModel.fromJson({
        'id': 'order-3',
        'orderNumber': 'ORD-1003',
        'status': 'PAID',
        'createdAt': '2026-01-01T00:00:00.000Z',
        'updatedAt': '2026-01-01T00:00:00.000Z',
        'billingCentreCode': '',
      });
      expect(emptyModel.billingCentreCode, equals(''));
    });

    test('copyWith updates or preserves billingCentreCode', () {
      final initial = AdminOrderDetailModel(
        id: 'order-4',
        orderNumber: 'ORD-1004',
        status: 'PAID',
        region: 'IN',
        currency: 'INR',
        subtotalCents: 1000,
        discountCents: 0,
        taxCents: 180,
        totalCents: 1180,
        createdAt: DateTime.parse('2026-01-01T00:00:00.000Z'),
        updatedAt: DateTime.parse('2026-01-01T00:00:00.000Z'),
        billingCentreCode: 'HIST_123',
      );

      final preserved = initial.copyWith(status: 'REFUNDED');
      expect(preserved.billingCentreCode, equals('HIST_123'));
      expect(preserved.status, equals('REFUNDED'));

      final updated = initial.copyWith(billingCentreCode: 'HIST_456');
      expect(updated.billingCentreCode, equals('HIST_456'));
    });
  });

  group('AdminOrderListItemModel.billingCentreCode', () {
    test('parses billingCentreCode correctly', () {
      final model = AdminOrderListItemModel.fromJson({
        'id': 'order-row-1',
        'orderNumber': 'ORD-ROW-1',
        'status': 'PAID',
        'currency': 'INR',
        'subtotalCents': 1000,
        'taxCents': 180,
        'totalCents': 1180,
        'createdAt': '2026-01-01T00:00:00.000Z',
        'billingCentreCode': 'ROW_CENTRE_1',
      });

      expect(model.billingCentreCode, equals('ROW_CENTRE_1'));
    });
  });

  group('StudentOrderRefModel.billingCentreCode', () {
    test('parses billingCentreCode from student order list item', () {
      final model = StudentOrderRefModel.fromJson({
        'orderNumber': 'ORD-REF-1',
        'totalCents': 5000,
        'currency': 'INR',
        'createdAt': '2026-01-01T00:00:00.000Z',
        'billingCentreCode': 'STUDENT_ORDER_CODE',
      });

      expect(model.billingCentreCode, equals('STUDENT_ORDER_CODE'));
    });
  });

  group('Historical Distinction between Student Profile and Order Billing', () {
    test('Student current profile code and order billing code remain independent', () {
      // Current student profile has XYZ999
      final student = StudentDetailModel.fromJson({
        'id': 'student-historical',
        'name': 'Historical Student',
        'role': 'STUDENT',
        'status': 'ACTIVE',
        'createdAt': '2026-01-01T00:00:00.000Z',
        'studentProfile': {
          'centreCode': 'XYZ999',
        },
      });

      // Historical order has ABC123
      final order = AdminOrderDetailModel.fromJson({
        'id': 'order-historical',
        'orderNumber': 'ORD-HIST-1',
        'status': 'PAID',
        'createdAt': '2025-06-01T00:00:00.000Z',
        'updatedAt': '2025-06-01T00:00:00.000Z',
        'billingCentreCode': 'ABC123',
      });

      expect(student.centreCode, equals('XYZ999'));
      expect(order.billingCentreCode, equals('ABC123'));
      expect(student.centreCode, isNot(equals(order.billingCentreCode)));
    });
  });
}
