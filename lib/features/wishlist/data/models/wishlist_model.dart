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
    final productData = json['product'] as Map<String, dynamic>;

    return WishlistItemModel(
      id: json['_id'],
      productId: productData['_id'],
      title: productData['title'] ?? 'No title',
      currentPrice: productData['current_price'] ?? 0,
      photos: productData['photos'] != null
          ? List<String>.from(productData['photos'])
          : [],
    );
  }
}

class WishlistModel {
  final List<WishlistItemModel> items;
  final int total;
  final int? nextPage;
  final int? lastPage;

  WishlistModel({
    required this.items,
    required this.total,
    this.nextPage,
    this.lastPage,
  });

  factory WishlistModel.fromJson(Map<String, dynamic> json) {
    List<WishlistItemModel> items = [];
    if (json['data'] != null && json['data']['results'] != null) {
      final results = json['data']['results'] as List;
      items = results.map((item) => WishlistItemModel.fromJson(item)).toList();
    }

    return WishlistModel(
      items: items,
      total: json['data']?['total'] ?? 0,
      nextPage: json['data']?['next'],
      lastPage: json['data']?['last_page'],
    );
  }
}
