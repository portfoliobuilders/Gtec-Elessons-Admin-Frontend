import 'dart:collection';
import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/network/api_client.dart';
import '../core/network/browser_video_upload.dart';

const int maxConcurrentUploads = 3;
const int maxQueuedUploads = 3;
const int maxTotalPendingUploads = 6;

enum VideoUploadStatus { queued, uploading, completed, failed, cancelled }

enum VideoUploadAdmission {
  started,
  queued,
  queueFull,
  lessonConflict,
  invalid
}

class VideoUploadSubmission {
  const VideoUploadSubmission(this.admission, {this.task, this.message});

  final VideoUploadAdmission admission;
  final VideoUploadTask? task;
  final String? message;

  bool get accepted =>
      admission == VideoUploadAdmission.started ||
      admission == VideoUploadAdmission.queued;
}

class VideoUploadTask {
  VideoUploadTask({
    required this.taskId,
    required this.lessonId,
    required this.lessonTitle,
    required BrowserVideoFile selectedFile,
    required this.createdAt,
  })  : file = selectedFile,
        fileName = selectedFile.name,
        totalBytes = selectedFile.size;

  final String taskId;
  final String lessonId;
  final String lessonTitle;

  /// Retained for queued/failed tasks so they can start or retry. Completed
  /// and cancelled tasks release this browser file reference.
  BrowserVideoFile? file;
  final String fileName;
  final int totalBytes;
  final DateTime createdAt;
  VideoUploadStatus status = VideoUploadStatus.queued;
  int uploadedBytes = 0;
  double currentSpeedBytesPerSecond = 0;
  double averageSpeedBytesPerSecond = 0;
  Duration? eta;
  String? errorMessage;
  DateTime? startedAt;
  DateTime? completedAt;
  DateTime? _lastProgressAt;
  int _lastProgressBytes = 0;

  double get progress => totalBytes == 0 ? 0 : uploadedBytes / totalBytes;
}

abstract class VideoUploadTransport {
  Future<BrowserVideoUploadOperation> start(
    String lessonId,
    BrowserVideoFile file, {
    void Function(int uploadedBytes, int totalBytes)? onProgress,
  });
}

class ApiVideoUploadTransport implements VideoUploadTransport {
  ApiVideoUploadTransport(this._apiClient);
  final ApiClient _apiClient;

  @override
  Future<BrowserVideoUploadOperation> start(
    String lessonId,
    BrowserVideoFile file, {
    void Function(int uploadedBytes, int totalBytes)? onProgress,
  }) =>
      _apiClient.startLessonVideoUpload(lessonId,
          file: file, onProgress: onProgress);
}

/// Application-scoped source of truth for independent video XHRs. It keeps
/// browser File references only until terminal state so no video bytes enter
/// Dart memory. The manager itself is provided above all routes in main.dart.
class VideoUploadManager extends ChangeNotifier {
  VideoUploadManager(this._transport, {DateTime Function()? clock})
      : _clock = clock ?? DateTime.now;

  final VideoUploadTransport _transport;
  final DateTime Function() _clock;
  final List<VideoUploadTask> _tasks = [];
  final Queue<VideoUploadTask> _queue = Queue<VideoUploadTask>();
  final Map<String, BrowserVideoUploadOperation> _operations = {};
  final Map<String, Completer<BrowserVideoUploadOperation>> _starting = {};
  int _nextTask = 0;

  List<VideoUploadTask> get tasks => List.unmodifiable(_tasks);
  List<VideoUploadTask> get activeTasks => List.unmodifiable(
      _tasks.where((task) => task.status == VideoUploadStatus.uploading));
  List<VideoUploadTask> get queuedTasks => List.unmodifiable(_queue);
  int get activeCount => activeTasks.length;
  int get queuedCount => _queue.length;
  int get pendingCount => activeCount + queuedCount;
  bool get hasPendingUploads => pendingCount > 0;

  VideoUploadTask? taskForLesson(String lessonId) {
    for (final task in _tasks.reversed) {
      if (task.lessonId == lessonId &&
          task.status != VideoUploadStatus.completed) {
        return task;
      }
    }
    return null;
  }

  int? queuePosition(VideoUploadTask task) {
    final index = _queue.toList().indexOf(task);
    return index < 0 ? null : index + 1;
  }

  VideoUploadSubmission submit({
    required String lessonId,
    required String lessonTitle,
    required BrowserVideoFile file,
  }) {
    if (lessonId.isEmpty || file.name.trim().isEmpty || file.size <= 0) {
      return const VideoUploadSubmission(VideoUploadAdmission.invalid,
          message: 'Select a valid video to upload.');
    }
    final existing = taskForLesson(lessonId);
    if (existing != null &&
        (existing.status == VideoUploadStatus.uploading ||
            existing.status == VideoUploadStatus.queued)) {
      return VideoUploadSubmission(VideoUploadAdmission.lessonConflict,
          task: existing,
          message: 'A video is already uploading for this lesson.');
    }
    if (activeCount < maxConcurrentUploads) {
      final task = _newTask(lessonId, lessonTitle, file);
      _start(task);
      return VideoUploadSubmission(VideoUploadAdmission.started, task: task);
    }
    if (queuedCount >= maxQueuedUploads ||
        pendingCount >= maxTotalPendingUploads) {
      return const VideoUploadSubmission(VideoUploadAdmission.queueFull,
          message:
              'Upload queue is full. Please wait for an upload to finish.');
    }
    final task = _newTask(lessonId, lessonTitle, file);
    task.status = VideoUploadStatus.queued;
    _queue.add(task);
    notifyListeners();
    return VideoUploadSubmission(VideoUploadAdmission.queued, task: task);
  }

