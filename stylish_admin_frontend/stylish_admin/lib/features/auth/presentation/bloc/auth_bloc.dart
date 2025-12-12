import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stylish_admin/core/usecases/usecase.dart';
import 'package:stylish_admin/features/auth/domain/entities/auth_credentials.dart';
import 'package:stylish_admin/features/auth/domain/entities/user_entity.dart';
import 'package:stylish_admin/features/auth/domain/usecase/auth_usecases.dart';
import 'package:flutter/foundation.dart';
part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  // Use cases
  final GetCurrentUserUsecase getCurrentUser;
  final LoginUseCase login;
  final LogoutUseCase logout;
  final UpdateProfileUseCase updateProfile;
  final ValidateTokenUseCase validateToken;

  AuthBloc({
    required this.getCurrentUser,
    required this.login,
    required this.logout,
    required this.updateProfile,
    required this.validateToken,
  }) : super(AuthInitial()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<LoginEvent>(_onLogin);
    on<LogoutEvent>(_onLogout);
    on<UpdateProfileEvent>(_onUpdateProfile);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    // Validate the token
    final validateResult = await validateToken(NoParams());
    final isTokenValid = validateResult.getOrElse(() => false);

    if (!isTokenValid) {
      emit(UnAuthenticated());
      return;
    }

    final userResult = await getCurrentUser(NoParams());
    userResult.fold(
      (failure) {
        emit(UnAuthenticated());
      },
      (user) {
        if (user != null) {
          emit(Authenticated(user: user));
        } else {
          emit(UnAuthenticated());
        }
      },
    );
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final credentials = AuthCredentials(
      email: event.email,
      password: event.password,
    );
    final result = await login(credentials);

    result.fold(
      (failure) {
        emit(AuthError(message: failure.message));
        debugPrint("Failure: $failure");
      },
      (user) {
        emit(Authenticated(user: user));
        debugPrint("User: $user");
      },
    );
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await logout(NoParams());

    result.fold(
      (failure) =>
          emit(AuthError(message: 'Logout failed: ${failure.message}')),
      (_) => emit(UnAuthenticated()),
    );
  }

  Future<void> _onUpdateProfile(
    UpdateProfileEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(ProfileUpdating());
    final result = await updateProfile(event.params);
    result.fold((failure) => emit(ProfileUpdateError(error: failure.message)), (
      updatedUser,
    ) {
      emit(ProfileUpdateSuccess(updatedUser: updatedUser));
      emit(Authenticated(user: updatedUser));
    });
  }
}
