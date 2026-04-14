import 'package:crafty_bay/features/products/data/models/add_to_cart_model.dart';
import 'package:crafty_bay/features/products/presentation/providers/add_to_cart_provider.dart';
import 'package:crafty_bay/features/shared/presentation/widgets/center_circular_progress.dart';
import 'package:crafty_bay/features/shared/presentation/widgets/snack_bar_message.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/app_colors.dart';
import '../../../../app/extensions/utils_extension.dart';
import '../../../review/presentation/screens/review_list_screen.dart';
import '../../../shared/presentation/widgets/inc_dec_button.dart';
import '../../../shared/presentation/widgets/product_favourite_button.dart';
import '../../../shared/presentation/widgets/product_rating.dart';
import '../../../wishlist/presentation/providers/wishlist_provider.dart';
import '../providers/product_details_provider.dart';
import '../widgets/color_picker.dart';
import '../widgets/price_and_add_to_cart_section.dart';
import '../widgets/product_image_carousel.dart';
import '../widgets/size_picker.dart';

class ProductDetailsScreen extends StatefulWidget {
  const ProductDetailsScreen({super.key, required this.productId});

  static const String name = '/product-details';

  final String productId;

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  late ProductDetailsProvider _productDetailsProvider;
  late AddToCartProvider _addToCartProvider;

  int _quantity = 1;
  String? _selectedColor;
  String? _selectedSize;

  @override
  void initState() {
    super.initState();
    _productDetailsProvider = ProductDetailsProvider();
    _addToCartProvider = AddToCartProvider();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProductDetails();
      _loadWishlist();
    });
  }

  Future<void> _loadProductDetails() async {
    await _productDetailsProvider.getProductDetails(widget.productId);
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadWishlist() async {
    try {
      final wishlistProvider = context.read<WishlistProvider>();
      await wishlistProvider.getWishlist();
    } catch (e) {
      debugPrint('WishlistProvider not available: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _productDetailsProvider),
        ChangeNotifierProvider.value(value: _addToCartProvider),
      ],
      child: Scaffold(
        appBar: AppBar(title: const Text('Product details')),
        body: Consumer<ProductDetailsProvider>(
          builder: (context, provider, child) {
            if (provider.getProductDetailsInProgress) {
              return const CenterCircularProgress();
            }

            if (provider.errorMessage != null) {
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
                      'Failed to load product details',
                      style: context.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      provider.errorMessage!,
                      style: const TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadProductDetails,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            final product = provider.productDetailsModel;
            if (product == null) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading product data...'),
                  ],
                ),
              );
            }
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        ProductImageCarousel(imageUrls: product.photos),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildTitleSection(product),
                              if (product.colors.isNotEmpty)
                                ColorPicker(
                                  colors: product.colors,
                                  onChange: (String color) {
                                    _selectedColor = color;
                                  },
                                ),
                              const SizedBox(height: 16),
                              if (product.sizes.isNotEmpty)
                                SizePicker(
                                  sizes: product.sizes,
                                  onChange: (String size) {
                                    _selectedSize = size;
                                  },
                                ),
                              const SizedBox(height: 16),
                              Text(
                                'Description',
                                style: context.textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                product.description,
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                PriceAndAddToCartSection(
                  price: product.currentPrice.toDouble(),
                  onTapAddToCart: () async {
                    AddToCartModel params = AddToCartModel(
                      id: product.id,
                      quantity: _quantity,
                      color: _selectedColor,
                      size: _selectedSize,
                    );
                    final isSuccess = await _addToCartProvider.addToCart(
                      params,
                    );
                    if (isSuccess) {
                      showSnackBarMessage(context, 'Added to cart');
                    } else {
                      showSnackBarMessage(
                        context,
                        _addToCartProvider.errorMessage ??
                            'Failed to add to cart',
                      );
                    }
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTitleSection(product) {
    return Row(
      spacing: 8,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.title,
                style: context.textTheme.titleMedium?.copyWith(
                  color: Colors.black87,
                ),
              ),
              Row(
                children: [
                  const ProductRating(rating: '4.7'),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        ReviewListScreen.name,
                        arguments: {
                          'productId': product.id,
                          'productTitle': product.title,
                          'productImage': product.photos.isNotEmpty
                              ? product.photos.first
                              : null,
                        },
                      );
                    },
                    child: Text(
                      'Reviews',
                      style: TextStyle(color: AppColors.themeColor),
                    ),
                  ),
                  ProductFavouriteButton(productId: product.id),
                ],
              ),
            ],
          ),
        ),
        IncDecButton(
          maxCount: product.availableQuantity,
          onChange: (int count) {
            setState(() {
              _quantity = count;
            });
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _productDetailsProvider.dispose();
    _addToCartProvider.dispose();
    super.dispose();
  }
}
