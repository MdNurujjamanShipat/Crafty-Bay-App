import 'package:crafty_bay/features/products/presentation/providers/product_list_provider.dart';
import 'package:crafty_bay/features/shared/presentation/widgets/center_circular_progress.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../category/data/models/category_model.dart';
import '../../../shared/presentation/widgets/product_card.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({
    super.key,
    this.category,
    this.categoryId,
    this.categoryName,
  });

  final CategoryModel? category;
  final String? categoryId;
  final String? categoryName;

  static const String name = '/product-list';

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final ScrollController _scrollController = ScrollController();
  final ProductListProvider _productListProvider = ProductListProvider();
  late String _categoryId;
  late String _categoryTitle;

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _categoryId = widget.category!.id;
      _categoryTitle = widget.category!.title;
    } else if (widget.categoryId != null) {
      _categoryId = widget.categoryId!;
      _categoryTitle = widget.categoryName ?? 'Products';
    } else {
      _categoryId = '';
      _categoryTitle = 'Products';
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _productListProvider.getProducts(_categoryId);
      _scrollController.addListener(_loadMoreProducts);
    });
  }

  void _loadMoreProducts() {
    if (_productListProvider.isLoading) {
      return;
    }

    if (_scrollController.position.extentBefore < 300) {
      _productListProvider.getProducts(_categoryId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _productListProvider,
      child: Scaffold(
        appBar: AppBar(title: Text(_categoryTitle)),
        body: Consumer<ProductListProvider>(
          builder: (context, _, _) {
            if (_productListProvider.getInitialProductListInProgress) {
              return const CenterCircularProgress();
            }

            if (_productListProvider.products.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.inventory_2_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No products in $_categoryTitle',
                      style: const TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                Expanded(
                  child: GridView.builder(
                    controller: _scrollController,
                    itemCount: _productListProvider.products.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 4,
                        ),
                    itemBuilder: (context, index) {
                      return FittedBox(
                        child: ProductCard(
                          productModel: _productListProvider.products[index],
                        ),
                      );
                    },
                  ),
                ),
                if (_productListProvider.loadMoreProductListInProgress)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: LinearProgressIndicator(),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
