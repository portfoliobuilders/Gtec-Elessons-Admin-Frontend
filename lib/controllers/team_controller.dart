import 'package:flutter/foundation.dart';

import '../models/models.dart';

/// Team & Roles — members + permission matrix.
class TeamController extends ChangeNotifier {
  final List<TeamMemberModel> members = const [
    TeamMemberModel(
        monogram: 'RM',
        name: 'Riya Mathew',
        email: 'riya@gtec.edu',
        role: 'SUPER ADMIN',
        scope: 'Everything · app + web',
        status: 'ACTIVE'),
    TeamMemberModel(
        monogram: 'KP',
        name: 'Karthik P.',
        email: 'karthik@gtec.edu',
        role: 'ADMIN',
        scope: 'Content, pricing, payments',
        status: 'ACTIVE'),
    TeamMemberModel(
        monogram: 'RM',
        name: 'R. Menon',
        email: 'menon@gtec.edu',
        role: 'TEACHER',
        scope: 'Maths · own classes',
        status: 'ACTIVE'),
    TeamMemberModel(
        monogram: 'SI',
        name: 'S. Iyer',
        email: 'iyer@gtec.edu',
        role: 'TEACHER',
        scope: 'Science · own classes',
        status: 'INVITED'),
  ];

  final List<PermissionModel> permissions = const [
    PermissionModel(
        capability: 'Upload lessons & materials',
        superAdmin: true,
        admin: true,
        teacher: true),
    PermissionModel(
        capability: 'Run live classes & grade tests',
        superAdmin: true,
        admin: true,
        teacher: true),
    PermissionModel(
        capability: 'Edit pricing & manage payments',
        superAdmin: true,
        admin: true,
        teacher: false),
    PermissionModel(
        capability: 'Publish app & web content',
        superAdmin: true,
        admin: true,
        teacher: false),
    PermissionModel(
        capability: 'Manage team, roles & settings',
        superAdmin: true,
        admin: false,
        teacher: false),
  ];
}
