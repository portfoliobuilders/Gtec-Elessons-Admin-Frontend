import '../../models/admin/admin_models.dart';
import '../network/api_client.dart';

/// Mirrors AdminPricingService. A product's regional prices are managed
/// individually through these endpoints (Phase 5) — the grade/subject/
/// chapter CREATE endpoints separately accept an inline `prices` array that
/// creates the product and all its rows in one call (see
/// AdminCurriculumService's Create*Request types), but their UPDATE
/// endpoints do not accept `prices` at all (confirmed live: 400 "property
/// prices should not exist") — existing prices must go through here.
class AdminPricingService {
  AdminPricingService(this._apiClient);

  final ApiClient _apiClient;

  Future<List<AdminProductModel>> list() async {
    final json = await _apiClient.get('/admin/pricing') as List<dynamic>;
    return json.map((e) => AdminProductModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<AdminProductPriceModel> createProductPrice(String productId, CreatePriceRequest request) async {
    final json = await _apiClient.post('/admin/pricing/products/$productId/prices', body: request.toJson());
    return AdminProductPriceModel.fromJson(json as Map<String, dynamic>);
  }

  Future<AdminProductPriceModel> updateProductPrice(
    String productId,
    String priceId,
    UpdateProductPriceRequest request,
  ) async {
    final json =
        await _apiClient.patch('/admin/pricing/products/$productId/prices/$priceId', body: request.toJson());
    return AdminProductPriceModel.fromJson(json as Map<String, dynamic>);
  }

  Future<AdminProductPriceModel> deleteProductPrice(String productId, String priceId) async {
    final json = await _apiClient.delete('/admin/pricing/products/$productId/prices/$priceId');
    return AdminProductPriceModel.fromJson(json as Map<String, dynamic>);
  }

  /// Soft delete — sets `isActive: false`, does not remove the row.
  Future<AdminProductModel> deleteProduct(String id) async {
    final json = await _apiClient.delete('/admin/pricing/products/$id');
    return AdminProductModel.fromJson(json as Map<String, dynamic>);
  }
}
