part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final UserEntity user;

  Authenticated({required this.user});

  @override
  List<Object?> get props => [user];
}

class UnAuthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  AuthError({required this.message});
  @override
  List<Object?> get props => [message];
}

class ProfileUpdating extends AuthState {}

class ProfileUpdateSuccess extends AuthState {
  final UserEntity updatedUser;

  ProfileUpdateSuccess({required this.updatedUser});
  @override
  List<Object?> get props => [updatedUser];
}

class ProfileUpdateError extends AuthState {
  final String error;

  ProfileUpdateError({required this.error});

  @override
  List<Object?> get props => [error];
}
