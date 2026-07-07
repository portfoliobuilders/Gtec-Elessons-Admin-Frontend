/// Top-courses table row (dashboard) & needs-attention row (growth).
class CourseModel {
  const CourseModel({
    required this.code,
    required this.name,
    this.enrollments,
    this.revenue,
    this.dropOff,
    this.dropOffCritical = false,
    this.rating,
    this.refunds,
  });

  final String code;
  final String name;
  final String? enrollments;
  final String? revenue;
  final String? dropOff;
  final bool dropOffCritical;
  final String? rating;
  final String? refunds;
}
