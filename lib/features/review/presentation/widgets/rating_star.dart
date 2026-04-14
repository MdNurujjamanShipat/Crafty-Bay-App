import 'package:flutter/material.dart';

class RatingStar extends StatelessWidget {
  final int rating;
  final double size;
  final bool interactive;
  final Function(int)? onRatingChanged;

  const RatingStar({
    super.key,
    required this.rating,
    this.size = 20,
    this.interactive = false,
    this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: interactive && onRatingChanged != null
              ? () => onRatingChanged!(index + 1)
              : null,
          child: Icon(
            index < rating ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: size,
          ),
        );
      }),
    );
  }
}
