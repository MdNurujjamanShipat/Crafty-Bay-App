import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../products/data/models/product_model.dart';
import '../../../products/presentation/providers/product_list_provider.dart';
import '../../../shared/presentation/widgets/center_circular_progress.dart';
import '../../../shared/presentation/widgets/product_card.dart';

class HorizontalProductListView extends StatefulWidget {
  const HorizontalProductListView({super.key, this.categoryId});

  final String? categoryId;

  @override
  State<HorizontalProductListView> createState() =>
      _HorizontalProductListViewState();
}

class _HorizontalProductListViewState extends State<HorizontalProductListView> {
  final ProductListProvider _provider = ProductListProvider();
  bool _isLoading = true;
  List<ProductModel> _products = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    if (widget.categoryId == null) {
      setState(() {
        _isLoading = false;
        _products = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });
    final isSuccess = await _provider.getProducts(widget.categoryId!);

    if (mounted) {
      setState(() {
        _products = List.from(_provider.products);
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(height: 195, child: CenterCircularProgress());
    }

    if (_products.isEmpty) {
      return SizedBox(
        height: 195,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.inventory_2_outlined,
                size: 48,
                color: Colors.grey,
              ),
              const SizedBox(height: 8),
              const Text(
                'No products available',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 195,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _products.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return SizedBox(
            width: 140,
            child: ProductCard(productModel: _products[index]),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }
}
