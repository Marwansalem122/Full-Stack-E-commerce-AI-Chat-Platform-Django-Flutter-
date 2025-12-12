import 'package:flutter/material.dart';
import 'package:stylish_admin/core/di/injection_container.dart';
import 'package:stylish_admin/core/layout/app_layout.dart';
import 'package:stylish_admin/core/routes/dashboard_router.dart';
import 'package:stylish_admin/core/routes/dashboard_router_observer.dart';
import 'package:stylish_admin/core/routes/route_names.dart';
import 'package:stylish_admin/core/service/navigation_service.dart';

class DashboardShell extends StatelessWidget {
  const DashboardShell({super.key});

  @override
  Widget build(BuildContext context) {
    final NavigationService navigationService = sl<NavigationService>();
    return AppLayout(
      child: Navigator(key: navigationService.navigatorKey, onGenerateRoute: DashboardRouter.generateRoute,initialRoute: RouteNames.dashboard,observers: [sl<DashboardRouterObserver>()],),
    );
  }
}
