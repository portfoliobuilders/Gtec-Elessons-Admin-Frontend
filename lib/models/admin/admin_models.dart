/// Barrel file — every backend-aligned Admin model + request type.
/// Deliberately separate from `lib/models/models.dart` (the prototype/mock
/// UI models) to avoid class-name collisions — see curriculum_models.dart's
/// header comment.
library admin_models;

export 'analytics_models.dart';
export 'assessment_models.dart';
export 'assessment_requests.dart';
export 'assignment_models.dart';
export 'assignment_requests.dart';
export 'curriculum_models.dart';
export 'curriculum_requests.dart';
export 'enrollment_models.dart';
export 'live_class_models.dart';
export 'live_class_requests.dart';
export 'order_models.dart';
export 'pricing_models.dart';
export 'pricing_requests.dart';
export 'review_models.dart';
export 'review_requests.dart';
export 'settings_models.dart';
export 'settings_requests.dart';
export 'student_models.dart';
export 'student_requests.dart';
export 'team_models.dart';
export 'team_requests.dart';
