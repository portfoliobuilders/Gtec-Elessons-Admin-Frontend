import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/team_controller.dart';
import '../../../models/admin/admin_models.dart';
import '../curriculum/curriculum_form_fields.dart';
import '../curriculum/save_action_bar.dart';

final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

/// TEACHER | ADMIN only — matches `CreateTeamInviteRequest.role` exactly;
/// STUDENT and SUPER_ADMIN are never offered.
const List<String> _inviteRoles = ['TEACHER', 'ADMIN'];

String _inviteRoleOptionLabel(String role) => role == 'ADMIN' ? 'Admin' : 'Teacher';

/// Invite Member — dialog form for `POST /admin/team-invites`. Returns true
/// if an invite was created.
Future<bool> showInviteMemberDialog(BuildContext context) async {
  final result = await showDialog<bool>(context: context, builder: (context) => const _InviteMemberDialog());
  return result ?? false;
}

class _InviteMemberDialog extends StatefulWidget {
  const _InviteMemberDialog();

  @override
  State<_InviteMemberDialog> createState() => _InviteMemberDialogState();
}

class _InviteMemberDialogState extends State<_InviteMemberDialog> {
  final _emailController = TextEditingController();
  final _teamNameController = TextEditingController();
  String _role = _inviteRoles.first;
  bool _saving = false;

  @override
  void dispose() {
    _emailController.dispose();
    _teamNameController.dispose();
    super.dispose();
  }

  void _showMessage(String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

  Future<void> _save() async {
    if (_saving) return;
    final email = _emailController.text.trim();
    if (email.isEmpty || !_emailPattern.hasMatch(email)) {
      _showMessage('Enter a valid email address.');
      return;
    }
    final teamName = _teamNameController.text.trim();

    setState(() => _saving = true);
    final controller = context.read<TeamController>();
    final ok = await controller.inviteMember(
      CreateTeamInviteRequest(email: email, role: _role, teamName: teamName.isEmpty ? null : teamName),
    );
    if (!mounted) return;
    setState(() => _saving = false);

    if (ok) {
      Navigator.of(context).pop(true);
    } else {
      _showMessage(controller.inviteError ?? 'Unable to send invitation. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Invite Member'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LabeledTextField('Email', required: true, controller: _emailController, hint: 'name@example.com'),
            const SizedBox(height: 16),
            LabeledDropdownField<String>(
              'Role',
              value: _role,
              items: _inviteRoles,
              itemLabel: _inviteRoleOptionLabel,
              required: true,
              onChanged: (v) => setState(() => _role = v ?? _role),
            ),
            const SizedBox(height: 16),
            LabeledTextField('Team Name', controller: _teamNameController, hint: 'Optional'),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      actions: [
        SaveActionBar(
          onCancel: () => Navigator.of(context).pop(false),
          onSave: _saving ? () {} : _save,
          saveLabel: _saving ? 'Sending…' : 'Send Invite',
        ),
      ],
    );
  }
}
