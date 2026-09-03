// Request bodies for AdminCurriculumService — mirrors curriculum.dto.ts
// exactly. `toJson()` omits unset optional fields entirely (not `null`) so
// partial updates don't accidentally clear fields the caller didn't touch —
// the backend's ValidationPipe also runs `forbidNonWhitelisted`, so only
// these exact keys may ever be sent.

import 'pricing_requests.dart';

/// Optional inline pricing block accepted by the grade/subject/chapter
/// CREATE requests — the only way to set a price (there's no standalone
/// "create price" endpoint; see AdminPricingService).
class CreateInlinePriceRequest {
  const CreateInlinePriceRequest({
    required this.amountCents,
    required this.region,
    required this.currency,
    this.format,
    this.accessDays,
  });

  final int amountCents;
  final String region;
  final String currency;

  /// Backend enum `ProductFormat`: RECORDED | LIVE_AND_RECORDED.
  final String? format;
  final int? accessDays;

  Map<String, dynamic> toJson() => {
        'amountCents': amountCents,
        'region': region,
        'currency': currency,
        if (format != null) 'format': format,
        if (accessDays != null) 'accessDays': accessDays,
      };
}

class CreateGradeRequest {
  const CreateGradeRequest({
    required this.name,
    this.board,
    this.syllabus,
    this.description,
    this.trailerYoutubeId,
    this.thumbnailUrl,
    this.order,
    this.price,
    this.prices,
  });

  final String name;
  final String? board;
  final String? syllabus;
  final String? description;
  final String? trailerYoutubeId;
  final String? thumbnailUrl;
  final int? order;
  final CreateInlinePriceRequest? price;

  /// Regional prices — confirmed live to create the Product and every
  /// ProductPrice row in the same call as the grade itself.
  final List<CreatePriceRequest>? prices;

  Map<String, dynamic> toJson() => {
        'name': name,
        if (board != null) 'board': board,
        if (syllabus != null) 'syllabus': syllabus,
        if (description != null) 'description': description,
        if (trailerYoutubeId != null) 'trailerYoutubeId': trailerYoutubeId,
        if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
        if (order != null) 'order': order,
        if (price != null) 'price': price!.toJson(),
        if (prices != null) 'prices': prices!.map((p) => p.toJson()).toList(),
      };
}

class UpdateGradeRequest {
  const UpdateGradeRequest({
    this.name,
    this.board,
    this.syllabus,
    this.description,
    this.trailerYoutubeId,
    this.thumbnailUrl,
    this.order,
    this.isActive,
  });

  final String? name;
  final String? board;
  final String? syllabus;
  final String? description;
  final String? trailerYoutubeId;
  final String? thumbnailUrl;
  final int? order;
  final bool? isActive;

  Map<String, dynamic> toJson() => {
        if (name != null) 'name': name,
        if (board != null) 'board': board,
        if (syllabus != null) 'syllabus': syllabus,
        if (description != null) 'description': description,
        if (trailerYoutubeId != null) 'trailerYoutubeId': trailerYoutubeId,
        if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
        if (order != null) 'order': order,
        if (isActive != null) 'isActive': isActive,
      };
}

/// `teacherId`/`teacherName` are deliberately absent — the backend derives
/// them server-side from the caller's JWT (TEACHER → self, ADMIN → null).
class CreateSubjectRequest {
  const CreateSubjectRequest({
    required this.name,
    this.code,
    this.description,
    this.trailerYoutubeId,
    this.thumbnailUrl,
    this.order,
    this.iconUrl,
    this.price,
    this.prices,
  });

  final String name;
  final String? code;
  final String? description;
  final String? trailerYoutubeId;
  final String? thumbnailUrl;
  final int? order;
  final String? iconUrl;
  final CreateInlinePriceRequest? price;

  /// Regional prices — a Subject's Product/prices are independent of its
  /// Grade's; never copied automatically.
  final List<CreatePriceRequest>? prices;

  Map<String, dynamic> toJson() => {
        'name': name,
        if (code != null) 'code': code,
        if (description != null) 'description': description,
        if (trailerYoutubeId != null) 'trailerYoutubeId': trailerYoutubeId,
        if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
        if (order != null) 'order': order,
        if (iconUrl != null) 'iconUrl': iconUrl,
        if (price != null) 'price': price!.toJson(),
        if (prices != null) 'prices': prices!.map((p) => p.toJson()).toList(),
      };
}

class UpdateSubjectRequest {
  const UpdateSubjectRequest({
    this.name,
    this.code,
    this.description,
    this.trailerYoutubeId,
    this.thumbnailUrl,
    this.order,
    this.iconUrl,
  });

  final String? name;
  final String? code;
  final String? description;
  final String? trailerYoutubeId;
  final String? thumbnailUrl;
  final int? order;
  final String? iconUrl;

