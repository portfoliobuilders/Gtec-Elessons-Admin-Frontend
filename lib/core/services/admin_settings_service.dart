import '../../models/admin/admin_models.dart';
import '../network/api_client.dart';

/// Mirrors AdminConfigService's settings/countries/exchange-rate methods
/// (notification templates live in [AdminNotificationService] instead —
/// grouped by frontend feature).
class AdminSettingsService {
  AdminSettingsService(this._apiClient);

  final ApiClient _apiClient;

  Future<List<AdminSettingModel>> listSettings() async {
    final json = await _apiClient.get('/admin/settings') as List<dynamic>;
    return json.map((e) => AdminSettingModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<AdminSettingModel> updateSetting(String key, String value) async {
    final json = await _apiClient.patch('/admin/settings/$key', body: {'value': value});
    return AdminSettingModel.fromJson(json as Map<String, dynamic>);
  }

  /// Admin sees inactive rows too — the public `GET /regions` filters them.
  Future<List<CountryModel>> listCountries() async {
    final json = await _apiClient.get('/admin/countries') as List<dynamic>;
    return json.map((e) => CountryModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<CountryModel> createCountry(CreateCountryRequest request) async {
    final json = await _apiClient.post('/admin/countries', body: request.toJson());
    return CountryModel.fromJson(json as Map<String, dynamic>);
  }

  Future<CountryModel> updateCountry(String code, UpdateCountryRequest request) async {
    final json = await _apiClient.patch('/admin/countries/$code', body: request.toJson());
    return CountryModel.fromJson(json as Map<String, dynamic>);
  }

  Future<void> deleteCountry(String code) => _apiClient.delete('/admin/countries/$code');

  Future<List<ExchangeRateModel>> listExchangeRates() async {
    final json = await _apiClient.get('/admin/exchange-rates') as List<dynamic>;
    return json.map((e) => ExchangeRateModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// `rateToInr` is 1 INR expressed in the target currency.
  Future<ExchangeRateModel> updateExchangeRate(String currency, num rateToInr) async {
    final json = await _apiClient.patch('/admin/exchange-rates/$currency', body: {'rateToInr': rateToInr});
    return ExchangeRateModel.fromJson(json as Map<String, dynamic>);
  }
}
