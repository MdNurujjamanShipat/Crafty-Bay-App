import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../shared/presentation/widgets/center_circular_progress.dart';
import '../../data/models/review_model.dart';
import '../providers/review_provider.dart';
import '../widgets/review_card.dart';
import 'create_review_screen.dart';

class ReviewListScreen extends StatefulWidget {
  const ReviewListScreen({
    super.key,
    required this.productId,
    required this.productTitle,
    this.productImage,
  });

  static const String name = '/review-list';

  final String productId;
  final String productTitle;
  final String? productImage;

  @override
  State<ReviewListScreen> createState() => _ReviewListScreenState();
}

class _ReviewListScreenState extends State<ReviewListScreen> {
  late ReviewProvider _reviewProvider;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _reviewProvider = ReviewProvider();
    _loadReviews();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _loadReviews() async {
    await _reviewProvider.getProductReviews(productId: widget.productId);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (_reviewProvider.hasMore && !_reviewProvider.isLoading) {
        _reviewProvider.getProductReviews(
          productId: widget.productId,
          loadMore: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _reviewProvider,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Reviews (${widget.productTitle})'),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  CreateReviewScreen.name,
                  arguments: {
                    'productId': widget.productId,
                    'productTitle': widget.productTitle,
                  },
                ).then((_) {
                  _reviewProvider.clearReviews();
                  _loadReviews();
                });
              },
              icon: const Icon(Icons.rate_review),
              tooltip: 'Write a review',
            ),
          ],
        ),
        body: Consumer<ReviewProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading && provider.reviews.isEmpty) {
              return const CenterCircularProgress();
            }

            if (provider.errorMessage != null && provider.reviews.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      provider.errorMessage!,
                      style: const TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadReviews,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (provider.reviews.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.reviews_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No reviews yet',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Be the first to review ${widget.productTitle}',
                      style: const TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          CreateReviewScreen.name,
                          arguments: {
                            'productId': widget.productId,
                            'productTitle': widget.productTitle,
                          },
                        ).then((_) {
                          _reviewProvider.clearReviews();
                          _loadReviews();
                        });
                      },
                      icon: const Icon(Icons.add_circle),
                      label: const Text('Write a Review'),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.grey[50],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${provider.totalReviews} Reviews',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Average Rating: ${_calculateAverageRating(provider.reviews).toStringAsFixed(1)}/5',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            CreateReviewScreen.name,
                            arguments: {
                              'productId': widget.productId,
                              'productTitle': widget.productTitle,
                            },
                          ).then((_) {
                            _reviewProvider.clearReviews();
                            _loadReviews();
                          });
                        },

                        icon: const Icon(Icons.add_circle),
                        label: const Text('Write Review'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount:
                        provider.reviews.length + (provider.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == provider.reviews.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      final review = provider.reviews[index];
                      return ReviewCard(
                        userName: review.user.fullName,
                        avatarUrl: review.user.avatarUrl,
                        rating: review.rating,
                        comment: review.comment,
                        createdAt: review.createdAt,
                        productImage: widget.productImage,
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  double _calculateAverageRating(List<ReviewModel> reviews) {
    if (reviews.isEmpty) return 0;
    final sum = reviews.fold<int>(0, (total, review) => total + review.rating);
    return (sum / reviews.length);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _reviewProvider.reset();
    super.dispose();
  }
}
