import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/network/api_exception.dart';
import '../core/services/admin_enrollments_service.dart';
import '../core/services/admin_students_service.dart';
import '../models/admin/admin_models.dart';

enum StudentsLoadStatus { initial, loading, loaded, error }

/// Student Management — real roster backed by `GET/PATCH /admin/students*`
/// via [AdminStudentsService]. Phase 6A: list + detail + status/role. Phase
/// 6B adds subject enrollment granting via [AdminEnrollmentsService] — the
/// only enrollment mutation the backend exposes (no list/revoke endpoint).
class StudentsController extends ChangeNotifier {
  StudentsController(this._service, this._enrollmentsService);

  final AdminStudentsService _service;
  final AdminEnrollmentsService _enrollmentsService;

  // ── List ─────────────────────────────────────────────────────────────────

  StudentsLoadStatus status = StudentsLoadStatus.initial;
  String? error;
  List<StudentListItemModel> students = [];
  int total = 0;
  String search = '';

  bool get isLoading => status == StudentsLoadStatus.loading;

  Future<void> loadStudents() async {
    status = StudentsLoadStatus.loading;
    error = null;
    notifyListeners();
    try {
      final result = await _service.list(search: search.trim().isEmpty ? null : search.trim());
      students = result.students;
      total = result.total;
      status = StudentsLoadStatus.loaded;
    } on ApiException catch (e) {
      error = e.message;
      status = StudentsLoadStatus.error;
    } catch (_) {
      error = 'Unable to load students. Please try again.';
      status = StudentsLoadStatus.error;
    }
    notifyListeners();
  }

  Future<void> refreshStudents() => loadStudents();

  /// Debounced — `search` is a real server-side query param (confirmed live
  /// against `GET /admin/students?search=`), so every keystroke would
  /// otherwise fire a request.
  Timer? _searchDebounce;

  void setSearch(String value) {
    search = value;
    notifyListeners();
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), loadStudents);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }

  // ── Detail ───────────────────────────────────────────────────────────────

  StudentsLoadStatus detailStatus = StudentsLoadStatus.initial;
  String? detailError;
  StudentDetailModel? selectedStudent;

  bool get isDetailLoading => detailStatus == StudentsLoadStatus.loading;

  Future<void> loadStudent(String id) async {
    detailStatus = StudentsLoadStatus.loading;
    detailError = null;
    notifyListeners();
    try {
      selectedStudent = await _service.detail(id);
      detailStatus = StudentsLoadStatus.loaded;
    } on ApiException catch (e) {
      detailError = e.message;
      detailStatus = StudentsLoadStatus.error;
    } catch (_) {
      detailError = 'Unable to load student. Please try again.';
      detailStatus = StudentsLoadStatus.error;
    }
    notifyListeners();
  }

  void clearSelectedStudent() {
    selectedStudent = null;
    detailStatus = StudentsLoadStatus.initial;
    detailError = null;
  }

  /// `newStatus` must be one of the backend's `UserStatus` values (ACTIVE |
  /// SUSPENDED) — the caller (student_detail_screen.dart) only ever offers
  /// those two. On success, the affected student is patched locally in both
  /// [selectedStudent] and [students] — the PATCH response is the raw user
  /// row (see [StudentDetailModel]'s doc comment on sensitive columns), not
  /// something worth re-parsing, and we already know the value we just set.
  Future<bool> updateStudentStatus(String id, String newStatus) async {
    try {
      await _service.setStatus(id, newStatus);
      if (selectedStudent?.id == id) selectedStudent = selectedStudent!.copyWith(status: newStatus);
      students = [for (final s in students) s.id == id ? s.copyWith(status: newStatus) : s];
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      detailError = e.message;
      notifyListeners();
      return false;
    }
  }

  /// `newRole` must be one of STUDENT | TEACHER | ADMIN — SUPER_ADMIN is
  /// never offered (backend-enforced; see SetStudentRoleRequest).
  Future<bool> updateStudentRole(String id, String newRole) async {
    try {
      await _service.setRole(id, newRole);
      if (selectedStudent?.id == id) selectedStudent = selectedStudent!.copyWith(role: newRole);
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      detailError = e.message;
      notifyListeners();
      return false;
    }
  }

  // ── Delete ───────────────────────────────────────────────────────────────
  // The one destructive mutation here — `DELETE /admin/students/:id`. The
  // backend is the sole source of truth for whether a user can be deleted
  // (self-delete, role hierarchy, and the orders/enrollments/teaching
  // blockers are all enforced server-side — see AdminStudentsService.delete's
  // doc comment); this only reflects the outcome locally.

  bool isDeleting = false;
  String? deleteError;

  /// On success, removes the student from both [students] and
  /// [selectedStudent] (if it was the one deleted) — no full reload. On
  /// failure (most commonly a 409 listing what's blocking deletion), local
  /// state is left untouched and the message is exposed via [deleteError].
  Future<bool> deleteStudent(String id) async {
    if (isDeleting) return false;
    isDeleting = true;
    deleteError = null;
    notifyListeners();
    try {
      await _service.delete(id);
      students = [for (final s in students) if (s.id != id) s];
      if (total > 0) total -= 1;
      if (selectedStudent?.id == id) selectedStudent = null;
      return true;
    } on ApiException catch (e) {
      deleteError = e.message;
      return false;
    } catch (_) {
      deleteError = 'Unable to delete this student. Please try again.';
      return false;
    } finally {
      isDeleting = false;
      notifyListeners();
    }
  }

  // ── Enrollment grant (Phase 6B) ─────────────────────────────────────────
  // Only `POST .../enrollments` exists — no list/revoke endpoint — so
  // there's no separate loading/error state to own here: the grant response
  // (`GrantEnrollmentResultModel`) carries a full enrollment row, which is
  // enough to patch `selectedStudent.enrollments` locally (same pattern as
  // updateStudentStatus/updateStudentRole above), never a reload.

  String? enrollmentError;

  /// Grants (or renews) `studentId`'s access to `subjectId`. Uses its own
  /// `enrollmentError` field rather than `detailError` — a grant failure
  /// shouldn't clobber an unrelated status/role error the screen might
  /// still be showing.
  Future<bool> grantSubjectEnrollment(String studentId, String subjectId) async {
    try {
      final result = await _enrollmentsService.grantSubject(studentId: studentId, subjectId: subjectId);
      if (selectedStudent?.id == studentId) {
        final granted = StudentEnrollmentRefModel(
          id: result.enrollment.id,
          scopeType: result.enrollment.scopeType,
          format: result.enrollment.format,
          status: result.enrollment.status,
          startsAt: result.enrollment.startsAt,
          expiresAt: result.enrollment.expiresAt,
          productTitle: result.subjectName,
          gradeId: result.enrollment.gradeId,
          subjectId: result.enrollment.subjectId,
          chapterId: result.enrollment.chapterId,
        );
        final current = selectedStudent!.enrollments;
        final existingIndex = current.indexWhere((e) => e.id == granted.id);
        final updated = [...current];
        if (existingIndex >= 0) {
          updated[existingIndex] = granted;
        } else {
          updated.add(granted);
        }
        selectedStudent = selectedStudent!.copyWith(enrollments: updated);
      }
      enrollmentError = null;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      enrollmentError = e.message;
      notifyListeners();
      return false;
    }
  }
}
