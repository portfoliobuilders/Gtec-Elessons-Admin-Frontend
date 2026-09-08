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

/// A browser upload remains cancellable after its originating screen disposes.
class BrowserVideoUploadOperation {
  BrowserVideoUploadOperation(this.response, this.cancel,
      {Future<void>? terminated})
      : terminated = terminated ?? Future<void>.value();

  final Future<BrowserVideoUploadResponse> response;
  final void Function() cancel;
  final Future<void> terminated;
}

class BrowserVideoUploadException implements Exception {
  const BrowserVideoUploadException(this.message);

  final String message;

  @override
  String toString() => message;
}

Future<BrowserVideoFile?> pickBrowserVideoFile() => throw UnsupportedError(
    'Local lesson video upload is available in the Admin Web app only.');

Future<BrowserVideoUploadResponse> sendBrowserVideoMultipart({
  required Uri uri,
  required BrowserVideoFile file,
  required Map<String, String> headers,
  void Function(int sentBytes, int totalBytes)? onProgress,
}) =>
    throw UnsupportedError(
        'Local lesson video upload is available in the Admin Web app only.');

BrowserVideoUploadOperation startBrowserVideoMultipart({
  required Uri uri,
  required BrowserVideoFile file,
  required Map<String, String> headers,
  void Function(int sentBytes, int totalBytes)? onProgress,
}) =>
    BrowserVideoUploadOperation(
      sendBrowserVideoMultipart(
          uri: uri, file: file, headers: headers, onProgress: onProgress),
      () {},
    );
