import 'package:flutter/foundation.dart';
import '../../../../app/network_caller_set_up.dart';
import '../../../../app/urls.dart';
import '../../data/models/wishlist_model.dart';

class WishlistProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isAddingToWishlist = false;
  List<WishlistItemModel> _wishlistItems = [];
  String? _errorMessage;
  int _totalItems = 0;

  bool get isLoading => _isLoading;
  bool get isAddingToWishlist => _isAddingToWishlist;
  List<WishlistItemModel> get wishlistItems => _wishlistItems;
  String? get errorMessage => _errorMessage;
  int get wishlistCount => _wishlistItems.length;
  int get totalItems => _totalItems;
  Future<bool> getWishlist() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint('Fetching wishlist from: ${Urls.wishlistUrl}');
      final response = await getNetworkCaller().getRequest(Urls.wishlistUrl);

      debugPrint('Wishlist response status: ${response.responseCode}');
      debugPrint('Wishlist response body: ${response.body}');

      if (response.isSuccess && response.body != null) {
        try {
          final wishlistModel = WishlistModel.fromJson(response.body);
          _wishlistItems = wishlistModel.items;
          _totalItems = wishlistModel.total;
          _isLoading = false;
          notifyListeners();
          debugPrint(
            'Wishlist loaded: ${_wishlistItems.length} items (Total: $_totalItems)',
          );
          return true;
        } catch (e) {
          debugPrint('Error parsing wishlist data: $e');
          _errorMessage = 'Error parsing wishlist data: $e';
          _isLoading = false;
          notifyListeners();
          return false;
        }
      } else {
        debugPrint('Wishlist request failed: ${response.errorMessage}');
        _errorMessage = response.errorMessage ?? 'Failed to load wishlist';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('Exception in getWishlist: $e');
      _errorMessage = 'Network error: Unable to load wishlist';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> addToWishlist(String productId) async {
    _isAddingToWishlist = true;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint('Adding to wishlist - Product ID: $productId');

      final response = await getNetworkCaller().postRequest(
        Urls.wishlistUrl,
        body: {'product': productId},
      );
      debugPrint('Add to wishlist response status: ${response.responseCode}');
      debugPrint('Add to wishlist response body: ${response.body}');

      if (response.isSuccess) {
        _isAddingToWishlist = false;
        await getWishlist();
        notifyListeners();
        debugPrint('Successfully added to wishlist');
        return true;
      } else {
        _errorMessage = response.errorMessage ?? 'Failed to add to wishlist';
        _isAddingToWishlist = false;
        notifyListeners();
        debugPrint('Failed to add to wishlist: $_errorMessage');
        return false;
      }
    } catch (e) {
      debugPrint('Exception in addToWishlist: $e');
      _errorMessage = 'Network error: Unable to add to wishlist';
      _isAddingToWishlist = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> removeFromWishlist(String wishlistItemId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint('Removing from wishlist - Item ID: $wishlistItemId');

      final response = await getNetworkCaller().deleteRequest(
        '${Urls.wishlistUrl}/$wishlistItemId',
      );

      debugPrint(
        'Remove from wishlist response status: ${response.responseCode}',
      );

      if (response.isSuccess) {
        _wishlistItems.removeWhere((item) => item.id == wishlistItemId);
        _isLoading = false;
        notifyListeners();
        debugPrint('Successfully removed from wishlist');
        return true;
      } else {
        _errorMessage =
            response.errorMessage ?? 'Failed to remove from wishlist';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('Exception in removeFromWishlist: $e');
      _errorMessage = 'Network error: Unable to remove from wishlist';
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
    _totalItems = 0;
    notifyListeners();
  }
}