  Map<String, dynamic> toJson() => {
        if (name != null) 'name': name,
        if (code != null) 'code': code,
        if (description != null) 'description': description,
        if (trailerYoutubeId != null) 'trailerYoutubeId': trailerYoutubeId,
        if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
        if (order != null) 'order': order,
        if (iconUrl != null) 'iconUrl': iconUrl,
      };
}

class CreateChapterRequest {
  const CreateChapterRequest({
    required this.name,
    this.description,
    this.trailerYoutubeId,
    this.thumbnailUrl,
    this.order,
    this.price,
    this.prices,
  });

  final String name;
  final String? description;
  final String? trailerYoutubeId;
  final String? thumbnailUrl;
  final int? order;
  final CreateInlinePriceRequest? price;

  /// Regional prices — optional; the backend supports Chapter/MODULE
  /// pricing but the UI never invents values, only what the admin enters.
  final List<CreatePriceRequest>? prices;

  Map<String, dynamic> toJson() => {
        'name': name,
        if (description != null) 'description': description,
        if (trailerYoutubeId != null) 'trailerYoutubeId': trailerYoutubeId,
        if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
        if (order != null) 'order': order,
        if (price != null) 'price': price!.toJson(),
        if (prices != null) 'prices': prices!.map((p) => p.toJson()).toList(),
      };
}

class UpdateChapterRequest {
  const UpdateChapterRequest({this.name, this.description, this.trailerYoutubeId, this.thumbnailUrl, this.order});

  final String? name;
  final String? description;
  final String? trailerYoutubeId;
  final String? thumbnailUrl;
  final int? order;

  Map<String, dynamic> toJson() => {
        if (name != null) 'name': name,
        if (description != null) 'description': description,
        if (trailerYoutubeId != null) 'trailerYoutubeId': trailerYoutubeId,
        if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
        if (order != null) 'order': order,
      };
}

class SetTrailerRequest {
  const SetTrailerRequest({required this.youtubeId, this.thumbnailUrl});

  final String youtubeId;
  final String? thumbnailUrl;

  Map<String, dynamic> toJson() => {
        'youtubeId': youtubeId,
        if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
      };
}

/// `chapterId` is deliberately absent — it comes from the URL path
/// (`POST /admin/chapters/:chapterId/lessons`).
class CreateLessonRequest {
  const CreateLessonRequest({
    required this.title,
    this.description,
    this.order,
    this.isFreePreview,
    this.isPublished,
    this.batchIds,
  });

  final String title;
  final String? description;
  final int? order;
  final bool? isFreePreview;
  final bool? isPublished;
  final List<String>? batchIds;

  Map<String, dynamic> toJson() => {
        'title': title,
        if (description != null) 'description': description,
        if (order != null) 'order': order,
        if (isFreePreview != null) 'isFreePreview': isFreePreview,
        if (isPublished != null) 'isPublished': isPublished,
        if (batchIds != null) 'batchIds': batchIds,
      };
}

class UpdateLessonRequest {
  const UpdateLessonRequest({
    this.title,
    this.description,
    this.order,
    this.isFreePreview,
    this.isPublished,
    this.durationSeconds,
    this.batchIds,
  });

  final String? title;
  final String? description;
  final int? order;
  final bool? isFreePreview;
  final bool? isPublished;
  final int? durationSeconds;
  final List<String>? batchIds;

  Map<String, dynamic> toJson() => {
        if (title != null) 'title': title,
        if (description != null) 'description': description,
        if (order != null) 'order': order,
        if (isFreePreview != null) 'isFreePreview': isFreePreview,
        if (isPublished != null) 'isPublished': isPublished,
        if (durationSeconds != null) 'durationSeconds': durationSeconds,
        if (batchIds != null) 'batchIds': batchIds,
      };
}

/// `youtubeId` accepts a bare video id or a full YouTube URL — the backend
/// extracts and validates the id server-side — `POST /admin/lessons/:id/video`
/// (a separate module from the rest of curriculum CRUD, but grouped into
/// AdminCurriculumService on the Flutter side since it's still "editing a
/// lesson").
class SetLessonVideoRequest {
  const SetLessonVideoRequest(this.youtubeId);

  final String youtubeId;

  Map<String, dynamic> toJson() => {'youtubeId': youtubeId};
}

/// Backend enum `ResourceType`: NOTE | PYQ | RESOURCE.
class CreateResourceRequest {
  const CreateResourceRequest({
    required this.title,
    required this.fileKey,
    this.type,
    this.pageCount,
    this.sizeBytes,
    this.isDownloadable,
  });

  final String title;
  final String fileKey;
  final String? type;
  final int? pageCount;
  final int? sizeBytes;
  final bool? isDownloadable;

  Map<String, dynamic> toJson() => {
        'title': title,
        'fileKey': fileKey,
        if (type != null) 'type': type,
        if (pageCount != null) 'pageCount': pageCount,
        if (sizeBytes != null) 'sizeBytes': sizeBytes,
        if (isDownloadable != null) 'isDownloadable': isDownloadable,
      };
}

