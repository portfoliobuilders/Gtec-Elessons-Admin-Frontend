/// The one place a backend base URL is allowed to live. Every service goes
/// through the shared `ApiClient`, which reads [baseUrl] from here — never
/// hardcode a URL in a screen/controller/service.
class ApiConfig {
  ApiConfig._();

  /// Already ends in `/api` — endpoint paths passed to ApiClient (e.g.
  /// `/admin/curriculum`) must NOT repeat it.
  static const String baseUrl = 'https://api.elessons.net/api';
  //static const String baseUrl = 'https://merrill-witty-doyly.ngrok-free.dev/api';
}
