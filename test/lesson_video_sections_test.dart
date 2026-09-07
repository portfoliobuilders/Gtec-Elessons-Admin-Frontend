import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gtec_admin/models/admin/curriculum_models.dart';
import 'package:gtec_admin/views/widgets/curriculum/lesson_video_player.dart';
import 'package:gtec_admin/views/widgets/curriculum/lesson_video_sections.dart';

AdminLessonModel lesson(
        {bool upload = false,
        bool youtube = false,
        bool offline = true,
        String? url,
        String? source,
        String? filename}) =>
    AdminLessonModel(
      id: 'lesson',
      title: 'Lesson',
      chapterId: 'chapter',
      videoSourceType: source,
      videoUrl: upload ? '/uploads/lesson.mp4' : null,
      videoFileName: filename ?? (upload ? 'lesson.mp4' : null),
      videoMimeType: upload ? 'video/mp4' : null,
      videoSizeBytes: upload ? 448790528 : null,
      youtubeId: youtube ? 'xvT1jH8B9AM' : null,
      youtubeUrl: url,
      allowOffline: offline,
    );

Future<void> showVideos(WidgetTester tester, AdminLessonModel model, {double width = 1000}) async {
  tester.view.physicalSize = Size(width, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester
      .pumpWidget(MaterialApp(home: Scaffold(body: SingleChildScrollView(child: LessonVideoSections(lesson: model)))));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  for (final upload in [true, false]) {
    for (final youtube in [true, false]) {
      testWidgets('independent sources upload=$upload youtube=$youtube', (tester) async {
        await showVideos(tester, lesson(upload: upload, youtube: youtube, source: 'YOUTUBE'));
        expect(find.text('Uploaded Video'), findsNWidgets(2));
        expect(find.text('YouTube Video'), findsOneWidget);
        expect(find.byType(LessonVideoPlayer), upload ? findsOneWidget : findsNothing);
        expect(find.byKey(const ValueKey('youtube-preview')), youtube ? findsOneWidget : findsNothing);
        expect(find.text('No uploaded video'), upload ? findsNothing : findsOneWidget);
        expect(find.text('No YouTube video'), youtube ? findsNothing : findsOneWidget);
        expect(find.text('Offline Download'), upload ? findsOneWidget : findsNothing);
        final uploaded = find.byKey(const ValueKey('uploaded-video-section'));
        final yt = find.byKey(const ValueKey('youtube-video-section'));
        expect(tester.getTopLeft(yt).dy, greaterThan(tester.getBottomLeft(uploaded).dy));
        expect(tester.takeException(), isNull);
      });
    }
  }

  for (final offline in [true, false]) {
    testWidgets('uploaded offline display $offline', (tester) async {
      await showVideos(tester, lesson(upload: true, youtube: true, offline: offline));
      final uploaded = find.byKey(const ValueKey('uploaded-video-section'));
      final yt = find.byKey(const ValueKey('youtube-video-section'));
      expect(find.descendant(of: uploaded, matching: find.text('Offline Download')), findsOneWidget);
      expect(find.descendant(of: uploaded, matching: find.text(offline ? 'Allowed' : 'Disabled')), findsOneWidget);
      expect(find.descendant(of: yt, matching: find.text('Offline Download')), findsNothing);
      expect(find.text('428.00 MB'), findsOneWidget);
      expect(find.text('video/mp4'), findsOneWidget);
    });
  }

  testWidgets('URL-only YouTube uses actual returned URL and thumbnail id', (tester) async {
    const url = 'https://www.youtube.com/watch?v=xvT1jH8B9AM&feature=shared';
    await showVideos(tester, lesson(url: url));
    expect(find.text(url), findsOneWidget);
    expect(find.text('Connected'), findsOneWidget);
    expect(find.text('Offline Download'), findsNothing);
    final image = tester.widget<Image>(find.byType(Image));
    expect((image.image as NetworkImage).url, 'https://img.youtube.com/vi/xvT1jH8B9AM/hqdefault.jpg');
  });

  testWidgets('source type and metadata cannot manufacture a missing video', (tester) async {
    await showVideos(tester, lesson(source: 'UPLOAD', filename: 'old.mp4'));
    expect(find.byType(LessonVideoPlayer), findsNothing);
    expect(find.text('No uploaded video'), findsOneWidget);
    expect(find.text('Not Available'), findsNWidgets(2));
  });

  for (final width in [360.0, 800.0, 1200.0]) {
    testWidgets('responsive sections at $width with long metadata', (tester) async {
      final filename = '${List.filled(12, 'long-filename').join()} .mp4';
      final url = 'https://youtu.be/xvT1jH8B9AM?tracking=${List.filled(20, 'abc').join()}';
      await showVideos(tester, lesson(upload: true, youtube: true, filename: filename, url: url), width: width);
      for (final key in ['uploaded-video-section', 'youtube-video-section']) {
        final section = find.byKey(ValueKey(key));
        final details = find.descendant(of: section, matching: find.text('VIDEO DETAILS'));
        final preview = find.descendant(of: section, matching: find.byType(AspectRatio));
        if (width < 720) {
          expect(tester.getTopLeft(details).dy, greaterThan(tester.getBottomLeft(preview).dy));
          expect(tester.getSize(preview).width, width);
        } else {
          expect(tester.getTopLeft(details).dx, greaterThan(tester.getTopRight(preview).dx));
        }
      }
      expect(tester.takeException(), isNull);
    });
  }
}
