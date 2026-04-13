import 'package:crafty_bay/features/products/data/models/product_model.dart';
import 'package:crafty_bay/features/products/presentation/screens/product_details_screen.dart';
import 'package:flutter/material.dart';

import '../../../../app/app_colors.dart';
import '../../../../app/constants.dart';
import '../../../../app/extensions/utils_extension.dart';
import 'network_image_widget.dart';
import 'product_favourite_button.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.productModel});

  final ProductModel productModel;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          ProductDetailsScreen.name,
          arguments: productModel.id,
        );
      },
      child: Card(
        color: Colors.white,
        elevation: 4,
        shadowColor: AppColors.themeColor.withAlpha(50),
        child: SizedBox(
          width: 140,
          child: Column(
            spacing: 8,
            children: [
              Container(
                width: 140,
                height: 120,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.themeColor.withAlpha(30),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                child: AppNetworkImage(urls: productModel.photos),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  spacing: 2,
                  children: [
                    Text(
                      productModel.title,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: const TextStyle(overflow: TextOverflow.ellipsis),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${Constants.takaSign}${productModel.currentPrice}',
                          style: context.textTheme.titleSmall?.copyWith(
                            color: AppColors.themeColor,
                          ),
                        ),
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            const Icon(
                              Icons.star,
                              size: 18,
                              color: Colors.amber,
                            ),
                            Text(
                              '4.6',
                              style: context.textTheme.titleSmall?.copyWith(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        ProductFavouriteButton(productId: productModel.id),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
  }
}
