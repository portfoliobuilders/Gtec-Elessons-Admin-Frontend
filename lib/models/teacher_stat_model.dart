/// Growth screen — teacher activity row.
class TeacherStatModel {
  const TeacherStatModel({
    required this.monogram,
    required this.name,
    required this.live,
    required this.graded,
    required this.sla,
    required this.slaGood,
    required this.rating,
    required this.ratingGood,
  });

  final String monogram;
  final String name;
  final String live;
  final String graded;
  final String sla;
  final bool slaGood;
  final String rating;
  final bool ratingGood; // false → amber
}
