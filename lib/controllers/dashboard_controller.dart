import 'package:flutter/foundation.dart';

import '../core/constants/app_icons.dart';
import '../core/widgets/charts.dart';
import '../models/models.dart';

/// Dashboard — KPI, enrollment chart, revenue split, top courses.
/// Data mirrors the design 1:1; swap with API calls when wiring backend.
class DashboardController extends ChangeNotifier {
  final List<KpiModel> kpis = const [
    KpiModel(
        caption: 'Active enrollments',
        value: '12,480',
        delta: '+8.2%',
        iconPaths: AppIcons.user),
    KpiModel(
        caption: 'Revenue · this month',
        value: '₹48.2L',
        delta: '+12%',
        iconPaths: AppIcons.pricing),
    KpiModel(
        caption: 'Avg. completion rate',
        value: '64%',
        delta: '+3.1%',
        iconPaths: AppIcons.assessments),
    KpiModel(
        caption: 'Avg. video drop-off',
        value: '23%',
        delta: '−2.4%',
        deltaPositive: false,
        iconPaths: AppIcons.trendingDown,
        accent: true),
  ];

  final List<StackedBarData> enrollmentBars = const [
    StackedBarData(label: 'Nov', total: 0.48, topFraction: 0.24),
    StackedBarData(label: 'Dec', total: 0.56, topFraction: 0.26),
    StackedBarData(label: 'Jan', total: 0.52, topFraction: 0.22),
    StackedBarData(label: 'Feb', total: 0.68, topFraction: 0.28),
    StackedBarData(label: 'Mar', total: 0.74, topFraction: 0.30),
    StackedBarData(label: 'Apr', total: 0.64, topFraction: 0.25),
    StackedBarData(label: 'May', total: 0.86, topFraction: 0.32),
    StackedBarData(label: 'Jun', total: 1.00, topFraction: 0.34),
  ];

  final double revenueIndiaShare = 0.72;
  final String revenueTotal = '₹48.2L';

  final List<CourseModel> topCourses = const [
    CourseModel(
        code: 'MAT',
        name: 'Class 10 Mathematics',
        enrollments: '3,210',
        revenue: '₹11.2L',
        dropOff: '18%'),
    CourseModel(
        code: 'SCI',
        name: 'Class 10 Science',
        enrollments: '2,940',
        revenue: '₹10.3L',
        dropOff: '21%'),
    CourseModel(
        code: 'SST',
        name: 'Class 10 Social Science',
        enrollments: '2,110',
        revenue: '₹6.8L',
        dropOff: '29%',
        dropOffCritical: true),
  ];
}
