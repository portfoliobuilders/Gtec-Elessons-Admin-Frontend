/// Browser-file support is intentionally isolated from the normal multipart
/// client. Lesson video upload is an Admin Web feature; native builds do not
/// use this path.
class BrowserVideoFile {
  const BrowserVideoFile({
    required this.name,
    required this.size,
    required this.mimeType,
  });

  final String name;
  final int size;
  final String mimeType;
}

class BrowserVideoUploadResponse {
  const BrowserVideoUploadResponse(this.statusCode, this.body);

  final int statusCode;
  final String body;
}

class BrowserVideoUploadException implements Exception {
  const BrowserVideoUploadException(this.message);

  final String message;

  @override
  String toString() => message;
}

Future<BrowserVideoFile?> pickBrowserVideoFile() =>
    throw UnsupportedError('Local lesson video upload is available in the Admin Web app only.');

Future<BrowserVideoUploadResponse> sendBrowserVideoMultipart({
  required Uri uri,
  required BrowserVideoFile file,
  required Map<String, String> headers,
  void Function(int sentBytes, int totalBytes)? onProgress,
}) =>
    throw UnsupportedError('Local lesson video upload is available in the Admin Web app only.');
