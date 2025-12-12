import 'package:flutter/material.dart';
import 'package:stylish_admin/core/routes/route_names.dart';
import 'package:stylish_admin/features/auth/domain/entities/user_entity.dart';
import 'package:stylish_admin/features/auth/presentation/pages/login_page.dart';
import 'package:stylish_admin/features/auth/presentation/pages/manage_account_page.dart';

class DashboardRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.login:
        return _buildRoute(const LoginPage(), settings);
      case RouteNames.dashboard:
        return _buildRoute(
          Center(child: Text("We are in dashboard screen")),
          settings,
        );
      // case RouteNames.products:
      //   return _buildRoute(const ProductsPage(), settings);
      // case RouteNames.categories:
      //   return _buildRoute(CategoriesPage(), settings);

      // case RouteNames.productDetails:
      //   final product = settings.arguments as ProductEntity;
      //   return _buildRoute(ProductDetailsPage(product: product), settings);

      // case RouteNames.productVariations:
      //   final args = settings.arguments as Map<String, dynamic>;
      //   return _buildRoute(
      //     ProductVariationsScreen(
      //       productId: args['productId'] as String,
      //       initialVariations: args['variations'] as Map<String, List<String>>,
      //       basePrice: args['basePrice'] as double,
      //       currentStock: args['currentStock'] as int,
      //       initialVariants: args['variants'] as List<ProductVariantEntity>?,
      //       initialSizes: args['sizes'] as List<String>?,
      //     ),
      //     settings,
      // );

      case RouteNames.profile:
        final user = settings.arguments as UserEntity;
        return _buildRoute(ManageAccountPage(user: user), settings);

      // case RouteNames.chat:
      //   return _buildRoute(ChatDashboardPage(), settings);

      // case RouteNames.chatAnalytics:
      //   return _buildRoute(ChatAnalyticsPage(), settings);

      // case RouteNames.chatSession:
      //   final args = settings.arguments as Map<String, dynamic>?;
      //   return _buildRoute(
      //     ChatSessonDetailPage(sessionId: args?['sessionId']),
      //     settings,
      //   );
      default:
        return _buildRoute(Center(child: Text("No Pages")), settings);
    }
  }

  static MaterialPageRoute _buildRoute(Widget page, RouteSettings settings) {
    return MaterialPageRoute(builder: (_) => page, settings: settings);
  }
}
