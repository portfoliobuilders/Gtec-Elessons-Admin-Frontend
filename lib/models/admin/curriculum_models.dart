// Backend-aligned Curriculum models — mirrors AdminCurriculumService's actual
// response shapes (see GET /admin/curriculum, /admin/subjects/:id, etc.).
// NOT the same as the prototype GradeModel/SubjectModel/ModuleModel used by
// the mock Curriculum UI (lib/models/grade_model.dart etc.) — those stay
// UI-only until the screens are migrated in a later phase.

import 'pricing_models.dart';

/// A Grade/Subject/Chapter has at most one active [Product], flattened to a
/// single price object by the backend (`toFlatPrice`) instead of an array.
class FlatPriceModel {
  const FlatPriceModel({
    required this.productId,
    required this.amountCents,
    required this.region,
    required this.currency,
    this.compareAtCents,
    this.displayPrice,
  });

  final String productId;
  final int amountCents;
  final String region;
  final String currency;
  final int? compareAtCents;
  final num? displayPrice;

  factory FlatPriceModel.fromJson(Map<String, dynamic> json) => FlatPriceModel(
        productId: json['productId'] as String,
        amountCents: json['amountCents'] as int,
        region: json['region'] as String,
        currency: json['currency'] as String,
        compareAtCents: json['compareAtCents'] as int?,
        displayPrice: json['displayPrice'] as num?,
      );
}

/// Response of `POST /admin/{grades,subjects,chapters}/:id/trailer`.
class CurriculumTrailerModel {
  const CurriculumTrailerModel({required this.entityId, required this.youtubeId, required this.embedUrl, required this.verified});

  final String entityId;
  final String? youtubeId;
  final String embedUrl;
  final bool verified;

  factory CurriculumTrailerModel.fromJson(Map<String, dynamic> json) => CurriculumTrailerModel(
        entityId: (json['gradeId'] ?? json['subjectId'] ?? json['chapterId'] ?? json['lessonId'])?.toString() ?? '',
        youtubeId: json['youtubeId'] as String?,
        embedUrl: json['embedUrl'] as String,
        verified: json['verified'] == true,
      );
}

class AdminGradeModel {
  const AdminGradeModel({
    required this.id,
    required this.name,
    required this.board,
    this.syllabus,
    this.description,
    this.trailerYoutubeId,
    this.trailerThumbnailUrl,
    this.iconUrl,
    this.order = 0,
    this.isActive = true,
    this.price,
    this.prices = const [],
    this.subjects,
  });

  final String id;
  final String name;
  final String board;
  final String? syllabus;
  final String? description;
  final String? trailerYoutubeId;
  final String? trailerThumbnailUrl;

  /// Cover image — set via `POST/DELETE /admin/grades/:id/photo` (confirmed
  /// present on the wire; just wasn't modeled here before that endpoint had
  /// a Flutter UI). An absolute URL exactly as the backend returns it —
  /// never rewritten/prefixed here.
  final String? iconUrl;
  final int order;
  final bool isActive;

  /// Kept for backward compatibility — the first regional price only.
  /// [prices] (the full regional list) is the source of truth as of Phase 5.
  final FlatPriceModel? price;
  final List<AdminProductPriceModel> prices;

  /// Only present when this grade came from `GET /admin/curriculum` (the
  /// full tree) — null for create/update responses.
  final List<AdminSubjectModel>? subjects;

