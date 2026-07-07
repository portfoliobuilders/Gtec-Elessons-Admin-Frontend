/// Curriculum module with nested lessons.
class ModuleModel {
  const ModuleModel({
    required this.title,
    required this.subtitle,
    required this.isDraft,
    this.expanded = false,
    this.lessons = const [],
  });

  final String title;
  final String subtitle;
  final bool isDraft;
  final bool expanded;
  final List<LessonModel> lessons;

  ModuleModel copyWith({bool? expanded}) => ModuleModel(
        title: title,
        subtitle: subtitle,
        isDraft: isDraft,
        expanded: expanded ?? this.expanded,
        lessons: lessons,
      );
}

class LessonModel {
  const LessonModel({required this.title, required this.duration});

  final String title;
  final String duration;
}
