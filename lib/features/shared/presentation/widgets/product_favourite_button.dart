import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/app_colors.dart';
import '../../../wishlist/presentation/providers/wishlist_provider.dart';
import 'snack_bar_message.dart';

class ProductFavouriteButton extends StatelessWidget {
  const ProductFavouriteButton({
    super.key,
    this.productId,
    this.onWishlistChanged,
  });

  final String? productId;
  final VoidCallback? onWishlistChanged;

  @override
  Widget build(BuildContext context) {
    if (productId == null) {
      return Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: AppColors.themeColor,
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Icon(
          Icons.favorite_outline,
          color: Colors.white,
          size: 16,
        ),
      );
    }
    return Consumer<WishlistProvider>(
      builder: (context, wishlistProvider, _) {
        final isFavourite = wishlistProvider.isProductInWishlist(productId!);
        final isProcessing = wishlistProvider.isAddingToWishlist;

        return GestureDetector(
          onTap: isProcessing
              ? null
              : () async {
                  bool success;
                  if (isFavourite) {
                    final wishlistItemId = wishlistProvider.getWishlistItemId(
                      productId!,
                    );
                    if (wishlistItemId != null) {
                      success = await wishlistProvider.removeFromWishlist(
                        wishlistItemId,
                      );
                      if (success && context.mounted) {
                        showSnackBarMessage(context, 'Removed from wishlist');
                        onWishlistChanged?.call();
                      }
                    } else {
                      success = false;
                    }
                  } else {
                    success = await wishlistProvider.addToWishlist(productId!);
                    if (success && context.mounted) {
                      showSnackBarMessage(context, 'Added to wishlist');
                      onWishlistChanged?.call();
                    }
                  }

                  if (!success && context.mounted) {
                    showSnackBarMessage(
                      context,
                      wishlistProvider.errorMessage ?? 'Operation failed',
                    );
                  }
                },
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isFavourite ? Colors.red : AppColors.themeColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              isFavourite ? Icons.favorite : Icons.favorite_outline,
              color: Colors.white,
              size: 16,
            ),
          ),
        );
      },
    );
  }
}