/// Metadata submitted with an uploaded resource PDF. It intentionally omits
/// `fileKey`, which the backend derives from multipart field `file`.
class CreateResourceFileRequest {
  const CreateResourceFileRequest({
    required this.title,
    required this.type,
    this.pageCount,
    required this.isDownloadable,
  });

  final String title;
  final String type;
  final int? pageCount;
  final bool isDownloadable;

  Map<String, String> toFormFields() => {
        'title': title,
        'type': type,
        if (pageCount != null) 'pageCount': pageCount.toString(),
        'isDownloadable': isDownloadable.toString(),
      };
}

class ReorderItemRequest {
  const ReorderItemRequest({required this.id, required this.order});

  final String id;
  final int order;

  Map<String, dynamic> toJson() => {'id': id, 'order': order};
}

/// `entity` must be one of: grade | subject | chapter | lesson.
class ReorderRequest {
  const ReorderRequest({required this.entity, required this.items});

  final String entity;
  final List<ReorderItemRequest> items;

  Map<String, dynamic> toJson() => {
        'entity': entity,
        'items': items.map((e) => e.toJson()).toList(),
      };
}

/// `entity` must be one of: lesson | chapter (chapter publishes/unpublishes
/// every lesson inside it — see AdminCurriculumService.setPublished).
class PublishRequest {
  const PublishRequest({required this.entity, required this.id, required this.isPublished});

  final String entity;
  final String id;
  final bool isPublished;

  Map<String, dynamic> toJson() => {'entity': entity, 'id': id, 'isPublished': isPublished};
}

// ── Bulk import (Excel → JSON, never the file itself) ───────────────────
// `POST /admin/subjects/:subjectId/chapters/bulk` and
// `POST /admin/chapters/:chapterId/lessons/bulk` — separate endpoints from
// the single-item create above, with their own request shapes. The bulk
// chapter price shape (`format`/`accessDays`, no `compareAt`) is NOT the
// same as [CreatePriceRequest] used by the regular Add/Edit Chapter form,
// so this is intentionally its own type rather than a reuse.

/// One regional price inside a bulk chapter import row.
class BulkChapterPriceRequest {
  const BulkChapterPriceRequest({
    required this.region,
    required this.currency,
    required this.amount,
    this.format,
    this.accessDays,
  });

  final String region;
  final String currency;
  final num amount;

  /// Backend enum `ProductFormat`: RECORDED | LIVE_AND_RECORDED.
  final String? format;
  final int? accessDays;

  Map<String, dynamic> toJson() => {
        'region': region,
        'currency': currency,
        'amount': amount,
        if (format != null) 'format': format,
        if (accessDays != null) 'accessDays': accessDays,
      };
}

/// One chapter inside a `POST /admin/subjects/:subjectId/chapters/bulk`
/// request body's `chapters[]`.
class BulkChapterItemRequest {
  const BulkChapterItemRequest({required this.name, this.description, this.order, this.prices = const []});

  final String name;
  final String? description;
  final int? order;
  final List<BulkChapterPriceRequest> prices;

  Map<String, dynamic> toJson() => {
        'name': name,
        if (description != null) 'description': description,
        if (order != null) 'order': order,
        if (prices.isNotEmpty) 'prices': prices.map((p) => p.toJson()).toList(),
      };
}

/// Body of `POST /admin/subjects/:subjectId/chapters/bulk`.
class BulkCreateChaptersRequest {
  const BulkCreateChaptersRequest(this.chapters);

  final List<BulkChapterItemRequest> chapters;

  Map<String, dynamic> toJson() => {'chapters': chapters.map((c) => c.toJson()).toList()};
}

/// One lesson inside a `POST /admin/chapters/:chapterId/lessons/bulk`
/// request body's `lessons[]`. Bulk-only: takes `youtubeUrl` directly
/// (unlike the normal lesson flow's separate `POST .../video` step which
/// takes `youtubeId` — see [SetLessonVideoRequest] — that endpoint and
/// flow are untouched by this).
class BulkLessonItemRequest {
  const BulkLessonItemRequest({
    required this.title,
    this.description,
    this.order,
    this.isFreePreview,
    this.isPublished,
    this.youtubeUrl,
  });

  final String title;
  final String? description;
  final int? order;
  final bool? isFreePreview;
  final bool? isPublished;
  final String? youtubeUrl;

  Map<String, dynamic> toJson() => {
        'title': title,
        if (description != null) 'description': description,
        if (order != null) 'order': order,
        if (isFreePreview != null) 'isFreePreview': isFreePreview,
        if (isPublished != null) 'isPublished': isPublished,
        if (youtubeUrl != null) 'youtubeUrl': youtubeUrl,
      };
}

/// Body of `POST /admin/chapters/:chapterId/lessons/bulk`.
class BulkCreateLessonsRequest {
  const BulkCreateLessonsRequest(this.lessons);

  final List<BulkLessonItemRequest> lessons;

  Map<String, dynamic> toJson() => {'lessons': lessons.map((l) => l.toJson()).toList()};
}
