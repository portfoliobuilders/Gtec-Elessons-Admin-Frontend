import 'dart:typed_data';

import 'package:flutter/foundation.dart';

import '../../models/admin/admin_models.dart';
import '../network/api_client.dart';

/// Grade → Subject → Chapter → Lesson → Resource CRUD, mirroring
/// AdminCurriculumService + VideoController.setVideo on the backend.
/// Pure API communication — no UI state, that's the controller's job.
class AdminCurriculumService {
  AdminCurriculumService(this._apiClient);

  final ApiClient _apiClient;

  /// `GET /admin/curriculum` — the full tree (TEACHER sees only subjects
  /// they teach; ADMIN/SUPER_ADMIN see everything).
  Future<List<AdminGradeModel>> tree() async {
    final json = await _apiClient.get('/admin/curriculum');
    if (kDebugMode) debugPrint('Admin curriculum: decoded response type is ${json.runtimeType}.');
    if (json is! List) {
      throw FormatException('Expected /admin/curriculum to return a JSON array, got ${json.runtimeType}.');
    }
    try {
      return json.map((e) => AdminGradeModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Admin curriculum: JSON model parsing failed: $error');
        debugPrintStack(stackTrace: stackTrace);
      }
      throw FormatException('The curriculum response contains an unsupported item: $error');
    }
  }

  Future<AdminGradeModel> createGrade(CreateGradeRequest request) async {
    final json = await _apiClient.post('/admin/grades', body: request.toJson());
    return AdminGradeModel.fromJson(json as Map<String, dynamic>);
  }

  Future<AdminGradeModel> updateGrade(String id, UpdateGradeRequest request) async {
    final json = await _apiClient.patch('/admin/grades/$id', body: request.toJson());
    return AdminGradeModel.fromJson(json as Map<String, dynamic>);
  }

  Future<CurriculumTrailerModel> setGradeTrailer(String id, SetTrailerRequest request) async {
    final json = await _apiClient.post('/admin/grades/$id/trailer', body: request.toJson());
    return CurriculumTrailerModel.fromJson(json as Map<String, dynamic>);
  }

  /// 409s server-side if the grade still has subjects.
  Future<AdminGradeModel> deleteGrade(String id) async {
    final json = await _apiClient.delete('/admin/grades/$id');
    return AdminGradeModel.fromJson(json as Map<String, dynamic>);
  }

  /// `POST /admin/grades/:id/photo` (multipart, field `file`) — sets/replaces
  /// the grade's cover image. Returns the full updated grade (no `subjects`
  /// nested — confirmed live).
  Future<AdminGradeModel> uploadGradePhoto(String id, Uint8List bytes, String filename) async {
    final json = await _apiClient.uploadFile('/admin/grades/$id/photo', fieldName: 'file', bytes: bytes, filename: filename);
    return AdminGradeModel.fromJson(json as Map<String, dynamic>);
  }

  /// `DELETE /admin/grades/:id/photo` — clears the cover image back to
  /// `iconUrl: null`. Confirmed live to exist and work (not assumed).
  Future<AdminGradeModel> deleteGradePhoto(String id) async {
    final json = await _apiClient.delete('/admin/grades/$id/photo');
    return AdminGradeModel.fromJson(json as Map<String, dynamic>);
  }

  Future<AdminSubjectModel> createSubject(String gradeId, CreateSubjectRequest request) async {
    final json = await _apiClient.post('/admin/grades/$gradeId/subjects', body: request.toJson());
    return AdminSubjectModel.fromJson(json as Map<String, dynamic>);
  }

  Future<AdminSubjectModel> getSubject(String id) async {
    final json = await _apiClient.get('/admin/subjects/$id');
    return AdminSubjectModel.fromJson(json as Map<String, dynamic>);
  }

  Future<AdminSubjectModel> updateSubject(String id, UpdateSubjectRequest request) async {
    final json = await _apiClient.patch('/admin/subjects/$id', body: request.toJson());
    return AdminSubjectModel.fromJson(json as Map<String, dynamic>);
  }

  Future<CurriculumTrailerModel> setSubjectTrailer(String id, SetTrailerRequest request) async {
    final json = await _apiClient.post('/admin/subjects/$id/trailer', body: request.toJson());
    return CurriculumTrailerModel.fromJson(json as Map<String, dynamic>);
  }

  /// Cascades server-side: deletes the subject's chapters/lessons/products
  /// and any enrollments/cart/order items pointing at them.
  Future<AdminSubjectModel> deleteSubject(String id) async {
    final json = await _apiClient.delete('/admin/subjects/$id');
    return AdminSubjectModel.fromJson(json as Map<String, dynamic>);
  }

  /// `POST /admin/subjects/:id/photo` (multipart, field `file`) —
  /// sets/replaces the subject's cover image. Returns the full updated
  /// subject (no `chapters` nested — confirmed live).
  Future<AdminSubjectModel> uploadSubjectPhoto(String id, Uint8List bytes, String filename) async {
    final json =
        await _apiClient.uploadFile('/admin/subjects/$id/photo', fieldName: 'file', bytes: bytes, filename: filename);
    return AdminSubjectModel.fromJson(json as Map<String, dynamic>);
  }

  /// `DELETE /admin/subjects/:id/photo` — confirmed live to exist and work.
  Future<AdminSubjectModel> deleteSubjectPhoto(String id) async {
    final json = await _apiClient.delete('/admin/subjects/$id/photo');
    return AdminSubjectModel.fromJson(json as Map<String, dynamic>);
  }

  Future<AdminChapterModel> createChapter(String subjectId, CreateChapterRequest request) async {
    final json = await _apiClient.post('/admin/subjects/$subjectId/chapters', body: request.toJson());
    return AdminChapterModel.fromJson(json as Map<String, dynamic>);
  }

