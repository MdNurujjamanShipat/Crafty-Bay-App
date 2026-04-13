class WishlistItemModel {
  final String id;
  final String productId;
  final String title;
  final int currentPrice;
  final List<String> photos;

  WishlistItemModel({
    required this.id,
    required this.productId,
    required this.title,
    required this.currentPrice,
    required this.photos,
  });

  factory WishlistItemModel.fromJson(Map<String, dynamic> json) {
    return WishlistItemModel(
      id: json['_id'],
      productId: json['product']['_id'],
      title: json['product']['title'],
      currentPrice: json['product']['current_price'],
      photos: List<String>.from(json['product']['photos']),
    );
  }
}
