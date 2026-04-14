import 'package:flutter/material.dart';
import '../../../shared/presentation/widgets/network_image_widget.dart';
import 'rating_star.dart';

class ReviewCard extends StatelessWidget {
  final String userName;
  final String? avatarUrl;
  final int rating;
  final String comment;
  final DateTime createdAt;
  final String? productImage;

  const ReviewCard({
    super.key,
    required this.userName,
    this.avatarUrl,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.productImage,
  });

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} year${(difference.inDays / 365).floor() > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} month${(difference.inDays / 30).floor() > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[200],
              ),
              child: avatarUrl != null && avatarUrl!.isNotEmpty
                  ? ClipOval(
                      child: AppNetworkImage(
                        urls: [avatarUrl!],
                        fit: BoxFit.cover,
                      ),
                    )
                  : productImage != null && productImage!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: AppNetworkImage(
                        urls: [productImage!],
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Icon(Icons.person, size: 30, color: Colors.grey),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          userName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Text(
                        _formatDate(createdAt),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  RatingStar(rating: rating, size: 16),
                  const SizedBox(height: 8),
                  Text(comment, style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
