import 'package:flutter/material.dart';
import 'package:stylish_admin/core/di/injection_container.dart';
import 'package:stylish_admin/core/service/navigation_service.dart';
import 'package:stylish_admin/core/theme/theme.dart';

class NavigationController extends ValueNotifier<String> {
  static final NavigationController _instance =
      NavigationController._internal();
  factory NavigationController() => _instance;
  NavigationController._internal() : super('/dashboard');
  void setCurrentRoute(String route) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (value != route) {
        value = route;
      }
    });
  }
}

class DashboardSideBar extends StatefulWidget {
  final bool isExpanded;
  final VoidCallback? onToggle;
  const DashboardSideBar({super.key, this.isExpanded = true, this.onToggle});

  @override
  State<DashboardSideBar> createState() => _DashboardSideBarState();
}

class _DashboardSideBarState extends State<DashboardSideBar>
    with SingleTickerProviderStateMixin {
  final NavigationController _controller = sl<NavigationController>();
  final NavigationService _navigationService = sl<NavigationService>();

  late AnimationController _animationController;
  late Animation<double> _widthAnimation;
  late Animation<double> _opacityAnimation;

  static const double _collapseWidth = 90.0;
  static const double _expandedWidth = 200.0;
  static const double _textFadeThreshold = 0.5;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _widthAnimation = Tween<double>(begin: _collapseWidth, end: _expandedWidth)
        .animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
      ),
    );
    _animationController.value = widget.isExpanded ? 1.0 : 0.0;
  }

  @override
  void didUpdateWidget(covariant DashboardSideBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded != oldWidget.isExpanded) {
      if (widget.isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: _controller,
      builder: (context, currentRoute, _) {
        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            final currentWidth = _widthAnimation.value;
            final showText = _animationController.value > _textFadeThreshold;

            return Container(
              width: currentWidth,
              color: AppTheme.cardBackground,
              child: Column(
                children: [
                  _buildHeader(currentWidth, showText),
                  Expanded(
                    child: SingleChildScrollView(
                      key: const PageStorageKey('sidebar_scroll_key'),
                      child: Column(
                        children: [
                          _builNavItem(
                            icon: Icons.dashboard_outlined,
                            selectedIcon: Icons.dashboard,
                            title: 'Dashboard',
                            route: '/dashboard',
                            isSelected: currentRoute == '/dashboard',
                            currentWidth: currentWidth,
                            showText: showText,
                          ),

                          _builNavItem(
                            icon: Icons.inventory_2_outlined,
                            selectedIcon: Icons.inventory_2,
                            title: 'Products',
                            route: '/products',
                            isSelected: currentRoute == '/products',
                            currentWidth: currentWidth,
                            showText: showText,
                          ),

                          _builNavItem(
                            icon: Icons.category_outlined,
                            selectedIcon: Icons.category,
                            title: 'Categories',
                            route: '/categories',
                            isSelected: currentRoute == '/categories',
                            currentWidth: currentWidth,
                            showText: showText,
                          ),

                          _builNavItem(
                            icon: Icons.chat_bubble,
                            selectedIcon: Icons.chat_bubble_outline_outlined,
                            title: 'Chat',
                            route: '/chat',
                            isSelected: currentRoute == '/chat',
                            currentWidth: currentWidth,
                            showText: showText,
                          ),
                        ],
                      ),
                    ),
                  ),
                  _buildFooter(currentWidth, showText),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHeader(double currentWidth, bool showText) {
    return Container(
      height: 70,
      width: currentWidth,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppTheme.dividerColor.withAlpha((0.2 * 255).round()),
          ),
        ),
      ),
      child: showText
          ? _buildExpandedHeader(currentWidth)
          : _buildCollapsedHeader(currentWidth),
    );
  }

  Widget _buildExpandedHeader(double currentWidth) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryLight.withAlpha((0.2 * 255).round()),
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
            ),
            child: Icon(Icons.analytics, color: AppTheme.accentBlue, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Stylish",
              style: AppTheme.headingMedium().copyWith(
                color: AppTheme.accentBlue,
                fontSize: 20,
              ),
              maxLines: 1,
              overflow: TextOverflow.clip,
            ),
          ),
          if (widget.onToggle != null)
            AnimatedOpacity(
              opacity: _opacityAnimation.value,
              duration: const Duration(milliseconds: 100),
              child: IconButton(
                icon: AnimatedIcon(
                  icon: AnimatedIcons.menu_close,
                  progress: _animationController,
                  color: AppTheme.textPrimary,
                ),
                onPressed: widget.onToggle,
                tooltip: 'Toggle sidebar',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minHeight: 24, minWidth: 24),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCollapsedHeader(double currentWidth) {
    return Stack(
      children: [
        Center(
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryLight.withAlpha((0.2 * 255).round()),
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
            ),
            child: Icon(Icons.analytics, color: AppTheme.accentBlue, size: 20),
          ),
        ),
        if (widget.onToggle != null)
          Positioned(
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.accentBlue.withAlpha((0.1 * 255).round()),
                borderRadius: BorderRadius.circular(4),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.chevron_right,
                  color: AppTheme.accentBlue,
                  size: 16,
                ),
                onPressed: widget.onToggle,
                tooltip: 'Expand sidebar',
                padding: const EdgeInsets.all(4),
                constraints: BoxConstraints(minHeight: 24, minWidth: 24),
              ),
            ),
          ),
      ],
    );
  }

  Widget _builNavItem({
    required IconData icon,
    required IconData selectedIcon,
    required String title,
    required String route,
    required bool isSelected,
    required double currentWidth,
    required bool showText,
  }) {
    final navItem = AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: currentWidth,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected
            ? AppTheme.primaryLight.withAlpha((0.15 * 255).round())
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          onTap: () => _handleNavigation(context, route),
          splashColor: AppTheme.primaryLight.withAlpha((0.1 * 255).round()),
          hoverColor: AppTheme.primaryLight.withAlpha((0.05 * 255).round()),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 20,
                  child: Icon(
                    isSelected ? selectedIcon : icon,
                    color: isSelected
                        ? AppTheme.accentBlue
                        : AppTheme.textSecondary,
                    size: 20,
                  ),
                ),
                if (showText && currentWidth > 100) ...[
                  const SizedBox(width: 16),
                  Expanded(
                    child: AnimatedOpacity(
                      opacity: _opacityAnimation.value,
                      duration: const Duration(milliseconds: 100),
                      child: Text(
                        title,
                        style: AppTheme.bodyMedium().copyWith(
                          color: isSelected
                              ? AppTheme.accentBlue
                              : AppTheme.textSecondary,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.clip,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
    if (!showText) {
      return Tooltip(
        message: title,
        preferBelow: false,
        textStyle: AppTheme.bodySmall().copyWith(color: AppTheme.textPrimary),
        decoration: BoxDecoration(
          color: AppTheme.primary.withAlpha((0.9 * 255).round()),
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
          boxShadow: [
            BoxShadow(
              color: AppTheme.textMuted,
              blurRadius: 4,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        waitDuration: const Duration(milliseconds: 500),
        child: navItem,
      );
    }
    return navItem;
  }

  Widget _buildFooter(double currentWidth, bool showText) {
    if (!showText) {
      return Container(
        width: currentWidth,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: AppTheme.dividerColor.withAlpha((0.2 * 255).round()),
            ),
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.keyboard_double_arrow_right,
              color: AppTheme.textSecondary.withAlpha((0.6 * 255).round()),
              size: 16,
            ),
            const SizedBox(height: 4),
            Text(
              'Expand',
              style: AppTheme.bodySmall().copyWith(
                color: AppTheme.textSecondary.withAlpha((0.6 * 255).round()),
                fontSize: 10,
              ),
            ),
          ],
        ),
      );
    }
    return Container(
      width: currentWidth,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppTheme.dividerColor.withAlpha((0.2 * 255).round()),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Need help? ",
            style: AppTheme.bodyMedium().copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.primaryLight.withAlpha((0.2 * 255).round()),
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.headset_mic_outlined,
                  color: AppTheme.accentBlue,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Support Center',
                    style: AppTheme.bodySmall().copyWith(
                      color: AppTheme.accentBlue,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleNavigation(BuildContext context, String route) {
    _navigationService.pushNamed(route);
  }
}
