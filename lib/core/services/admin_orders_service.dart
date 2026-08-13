import '../../models/admin/admin_models.dart';
import '../network/api_client.dart';

/// Mirrors AdminOrdersService + PaymentsService.refundOrder.
class AdminOrdersService {
  AdminOrdersService(this._apiClient);

  final ApiClient _apiClient;

  /// `status` (when given) must be one of the backend `OrderStatus` enum
  /// values: PENDING | PAID | FAILED | REFUNDED.
  Future<({int total, List<AdminOrderListItemModel> orders})> list({
    String? status,
    int take = 50,
    int skip = 0,
  }) async {
    final query = {
      if (status != null && status.isNotEmpty) 'status': status,
      'take': '$take',
      'skip': '$skip',
    };
    final path = '/admin/orders?${Uri(queryParameters: query).query}';
    final json = await _apiClient.get(path) as Map<String, dynamic>;
    return (
      total: json['total'] as int? ?? 0,
      orders: (json['orders'] as List<dynamic>)
          .map((e) => AdminOrderListItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<AdminOrderDetailModel> detail(String id) async {
    final json = await _apiClient.get('/admin/orders/$id');
    return AdminOrderDetailModel.fromJson(json as Map<String, dynamic>);
  }

  /// Reverses the Razorpay charge (if any), marks the order REFUNDED, and
  /// cancels its enrollments. Only a PAID order can be refunded (400
  /// otherwise).
  Future<AdminOrderDetailModel> refund(String id, {String? reason}) async {
    final json = await _apiClient.post('/admin/orders/$id/refund', body: {if (reason != null) 'reason': reason});
    return AdminOrderDetailModel.fromJson(json as Map<String, dynamic>);
  }
}
