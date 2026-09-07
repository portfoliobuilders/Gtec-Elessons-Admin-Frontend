import 'package:flutter/material.dart';

/// The Admin lesson-detail video preview is a browser feature. Native builds
/// retain an in-place unavailable state instead of buffering a large video in
/// Dart memory.
class LessonVideoPlayer extends StatelessWidget {
  const LessonVideoPlayer({super.key, required this.videoUrl});

  final String videoUrl;

  @override
  Widget build(BuildContext context) => const Center(
        child: Text('Video preview is available in the Admin Web app.'),
      );
}
