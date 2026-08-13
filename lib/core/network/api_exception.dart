/// Thrown by [ApiClient] for non-2xx responses and network/parse failures.
/// [message] is already suitable to show directly in the UI.
class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode, this.rawBody});

  final String message;
  final int? statusCode;

  /// The raw decoded error body, if any. Debug logging only — never shown
  /// to the user directly (that's what [message] is for).
  final Map<String, dynamic>? rawBody;

  bool get isUnauthorized => statusCode == 401;

  @override
  String toString() => message;
}
