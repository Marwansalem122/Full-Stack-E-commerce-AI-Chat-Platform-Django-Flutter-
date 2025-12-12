import 'dart:async';

import 'package:flutter/material.dart';
import 'package:stylish_admin/app/app.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stylish_admin/app/app_bloc_observer.dart';
import 'package:stylish_admin/core/di/injection_container.dart' as di;
import 'package:stylish_admin/features/auth/presentation/bloc/auth_bloc.dart';

// Global error handler for uncaught exceptions
void _logError(Object error, StackTrace stack) {
  debugPrint('Unhandled exception: $error');
  debugPrint(stack.toString());
}

void main() async {
  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    Bloc.observer = AppBlocObserver();
    await di.init();
    final authBloc = di.sl<AuthBloc>()..add(CheckAuthStatusEvent());
    runApp(StylishAdminApp(authBloc: authBloc));
  }, _logError);
}
