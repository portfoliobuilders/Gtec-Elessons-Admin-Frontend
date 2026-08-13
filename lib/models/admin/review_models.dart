/// Backend-aligned Review model — mirrors `GET /admin/reviews`.
class AdminReviewModel {
  const AdminReviewModel({
    required this.id,
    this.userId,
    this.userName,
    this.userEmail,
    this.productId,
    this.productTitle,
    this.subjectId,
    this.subjectName,
    required this.rating,
    this.comment,
    this.isApproved = true,
    required this.createdAt,
  });

  final String id;
  final String? userId;
  final String? userName;
  final String? userEmail;
  final String? productId;
  final String? productTitle;
  final String? subjectId;
  final String? subjectName;

  /// 1–5.
  final int rating;
  final String? comment;
  final bool isApproved;
  final DateTime createdAt;

  factory AdminReviewModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    final product = json['product'] as Map<String, dynamic>?;
    final subject = json['subject'] as Map<String, dynamic>?;
    return AdminReviewModel(
      id: json['id'] as String,
      userId: user?['id'] as String? ?? json['userId'] as String?,
      userName: user?['name'] as String?,
      userEmail: user?['email'] as String?,
      productId: product?['id'] as String? ?? json['productId'] as String?,
      productTitle: product?['title'] as String?,
      subjectId: subject?['id'] as String? ?? json['subjectId'] as String?,
      subjectName: subject?['name'] as String?,
      rating: json['rating'] as int,
      comment: json['comment'] as String?,
      isApproved: json['isApproved'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
