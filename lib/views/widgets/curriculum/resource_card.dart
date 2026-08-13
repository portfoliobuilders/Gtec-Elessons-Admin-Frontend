import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_card.dart';
import '../../../models/admin/admin_models.dart';
import 'curriculum_tints.dart';

/// Backend enum `ResourceType` (`NOTE`/`PYQ`/`RESOURCE`) → the label the
/// design shows. Falls back to the raw value if the backend ever adds a
/// type this build doesn't know about yet.
String resourceTypeLabel(String type) => switch (type) {
      'NOTE' => 'Note',
      'PYQ' => 'PYQ',
      'RESOURCE' => 'Resource',
      _ => type,
    };

/// `1536` → `1.5 KB`, `null` stays null — a resource with no known size is
/// not the same fact as a zero-byte file.
String? formatResourceSize(int? bytes) {
  if (bytes == null) return null;
  if (bytes < 1024) return '$bytes B';
  final kb = bytes / 1024;
  if (kb < 1024) return '${kb.toStringAsFixed(1)} KB';
  final mb = kb / 1024;
  return '${mb.toStringAsFixed(1)} MB';
}

/// Compact horizontal card for one lesson resource — icon tile, title, type
/// + page count + size + downloadable status (only fields that are actually
/// present), download count when non-zero, and a delete button. Mirrors
/// [LessonCard]'s visual language one level down the hierarchy.
class ResourceCard extends StatelessWidget {
  const ResourceCard({super.key, required this.resource, required this.tintIndex, this.onDelete});

  final AdminResourceModel resource;
  final int tintIndex;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final tint = tintForIndex(tintIndex);
    final size = formatResourceSize(resource.sizeBytes);

    return AppCard(
      padding: const EdgeInsets.fromLTRB(18, 14, 14, 14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: tint.bg, borderRadius: BorderRadius.circular(12)),
            child: Center(child: AppIcon(AppIcons.fileCorner, size: 18, color: tint.accent, strokeWidth: 1.8)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(resource.title,
                    style: AppTextStyles.jakarta(size: 14.5, weight: FontWeight.w800, color: AppColors.ink)),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 10,
                  children: [
                    Text(resourceTypeLabel(resource.type),
                        style: AppTextStyles.jakarta(size: 12, weight: FontWeight.w600, color: AppColors.grey)),
                    if (resource.pageCount != null)
                      Text('${resource.pageCount} pages',
                          style: AppTextStyles.jakarta(size: 12, weight: FontWeight.w600, color: AppColors.grey)),
                    if (size != null)
                      Text(size, style: AppTextStyles.jakarta(size: 12, weight: FontWeight.w600, color: AppColors.grey)),
                    if (resource.downloadCount > 0)
                      Text('${resource.downloadCount} downloads',
                          style: AppTextStyles.jakarta(size: 12, weight: FontWeight.w600, color: AppColors.grey)),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: resource.isDownloadable ? AppColors.greenBg : AppColors.hairline,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              resource.isDownloadable ? 'Downloadable' : 'View only',
              style: AppTextStyles.jakarta(
                size: 11,
                weight: FontWeight.w700,
                color: resource.isDownloadable ? AppColors.green : AppColors.grey,
              ),
            ),
          ),
          if (onDelete != null) ...[
            const SizedBox(width: 12),
            GestureDetector(
              onTap: onDelete,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(color: AppColors.red.withValues(alpha: 0.08), shape: BoxShape.circle),
                  child: const Center(child: AppIcon(AppIcons.trash, size: 15, color: AppColors.red, strokeWidth: 1.9)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Vertical stack of [ResourceCard]s.
class ResourceList extends StatelessWidget {
  const ResourceList({super.key, required this.resources, this.onDeleteResource});

  final List<AdminResourceModel> resources;
  final ValueChanged<AdminResourceModel>? onDeleteResource;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < resources.length; i++)
          Padding(
            padding: EdgeInsets.only(bottom: i == resources.length - 1 ? 0 : 12),
            child: ResourceCard(
              resource: resources[i],
              tintIndex: i,
              onDelete: onDeleteResource == null ? null : () => onDeleteResource!(resources[i]),
            ),
          ),
      ],
    );
  }
}
