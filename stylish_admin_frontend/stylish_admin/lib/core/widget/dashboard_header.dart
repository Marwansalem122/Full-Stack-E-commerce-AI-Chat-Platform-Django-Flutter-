import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stylish_admin/core/theme/theme.dart';
import 'package:stylish_admin/core/utils/responsive_helper.dart';
import 'package:stylish_admin/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:stylish_admin/features/auth/presentation/widgets/profile_dropdown.dart';

class DashboardHeader extends StatelessWidget {
  final VoidCallback? onMenuPressed;
  const DashboardHeader({super.key, this.onMenuPressed});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (previous, current) {
        if (previous is Authenticated && current is Authenticated) {
          return previous.user != current.user;
        }
        return previous.runtimeType != current.runtimeType;
      },
      builder: (context, state) {
        if (state is Authenticated) {
          final user = state.user;
          return Container(
            padding: EdgeInsets.all(AppTheme.spacingMedium),
            decoration: BoxDecoration(
              color: AppTheme.cardBackground,
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.dividerColor.withAlpha((0.1 * 255).round()),
                ),
              ),
            ),
            child: Row(
              children: [
                if (ResponsiveHelper.isMobile(context) && onMenuPressed != null)
                  IconButton(
                    onPressed: onMenuPressed,
                    icon: Icon(Icons.menu, color: AppTheme.textPrimary),
                  ),
                Expanded(
                  child: Container(
                    height: 45,
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundDark,
                      borderRadius: BorderRadius.circular(
                        AppTheme.borderRadiusSmall,
                      ),
                      border: Border.all(
                        color: AppTheme.borderColor.withAlpha(
                          (0.2 * 255).round(),
                        ),
                      ),
                    ),
                    child: TextField(
                      style: AppTheme.bodyMedium(),
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        hintStyle: AppTheme.bodyMedium().copyWith(
                          color: AppTheme.textMuted,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: AppTheme.textMuted,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: AppTheme.spacingMedium,
                          vertical: AppTheme.spacingMedium - 4,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: AppTheme.spacingMedium),
                IconButton(
                  icon: Stack(
                    children: [
                      Icon(
                        Icons.notifications_outlined,
                        color: AppTheme.textPrimary,
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: EdgeInsets.all(AppTheme.spacingXSmall),
                          decoration: BoxDecoration(
                            color: AppTheme.negative,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '3',
                            style: AppTheme.bodyXSmall().copyWith(
                              color: AppTheme.textPrimary,
                              fontSize: 8,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  onPressed: () {},
                ),
                SizedBox(width: AppTheme.spacingMedium),
                ProfileDropdown(user:user)
              ],
            ),
          );
        }
        return Container(); 
      },
    );
  }
}
