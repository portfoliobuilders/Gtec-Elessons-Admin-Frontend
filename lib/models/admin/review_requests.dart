/// `POST /admin/reviews` (and the `/subjects/:id/reviews`,
/// `/pricing/products/:id/reviews` scoped variants). `userId` is accepted by
/// the DTO but ignored server-side — the reviewer is always the caller's
/// JWT identity — so it's deliberately not a field here.
class CreateReviewRequest {
  const CreateReviewRequest({required this.rating, this.comment, this.productId, this.subjectId});

  /// 1–5.
  final int rating;
  final String? comment;
  final String? productId;
  final String? subjectId;

  Map<String, dynamic> toJson() => {
        'rating': rating,
        if (comment != null) 'comment': comment,
        if (productId != null) 'productId': productId,
        if (subjectId != null) 'subjectId': subjectId,
      };
}