  factory AdminGradeModel.fromJson(Map<String, dynamic> json) => AdminGradeModel(
        id: json['id'] as String,
        name: json['name'] as String,
        board: json['board'] as String? ?? 'CBSE',
        syllabus: json['syllabus'] as String?,
        description: json['description'] as String?,
        trailerYoutubeId: json['trailerYoutubeId'] as String?,
        trailerThumbnailUrl: json['trailerThumbnailUrl'] as String?,
        iconUrl: json['iconUrl'] as String?,
        order: json['order'] as int? ?? 0,
        isActive: json['isActive'] as bool? ?? true,
        price: json['price'] == null ? null : FlatPriceModel.fromJson(json['price'] as Map<String, dynamic>),
        prices: (json['prices'] as List<dynamic>?)
                ?.map((e) => AdminProductPriceModel.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
        subjects: (json['subjects'] as List<dynamic>?)
            ?.map((e) => AdminSubjectModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  /// Used after a cover-image upload/remove to patch this grade locally —
  /// the photo endpoints return the full updated grade (no `subjects`
  /// nested), so only `iconUrl` is applied rather than replacing the whole
  /// object and losing the already-loaded subject tree.
  AdminGradeModel copyWith({String? iconUrl, bool clearIconUrl = false}) => AdminGradeModel(
        id: id,
        name: name,
        board: board,
        syllabus: syllabus,
        description: description,
        trailerYoutubeId: trailerYoutubeId,
        trailerThumbnailUrl: trailerThumbnailUrl,
        iconUrl: clearIconUrl ? null : (iconUrl ?? this.iconUrl),
        order: order,
        isActive: isActive,
        price: price,
        prices: prices,
        subjects: subjects,
      );
}

/// NOTE: the backend Subject entity has `teacherId`/`teacherName` (auto-set
/// when a TEACHER creates a subject), but no admin endpoint currently
/// returns them — `toSubjectResponse()` on the backend omits both. Assigning
/// a teacher via the UI isn't possible until the backend exposes them.
class AdminSubjectModel {
  const AdminSubjectModel({
    required this.id,
    required this.name,
    this.code,
    this.description,
    required this.gradeId,
    this.order = 0,
    this.iconUrl,
    this.trailerYoutubeId,
    this.trailerThumbnailUrl,
    this.price,
    this.prices = const [],
    this.chapters,
  });

  final String id;
  final String name;
  final String? code;
  final String? description;
  final String gradeId;
  final int order;
  final String? iconUrl;
  final String? trailerYoutubeId;
  final String? trailerThumbnailUrl;

  /// Kept for backward compatibility — the first regional price only.
  /// [prices] (the full regional list) is the source of truth as of Phase 5.
  final FlatPriceModel? price;
  final List<AdminProductPriceModel> prices;

  /// Only present from `GET /admin/curriculum` or `GET /admin/subjects/:id`.
  final List<AdminChapterModel>? chapters;

  factory AdminSubjectModel.fromJson(Map<String, dynamic> json) => AdminSubjectModel(
        id: json['id'] as String,
        name: json['name'] as String,
        code: json['code'] as String?,
        description: json['description'] as String?,
        gradeId: json['gradeId'] as String,
        order: json['order'] as int? ?? 0,
        iconUrl: json['iconUrl'] as String?,
        trailerYoutubeId: json['trailerYoutubeId'] as String?,
        trailerThumbnailUrl: json['trailerThumbnailUrl'] as String?,
        price: json['price'] == null ? null : FlatPriceModel.fromJson(json['price'] as Map<String, dynamic>),
        prices: (json['prices'] as List<dynamic>?)
                ?.map((e) => AdminProductPriceModel.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
        chapters: (json['chapters'] as List<dynamic>?)
            ?.map((e) => AdminChapterModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  /// See [AdminGradeModel.copyWith] — same reasoning, the photo endpoints
  /// return the full subject but without `chapters` nested.
  AdminSubjectModel copyWith({String? iconUrl, bool clearIconUrl = false}) => AdminSubjectModel(
        id: id,
        name: name,
        code: code,
        description: description,
        gradeId: gradeId,
        order: order,
        iconUrl: clearIconUrl ? null : (iconUrl ?? this.iconUrl),
        trailerYoutubeId: trailerYoutubeId,
        trailerThumbnailUrl: trailerThumbnailUrl,
        price: price,
        prices: prices,
        chapters: chapters,
      );
}

class AdminChapterModel {
  const AdminChapterModel({
    required this.id,
    required this.name,
    this.description,
    required this.subjectId,
    this.order = 0,
    this.trailerYoutubeId,
    this.trailerThumbnailUrl,
    this.iconUrl,
    this.lessonCount,
    this.price,
    this.prices = const [],
  });

  final String id;
  final String name;
  final String? description;
  final String subjectId;
  final int order;
  final String? trailerYoutubeId;
  final String? trailerThumbnailUrl;

  /// Cover image — set via `POST/DELETE /admin/chapters/:id/photo`
  /// (confirmed present on the wire). An absolute URL exactly as the
  /// backend returns it — never rewritten/prefixed here.
  final String? iconUrl;

  /// From `_count.lessons` — only present via `GET /admin/curriculum`.
  final int? lessonCount;

  /// Kept for backward compatibility — the first regional price only.
  /// [prices] (the full regional list) is the source of truth as of Phase 5.
  final FlatPriceModel? price;
  final List<AdminProductPriceModel> prices;

  factory AdminChapterModel.fromJson(Map<String, dynamic> json) => AdminChapterModel(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String?,
        subjectId: json['subjectId'] as String,
        order: json['order'] as int? ?? 0,
        trailerYoutubeId: json['trailerYoutubeId'] as String?,
        trailerThumbnailUrl: json['trailerThumbnailUrl'] as String?,
        iconUrl: json['iconUrl'] as String?,
        lessonCount: (json['_count'] as Map<String, dynamic>?)?['lessons'] as int?,
        price: json['price'] == null ? null : FlatPriceModel.fromJson(json['price'] as Map<String, dynamic>),
        prices: (json['prices'] as List<dynamic>?)
                ?.map((e) => AdminProductPriceModel.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
      );

  /// See [AdminGradeModel.copyWith] — same reasoning.
  AdminChapterModel copyWith({String? iconUrl, bool clearIconUrl = false}) => AdminChapterModel(
        id: id,
        name: name,
        description: description,
        subjectId: subjectId,
        order: order,
        trailerYoutubeId: trailerYoutubeId,
        trailerThumbnailUrl: trailerThumbnailUrl,
        iconUrl: clearIconUrl ? null : (iconUrl ?? this.iconUrl),
        lessonCount: lessonCount,
        price: price,
        prices: prices,
      );
}

class LessonBatchRefModel {
  const LessonBatchRefModel({required this.batchId, required this.batchName});

  final String batchId;
  final String batchName;

  factory LessonBatchRefModel.fromJson(Map<String, dynamic> json) {
    final batch = json['batch'] as Map<String, dynamic>? ?? const {};
    return LessonBatchRefModel(
      batchId: batch['id']?.toString() ?? '',
      batchName: batch['name']?.toString() ?? '',
    );
  }
}

class AdminLessonModel {
  const AdminLessonModel({
    required this.id,
    required this.title,
    this.description,
    required this.chapterId,
    this.youtubeUrl,
    this.youtubeId,
    this.durationSeconds,
    this.thumbnailUrl,
    this.order = 0,
    this.isFreePreview = false,
    this.isPublished = true,
    this.resources = const [],
    this.batches = const [],
  });

  final String id;
  final String title;
  final String? description;
  final String chapterId;
  final String? youtubeUrl;
  final String? youtubeId;
  final int? durationSeconds;
  final String? thumbnailUrl;
  final int order;
  final bool isFreePreview;
  final bool isPublished;

  /// Only present from `GET /admin/chapters/:id/lessons`.
  final List<AdminResourceModel> resources;
  final List<LessonBatchRefModel> batches;

  factory AdminLessonModel.fromJson(Map<String, dynamic> json) => AdminLessonModel(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String?,
        chapterId: json['chapterId'] as String,
        youtubeUrl: json['youtubeUrl'] as String?,
        youtubeId: json['youtubeId'] as String?,
        durationSeconds: json['durationSeconds'] as int?,
        thumbnailUrl: json['thumbnailUrl'] as String?,
        order: json['order'] as int? ?? 0,
        isFreePreview: json['isFreePreview'] as bool? ?? false,
        isPublished: json['isPublished'] as bool? ?? true,
        resources: (json['resources'] as List<dynamic>?)
                ?.map((e) => AdminResourceModel.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
        batches: (json['batches'] as List<dynamic>?)
                ?.map((e) => LessonBatchRefModel.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
      );
}

/// Backend enum `ResourceType`: NOTE | PYQ | RESOURCE — exact wire values,
/// do not rename.
class AdminResourceModel {
  const AdminResourceModel({
    required this.id,
    required this.type,
    required this.title,
    required this.fileKey,
    this.sizeBytes,
    this.pageCount,
    this.isDownloadable = true,
    this.downloadCount = 0,
    this.lessonId,
    this.chapterId,
  });

  final String id;
  final String type;
  final String title;
  final String fileKey;
  final int? sizeBytes;
  final int? pageCount;
  final bool isDownloadable;
  final int downloadCount;
  final String? lessonId;
  final String? chapterId;

  factory AdminResourceModel.fromJson(Map<String, dynamic> json) => AdminResourceModel(
        id: json['id'] as String,
        type: json['type'] as String? ?? 'NOTE',
        title: json['title'] as String,
        fileKey: json['fileKey'] as String,
        sizeBytes: json['sizeBytes'] as int?,
        pageCount: json['pageCount'] as int?,
        isDownloadable: json['isDownloadable'] as bool? ?? true,
        downloadCount: json['downloadCount'] as int? ?? 0,
        lessonId: json['lessonId'] as String?,
        chapterId: json['chapterId'] as String?,
      );
}
