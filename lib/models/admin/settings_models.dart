// Backend-aligned Settings models — mirrors AdminConfigService.

/// `GET /admin/settings` — flat key/value store (GST%, default currency, …).
class AdminSettingModel {
  const AdminSettingModel({required this.key, required this.value, required this.updatedAt});

  final String key;
  final String value;
  final DateTime updatedAt;

  factory AdminSettingModel.fromJson(Map<String, dynamic> json) => AdminSettingModel(
        key: json['key'] as String,
        value: json['value'] as String,
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );
}

/// `GET /admin/countries` (admin sees inactive rows too — the public
/// `GET /regions` filters them out).
class CountryModel {
  const CountryModel({
    required this.code,
    required this.name,
    required this.currency,
    required this.symbol,
    this.isActive = true,
  });

  final String code;
  final String name;
  final String currency;
  final String symbol;
  final bool isActive;

  factory CountryModel.fromJson(Map<String, dynamic> json) => CountryModel(
        code: json['code'] as String,
        name: json['name'] as String,
        currency: json['currency'] as String,
        symbol: json['symbol'] as String,
        isActive: json['isActive'] as bool? ?? true,
      );
}

/// `GET /admin/exchange-rates` — fallback used when the live FX fetch fails.
/// `rateToInr` is 1 INR expressed in the target currency (e.g. AED row
/// 0.044 means 1 INR = 0.044 AED).
class ExchangeRateModel {
  const ExchangeRateModel({required this.currency, required this.rateToInr, required this.updatedAt});

  final String currency;
  final num rateToInr;
  final DateTime updatedAt;

  factory ExchangeRateModel.fromJson(Map<String, dynamic> json) => ExchangeRateModel(
        currency: json['currency'] as String,
        rateToInr: json['rateToInr'] as num,
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );
}

/// `GET /admin/notification-templates`. `title`/`body` may contain
/// `{{variable}}` placeholders substituted server-side.
class NotificationTemplateModel {
  const NotificationTemplateModel({required this.type, required this.title, required this.body});

  /// Matches `Notification.type`, e.g. "PAYMENT_SUCCESS".
  final String type;
  final String title;
  final String body;

  factory NotificationTemplateModel.fromJson(Map<String, dynamic> json) => NotificationTemplateModel(
        type: json['type'] as String,
        title: json['title'] as String,
        body: json['body'] as String,
      );
}
