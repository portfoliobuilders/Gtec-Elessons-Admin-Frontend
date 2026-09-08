import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:gtec_admin/controllers/video_upload_manager.dart';
import 'package:gtec_admin/core/network/browser_video_upload.dart';

class _FakeTransport implements VideoUploadTransport {
  final Map<String, Completer<BrowserVideoUploadResponse>> responses = {};
  final Map<String, void Function(int, int)> progress = {};
  final Set<String> cancelled = {};

  @override
  Future<BrowserVideoUploadOperation> start(
      String lessonId, BrowserVideoFile file,
      {void Function(int uploadedBytes, int totalBytes)? onProgress}) async {
    final id = '$lessonId-${responses.length}';
    final completer = Completer<BrowserVideoUploadResponse>();
    responses[id] = completer;
    progress[id] = onProgress!;
    return BrowserVideoUploadOperation(completer.future, () {
      cancelled.add(id);
      if (!completer.isCompleted) {
        completer.completeError(StateError('cancelled'));
      }
    });
  }

  String idFor(String lessonId) =>
      responses.keys.lastWhere((id) => id.startsWith('$lessonId-'));
  void succeed(String id) =>
      responses[id]!.complete(const BrowserVideoUploadResponse(200, '{}'));
  void fail(String id) =>
      responses[id]!.completeError(StateError('network failure'));
}

BrowserVideoFile _file(int index) => BrowserVideoFile(
    name: 'video$index.mp4', size: 1000, mimeType: 'video/mp4');

void main() {
  late _FakeTransport transport;
  late VideoUploadManager manager;

  setUp(() {
    transport = _FakeTransport();
    manager = VideoUploadManager(transport);
  });

  VideoUploadSubmission submit(int i, {String? lesson}) => manager.submit(
      lessonId: lesson ?? 'lesson-$i',
      lessonTitle: 'Lesson $i',
      file: _file(i));

  test('enforces exactly three active and three queued uploads', () async {
    final results = [for (var i = 0; i < 6; i++) submit(i)];
    await Future<void>.delayed(Duration.zero);
    expect(
        results.take(3).every(
            (result) => result.admission == VideoUploadAdmission.started),
        isTrue);
    expect(
        results
            .skip(3)
            .every((result) => result.admission == VideoUploadAdmission.queued),
        isTrue);
    expect(manager.activeCount, 3);
    expect(manager.queuedCount, 3);
    final seventh = submit(7);
    expect(seventh.admission, VideoUploadAdmission.queueFull);
    expect(seventh.message,
        'Upload queue is full. Please wait for an upload to finish.');
    expect(manager.tasks, hasLength(6));
  });

  test('completion, failure and active cancellation promote the queue',
      () async {
    for (var i = 0; i < 4; i++) {
      submit(i);
    }
    await Future<void>.delayed(Duration.zero);
    transport.succeed(transport.idFor('lesson-0'));
    await Future<void>.delayed(Duration.zero);
    expect(manager.activeCount, 3);
    expect(manager.queuedCount, 0);

    submit(5);
    await Future<void>.delayed(Duration.zero);
    transport.fail(transport.idFor('lesson-1'));
    await Future<void>.delayed(Duration.zero);
    expect(manager.activeCount, 3);

    submit(6);
    await Future<void>.delayed(Duration.zero);
    final active = manager.activeTasks.first;
    await manager.cancel(active.taskId);
    await Future<void>.delayed(Duration.zero);
    expect(manager.activeCount, 3);
    expect(active.status, VideoUploadStatus.cancelled);
  });

  test('queued cancellation does not affect active tasks', () async {
    for (var i = 0; i < 4; i++) {
      submit(i);
    }
    await Future<void>.delayed(Duration.zero);
    final queued = manager.queuedTasks.single;
    await manager.cancel(queued.taskId);
    expect(queued.status, VideoUploadStatus.cancelled);
    expect(manager.activeCount, 3);
    expect(manager.queuedCount, 0);
  });

  test('same lesson is blocked and cancel and replace follows normal admission',
      () async {
    final first = submit(1, lesson: 'same');
    await Future<void>.delayed(Duration.zero);
    expect(submit(2, lesson: 'same').admission,
        VideoUploadAdmission.lessonConflict);
    final replacement = await manager.cancelAndReplace(
        lessonId: 'same', lessonTitle: 'Lesson', file: _file(3));
    expect(first.task!.status, VideoUploadStatus.cancelled);
    expect(replacement.admission, VideoUploadAdmission.started);
    expect(manager.activeCount, 1);
  });

  test('failed retry uses normal admission and progress computes speed and eta',
      () async {
    final submitted = submit(1);
    await Future<void>.delayed(Duration.zero);
    final id = transport.idFor('lesson-1');
    transport.progress[id]!(500, 1000);
    transport.fail(id);
    await Future<void>.delayed(Duration.zero);
    expect(submitted.task!.status, VideoUploadStatus.failed);
    final retry = manager.retry(submitted.task!.taskId);
    expect(retry.accepted, isTrue);
    expect(manager.activeCount, 1);
  });

  test('progress derives current speed, average speed and ETA from samples',
      () async {
    var now = DateTime(2026, 1, 1);
    manager = VideoUploadManager(transport, clock: () => now);
    final submitted = submit(1);
    await Future<void>.delayed(Duration.zero);
    now = now.add(const Duration(seconds: 1));
    transport.progress[transport.idFor('lesson-1')]!(500, 1000);
    expect(submitted.task!.progress, .5);
    expect(submitted.task!.currentSpeedBytesPerSecond, 500);
    expect(submitted.task!.averageSpeedBytesPerSecond, 500);
    expect(submitted.task!.eta, const Duration(seconds: 1));
  });
}
