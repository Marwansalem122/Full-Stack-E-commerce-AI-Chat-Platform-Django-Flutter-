import 'package:flutter/material.dart';
import 'package:stylish_admin/core/utils/responsive_helper.dart';
import 'package:stylish_admin/core/widget/dashboard_header.dart';
import 'package:stylish_admin/core/widget/dashboard_side_bar.dart';

class AppLayout extends StatelessWidget {
  final Widget child;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  AppLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: ResponsiveHelper.isMobile(context)
          ? Drawer(
              child: DashboardSideBar(
                isExpanded: true,
                onToggle: () => _scaffoldKey.currentState?.closeDrawer(),
              ),
            )
          : null,
      body: SafeArea(
        child:ResponsiveHelper.buildResponsiveLayout(
          context, 
          mobile: _MobileLayout(scaffoldKey: _scaffoldKey , child: child,),
          tablet: _DesktopLayout(isTablet: true,child: child,),
          desktop: _DesktopLayout(isTablet: false,child: child,),
        ),
      ),
    );
  }
}


class _MobileLayout extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Widget child;
  const _MobileLayout({required this.scaffoldKey, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DashboardHeader(
          onMenuPressed: () => scaffoldKey.currentState?.openDrawer(),
        ),
        Expanded(child: child),
      ],
    );
  }
}

class _DesktopLayout extends StatefulWidget {
  final Widget child;
  final bool isTablet;
  const _DesktopLayout({required this.child, this.isTablet = false});

  @override
  State<_DesktopLayout> createState() => __DesktopLayoutState();
}

class __DesktopLayoutState extends State<_DesktopLayout> {
  bool _isSidebarExpanded = true;

  void _toggleSidebar() {
    setState(() {
      _isSidebarExpanded = !_isSidebarExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        DashboardSideBar(
          isExpanded: _isSidebarExpanded,
          onToggle: _toggleSidebar,
        ),
        Expanded(
          child: Column(
            children: [
              const DashboardHeader(onMenuPressed: null),
              Expanded(child: widget.child),
            ],
          ),
        ),
      ],
    );
  }
}
