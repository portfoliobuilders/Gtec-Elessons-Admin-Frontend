import 'package:flutter/material.dart';

import '../../../core/config/api_config.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_card.dart';
import '../../../models/admin/curriculum_models.dart';
import 'curriculum_form_card.dart';
import 'lesson_video_player.dart';

/// Display stored sources independently; videoSourceType remains the backend's
/// effective playback choice and does not determine which sections are shown.
class LessonVideoSections extends StatelessWidget {
  const LessonVideoSections({super.key, required this.lesson});

  final AdminLessonModel lesson;

  @override
  Widget build(BuildContext context) {
    final uploadedUrl = lesson.videoUrl?.trim() ?? '';
    final hasUpload = uploadedUrl.isNotEmpty;
    final youtubeId = _youtubePreviewId(lesson);
    final youtubeUrl = lesson.youtubeUrl?.trim();
    final hasYoutube = youtubeId != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _VideoSection(
          key: const ValueKey('uploaded-video-section'),
          title: 'Uploaded Video',
          preview: hasUpload
              ? _PreviewCard(
                  child:
                      LessonVideoPlayer(key: ValueKey(uploadedUrl), videoUrl: _absoluteUploadedVideoUrl(uploadedUrl)))
              : const CurriculumEmptyState(
                  icon: AppIcons.play, title: 'No uploaded video', message: 'No local video has been added.'),
          details: [
            const _VideoDetail(label: 'Source', value: 'Uploaded Video'),
            if (!hasUpload)
              const _VideoDetail(label: 'Status', value: 'Not Available')
            else ...[
              if (lesson.videoFileName?.trim().isNotEmpty ?? false)
                _VideoDetail(label: 'File', value: lesson.videoFileName!),
              if (lesson.videoSizeBytes != null)
                _VideoDetail(label: 'Size', value: _formatVideoSize(lesson.videoSizeBytes!)),
              if (lesson.videoMimeType?.trim().isNotEmpty ?? false)
                _VideoDetail(label: 'Type', value: lesson.videoMimeType!),
              _VideoDetail(
                  label: 'Offline Download',
                  value: lesson.allowOffline ? 'Allowed' : 'Disabled',
                  valueColor: lesson.allowOffline ? AppColors.green : AppColors.grey),
            ],
          ],
        ),
        const SizedBox(height: 24),
        _VideoSection(
          key: const ValueKey('youtube-video-section'),
          title: 'YouTube Video',
          preview: hasYoutube
              ? _PreviewCard(
                  child: Stack(
                  key: const ValueKey('youtube-preview'),
                  fit: StackFit.expand,
                  children: [
                    Image.network('https://img.youtube.com/vi/$youtubeId/hqdefault.jpg',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Center(
                            child: Text('YouTube preview unavailable',
                                style: AppTextStyles.jakarta(color: AppColors.white)))),
                    Container(color: Colors.black.withValues(alpha: 0.18)),
                    Center(
                        child: Container(
                            width: 56,
                            height: 56,
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            child: const Center(
                                child: AppIcon(AppIcons.play, size: 24, color: AppColors.navy, strokeWidth: 1.8)))),
                  ],
                ))
              : const CurriculumEmptyState(
                  icon: AppIcons.play, title: 'No YouTube video', message: 'No YouTube URL has been added.'),
          details: [
            const _VideoDetail(label: 'Source', value: 'YouTube'),
            if (hasYoutube && youtubeUrl != null && youtubeUrl.isNotEmpty)
              _VideoDetail(label: 'URL', value: youtubeUrl),
            _VideoDetail(
                label: 'Status',
                value: hasYoutube ? 'Connected' : 'Not Available',
                valueColor: hasYoutube ? AppColors.green : AppColors.grey),
          ],
        ),
      ],
    );
  }
}

