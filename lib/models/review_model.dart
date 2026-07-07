/// Growth screen — latest review card row.
class ReviewModel {
  const ReviewModel({
    required this.author,
    required this.rating,
    required this.ratingGood,
    required this.text,
  });

  final String author;
  final String rating;
  final bool ratingGood;
  final String text;
}
