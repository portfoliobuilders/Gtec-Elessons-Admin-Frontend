/// Student Management row.
class StudentModel {
  const StudentModel({
    required this.monogram,
    required this.name,
    required this.location,
    required this.grade,
    required this.courses,
    required this.progress,
    required this.status,
  });

  final String monogram;
  final String name;
  final String location;
  final String grade;
  final String courses;
  final String progress;
  final String status; // ACTIVE / EXPIRING / INACTIVE
}
