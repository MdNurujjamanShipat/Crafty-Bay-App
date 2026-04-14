class ReviewUserModel {
  final String id;
  final String firstName;
  final String lastName;
  final String? avatarUrl;

  ReviewUserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.avatarUrl,
  });

  factory ReviewUserModel.fromJson(Map<String, dynamic> json) {
    return ReviewUserModel(
      id: json['_id'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      avatarUrl: json['avatar_url'],
    );
  }

  String get fullName => '$firstName $lastName';
}

class ReviewProductModel {
  final String id;
  final String title;
  final String slug;
  final List<String> photos;

  ReviewProductModel({
    required this.id,
    required this.title,
    required this.slug,
    required this.photos,
  });

  factory ReviewProductModel.fromJson(Map<String, dynamic> json) {
    return ReviewProductModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      slug: json['slug'] ?? '',
      photos: json['photos'] != null ? List<String>.from(json['photos']) : [],
    );
  }
}

class ReviewModel {
  final String id;
  final ReviewProductModel product;
  final ReviewUserModel user;
  final int rating;
  final String comment;
  final DateTime createdAt;
  final DateTime updatedAt;

  ReviewModel({
    required this.id,
    required this.product,
    required this.user,
    required this.rating,
    required this.comment,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['_id'] ?? '',
      product: ReviewProductModel.fromJson(json['product'] ?? {}),
      user: ReviewUserModel.fromJson(json['user'] ?? {}),
      rating: json['rating'] ?? 0,
      comment: json['comment'] ?? '',
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}

class ReviewListModel {
  final List<ReviewModel> reviews;
  final int total;
  final int? nextPage;
  final int lastPage;

  ReviewListModel({
    required this.reviews,
    required this.total,
    this.nextPage,
    required this.lastPage,
  });

  factory ReviewListModel.fromJson(Map<String, dynamic> json) {
    List<ReviewModel> reviews = [];

    if (json['data'] != null && json['data']['results'] != null) {
      final results = json['data']['results'] as List;
      reviews = results.map((item) => ReviewModel.fromJson(item)).toList();
    }

    return ReviewListModel(
      reviews: reviews,
      total: json['data']?['total'] ?? 0,
      nextPage: json['data']?['next'],
      lastPage: json['data']?['last_page'] ?? 1,
    );
  }
}