  Future<VideoUploadSubmission> cancelAndReplace({
    required String lessonId,
    required String lessonTitle,
    required BrowserVideoFile file,
  }) async {
    final existing = taskForLesson(lessonId);
    if (existing != null) {
      await cancel(existing.taskId);
    }
    return submit(lessonId: lessonId, lessonTitle: lessonTitle, file: file);
  }

  Future<void> cancel(String taskId) async {
    final task = _byId(taskId);
    if (task == null ||
        (task.status != VideoUploadStatus.uploading &&
            task.status != VideoUploadStatus.queued)) {
      return;
    }
    if (task.status == VideoUploadStatus.queued) {
      _queue.remove(task);
    } else {
      var operation = _operations.remove(taskId);
      final starting = _starting[taskId];
      if (operation == null && starting != null) {
        try {
          operation = await starting.future;
        } catch (_) {
          // Startup failed before an XHR existed; the normal failure path has
          // no live operation to abort.
        }
      }
      operation?.cancel();
      if (operation != null) {
        await operation.terminated;
      }
    }
    task.status = VideoUploadStatus.cancelled;
    task.completedAt = _clock();
    task.file = null;
    _promote();
    notifyListeners();
  }

  VideoUploadSubmission retry(String taskId) {
    final task = _byId(taskId);
    if (task == null || task.status != VideoUploadStatus.failed) {
      return const VideoUploadSubmission(VideoUploadAdmission.invalid,
          message: 'This upload cannot be retried.');
    }
    // The old terminal task remains history; retry gets a fresh task identity.
    final file = task.file;
    if (file == null) {
      return const VideoUploadSubmission(VideoUploadAdmission.invalid,
          message: 'The original file is no longer available.');
    }
    return submit(
        lessonId: task.lessonId, lessonTitle: task.lessonTitle, file: file);
  }

  void _start(VideoUploadTask task) async {
    task.status = VideoUploadStatus.uploading;
    task.startedAt = _clock();
    task._lastProgressAt = task.startedAt;
    task._lastProgressBytes = 0;
    final starting = Completer<BrowserVideoUploadOperation>();
    _starting[task.taskId] = starting;
    notifyListeners();
    try {
      final file = task.file;
      if (file == null) {
        throw StateError('The selected video is unavailable.');
      }
      final operation = await _transport.start(task.lessonId, file,
          onProgress: (sent, total) {
        if (task.status != VideoUploadStatus.uploading) return;
        _updateProgress(task, sent, total);
      });
      if (!starting.isCompleted) {
        starting.complete(operation);
      }
      if (task.status != VideoUploadStatus.uploading) {
        operation.cancel();
        return;
      }
      _operations[task.taskId] = operation;
      await operation.response;
      if (task.status != VideoUploadStatus.uploading) return;
      task.status = VideoUploadStatus.completed;
      task.uploadedBytes = task.totalBytes;
      task.eta = Duration.zero;
      task.completedAt = _clock();
      task.file = null;
    } catch (error) {
      if (!starting.isCompleted) {
        // There is no XHR to cancel when startup itself fails. Complete the
        // handshake so a concurrent cancellation can release its slot.
        starting.complete(BrowserVideoUploadOperation(
            Future<BrowserVideoUploadResponse>.value(
                const BrowserVideoUploadResponse(0, '')),
            () {}));
      }
      if (task.status != VideoUploadStatus.uploading) return;
      task.status = VideoUploadStatus.failed;
      task.errorMessage = error.toString().replaceFirst('ApiException: ', '');
      task.completedAt = _clock();
    } finally {
      _starting.remove(task.taskId);
      _operations.remove(task.taskId);
      if (task.status == VideoUploadStatus.completed ||
          task.status == VideoUploadStatus.failed) {
        _promote();
      }
      notifyListeners();
    }
  }

  void _updateProgress(VideoUploadTask task, int sent, int total) {
    final now = _clock();
    task.uploadedBytes = sent.clamp(0, total);
    final previous = task._lastProgressAt;
    if (previous != null) {
      final elapsedMilliseconds = now.difference(previous).inMilliseconds;
      final delta = sent - task._lastProgressBytes;
      if (elapsedMilliseconds > 0 && delta >= 0) {
        task.currentSpeedBytesPerSecond = delta * 1000 / elapsedMilliseconds;
      }
    }
    final started = task.startedAt;
    if (started != null) {
      final elapsedMilliseconds = now.difference(started).inMilliseconds;
      if (elapsedMilliseconds > 0) {
        task.averageSpeedBytesPerSecond = sent * 1000 / elapsedMilliseconds;
      }
    }
    final speed = task.currentSpeedBytesPerSecond > 0
        ? task.currentSpeedBytesPerSecond
        : task.averageSpeedBytesPerSecond;
    task.eta = speed > 0
        ? Duration(
            milliseconds: ((task.totalBytes - sent) * 1000 / speed).round())
        : null;
    task._lastProgressAt = now;
    task._lastProgressBytes = sent;
    notifyListeners();
  }

  void _promote() {
    while (activeCount < maxConcurrentUploads && _queue.isNotEmpty) {
      _start(_queue.removeFirst());
    }
  }

  VideoUploadTask? _byId(String taskId) {
    for (final task in _tasks) {
      if (task.taskId == taskId) return task;
    }
    return null;
  }

  VideoUploadTask _newTask(
      String lessonId, String lessonTitle, BrowserVideoFile file) {
    final task = VideoUploadTask(
      taskId: 'video-upload-${_clock().microsecondsSinceEpoch}-${_nextTask++}',
      lessonId: lessonId,
      lessonTitle: lessonTitle,
      selectedFile: file,
      createdAt: _clock(),
    );
    _tasks.add(task);
    return task;
  }
}