  Future<AdminChapterModel> updateChapter(String id, UpdateChapterRequest request) async {
    final json = await _apiClient.patch('/admin/chapters/$id', body: request.toJson());
    return AdminChapterModel.fromJson(json as Map<String, dynamic>);
  }

  Future<CurriculumTrailerModel> setChapterTrailer(String id, SetTrailerRequest request) async {
    final json = await _apiClient.post('/admin/chapters/$id/trailer', body: request.toJson());
    return CurriculumTrailerModel.fromJson(json as Map<String, dynamic>);
  }

  Future<AdminChapterModel> deleteChapter(String id) async {
    final json = await _apiClient.delete('/admin/chapters/$id');
    return AdminChapterModel.fromJson(json as Map<String, dynamic>);
  }

  /// `POST /admin/chapters/:id/photo` (multipart, field `file`) —
  /// sets/replaces the chapter's cover image. Returns the full updated
  /// chapter.
  Future<AdminChapterModel> uploadChapterPhoto(String id, Uint8List bytes, String filename) async {
    final json =
        await _apiClient.uploadFile('/admin/chapters/$id/photo', fieldName: 'file', bytes: bytes, filename: filename);
    return AdminChapterModel.fromJson(json as Map<String, dynamic>);
  }

  /// `DELETE /admin/chapters/:id/photo` — confirmed live to exist and work.
  Future<AdminChapterModel> deleteChapterPhoto(String id) async {
    final json = await _apiClient.delete('/admin/chapters/$id/photo');
    return AdminChapterModel.fromJson(json as Map<String, dynamic>);
  }

  Future<List<AdminLessonModel>> chapterLessons(String chapterId) async {
    final json = await _apiClient.get('/admin/chapters/$chapterId/lessons') as List<dynamic>;
    return json.map((e) => AdminLessonModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<AdminLessonModel> createLesson(String chapterId, CreateLessonRequest request) async {
    final json = await _apiClient.post('/admin/chapters/$chapterId/lessons', body: request.toJson());
    return AdminLessonModel.fromJson(json as Map<String, dynamic>);
  }

  Future<AdminLessonModel> updateLesson(String id, UpdateLessonRequest request) async {
    final json = await _apiClient.patch('/admin/lessons/$id', body: request.toJson());
    return AdminLessonModel.fromJson(json as Map<String, dynamic>);
  }

  /// `youtubeId` accepts a bare video id or a full YouTube URL — the
  /// backend extracts/validates the id itself.
  /// Response is `{lessonId, youtubeId, embedUrl, verified}` — the same
  /// trailer-style shape as setGradeTrailer/setSubjectTrailer/
  /// setChapterTrailer, NOT a full lesson row — confirmed via live testing.
  Future<CurriculumTrailerModel> setLessonVideo(String id, String youtubeId) async {
    final json = await _apiClient.post('/admin/lessons/$id/video', body: SetLessonVideoRequest(youtubeId).toJson());
    return CurriculumTrailerModel.fromJson(json as Map<String, dynamic>);
  }

  Future<AdminLessonModel> deleteLesson(String id) async {
    final json = await _apiClient.delete('/admin/lessons/$id');
    return AdminLessonModel.fromJson(json as Map<String, dynamic>);
  }

  Future<AdminResourceModel> createChapterResource(String chapterId, CreateResourceRequest request) async {
    final json = await _apiClient.post('/admin/chapters/$chapterId/resources', body: request.toJson());
    return AdminResourceModel.fromJson(json as Map<String, dynamic>);
  }

  Future<AdminResourceModel> createLessonResource(String lessonId, CreateResourceRequest request) async {
    final json = await _apiClient.post('/admin/lessons/$lessonId/resources', body: request.toJson());
    return AdminResourceModel.fromJson(json as Map<String, dynamic>);
  }

  Future<AdminResourceModel> deleteResource(String id) async {
    final json = await _apiClient.delete('/admin/resources/$id');
    return AdminResourceModel.fromJson(json as Map<String, dynamic>);
  }

  Future<int> reorder(ReorderRequest request) async {
    final json = await _apiClient.post('/admin/curriculum/reorder', body: request.toJson()) as Map<String, dynamic>;
    return json['reordered'] as int? ?? 0;
  }

  /// Response shape depends on `entity`: a full lesson row when
  /// `entity: lesson`, or `{chapterId, isPublished}` when `entity: chapter`
  /// (publishing a chapter flips every lesson inside it — see
  /// AdminCurriculumService.setPublished on the backend). Returned raw
  /// rather than forced into one model.
  Future<Map<String, dynamic>> publish(PublishRequest request) async {
    final json = await _apiClient.patch('/admin/curriculum/publish', body: request.toJson());
    return json as Map<String, dynamic>;
  }

  // ── Bulk import (Curriculum Bulk Create — Excel is parsed locally and
  // never uploaded; the caller has already turned it into these JSON
  // request bodies) ─────────────────────────────────────────────────────

  /// `POST /admin/subjects/:subjectId/chapters/bulk` — one call per batch;
  /// the caller (bulk import screen) owns splitting into ≤100-record
  /// batches and reporting progress/failures, this just forwards one.
  Future<void> bulkCreateChapters(String subjectId, BulkCreateChaptersRequest request) async {
    await _apiClient.post('/admin/subjects/$subjectId/chapters/bulk', body: request.toJson());
  }

  /// `POST /admin/chapters/:chapterId/lessons/bulk`.
  Future<void> bulkCreateLessons(String chapterId, BulkCreateLessonsRequest request) async {
    await _apiClient.post('/admin/chapters/$chapterId/lessons/bulk', body: request.toJson());
  }
}
