import 'dart:async';
import 'dart:async';
import 'dart:html' as html;

/// A selected browser [html.File]. Keeping the browser File (rather than its
/// bytes or a Dart stream) lets XHR submit it as multipart data without
/// materialising the whole video in the Flutter/Dart heap.
class BrowserVideoFile {
  BrowserVideoFile._(this._file, {required this.mimeType});

  final html.File _file;
  final String mimeType;

  String get name => _file.name;
  int get size => _file.size;
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

const _allowedExtensions = {'mp4', 'webm', 'mov'};

String? _extensionOf(String filename) {
  final dot = filename.lastIndexOf('.');
  if (dot <= 0 || dot == filename.length - 1) return null;
  return filename.substring(dot + 1).toLowerCase();
}

String? _mimeTypeForExtension(String? extension) {
  switch (extension) {
    case 'mp4':
      return 'video/mp4';
    case 'webm':
      return 'video/webm';
    case 'mov':
      return 'video/quicktime';
    default:
      return null;
  }
}

/// Opens a native browser file chooser restricted to the same MP4/WebM/MOV
/// set as the app's FilePicker uses elsewhere. We deliberately retain the
/// native [html.File]: file_picker 11.0.3 can expose a chunked read stream,
/// but its PlatformFile does not expose that original File and package:http's
/// BrowserClient buffers request streams before sending them.
Future<BrowserVideoFile?> pickBrowserVideoFile() async {
  final input = html.FileUploadInputElement()
    ..accept = '.mp4,.webm,.mov'
    ..multiple = false;
  html.document.body?.append(input);

  try {
    final result = Completer<BrowserVideoFile?>();
    var changed = false;
    late final StreamSubscription<html.Event> changeSubscription;

    void complete(BrowserVideoFile? file) {
      if (!result.isCompleted) result.complete(file);
    }

    changeSubscription = input.onChange.listen((_) {
      changed = true;
      final file = input.files?.isNotEmpty == true ? input.files!.first : null;
      final extension = file == null ? null : _extensionOf(file.name);
      final mimeType = _mimeTypeForExtension(extension);
      complete(file != null && mimeType != null && _allowedExtensions.contains(extension)
          ? BrowserVideoFile._(file, mimeType: mimeType)
          : null);
    });
    // Regaining window focus without a change is the portable cancellation
    // fallback used by file_picker's web adapter.
    final focusSubscription = html.window.onFocus.listen((_) {
      Future<void>.delayed(const Duration(seconds: 1), () {
        if (!changed) complete(null);
      });
    });
    input.click();
    final file = await result.future;
    await changeSubscription.cancel();
    await focusSubscription.cancel();
    return file;
  } finally {
    input.remove();
  }
}

/// Sends the original browser File through XHR + FormData. The browser owns
/// the file body and streams it to the network; this code never calls
/// FileReader, PlatformFile.bytes, or MultipartFile.fromBytes. XHR also gives
/// us genuine upload progress events.
Future<BrowserVideoUploadResponse> sendBrowserVideoMultipart({
  required Uri uri,
  required BrowserVideoFile file,
  required Map<String, String> headers,
  void Function(int sentBytes, int totalBytes)? onProgress,
}) async {
  final request = html.HttpRequest();
  final lessonId = _lessonIdFrom(uri);
  request.open('POST', uri.toString());
  headers.forEach(request.setRequestHeader);

  print('=== VIDEO UPLOAD DEBUG START ===');
  print('Request URL: $uri');
  print('HTTP method: POST');
  print('Lesson ID: ${lessonId ?? 'unknown'}');
  print('Selected file name: ${file.name}');
  print('File MIME type: ${file.mimeType}');
  print('File size in bytes: ${file.size}');
  print('Authorization header present: ${headers.keys.any((key) => key.toLowerCase() == 'authorization')}');

  var lastLoggedPercent = -1;
  final progressSubscription = request.upload.onProgress.listen((event) {
    if (event.lengthComputable && event.loaded != null && event.total != null) {
      final percentage = event.total! <= 0 ? 0 : ((event.loaded! / event.total!) * 100).floor();
      if (percentage == 0 || percentage == 100 || percentage - lastLoggedPercent >= 10) {
        lastLoggedPercent = percentage;
        print('=== VIDEO UPLOAD PROGRESS ===');
        print('uploadedBytes: ${event.loaded}');
        print('totalBytes: ${event.total}');
        print('percentage: $percentage%');
      }
      onProgress?.call(event.loaded!, event.total!);
    }
  });
  final errorSubscription = request.onError.listen((event) {
    print('=== VIDEO UPLOAD NETWORK ERROR ===');
    _printRequestState(request, event.type);
  });
  final timeoutSubscription = request.onTimeout.listen((event) {
    print('=== VIDEO UPLOAD TIMEOUT ===');
    _printRequestState(request, event.type);
  });
  final abortSubscription = request.onAbort.listen((event) {
    print('=== VIDEO UPLOAD ABORTED ===');
    _printRequestState(request, event.type);
  });

  try {
    final data = html.FormData();
    // Wrapping the File in a Blob changes only the declared MIME type. It does
    // not read the file into Dart memory, and ensures Multer sees the exact
    // content type required by the backend for every supported extension.
    final blob = html.Blob([file._file], file.mimeType);
    data.appendBlob('video', blob, file.name);
    print('Whether FormData contains the "video" field: ${data.has('video')}');
    print('=== VIDEO UPLOAD REQUEST START ===');
    request.send(data);
    final loadEndEvent = await request.onLoadEnd.first;

    print('=== VIDEO UPLOAD RESPONSE ===');
    _printRequestState(request, loadEndEvent.type);

    final status = request.status ?? 0;
    final responseText = request.responseText ?? '';
    if (status == 0) {
      throw const BrowserVideoUploadException(
        'Video upload failed: browser/network/CORS error (status 0).',
      );
    }
    if (status < 200 || status >= 300) {
      print('=== VIDEO UPLOAD SERVER ERROR ===');
      _printRequestState(request, loadEndEvent.type);
    }
    return BrowserVideoUploadResponse(
      status,
      responseText,
    );
  } finally {
    await progressSubscription.cancel();
    await errorSubscription.cancel();
    await timeoutSubscription.cancel();
    await abortSubscription.cancel();
  }
}

String? _lessonIdFrom(Uri uri) {
  final index = uri.pathSegments.indexOf('lessons');
  return index >= 0 && index + 1 < uri.pathSegments.length ? uri.pathSegments[index + 1] : null;
}

void _printRequestState(html.HttpRequest request, String eventType) {
  print('XHR event type: $eventType');
  print('HTTP status: ${request.status ?? 0}');
  print('statusText: ${request.statusText ?? ''}');
  print('responseText: ${request.responseText ?? ''}');
  print('response URL: ${request.responseUrl ?? ''}');
  print('readyState: ${request.readyState}');
}
