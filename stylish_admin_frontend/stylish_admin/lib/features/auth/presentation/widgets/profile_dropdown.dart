import 'package:flutter/material.dart';
import 'package:stylish_admin/core/di/injection_container.dart';
import 'package:stylish_admin/core/routes/route_names.dart';
import 'package:stylish_admin/core/service/navigation_service.dart';
import 'package:stylish_admin/core/theme/theme.dart';
import 'package:stylish_admin/features/auth/domain/entities/user_entity.dart';
import 'package:stylish_admin/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileDropdown extends StatelessWidget {
  final UserEntity user;
  const ProfileDropdown({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (String value) {
        switch (value) {
          case 'manage_account':
            sl<NavigationService>().pushNamed(
              RouteNames.profile,
              arguments: user,
            );
            break;

          case 'logout':
            context.read<AuthBloc>().add(LogoutEvent());
        }
      },
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
      ),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'manage_account',
          child: ListTile(
            leading: Icon(Icons.manage_accounts, color: AppTheme.textPrimary),
            title: Text('Manage Account', style: AppTheme.bodyMedium()),
          ),
        ),
        PopupMenuItem<String>(
          value: 'change_password',
          child: ListTile(
            leading: Icon(Icons.lock_outline, color: AppTheme.textPrimary),
            title: Text('Change Password', style: AppTheme.bodyMedium()),
          ),
        ),
        PopupMenuItem<String>(
          value: 'activity_log',
          child: ListTile(
            leading: Icon(Icons.history, color: AppTheme.textPrimary),
            title: Text('Activity Log', style: AppTheme.bodyMedium()),
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'logout',
          child: ListTile(
            leading: Icon(Icons.logout, color: AppTheme.textPrimary),
            title: Text('Log Out', style: AppTheme.bodyMedium()),
          ),
        ),
      ],
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppTheme.spacingMedium - 4,
          vertical: AppTheme.spacingSmall,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
          border: Border.all(
            color: AppTheme.borderColor.withAlpha((0.2 * 255).round()),
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: user.profilePictureUrl != null
                  ? NetworkImage(user.profilePictureUrl!)
                  : null,
              backgroundColor: user.profilePictureUrl == null
                  ? AppTheme.accentBlue
                  : null,
              onBackgroundImageError: user.profilePictureUrl != null
                  ? (exception, stackTrace) {
                      debugPrint('Error loading profile image : $exception');
                    }
                  : null,
              child: user.profilePictureUrl == null
                  ? Text(
                      (user.fullName.isNotEmpty == true
                          ? user.fullName[0]
                          : user.email[0].toUpperCase()),
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            SizedBox(width: AppTheme.spacingSmall),
            Text(
              user.fullName,
              style: AppTheme.bodyMedium().copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            Icon(Icons.arrow_drop_down, color: AppTheme.textPrimary),
          ],
        ),
      ),
    );
  }
}
