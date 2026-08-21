import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_buttons.dart';

const List<String> _allowedExtensions = ['jpg', 'jpeg', 'png', 'webp'];
const int _maxBytes = 5 * 1024 * 1024;

/// Cover Image picker/preview/upload — shared by every Grade/Subject/
/// Chapter Add AND Edit screen. Two modes, picked by which callback is
/// provided (never both):
///
/// - **Edit mode** (`onUpload` set): the entity already has an id. Picking
///   a file stages a local preview with its own Upload/Cancel step; only
///   "Upload" actually calls [onUpload] (the real `POST .../photo`).
/// - **Create mode** (`onPendingImageSelected` set): the entity doesn't
///   exist yet, so there is nothing to upload to. Picking a file just
///   reports the bytes back to the parent form immediately (no confirm
///   step — "Replace Image" to pick again) via [onPendingImageSelected];
///   the parent holds the pending bytes ([pendingBytes]) and is
///   responsible for uploading them after the entity is actually created
///   and has a real id.
///
/// Either way, picking goes through `file_picker` (works on Flutter Web —
/// reads bytes directly, never assumes `dart:io File`) and the same
/// type/size validation.
class CoverImageUploader extends StatefulWidget {
  const CoverImageUploader({
    super.key,
    this.currentImageUrl,
    this.uploading = false,
    this.onUpload,
    this.onRemove,
    this.onPendingImageSelected,
    this.pendingBytes,
  }) : assert(
          (onUpload != null) != (onPendingImageSelected != null),
          'Provide exactly one of onUpload (edit mode) or onPendingImageSelected (create mode).',
        );

  /// Edit mode only — the currently-saved cover image URL, if any.
  final String? currentImageUrl;

  /// True while an edit-mode upload/remove request is in flight.
  final bool uploading;

  /// Edit mode — performs the real `POST .../photo` when the admin
  /// confirms a staged image.
  final Future<bool> Function(Uint8List bytes, String filename)? onUpload;

  /// Edit mode — performs the real `DELETE .../photo`.
  final Future<bool> Function()? onRemove;

  /// Create mode — reports a freshly-picked, already-validated image back
  /// to the parent form. No API call happens here.
  final void Function(Uint8List bytes, String filename)? onPendingImageSelected;

  /// Create mode — the parent-owned pending preview bytes.
  final Uint8List? pendingBytes;

  @override
  State<CoverImageUploader> createState() => _CoverImageUploaderState();
}

class _CoverImageUploaderState extends State<CoverImageUploader> {
  // Edit-mode-only local staging, ahead of its own Upload/Cancel confirm
  // step. Create mode never touches this — its pending bytes live in the
  // parent (widget.pendingBytes) instead, per the "don't put temporary
  // selected-file bytes in global state, keep them in the form" guidance.
  Uint8List? _pendingBytes;
  String? _pendingFilename;

  bool get _isCreateMode => widget.onPendingImageSelected != null;

  void _showMessage(String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

  /// Pinned to `file_picker: 11.0.3` — confirmed live (browser test, see
  /// Cover Image bug-fix report) that `file_picker: 12.0.0`'s brand-new
  /// federated web split (published days before this was written) throws
  /// an uncaught JS interop error the instant `FilePicker.pickFiles()` is
  /// called in a release/optimized web build — the native picker never
  /// opens. 11.0.3 has the same static-method `FilePicker.pickFiles()`
  /// call shape but predates that split; verified working in both debug
  /// and release web builds. Its `PlatformFile` exposes bytes/size/
  /// extension synchronously (`.bytes`/`.size`/`.extension`), not via the
  /// async `readAsBytes()`/`length()` 12.x introduced — do not "upgrade"
  /// this without re-verifying a release web build actually opens the
  /// picker, not just that `flutter build web` succeeds.
  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles(type: FileType.custom, allowedExtensions: _allowedExtensions, withData: true);
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;

    final ext = (file.extension ?? '').toLowerCase();
    if (!_allowedExtensions.contains(ext)) {
      _showMessage('Please select a JPG, PNG, or WEBP image under 5 MB.');
      return;
    }
    if (file.size > _maxBytes) {
      _showMessage('Please select a JPG, PNG, or WEBP image under 5 MB.');
      return;
    }
    final bytes = file.bytes;
    if (bytes == null) {
      _showMessage('Could not read that file. Please try again.');
      return;
    }

    if (_isCreateMode) {
      widget.onPendingImageSelected!(bytes, file.name);
      return;
    }

    setState(() {
      _pendingBytes = bytes;
      _pendingFilename = file.name;
    });
  }

  void _cancelPending() => setState(() {
        _pendingBytes = null;
        _pendingFilename = null;
      });

