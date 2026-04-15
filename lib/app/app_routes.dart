import 'package:crafty_bay/features/category/data/models/category_model.dart';
import 'package:flutter/material.dart';

import '../features/auth/presentation/screens/sign_in_screen.dart';
import '../features/auth/presentation/screens/sign_up_screen.dart';
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/auth/presentation/screens/verify_otp_screen.dart';
import '../features/products/presentation/screens/product_details_screen.dart';
import '../features/products/presentation/screens/product_list_screen.dart';
import '../features/shared/presentation/screens/main_nav_holder_screen.dart';
import '../features/review/presentation/screens/review_list_screen.dart';
import '../features/review/presentation/screens/create_review_screen.dart';

class AppRoutes {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    Widget widget = const SizedBox();
    switch (settings.name) {
      case SplashScreen.name:
        widget = const SplashScreen();
        break;
      case SignUpScreen.name:
        widget = const SignUpScreen();
        break;
      case SignInScreen.name:
        widget = const SignInScreen();
        break;
      case VerifyOtpScreen.name:
        final email = settings.arguments as String;
        widget = VerifyOtpScreen(email: email);
        break;
      case MainNavHolderScreen.name:
        widget = const MainNavHolderScreen();
        break;
      case ProductListScreen.name:
        final args = settings.arguments;
        if (args is CategoryModel) {
          widget = ProductListScreen(category: args);
        } else if (args is Map<String, String>) {
          widget = ProductListScreen(
            categoryId: args['categoryId'],
            categoryName: args['categoryName'],
          );
        } else if (args is Map<String, dynamic>) {
          widget = ProductListScreen(
            categoryId: args['categoryId'],
            categoryName: args['categoryName'],
          );
        } else {
          widget = const ProductListScreen();
        }
        break;
      case ProductDetailsScreen.name:
        final productId = settings.arguments as String;
        widget = ProductDetailsScreen(productId: productId);
        break;
      case ReviewListScreen.name:
        final args = settings.arguments as Map<String, dynamic>;
        widget = ReviewListScreen(
          productId: args['productId'],
          productTitle: args['productTitle'],
          productImage: args['productImage'],
        );
        break;
      case CreateReviewScreen.name:
        final args = settings.arguments as Map<String, dynamic>;
        widget = CreateReviewScreen(
          productId: args['productId'],
          productTitle: args['productTitle'],
        );
        break;
    }
    return MaterialPageRoute(builder: (context) => widget);
  }
}
