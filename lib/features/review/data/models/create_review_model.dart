class CreateReviewModel {
  final String productId;
  final String comment;
  final int rating;

  CreateReviewModel({
    required this.productId,
    required this.comment,
    required this.rating,
  });

  Map<String, dynamic> toJson() {
    return {'product': productId, 'comment': comment, 'rating': rating};
  }
}