  Future<void> _confirmUpload() async {
    final bytes = _pendingBytes;
    final filename = _pendingFilename;
    if (bytes == null || filename == null || widget.uploading) return;

    final ok = await widget.onUpload!(bytes, filename);
    if (!mounted) return;
    if (ok) {
      setState(() {
        _pendingBytes = null;
        _pendingFilename = null;
      });
      _showMessage('Cover image updated successfully.');
    }
    // On failure the caller's error is surfaced by the screen (via its own
    // error field) — the pending preview stays so the selection isn't lost.
  }

  Future<void> _remove() async {
    if (widget.onRemove == null || widget.uploading) return;
    final ok = await widget.onRemove!();
    if (!mounted) return;
    _showMessage(ok ? 'Cover image removed.' : 'Unable to remove the cover image.');
  }

  @override
  Widget build(BuildContext context) {
    final previewBytes = _isCreateMode ? widget.pendingBytes : _pendingBytes;
    final hasPending = previewBytes != null;
    final hasCurrent = !_isCreateMode && widget.currentImageUrl != null && widget.currentImageUrl!.isNotEmpty;
    final showConfirmStep = !_isCreateMode && hasPending;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: double.infinity,
            height: 160,
            color: AppColors.inputBg,
            child: hasPending
                ? Image.memory(previewBytes, fit: BoxFit.cover)
                : (hasCurrent
                    ? Image.network(
                        widget.currentImageUrl!,
                        fit: BoxFit.cover,
                        headers: _ngrokHeadersFor(widget.currentImageUrl!),
                        errorBuilder: (context, error, stackTrace) => const _EmptyState(broken: true),
                        loadingBuilder: (context, child, progress) => progress == null
                            ? child
                            : const Center(
                                child: SizedBox(
                                    width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.2))),
                      )
                    : const _EmptyState()),
          ),
        ),
        const SizedBox(height: 12),
        if (showConfirmStep)
          Row(
            children: [
              PrimaryButton(
                label: widget.uploading ? 'Uploading…' : 'Upload',
                iconPaths: AppIcons.check,
                onTap: widget.uploading ? () {} : _confirmUpload,
              ),
              const SizedBox(width: 10),
              OutlineButtonX(label: 'Cancel', onTap: widget.uploading ? () {} : _cancelPending),
            ],
          )
        else
          Row(
            children: [
              OutlineButtonX(
                label: (hasCurrent || hasPending) ? 'Replace Image' : 'Upload Image',
                iconPaths: AppIcons.upload,
                onTap: widget.uploading ? () {} : _pickFile,
              ),
              if (!_isCreateMode && hasCurrent && widget.onRemove != null) ...[
                const SizedBox(width: 10),
                OutlineButtonX(label: 'Remove', color: AppColors.red, onTap: widget.uploading ? () {} : _remove),
              ],
            ],
          ),
        const SizedBox(height: 6),
        Text('JPG, PNG, or WEBP — up to 5 MB.',
            style: AppTextStyles.jakarta(size: 11.5, weight: FontWeight.w600, color: AppColors.grey)),
      ],
    );
  }
}

/// Small read-only thumbnail for the Grade/Subject/Chapter Detail screens —
/// shown only when `iconUrl` is actually set (never a placeholder for a
/// null image, per the "do not fabricate an image" instruction). Editing
/// happens on the Edit screen via [CoverImageUploader], not here.
class CoverThumbnail extends StatelessWidget {
  const CoverThumbnail({super.key, required this.imageUrl, this.size = 56});

  final String imageUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        imageUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        headers: _ngrokHeadersFor(imageUrl),
        errorBuilder: (context, error, stackTrace) => Container(
          width: size,
          height: size,
          color: AppColors.inputBg,
          child: const Center(child: AppIcon(AppIcons.fileCorner, size: 18, color: AppColors.softGrey, strokeWidth: 1.6)),
        ),
      ),
    );
  }
}

/// Free ngrok tunnels serve an HTML "you are about to visit…" interstitial
/// to any request that looks like it came from a browser — including the
/// `Image.network` requests Flutter Web makes to fetch a cover image, which
/// otherwise silently renders as a broken/failed image instead of the real
/// photo. Only applied when the URL is actually on an ngrok host, so this
/// is a no-op against the production image host. Mirrors the same header
/// `ApiClient` already sends on every JSON/multipart request.
Map<String, String>? _ngrokHeadersFor(String url) =>
    url.contains('ngrok-free.dev') ? const {'ngrok-skip-browser-warning': 'true'} : null;

class _EmptyState extends StatelessWidget {
  const _EmptyState({this.broken = false});

  final bool broken;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppIcon(AppIcons.fileCorner, size: 26, color: AppColors.softGrey, strokeWidth: 1.6),
          const SizedBox(height: 8),
          Text(
            broken ? 'Image unavailable' : 'No cover image',
            style: AppTextStyles.jakarta(size: 12.5, weight: FontWeight.w700, color: AppColors.grey),
          ),
        ],
      ),
    );
  }
}
