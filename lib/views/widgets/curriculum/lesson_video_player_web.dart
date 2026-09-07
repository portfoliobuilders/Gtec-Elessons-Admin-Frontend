import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Native HTML5 video playback for an uploaded lesson video. The browser
/// streams the URL directly; no video bytes enter Dart memory.
class LessonVideoPlayer extends StatefulWidget {
  const LessonVideoPlayer({super.key, required this.videoUrl});

  final String videoUrl;

  @override
  State<LessonVideoPlayer> createState() => _LessonVideoPlayerState();
}

class _LessonVideoPlayerState extends State<LessonVideoPlayer> {
  static var _nextViewId = 0;
  late final String _viewType;
  var _failedToLoad = false;

  @override
  void initState() {
    super.initState();
    _viewType = 'lesson-uploaded-video-${_nextViewId++}';
    ui_web.platformViewRegistry.registerViewFactory(_viewType, (viewId) {
      final video = html.VideoElement()
        ..src = widget.videoUrl
        ..controls = true
        ..autoplay = false
        ..loop = false
        ..muted = false
        ..preload = 'metadata'
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.objectFit = 'contain'
        ..style.backgroundColor = '#0E1C36';
      video.setAttribute('playsinline', 'true');
      video.onError.listen((_) {
        if (mounted) setState(() => _failedToLoad = true);
      });
      return video;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_failedToLoad) {
      return Center(
        child: Text(
          'Uploaded video could not be loaded.',
          style: AppTextStyles.jakarta(size: 12.5, weight: FontWeight.w700, color: AppColors.white.withValues(alpha: 0.7)),
        ),
      );
    }
    return HtmlElementView(viewType: _viewType);
  }
}
