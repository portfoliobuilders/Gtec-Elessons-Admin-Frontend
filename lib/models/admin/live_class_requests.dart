/// `startsAt`/`endsAt` must be ISO-8601 date strings (`@IsDateString()` on
/// the backend) — use `DateTime.toIso8601String()`.
class CreateLiveClassRequest {
  const CreateLiveClassRequest({
    required this.title,
    this.description,
    this.gradeId,
    this.subjectId,
    required this.mentorName,
    this.youtubeUrl,
    required this.startsAt,
    this.endsAt,
  });

  final String title;
  final String? description;
  final String? gradeId;
  final String? subjectId;
  final String mentorName;
  final String? youtubeUrl;
  final String startsAt;
  final String? endsAt;

  Map<String, dynamic> toJson() => {
        'title': title,
        if (description != null) 'description': description,
        if (gradeId != null) 'gradeId': gradeId,
        if (subjectId != null) 'subjectId': subjectId,
        'mentorName': mentorName,
        if (youtubeUrl != null) 'youtubeUrl': youtubeUrl,
        'startsAt': startsAt,
        if (endsAt != null) 'endsAt': endsAt,
      };
}
