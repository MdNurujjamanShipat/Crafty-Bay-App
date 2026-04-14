import 'package:flutter/foundation.dart';
import '../../../../app/network_caller_set_up.dart';
import '../../../../app/urls.dart';
import '../../data/models/review_model.dart';
import '../../data/models/create_review_model.dart';

class ReviewProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isSubmitting = false;
  List<ReviewModel> _reviews = [];
  String? _errorMessage;
  int _totalReviews = 0;
  int _currentPage = 1;
  bool _hasMore = true;

  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  List<ReviewModel> get reviews => _reviews;
  String? get errorMessage => _errorMessage;
  int get totalReviews => _totalReviews;
  bool get hasMore => _hasMore;

  Future<bool> getProductReviews({
    required String productId,
    int count = 10,
    bool loadMore = false,
  }) async {
    if (loadMore && !_hasMore) return false;
    if (loadMore) _currentPage++;
    if (!loadMore) {
      _isLoading = true;
      _currentPage = 1;
      _reviews = [];
    }

    _errorMessage = null;
    notifyListeners();

    try {
      final url =
          '${Urls.reviewsUrl}?product=$productId&count=$count&page=$_currentPage';
      debugPrint('Fetching reviews from: $url');

      final response = await getNetworkCaller().getRequest(url);

      debugPrint('Reviews response status: ${response.responseCode}');

      if (response.isSuccess && response.body != null) {
        try {
          final reviewListModel = ReviewListModel.fromJson(response.body);

          if (loadMore) {
            _reviews.addAll(reviewListModel.reviews);
          } else {
            _reviews = reviewListModel.reviews;
          }

          _totalReviews = reviewListModel.total;
          _hasMore = _currentPage < reviewListModel.lastPage;

          _isLoading = false;
          notifyListeners();
          debugPrint(
            'Reviews loaded: ${_reviews.length} items (Total: $_totalReviews)',
          );
          return true;
        } catch (e) {
          debugPrint('Error parsing reviews data: $e');
          _errorMessage = 'Error parsing reviews data';
          _isLoading = false;
          notifyListeners();
          return false;
        }
      } else {
        debugPrint('Reviews request failed: ${response.errorMessage}');
        _errorMessage = response.errorMessage ?? 'Failed to load reviews';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('Exception in getProductReviews: $e');
      _errorMessage = 'Network error: Unable to load reviews';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> createReview(CreateReviewModel review) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint('Creating review for product: ${review.productId}');
      debugPrint('Review data: ${review.toJson()}');

      final response = await getNetworkCaller().postRequest(
        Urls.createReviewUrl,
        body: review.toJson(),
      );

      debugPrint('Create review response status: ${response.responseCode}');
      debugPrint('Create review response body: ${response.body}');

      if (response.isSuccess) {
        _isSubmitting = false;
        notifyListeners();
        debugPrint('Successfully created review');
        return true;
      } else {
        _errorMessage = response.errorMessage ?? 'Failed to create review';
        _isSubmitting = false;
        notifyListeners();
        debugPrint('Failed to create review: $_errorMessage');
        return false;
      }
    } catch (e) {
      debugPrint('Exception in createReview: $e');
      _errorMessage = 'Network error: Unable to create review';
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  void clearReviews() {
    _reviews = [];
    _totalReviews = 0;
    _currentPage = 1;
    _hasMore = true;
    _errorMessage = null;
    notifyListeners();
  }

  void reset() {
    _isLoading = false;
    _isSubmitting = false;
    _reviews = [];
    _errorMessage = null;
    _totalReviews = 0;
    _currentPage = 1;
    _hasMore = true;
    notifyListeners();
  }
}
