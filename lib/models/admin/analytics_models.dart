// Backend-aligned Analytics/Insights models. "Dashboard" (AdminAnalyticsService,
// GET /admin/analytics/*) and "Growth/Insights" (AdminFeatureService, GET
// /admin/insights/*) are two distinct backend services with different data —
// kept as separate model groups to match.

class EnrollmentDayCountModel {
  const EnrollmentDayCountModel({required this.date, required this.count});

  /// `yyyy-MM-dd`.
  final String date;
  final int count;

  factory EnrollmentDayCountModel.fromJson(Map<String, dynamic> json) =>
      EnrollmentDayCountModel(date: json['date'] as String, count: json['count'] as int);
}

/// `GET /admin/analytics/overview`.
class DashboardOverviewModel {
  const DashboardOverviewModel({
    required this.students,
    required this.activeEnrollments,
    required this.paidOrders,
    this.revenueByCurrency = const {},
    this.revenueByRegion = const {},
    required this.completionRate,
    this.enrollmentsOverTime = const [],
  });

  final int students;
  final int activeEnrollments;
  final int paidOrders;

  /// `{ currency: totalCents }`.
  final Map<String, int> revenueByCurrency;

  /// `{ region: { currency: totalCents } }`.
  final Map<String, Map<String, int>> revenueByRegion;
  final int completionRate;
  final List<EnrollmentDayCountModel> enrollmentsOverTime;

  factory DashboardOverviewModel.fromJson(Map<String, dynamic> json) => DashboardOverviewModel(
        students: json['students'] as int,
        activeEnrollments: json['activeEnrollments'] as int,
        paidOrders: json['paidOrders'] as int,
        revenueByCurrency: (json['revenueByCurrency'] as Map<String, dynamic>? ?? const {})
            .map((k, v) => MapEntry(k, v as int)),
        revenueByRegion: (json['revenueByRegion'] as Map<String, dynamic>? ?? const {}).map(
          (region, byCurrency) => MapEntry(
            region,
            (byCurrency as Map<String, dynamic>).map((k, v) => MapEntry(k, v as int)),
          ),
        ),
        completionRate: json['completionRate'] as int? ?? 0,
        enrollmentsOverTime: (json['enrollmentsOverTime'] as List<dynamic>?)
                ?.map((e) => EnrollmentDayCountModel.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
      );
}

/// `GET /admin/analytics/top-courses`.
class TopCourseModel {
  const TopCourseModel({this.subjectId, this.subject, this.grade, required this.enrollments});

  final String? subjectId;
  final String? subject;
  final String? grade;
  final int enrollments;

  factory TopCourseModel.fromJson(Map<String, dynamic> json) => TopCourseModel(
        subjectId: json['subjectId'] as String?,
        subject: json['subject'] as String?,
        grade: json['grade'] as String?,
        enrollments: json['enrollments'] as int? ?? 0,
      );
}

/// `GET /admin/analytics/recent-orders`.
class RecentOrderModel {
  const RecentOrderModel({
    required this.orderNumber,
    required this.totalCents,
    required this.currency,
    required this.createdAt,
    this.billingName,
    this.billingPhone,
    this.billingAddress,
    this.billingCity,
    this.billingState,
    this.billingPincode,
    this.userName,
    this.userEmail,
  });

  final String orderNumber;
  final int totalCents;
  final String currency;
  final DateTime createdAt;
  final String? billingName;
  final String? billingPhone;
  final String? billingAddress;
  final String? billingCity;
  final String? billingState;
  final String? billingPincode;
  final String? userName;
  final String? userEmail;

  factory RecentOrderModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    return RecentOrderModel(
      orderNumber: json['orderNumber'] as String,
      totalCents: json['totalCents'] as int,
      currency: json['currency'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      billingName: json['billingName'] as String?,
      billingPhone: json['billingPhone'] as String?,
      billingAddress: json['billingAddress'] as String?,
      billingCity: json['billingCity'] as String?,
      billingState: json['billingState'] as String?,
      billingPincode: json['billingPincode'] as String?,
      userName: user?['name'] as String?,
      userEmail: user?['email'] as String?,
    );
  }
}

/// `GET /admin/insights/overview`.
class InsightsOverviewModel {
  const InsightsOverviewModel({
    required this.students,
    required this.teachers,
    required this.activeEnrollments,
    required this.pendingOrders,
    this.averageRating,
  });

  final int students;
  final int teachers;
  final int activeEnrollments;
  final int pendingOrders;
  final num? averageRating;

  factory InsightsOverviewModel.fromJson(Map<String, dynamic> json) => InsightsOverviewModel(
        students: json['students'] as int,
        teachers: json['teachers'] as int,
        activeEnrollments: json['activeEnrollments'] as int,
        pendingOrders: json['pendingOrders'] as int,
        averageRating: json['averageRating'] as num?,
      );
}

/// `GET /admin/insights/funnel`. `visitors`/`trialStarts`/`conversionRate`
/// are genuinely `null` on the wire — visitor/trial-start tracking is not
/// instrumented on the backend yet (see [note]). Do NOT default these to 0;
/// a real 0 and "not tracked" are different facts.
class InsightsFunnelModel {
  const InsightsFunnelModel({
    this.visitors,
    this.trialStarts,
    required this.paidEnrollments,
    this.conversionRate,
    this.note,
  });

  final int? visitors;
  final int? trialStarts;
  final int paidEnrollments;
  final num? conversionRate;
  final String? note;

  factory InsightsFunnelModel.fromJson(Map<String, dynamic> json) => InsightsFunnelModel(
        visitors: json['visitors'] as int?,
        trialStarts: json['trialStarts'] as int?,
        paidEnrollments: json['paidEnrollments'] as int? ?? 0,
        conversionRate: json['conversionRate'] as num?,
        note: json['note'] as String?,
      );
}

/// `GET /admin/insights/courses`.
class CourseInsightModel {
  const CourseInsightModel({required this.id, required this.title, required this.enrollments});

  final String id;
  final String? title;
  final int enrollments;

  factory CourseInsightModel.fromJson(Map<String, dynamic> json) => CourseInsightModel(
        id: json['id'] as String,
        title: json['title'] as String?,
        enrollments: json['enrollments'] as int? ?? 0,
      );
}

/// `GET /admin/insights/teachers`.
class TeacherInsightModel {
  const TeacherInsightModel({required this.id, this.name, this.email, required this.answeredDoubts});

  final String id;
  final String? name;
  final String? email;
  final int answeredDoubts;

  factory TeacherInsightModel.fromJson(Map<String, dynamic> json) => TeacherInsightModel(
        id: json['id'] as String,
        name: json['name'] as String?,
        email: json['email'] as String?,
        answeredDoubts: json['answeredDoubts'] as int? ?? 0,
      );
}
