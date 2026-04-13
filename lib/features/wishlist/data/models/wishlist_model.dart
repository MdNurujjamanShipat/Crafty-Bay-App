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

class WishlistModel {
  final List<WishlistItemModel> items;

  WishlistModel({required this.items});

  factory WishlistModel.fromJson(Map<String, dynamic> json) {
    List<WishlistItemModel> items = [];
    if (json['data'] != null && json['data'] is List) {
      items = List<WishlistItemModel>.from(
        json['data'].map((item) => WishlistItemModel.fromJson(item)),
      );
    }
    return WishlistModel(items: items);
  }
}
