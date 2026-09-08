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

/// Holds the XHR lifecycle outside a widget, including its explicit abort.
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
      complete(file != null &&
              mimeType != null &&
              _allowedExtensions.contains(extension)
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
}) =>
    startBrowserVideoMultipart(
            uri: uri, file: file, headers: headers, onProgress: onProgress)
        .response;

BrowserVideoUploadOperation startBrowserVideoMultipart({
  required Uri uri,
  required BrowserVideoFile file,
  required Map<String, String> headers,
  void Function(int sentBytes, int totalBytes)? onProgress,
}) {
  final request = html.HttpRequest();
  final result = Completer<BrowserVideoUploadResponse>();
  final terminated = Completer<void>();
  request.open('POST', uri.toString());
  headers.forEach(request.setRequestHeader);

  final progressSubscription = request.upload.onProgress.listen((event) {
    if (event.lengthComputable && event.loaded != null && event.total != null) {
      onProgress?.call(event.loaded!, event.total!);
    }
  });
  final subscriptions = <StreamSubscription<html.Event>>[
    progressSubscription,
    request.onError.listen((_) {}),
    request.onTimeout.listen((_) {}),
    request.onAbort.listen((_) {}),
  ];

  Future<void> complete() async {
    for (final subscription in subscriptions) {
      await subscription.cancel();
    }
  }

  final data = html.FormData();
  // Wrapping the File in a Blob only declares its MIME type; it does not
  // materialise the video in Dart memory.
  final blob = html.Blob([file._file], file.mimeType);
  data.appendBlob('video', blob, file.name);
  request.onLoadEnd.first.then((_) async {
    final status = request.status ?? 0;
    final responseText = request.responseText ?? '';
    await complete();
    if (!terminated.isCompleted) {
      terminated.complete();
    }
    if (status == 0) {
      if (!result.isCompleted) {
        result.completeError(const BrowserVideoUploadException(
            'Video upload cancelled or failed.'));
      }
      return;
    }
    if (!result.isCompleted) {
      result.complete(BrowserVideoUploadResponse(status, responseText));
    }
  });
  request.send(data);
  return BrowserVideoUploadOperation(result.future, () {
    if (!result.isCompleted) {
      request.abort();
    }
  }, terminated: terminated.future);
}
