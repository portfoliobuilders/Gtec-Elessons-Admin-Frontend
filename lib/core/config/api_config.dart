/// The one place a backend base URL is allowed to live. Every service goes
/// through the shared `ApiClient`, which reads [baseUrl] from here — never
/// hardcode a URL in a screen/controller/service.
class ApiConfig {
  ApiConfig._();

  /// Flip this — and only this — to switch environments.
  /// `true` while developing against the ngrok tunnel; `false` for
  /// production builds. The ngrok URL changes whenever the tunnel is
  /// restarted, so it's isolated here rather than duplicated anywhere.
  static const bool useDevelopmentBackend = true;

  static const String _developmentBaseUrl = 'https://merrill-witty-doyly.ngrok-free.dev/api';
  static const String _productionBaseUrl = 'https://api.portfoliobuilders.in/gtec/api';

  /// Both environment URLs already end in `/api` — endpoint paths passed to
  /// ApiClient (e.g. `/admin/curriculum`) must NOT repeat it.
  static const String baseUrl = useDevelopmentBackend ? _developmentBaseUrl : _productionBaseUrl;
}
