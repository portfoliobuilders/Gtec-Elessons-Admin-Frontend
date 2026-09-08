import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/video_upload_manager.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_buttons.dart';
import '../../core/widgets/app_card.dart';
import '../layouts/admin_shell.dart';
import '../widgets/curriculum/curriculum_header.dart';
import '../widgets/nav_presets.dart';
import '../widgets/shared_widgets.dart';

class UploadCenterScreen extends StatelessWidget {
  const UploadCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final manager = context.watch<VideoUploadManager>();
    return AdminShell(
      navItems: NavPresets.admin,
      activeIndex: 6,
      user: NavPresets.gtecAdmin,
      title: 'Uploads',
      body: PageBody(
        topPadding: 26,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          CurriculumHeader(
              title: 'Upload Center',
              subtitle:
                  '${manager.activeCount}/3 uploading · ${manager.queuedCount}/3 queued'),
          const SizedBox(height: 24),
          if (manager.tasks.isEmpty)
            const InfoBanner(
                text:
                    'No video uploads yet. Select a video from Add or Edit Lesson to begin.')
          else
            ...manager.tasks.reversed.map((task) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _UploadTaskCard(task: task),
                )),
        ]),
      ),
    );
  }
}

class _UploadTaskCard extends StatelessWidget {
  const _UploadTaskCard({required this.task});
  final VideoUploadTask task;

  @override
  Widget build(BuildContext context) {
    final manager = context.read<VideoUploadManager>();
    final active = task.status == VideoUploadStatus.uploading;
    final queued = task.status == VideoUploadStatus.queued;
    final failed = task.status == VideoUploadStatus.failed;
    final position = manager.queuePosition(task);
    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const AppIcon(AppIcons.upload, size: 20, color: AppColors.navy),
          const SizedBox(width: 10),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(task.lessonTitle, style: AppTextStyles.cell),
                const SizedBox(height: 3),
                Text(task.fileName,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.jakarta(
                        size: 11.5,
                        weight: FontWeight.w600,
                        color: AppColors.grey)),
              ])),
          _StatusLabel(status: task.status, queuePosition: position),
        ]),
        if (active) ...[
          const SizedBox(height: 16),
          LinearProgressIndicator(value: task.progress.clamp(0, 1)),
          const SizedBox(height: 8),
          Text(
              '${(task.progress * 100).round()}% · ${_bytes(task.uploadedBytes)} / ${_bytes(task.totalBytes)}'
              '${task.currentSpeedBytesPerSecond > 0 ? ' · ${_bytes(task.currentSpeedBytesPerSecond.round())}/s' : ''}'
              '${task.eta != null ? ' · ETA ${_eta(task.eta!)}' : ''}',
              style: AppTextStyles.jakarta(
                  size: 11.5, weight: FontWeight.w700, color: AppColors.muted)),
        ],
        if (failed && task.errorMessage != null) ...[
          const SizedBox(height: 10),
          Text(task.errorMessage!,
              style: AppTextStyles.jakarta(
                  size: 12, weight: FontWeight.w600, color: AppColors.red)),
        ],
        if (active || queued || failed) ...[
          const SizedBox(height: 14),
          Row(children: [
            if (failed)
              PrimaryButton(
                  label: 'Retry',
                  iconPaths: AppIcons.arrowRight,
                  height: 36,
                  fontSize: 12,
                  onTap: () {
                    final result = manager.retry(task.taskId);
                    if (!result.accepted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(result.message!)));
                    }
                  }),
            if (failed) const SizedBox(width: 10),
            OutlineButtonX(
                label: 'Cancel',
                iconPaths: AppIcons.close,
                height: 36,
                onTap: () {
                  manager.cancel(task.taskId);
                }),
          ]),
        ],
      ]),
    );
  }
}

class _StatusLabel extends StatelessWidget {
  const _StatusLabel({required this.status, this.queuePosition});
  final VideoUploadStatus status;
  final int? queuePosition;

  @override
  Widget build(BuildContext context) {
    final label = switch (status) {
      VideoUploadStatus.queued =>
        'Queued${queuePosition == null ? '' : ' #$queuePosition'}',
      VideoUploadStatus.uploading => 'Uploading',
      VideoUploadStatus.completed => 'Completed',
      VideoUploadStatus.failed => 'Failed',
      VideoUploadStatus.cancelled => 'Cancelled',
    };
    final color = switch (status) {
      VideoUploadStatus.completed => AppColors.green,
      VideoUploadStatus.failed => AppColors.red,
      VideoUploadStatus.cancelled => AppColors.grey,
      _ => AppColors.navy,
    };
    return Text(label,
        style: AppTextStyles.jakarta(
            size: 11.5, weight: FontWeight.w800, color: color));
  }
}

String _bytes(int bytes) {
  const units = ['B', 'KB', 'MB', 'GB'];
  var value = bytes.toDouble();
  var unit = 0;
  while (value >= 1024 && unit < units.length - 1) {
    value /= 1024;
    unit++;
  }
  return '${value.toStringAsFixed(unit == 0 ? 0 : 1)} ${units[unit]}';
}

String _eta(Duration value) {
  if (value.inHours > 0) return '${value.inHours}h ${(value.inMinutes % 60)}m';
  if (value.inMinutes > 0) {
    return '${value.inMinutes}m ${(value.inSeconds % 60)}s';
  }
  return '${value.inSeconds}s';
}
