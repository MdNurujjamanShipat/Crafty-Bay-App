import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../shared/presentation/widgets/snack_bar_message.dart';
import '../../data/models/create_review_model.dart';
import '../providers/review_provider.dart';
import '../widgets/rating_star.dart';

class CreateReviewScreen extends StatefulWidget {
  const CreateReviewScreen({
    super.key,
    required this.productId,
    required this.productTitle,
  });

  static const String name = '/create-review';

  final String productId;
  final String productTitle;

  @override
  State<CreateReviewScreen> createState() => _CreateReviewScreenState();
}

class _CreateReviewScreenState extends State<CreateReviewScreen> {
  final TextEditingController _commentController = TextEditingController();
  int _rating = 0;
  late ReviewProvider _reviewProvider;

  @override
  void initState() {
    super.initState();
    _reviewProvider = ReviewProvider();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _reviewProvider,
      child: Scaffold(
        appBar: AppBar(title: const Text('Write a Review')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.shopping_bag,
                      size: 24,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.productTitle,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'Your Rating',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Center(
                child: RatingStar(
                  rating: _rating,
                  size: 40,
                  interactive: true,
                  onRatingChanged: (rating) {
                    setState(() {
                      _rating = rating;
                    });
                  },
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'Your Review',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _commentController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Share your experience with this product...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
              const SizedBox(height: 32),
              Consumer<ReviewProvider>(
                builder: (context, provider, _) {
                  return SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed:
                          (_rating == 0 ||
                              _commentController.text.trim().isEmpty ||
                              provider.isSubmitting)
                          ? null
                          : () async {
                              final review = CreateReviewModel(
                                productId: widget.productId,
                                comment: _commentController.text.trim(),
                                rating: _rating,
                              );

                              final isSuccess = await provider.createReview(
                                review,
                              );

                              if (isSuccess && mounted) {
                                showSnackBarMessage(
                                  context,
                                  'Review submitted successfully!',
                                );
                                Navigator.pop(context, true);
                              } else if (mounted) {
                                showSnackBarMessage(
                                  context,
                                  provider.errorMessage ??
                                      'Failed to submit review',
                                );
                              }
                            },
                      child: provider.isSubmitting
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Submit Review',
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    _reviewProvider.dispose();
    super.dispose();
  }
}
