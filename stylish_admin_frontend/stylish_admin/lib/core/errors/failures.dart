import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure({this.message = ''});
  @override
  List<Object> get props => [];
}

class ServerFailure extends Failure {
  const ServerFailure({super.message = "Server failure"});
}

class CacheFailure extends Failure {
  const CacheFailure({super.message = "Cache failure"});
}

class NetworkFailure extends Failure {
  const NetworkFailure({super.message = "Network failure"});
}

class AuthenticationFailure extends Failure {
  const AuthenticationFailure({super.message = "Auth failure"});
}

class ValidationFailure extends Failure {
  const ValidationFailure({super.message = "Validation failure"});
}
