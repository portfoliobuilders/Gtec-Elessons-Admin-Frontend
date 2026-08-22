import 'package:flutter/foundation.dart';

import '../core/network/api_exception.dart';
import '../core/services/admin_curriculum_service.dart';
import '../core/services/admin_pricing_service.dart';
import '../models/admin/admin_models.dart';

enum CurriculumLoadStatus { initial, loading, loaded, error }

/// Curriculum — Grade → Subject → Chapter → Lesson state, fully backed by
/// the real `/admin/*` endpoints via [AdminCurriculumService]. As of
/// Phase 3D, the mock Phase-1-era data (GradeModel/SubjectModel/ModuleModel/
/// LessonModel + the old Add Module/legacy Add Lesson flow) has been fully
/// retired — every member below talks to the real backend. Phase 5 adds
/// regional pricing (Grade/Subject/Chapter only) via [AdminPricingService].
class CurriculumController extends ChangeNotifier {
  CurriculumController(this._service, this._pricingService);

  final AdminCurriculumService _service;
  final AdminPricingService _pricingService;

  // ── Grade data ────────────────────────────────────────────────────────────

  CurriculumLoadStatus curriculumStatus = CurriculumLoadStatus.initial;
  String? curriculumError;
  List<AdminGradeModel> curriculumGrades = [];
  String curriculumGradeSearch = '';
  String? selectedCurriculumGradeId;

  bool get isCurriculumLoading => curriculumStatus == CurriculumLoadStatus.loading;

  List<AdminGradeModel> get filteredCurriculumGrades {
    final query = curriculumGradeSearch.trim().toLowerCase();
    if (query.isEmpty) return curriculumGrades;
    return [for (final g in curriculumGrades) if (g.name.toLowerCase().contains(query)) g];
  }

  static const _emptyCurriculumGrade = AdminGradeModel(id: '', name: '', board: 'CBSE');

  AdminGradeModel get selectedCurriculumGrade => curriculumGrades.firstWhere(
        (g) => g.id == selectedCurriculumGradeId,
        orElse: () => curriculumGrades.isNotEmpty ? curriculumGrades.first : _emptyCurriculumGrade,
      );

  Future<void> loadCurriculum() async {
    curriculumStatus = CurriculumLoadStatus.loading;
    curriculumError = null;
    notifyListeners();
    try {
      curriculumGrades = await _service.tree();
      curriculumStatus = CurriculumLoadStatus.loaded;
    } on ApiException catch (e) {
      curriculumError = e.message;
      curriculumStatus = CurriculumLoadStatus.error;
    } catch (_) {
      curriculumError = 'Unable to load curriculum. Please try again.';
      curriculumStatus = CurriculumLoadStatus.error;
    }
    notifyListeners();
  }

  Future<void> refreshCurriculum() => loadCurriculum();

  void selectCurriculumGrade(String id) {
    selectedCurriculumGradeId = id;
    notifyListeners();
  }

  void clearSelectedCurriculumGrade() {
    selectedCurriculumGradeId = null;
    notifyListeners();
  }

  void setCurriculumGradeSearch(String value) {
    curriculumGradeSearch = value;
    notifyListeners();
  }

