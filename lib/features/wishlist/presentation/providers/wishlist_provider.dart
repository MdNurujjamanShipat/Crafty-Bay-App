import 'package:flutter/foundation.dart';
import '../../../../app/network_caller_set_up.dart';
import '../../../../app/urls.dart';
import '../../data/models/wishlist_model.dart';

class WishlistProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isAddingToWishlist = false;
  List<WishlistItemModel> _wishlistItems = [];
  String? _errorMessage;

  bool get isLoading => _isLoading;
  bool get isAddingToWishlist => _isAddingToWishlist;
  List<WishlistItemModel> get wishlistItems => _wishlistItems;
  String? get errorMessage => _errorMessage;
  int get wishlistCount => _wishlistItems.length;

  Future<bool> getWishlist() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await getNetworkCaller().getRequest(Urls.wishlistUrl);

    if (response.isSuccess) {
      final wishlistModel = WishlistModel.fromJson(response.body);
      _wishlistItems = wishlistModel.items;
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _errorMessage = response.errorMessage ?? 'Failed to load wishlist';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> addToWishlist(String productId) async {
    _isAddingToWishlist = true;
    _errorMessage = null;
    notifyListeners();

    final response = await getNetworkCaller().postRequest(
      Urls.wishlistUrl,
      body: {'product': productId},
    );

    if (response.isSuccess) {
      _isAddingToWishlist = false;
      await getWishlist();
      notifyListeners();
      return true;
    } else {
      _errorMessage = response.errorMessage ?? 'Failed to add to wishlist';
      _isAddingToWishlist = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> removeFromWishlist(String wishlistItemId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await getNetworkCaller().postRequest(
      '${Urls.wishlistUrl}/$wishlistItemId',
      body: {'_method': 'delete'},
    );

    if (response.isSuccess) {
      _wishlistItems.removeWhere((item) => item.id == wishlistItemId);
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _errorMessage = response.errorMessage ?? 'Failed to remove from wishlist';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  bool isProductInWishlist(String productId) {
    return _wishlistItems.any((item) => item.productId == productId);
  }

  String? getWishlistItemId(String productId) {
    try {
      final item = _wishlistItems.firstWhere(
        (item) => item.productId == productId,
      );
      return item.id;
    } catch (e) {
      return null;
    }
  }

  void clearWishlist() {
    _wishlistItems = [];
    notifyListeners();
  }
}
