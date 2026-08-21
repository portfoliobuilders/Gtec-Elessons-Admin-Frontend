import '../../../core/widgets/status_badge.dart';

/// Backend enum `OrderStatus`: PENDING | PAID | FAILED | REFUNDED — exact
/// wire values, do not rename. Maps each to the closest existing
/// [BadgeStatus] variant (adding `refunded` was the only gap).
BadgeStatus orderStatusBadge(String status) => switch (status) {
      'PAID' => BadgeStatus.paid,
      'FAILED' => BadgeStatus.failed,
      'REFUNDED' => BadgeStatus.refunded,
      _ => BadgeStatus.draft, // PENDING
    };
