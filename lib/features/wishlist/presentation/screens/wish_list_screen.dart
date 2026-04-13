import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../products/data/models/product_model.dart';
import '../../../shared/presentation/widgets/center_circular_progress.dart';
import '../../../shared/presentation/widgets/product_card.dart';
import '../../data/models/wishlist_model.dart';
import '../providers/wishlist_provider.dart';

class WishListScreen extends StatefulWidget {
  const WishListScreen({super.key});

  static const String name = '/wish-list';

  @override
  State<WishListScreen> createState() => _WishListScreenState();
}

class _WishListScreenState extends State<WishListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WishlistProvider>().getWishlist();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wishlist'),
        actions: [
          Consumer<WishlistProvider>(
            builder: (context, provider, _) {
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(
                  child: Text(
                    '${provider.wishlistCount} items',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<WishlistProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const CenterCircularProgress();
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    provider.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.getWishlist(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (provider.wishlistItems.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Your wishlist is empty',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Start adding items to your wishlist',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: provider.wishlistItems.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 0.75,
            ),
            itemBuilder: (context, index) {
              final WishlistItemModel item = provider.wishlistItems[index];
              final productModel = ProductModel(
                id: item.productId,
                title: item.title,
                currentPrice: item.currentPrice,
                photos: item.photos,
              );
              return ProductCard(productModel: productModel);
            },
          );
        },
      ),
    );
  }
}
