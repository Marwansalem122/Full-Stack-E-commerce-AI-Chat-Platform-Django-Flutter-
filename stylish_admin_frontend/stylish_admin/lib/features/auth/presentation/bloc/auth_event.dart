part of 'auth_bloc.dart';



abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CheckAuthStatusEvent extends AuthEvent {
  final bool forceCheck;
  CheckAuthStatusEvent({this.forceCheck = false});

  @override
  List<Object?> get props => [forceCheck];
}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  LoginEvent({required this.email, required this.password});
@override
  List<Object?> get props => [email, password];
}

class LogoutEvent extends AuthEvent {}
class UpdateProfileEvent extends AuthEvent {
  final UpdateProfileParams params;

  UpdateProfileEvent(this.params);
  
  @override
  List<Object?> get props => [params];
}
