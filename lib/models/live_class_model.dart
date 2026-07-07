/// Upcoming live class (teacher console) & submissions to grade.
class LiveClassModel {
  const LiveClassModel({
    required this.day,
    required this.date,
    required this.title,
    required this.meta,
  });

  final String day;
  final String date;
  final String title;
  final String meta;
}

class SubmissionModel {
  const SubmissionModel({required this.student, required this.task});

  final String student;
  final String task;
}
