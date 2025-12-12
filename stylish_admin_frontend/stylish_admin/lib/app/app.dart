import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stylish_admin/core/di/injection_container.dart';
import 'package:stylish_admin/core/theme/theme.dart';
import 'package:stylish_admin/core/widget/dashboard_shell.dart';
// import 'package:stylish_admin/core/widget/dashboard_shell.dart';
import 'package:stylish_admin/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:stylish_admin/features/auth/presentation/pages/login_page.dart';
// import 'package:stylish_admin/features/category/presentation/bloc/category_bloc.dart';
// import 'package:stylish_admin/features/chat/presentation/bloc/chat_bloc.dart';
// import 'package:stylish_admin/features/products/presentation/bloc/product_details/product_details_bloc.dart';
// import 'package:stylish_admin/features/products/presentation/bloc/product_list/product_list_bloc.dart';
// import 'package:stylish_admin/features/variations/presentation/bloc/product_variant_bloc.dart';

class StylishAdminApp extends StatelessWidget {
  final AuthBloc authBloc;
  const StylishAdminApp({super.key, required this.authBloc});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: authBloc),
        // BlocProvider<ProductsListBloc>(
        //   create: (context) => sl<ProductsListBloc>(),
        // ),
        // BlocProvider<ProductDetailBloc>(
        //   create: (context) => sl<ProductDetailBloc>(),
        // ),
        // BlocProvider<CategoryBloc>(create: (context) => sl<CategoryBloc>()),
        // BlocProvider<ProductVariantBloc>(
        //   create: (context) => sl<ProductVariantBloc>(),
        // ),

        // BlocProvider<ChatBloc>(create: (_) => sl<ChatBloc>()),
      ],
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Admin Dashboard',
            theme: AppTheme.buildThemeData(),
            home: _buildHome(state),
            key: const ValueKey('App'),
          );
        },
      ),
    );
  }

  Widget _buildHome(AuthState state) {
    if (state is Authenticated) {
      return const DashboardShell();
    }
    if (state is UnAuthenticated) {
      return const LoginPage();
    }
    if (state is AuthError) {
      return LoginPage(errorMessage: state.message);
    }
    // for AuthInitial , AuthLoading, etc., show a loading indicator
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: AppTheme.spacingMedium),
            Text('Loading...'),
          ],
        ),
      ),
    );
  }
}
