import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/network/api_exception.dart';
import '../core/services/admin_students_service.dart';
import '../core/services/admin_team_service.dart';
import '../models/admin/admin_models.dart';

enum TeamLoadStatus { initial, loading, loaded, error }

/// Team & Roles (Phase 8) — real state backed by [AdminTeamService]
/// (`GET/POST /admin/team-invites`, and the `GET /me/users?role=` roster —
/// there is no dedicated `/admin/team` endpoint) plus role changes reused
/// from [AdminStudentsService.setRole] (`PATCH /admin/students/:id/role`) —
/// no second role-mutation endpoint exists or is created here.
class TeamController extends ChangeNotifier {
  TeamController(this._teamService, this._studentsService);

  final AdminTeamService _teamService;
  final AdminStudentsService _studentsService;

  // ── Roster (ADMIN + TEACHER only — never STUDENT) ───────────────────────

  TeamLoadStatus rosterStatus = TeamLoadStatus.initial;
  String? rosterError;
  List<UserListItemModel> admins = [];
  List<UserListItemModel> teachers = [];
  String rosterSearch = '';

  bool get isRosterLoading => rosterStatus == TeamLoadStatus.loading;

  Future<void> loadRoster() async {
    rosterStatus = TeamLoadStatus.loading;
    rosterError = null;
    notifyListeners();
    try {
      final search = rosterSearch.trim().isEmpty ? null : rosterSearch.trim();
      final results = await Future.wait([
        _teamService.roster(role: 'ADMIN', search: search),
        _teamService.roster(role: 'TEACHER', search: search),
      ]);
      admins = results[0].users;
      teachers = results[1].users;
      rosterStatus = TeamLoadStatus.loaded;
    } on ApiException catch (e) {
      rosterError = e.message;
      rosterStatus = TeamLoadStatus.error;
    } catch (_) {
      rosterError = 'Unable to load the team roster. Please try again.';
      rosterStatus = TeamLoadStatus.error;
    }
    notifyListeners();
  }

  Future<void> refreshRoster() => loadRoster();

  Timer? _searchDebounce;

  void setRosterSearch(String value) {
    rosterSearch = value;
    notifyListeners();
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), loadRoster);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }

  String? roleChangeError;

  /// `newRole` must be `ADMIN` or `TEACHER` — reuses the exact Phase 6A
  /// endpoint/request model, no duplicate role API. On success, moves the
  /// member between [admins]/[teachers] locally instead of reloading both
  /// roster calls.
  Future<bool> changeMemberRole(UserListItemModel member, String newRole) async {
    try {
      await _studentsService.setRole(member.id, newRole);
      final updated = member.copyWith(role: newRole);
      admins = [for (final m in admins) if (m.id != member.id) m];
      teachers = [for (final m in teachers) if (m.id != member.id) m];
      if (newRole == 'ADMIN') {
        admins = [...admins, updated];
      } else {
        teachers = [...teachers, updated];
      }
      roleChangeError = null;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      roleChangeError = e.message;
      notifyListeners();
      return false;
    }
  }

  // ── Invitations ──────────────────────────────────────────────────────────
  // LIST + CREATE only — `GET`/`POST /admin/team-invites` are the only
  // verified endpoints; there is no revoke/resend/cancel endpoint, so none
  // is offered.

  TeamLoadStatus invitesStatus = TeamLoadStatus.initial;
  String? invitesError;
  List<TeamInviteModel> invites = [];

  bool get isInvitesLoading => invitesStatus == TeamLoadStatus.loading;

  Future<void> loadInvites() async {
    invitesStatus = TeamLoadStatus.loading;
    invitesError = null;
    notifyListeners();
    try {
      invites = await _teamService.listInvites();
      invitesStatus = TeamLoadStatus.loaded;
    } on ApiException catch (e) {
      invitesError = e.message;
      invitesStatus = TeamLoadStatus.error;
    } catch (_) {
      invitesError = 'Unable to load invitations. Please try again.';
      invitesStatus = TeamLoadStatus.error;
    }
    notifyListeners();
  }

  Future<void> refreshInvites() => loadInvites();

  String? inviteError;

  Future<bool> inviteMember(CreateTeamInviteRequest request) async {
    try {
      final created = await _teamService.createInvite(request);
      invites = [created, ...invites];
      inviteError = null;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      inviteError = e.message;
      notifyListeners();
      return false;
    }
  }
}