  /// Reloads the full tree afterward so nested subjects/chapters stay
  /// consistent everywhere they're displayed. Returns the real created
  /// grade (with its real `id`) on success, null on failure — the caller
  /// (Add Grade's cover-image-after-create step) needs that actual id, not
  /// a guess.
  Future<AdminGradeModel?> createGrade(CreateGradeRequest request) async {
    try {
      final created = await _service.createGrade(request);
      await loadCurriculum();
      return created;
    } on ApiException catch (e) {
      curriculumError = e.message;
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateGrade(String id, UpdateGradeRequest request) async {
    try {
      await _service.updateGrade(id, request);
      await loadCurriculum();
      return true;
    } on ApiException catch (e) {
      curriculumError = e.message;
      notifyListeners();
      return false;
    }
  }

  /// The backend 409s if the grade still has subjects — [curriculumError]
  /// carries that message through for the UI to show as-is.
  Future<bool> deleteGrade(String id) async {
    try {
      await _service.deleteGrade(id);
      await loadCurriculum();
      return true;
    } on ApiException catch (e) {
      curriculumError = e.message;
      notifyListeners();
      return false;
    }
  }

  // ── Subject data ──────────────────────────────────────────────────────────
  // No separate fetch/loading state of its own — `GET /admin/curriculum`
  // already nests each grade's subjects (and their chapters), so the
  // "subjects for the selected grade" is just `selectedCurriculumGrade.subjects`.
  // Mutations reuse `curriculumError`/`loadCurriculum()` above — one
  // coherent state owner, not a second loading/error flag to keep in sync.

  String? selectedCurriculumSubjectId;

  static const _emptyCurriculumSubject = AdminSubjectModel(id: '', name: '', gradeId: '');

  AdminSubjectModel get selectedCurriculumSubject {
    final subjects = selectedCurriculumGrade.subjects ?? const [];
    return subjects.firstWhere(
      (s) => s.id == selectedCurriculumSubjectId,
      orElse: () => subjects.isNotEmpty ? subjects.first : _emptyCurriculumSubject,
    );
  }

  void selectCurriculumSubject(String id) {
    selectedCurriculumSubjectId = id;
    notifyListeners();
  }

  void clearSelectedCurriculumSubject() {
    selectedCurriculumSubjectId = null;
    notifyListeners();
  }

  /// Returns the real created subject (with its real `id`) on success, null
  /// on failure — see [createGrade]'s doc for why.
  Future<AdminSubjectModel?> createSubject(String gradeId, CreateSubjectRequest request) async {
    try {
      final created = await _service.createSubject(gradeId, request);
      await loadCurriculum();
      return created;
    } on ApiException catch (e) {
      curriculumError = e.message;
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateSubject(String id, UpdateSubjectRequest request) async {
    try {
      await _service.updateSubject(id, request);
      await loadCurriculum();
      return true;
    } on ApiException catch (e) {
      curriculumError = e.message;
      notifyListeners();
      return false;
    }
  }

  /// The backend cascades chapters/lessons/products/enrollments under this
  /// subject when it deletes it — no dependency block like grades have.
  Future<bool> deleteSubject(String id) async {
    try {
      await _service.deleteSubject(id);
      await loadCurriculum();
      return true;
    } on ApiException catch (e) {
      curriculumError = e.message;
      notifyListeners();
      return false;
    }
  }

  // ── Chapter data ──────────────────────────────────────────────────────────
  // Same reasoning as Subject above: chapters are already nested under
  // `selectedCurriculumSubject.chapters` from the tree load — no separate
  // fetch/loading state, mutations reuse `curriculumError`/`loadCurriculum()`.

  String? selectedCurriculumChapterId;

  static const _emptyCurriculumChapter = AdminChapterModel(id: '', name: '', subjectId: '');

  AdminChapterModel get selectedCurriculumChapter {
    final chapters = selectedCurriculumSubject.chapters ?? const [];
    return chapters.firstWhere(
      (c) => c.id == selectedCurriculumChapterId,
      orElse: () => chapters.isNotEmpty ? chapters.first : _emptyCurriculumChapter,
    );
  }

  void selectCurriculumChapter(String id) {
    selectedCurriculumChapterId = id;
    notifyListeners();
  }

  void clearSelectedCurriculumChapter() {
    selectedCurriculumChapterId = null;
    notifyListeners();
  }

  /// Returns the real created chapter (with its real `id`) on success, null
  /// on failure — see [createGrade]'s doc for why.
  Future<AdminChapterModel?> createChapter(String subjectId, CreateChapterRequest request) async {
    try {
      final created = await _service.createChapter(subjectId, request);
      await loadCurriculum();
      return created;
    } on ApiException catch (e) {
      curriculumError = e.message;
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateChapter(String id, UpdateChapterRequest request) async {
    try {
      await _service.updateChapter(id, request);
      await loadCurriculum();
      return true;
    } on ApiException catch (e) {
      curriculumError = e.message;
      notifyListeners();
      return false;
    }
  }

  /// The backend cascades lessons/resources/products/enrollments under this
  /// chapter when it deletes it — no dependency block like grades have.
  Future<bool> deleteChapter(String id) async {
    try {
      await _service.deleteChapter(id);
      await loadCurriculum();
      return true;
    } on ApiException catch (e) {
      curriculumError = e.message;
      notifyListeners();
      return false;
    }
  }

  // ── Lesson data ───────────────────────────────────────────────────────────
  // Unlike Subject/Chapter, lessons are NOT nested in the GET /admin/curriculum
  // tree — AdminChapterModel only carries a lessonCount (`_count.lessons`),
  // not the lessons themselves — so this is a genuine separate fetch via
  // GET /admin/chapters/:id/lessons, with its own loading/error state
  // distinct from `curriculumStatus` above.

  CurriculumLoadStatus lessonStatus = CurriculumLoadStatus.initial;
  String? lessonError;
  List<AdminLessonModel> chapterLessons = [];
  String? selectedCurriculumLessonId;

  bool get isLessonLoading => lessonStatus == CurriculumLoadStatus.loading;

  static const _emptyCurriculumLesson = AdminLessonModel(id: '', title: '', chapterId: '');

  AdminLessonModel get selectedCurriculumLesson => chapterLessons.firstWhere(
        (l) => l.id == selectedCurriculumLessonId,
        orElse: () => chapterLessons.isNotEmpty ? chapterLessons.first : _emptyCurriculumLesson,
      );

  Future<void> loadChapterLessons() async {
    final chapterId = selectedCurriculumChapter.id;
    if (chapterId.isEmpty) return;
    lessonStatus = CurriculumLoadStatus.loading;
    lessonError = null;
    notifyListeners();
    try {
      chapterLessons = await _service.chapterLessons(chapterId);
      lessonStatus = CurriculumLoadStatus.loaded;
    } on ApiException catch (e) {
      lessonError = e.message;
      lessonStatus = CurriculumLoadStatus.error;
    } catch (_) {
      lessonError = 'Unable to load lessons. Please try again.';
      lessonStatus = CurriculumLoadStatus.error;
    }
    notifyListeners();
  }

  Future<void> refreshChapterLessons() => loadChapterLessons();

  void selectCurriculumLesson(String id) {
    selectedCurriculumLessonId = id;
    notifyListeners();
  }

  void clearSelectedCurriculumLesson() {
    selectedCurriculumLessonId = null;
    notifyListeners();
  }

  /// Returns the real created lesson (with its real `id`) on success, null
  /// on failure — see [createGrade]'s doc for why: the caller (Add Lesson's
  /// set-video-after-create step) needs that actual id to call
  /// [setLessonVideo], not a guess.
  Future<AdminLessonModel?> createLesson(String chapterId, CreateLessonRequest request) async {
    try {
      final created = await _service.createLesson(chapterId, request);
      await loadChapterLessons();
      return created;
    } on ApiException catch (e) {
      lessonError = e.message;
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateLesson(String id, UpdateLessonRequest request) async {
    try {
      await _service.updateLesson(id, request);
      await loadChapterLessons();
      return true;
    } on ApiException catch (e) {
      lessonError = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteLesson(String id) async {
    try {
      await _service.deleteLesson(id);
      await loadChapterLessons();
      return true;
    } on ApiException catch (e) {
      lessonError = e.message;
      notifyListeners();
      return false;
    }
  }

  /// `youtubeId` accepts a bare video id or a full YouTube URL — the
  /// backend extracts and validates it server-side (see AddLessonScreen).
  Future<bool> setLessonVideo(String id, String youtubeId) async {
    try {
      await _service.setLessonVideo(id, youtubeId);
      await loadChapterLessons();
      return true;
    } on ApiException catch (e) {
      lessonError = e.message;
      notifyListeners();
      return false;
    }
  }

  // ── Resource data ─────────────────────────────────────────────────────────
  // No separate fetch/loading state — there is no admin GET resources
  // endpoint. `AdminLessonModel.resources` already arrives nested inside
  // `GET /admin/chapters/:id/lessons` (confirmed live), so
  // `selectedCurriculumLesson.resources` is the resource list; mutations
  // reuse `lessonError`/`loadChapterLessons()` above, same pattern as
  // Subject/Chapter reusing `curriculumError`/`loadCurriculum()`.

  Future<bool> createLessonResource(String lessonId, CreateResourceRequest request) async {
    try {
      await _service.createLessonResource(lessonId, request);
      await loadChapterLessons();
      return true;
    } on ApiException catch (e) {
      lessonError = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteResource(String id) async {
    try {
      await _service.deleteResource(id);
      await loadChapterLessons();
      return true;
    } on ApiException catch (e) {
      lessonError = e.message;
      notifyListeners();
      return false;
    }
  }

  // ── Chapter-level Study Materials ───────────────────────────────────────
  // Unlike lesson resources, a Chapter's resources are NOT returned by any
  // backend GET — `GET /admin/curriculum` doesn't include a `resources`
  // field on chapters, and there is no `GET /admin/chapters/:id/resources`
  // (confirmed against the backend source, not assumed). The only chapter-
  // resource data that ever reaches the frontend is the created/deleted
  // record each mutation itself returns — so this list is built up locally
  // from those responses rather than reloaded from a fetch. It is NOT
  // cleared on chapter open (nothing to reconcile it against), so it
  // persists across navigation for the lifetime of the app session, but a
  // full reload starts empty again — surfaced to the admin via the Study
  // Materials section's own note rather than left implicit.
  final Map<String, List<AdminResourceModel>> _chapterResources = {};
  String? chapterResourceError;

  List<AdminResourceModel> chapterResourcesFor(String chapterId) => _chapterResources[chapterId] ?? const [];

  Future<bool> createChapterResource(String chapterId, CreateResourceRequest request) async {
    chapterResourceError = null;
    try {
      final created = await _service.createChapterResource(chapterId, request);
      final list = List<AdminResourceModel>.of(_chapterResources[chapterId] ?? const []);
      list.add(created);
      _chapterResources[chapterId] = list;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      chapterResourceError = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteChapterResource(String chapterId, String resourceId) async {
    chapterResourceError = null;
    try {
      await _service.deleteResource(resourceId);
      final list = List<AdminResourceModel>.of(_chapterResources[chapterId] ?? const []);
      list.removeWhere((r) => r.id == resourceId);
      _chapterResources[chapterId] = list;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      chapterResourceError = e.message;
      notifyListeners();
      return false;
    }
  }

  // ── Regional pricing (Grade/Subject/Chapter only) ───────────────────────
  // Reuses `curriculumError` (already shared across Grade/Subject/Chapter
  // mutations above) rather than adding a fourth error surface. The
  // curriculum tree's own `prices` arrays never carry a price id (confirmed
  // live), so an edit form must hydrate real ids via `findProductFor()`
  // before it can PATCH/DELETE a specific row.

  /// Finds the Product backing a Grade/Subject/Chapter (if one exists yet)
  /// by calling `GET /admin/pricing` and matching on the owning id + the
  /// type the backend uses for that level (`FULL_CLASS` for Grade,
  /// `SUBJECT` for Subject, `MODULE` for Chapter — see [AdminProductModel]'s
  /// documented `ProductType` enum). Returns null if this item has no
  /// pricing product yet — happens for anything created without prices.
  Future<AdminProductModel?> findProductFor({String? gradeId, String? subjectId, String? chapterId}) async {
    try {
      final products = await _pricingService.list();
      for (final p in products) {
        if (gradeId != null && p.type == 'FULL_CLASS' && p.gradeId == gradeId) return p;
        if (subjectId != null && p.type == 'SUBJECT' && p.subjectId == subjectId) return p;
        if (chapterId != null && p.type == 'MODULE' && p.chapterId == chapterId) return p;
      }
      return null;
    } on ApiException catch (e) {
      curriculumError = e.message;
      notifyListeners();
      return null;
    }
  }

  Future<bool> createProductPrice(String productId, CreatePriceRequest request) async {
    try {
      await _pricingService.createProductPrice(productId, request);
      return true;
    } on ApiException catch (e) {
      curriculumError = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProductPrice(String productId, String priceId, UpdateProductPriceRequest request) async {
    try {
      await _pricingService.updateProductPrice(productId, priceId, request);
      return true;
    } on ApiException catch (e) {
      curriculumError = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteProductPrice(String productId, String priceId) async {
    try {
      await _pricingService.deleteProductPrice(productId, priceId);
      return true;
    } on ApiException catch (e) {
      curriculumError = e.message;
      notifyListeners();
      return false;
    }
  }

  // ── Cover images (Grade/Subject/Chapter) ────────────────────────────────
  // One shared loading/error pair — only ever one upload happens at a time,
  // from one Edit screen, same reasoning as sharing `curriculumError`
  // across Grade/Subject/Chapter above. Every method here reloads the whole
  // tree afterward (`loadCurriculum()`) rather than hand-patching the
  // nested Grade→Subject→Chapter structure locally — exactly what every
  // other Grade/Subject/Chapter mutation above already does.

  bool isUploadingCover = false;
  String? coverError;

  Future<bool> uploadGradeCover(String id, Uint8List bytes, String filename) async {
    isUploadingCover = true;
    coverError = null;
    notifyListeners();
    try {
      await _service.uploadGradePhoto(id, bytes, filename);
      await loadCurriculum();
      return true;
    } on ApiException catch (e) {
      coverError = e.message;
      return false;
    } catch (_) {
      coverError = 'Unable to upload the cover image. Please try again.';
      return false;
    } finally {
      isUploadingCover = false;
      notifyListeners();
    }
  }

  Future<bool> removeGradeCover(String id) async {
    isUploadingCover = true;
    coverError = null;
    notifyListeners();
    try {
      await _service.deleteGradePhoto(id);
      await loadCurriculum();
      return true;
    } on ApiException catch (e) {
      coverError = e.message;
      return false;
    } finally {
      isUploadingCover = false;
      notifyListeners();
    }
  }

  Future<bool> uploadSubjectCover(String id, Uint8List bytes, String filename) async {
    isUploadingCover = true;
    coverError = null;
    notifyListeners();
    try {
      await _service.uploadSubjectPhoto(id, bytes, filename);
      await loadCurriculum();
      return true;
    } on ApiException catch (e) {
      coverError = e.message;
      return false;
    } catch (_) {
      coverError = 'Unable to upload the cover image. Please try again.';
      return false;
    } finally {
      isUploadingCover = false;
      notifyListeners();
    }
  }

  Future<bool> removeSubjectCover(String id) async {
    isUploadingCover = true;
    coverError = null;
    notifyListeners();
    try {
      await _service.deleteSubjectPhoto(id);
      await loadCurriculum();
      return true;
    } on ApiException catch (e) {
      coverError = e.message;
      return false;
    } finally {
      isUploadingCover = false;
      notifyListeners();
    }
  }

  Future<bool> uploadChapterCover(String id, Uint8List bytes, String filename) async {
    isUploadingCover = true;
    coverError = null;
    notifyListeners();
    try {
      await _service.uploadChapterPhoto(id, bytes, filename);
      await loadCurriculum();
      return true;
    } on ApiException catch (e) {
      coverError = e.message;
      return false;
    } catch (_) {
      coverError = 'Unable to upload the cover image. Please try again.';
      return false;
    } finally {
      isUploadingCover = false;
      notifyListeners();
    }
  }

  Future<bool> removeChapterCover(String id) async {
    isUploadingCover = true;
    coverError = null;
    notifyListeners();
    try {
      await _service.deleteChapterPhoto(id);
      await loadCurriculum();
      return true;
    } on ApiException catch (e) {
      coverError = e.message;
      return false;
    } finally {
      isUploadingCover = false;
      notifyListeners();
    }
  }
}