// The existing preview is a thumbnail keyed by video id. Read the same id
// from a returned YouTube URL when the response omits youtubeId.
String? _youtubePreviewId(AdminLessonModel lesson) {
  final id = lesson.youtubeId?.trim();
  final validId = RegExp(r'^[a-zA-Z0-9_-]{11}$');
  if (id != null && validId.hasMatch(id)) return id;
  final uri = Uri.tryParse(lesson.youtubeUrl?.trim() ?? '');
  if (uri == null || !const ['https', 'http'].contains(uri.scheme)) return null;
  final host = uri.host.toLowerCase();
  String? candidate;
  if (host == 'youtu.be') {
    candidate = uri.pathSegments.firstOrNull;
  } else if (host == 'youtube.com' ||
      host.endsWith('.youtube.com') ||
      host == 'youtube-nocookie.com' ||
      host.endsWith('.youtube-nocookie.com')) {
    candidate = uri.queryParameters['v'];
    if (candidate == null &&
        uri.pathSegments.length >= 2 &&
        const ['embed', 'shorts', 'live'].contains(uri.pathSegments.first)) {
      candidate = uri.pathSegments[1];
    }
  }
  return candidate != null && validId.hasMatch(candidate) ? candidate : null;
}

String _absoluteUploadedVideoUrl(String videoUrl) {
  final videoUri = Uri.tryParse(videoUrl);
  if (videoUri != null && videoUri.hasScheme && videoUri.hasAuthority) return videoUrl;
  final apiUri = Uri.parse(ApiConfig.baseUrl);
  if (videoUrl.startsWith('//')) return '${apiUri.scheme}:$videoUrl';
  final origin = '${apiUri.scheme}://${apiUri.authority}';
  return '$origin${videoUrl.startsWith('/') ? videoUrl : '/$videoUrl'}';
}

String _formatVideoSize(int bytes) {
  const units = ['B', 'KB', 'MB', 'GB', 'TB'];
  var size = bytes.toDouble();
  var unit = 0;
  while (size >= 1024 && unit < units.length - 1) {
    size /= 1024;
    unit++;
  }
  return unit == 0 ? '${size.toStringAsFixed(0)} ${units[unit]}' : '${size.toStringAsFixed(2)} ${units[unit]}';
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => AppCard(
      padding: EdgeInsets.zero,
      clip: true,
      child: AspectRatio(aspectRatio: 16 / 9, child: ColoredBox(color: AppColors.sidebarBg, child: child)));
}

class _VideoSection extends StatelessWidget {
  const _VideoSection({super.key, required this.title, required this.preview, required this.details});
  final String title;
  final Widget preview;
  final List<Widget> details;

  @override
  Widget build(BuildContext context) {
    final info = AppCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('VIDEO DETAILS', style: AppTextStyles.eyebrow),
      const SizedBox(height: 14),
      for (var i = 0; i < details.length; i++) ...[
        if (i != 0) const SizedBox(height: 12),
        details[i],
      ],
    ]));
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text(title, style: AppTextStyles.eyebrow),
      const SizedBox(height: 14),
      LayoutBuilder(builder: (context, constraints) {
        // Use the app's phone breakpoint against available space, including
        // when the desktop sidebar leaves a narrow content column.
        if (constraints.maxWidth < AppSizes.phone) {
          return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch, children: [preview, const SizedBox(height: 20), info]);
        }
        return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(flex: 62, child: preview),
          const SizedBox(width: 20),
          Expanded(flex: 38, child: info),
        ]);
      }),
    ]);
  }
}

class _VideoDetail extends StatelessWidget {
  const _VideoDetail({required this.label, required this.value, this.valueColor});
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Flexible(
            flex: 4,
            child:
                Text(label, style: AppTextStyles.jakarta(size: 12.5, weight: FontWeight.w600, color: AppColors.muted))),
        const SizedBox(width: 12),
        Expanded(
            flex: 6,
            child: Text(value,
                textAlign: TextAlign.right,
                style: AppTextStyles.jakarta(size: 13, weight: FontWeight.w800, color: valueColor ?? AppColors.ink))),
      ]);
}
