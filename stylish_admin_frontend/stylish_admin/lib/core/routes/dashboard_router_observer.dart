import 'package:flutter/material.dart';
import 'package:stylish_admin/core/widget/dashboard_side_bar.dart';

class DashboardRouterObserver extends NavigatorObserver {
  final NavigationController navigationController;

  DashboardRouterObserver(this.navigationController);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _updateRoute(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute != null) {
      _updateRoute(newRoute);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute != null) {
      _updateRoute(previousRoute);
    }
  }

  void _updateRoute(Route<dynamic> route) {
    final String? routeName = route.settings.name;
    if (routeName != null) {
      navigationController.setCurrentRoute(routeName);
    }
  }
}
