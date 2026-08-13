class CreateCountryRequest {
  const CreateCountryRequest({
    required this.code,
    required this.name,
    required this.currency,
    required this.symbol,
    this.isActive,
  });

  final String code;
  final String name;
  final String currency;
  final String symbol;
  final bool? isActive;

  Map<String, dynamic> toJson() => {
        'code': code,
        'name': name,
        'currency': currency,
        'symbol': symbol,
        if (isActive != null) 'isActive': isActive,
      };
}

class UpdateCountryRequest {
  const UpdateCountryRequest({this.name, this.currency, this.symbol, this.isActive});

  final String? name;
  final String? currency;
  final String? symbol;
  final bool? isActive;

  Map<String, dynamic> toJson() => {
        if (name != null) 'name': name,
        if (currency != null) 'currency': currency,
        if (symbol != null) 'symbol': symbol,
        if (isActive != null) 'isActive': isActive,
      };
}

class CreateNotificationTemplateRequest {
  const CreateNotificationTemplateRequest({required this.type, required this.title, required this.body});

  final String type;
  final String title;
  final String body;

  Map<String, dynamic> toJson() => {'type': type, 'title': title, 'body': body};
}

class UpdateNotificationTemplateRequest {
  const UpdateNotificationTemplateRequest({this.title, this.body});

  final String? title;
  final String? body;

  Map<String, dynamic> toJson() => {
        if (title != null) 'title': title,
        if (body != null) 'body': body,
      };
}
