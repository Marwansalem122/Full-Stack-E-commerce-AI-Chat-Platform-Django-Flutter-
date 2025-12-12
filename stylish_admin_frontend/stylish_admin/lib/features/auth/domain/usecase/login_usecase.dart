import 'package:dartz/dartz.dart';
import 'package:stylish_admin/core/errors/failures.dart';
import 'package:stylish_admin/core/usecases/usecase.dart';
import 'package:stylish_admin/features/auth/domain/entities/auth_credentials.dart';
import 'package:stylish_admin/features/auth/domain/entities/user_entity.dart';
import 'package:stylish_admin/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase implements UseCase<UserEntity, AuthCredentials> {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(AuthCredentials params) async {
    // Validate credentials
    if (!params.hasValidEmail) {
      return Left(
        ValidationFailure(message: "Please enter a valid email address"),
      );
    }

    if (params.password.isEmpty) {
      return Left(ValidationFailure(message: "Password cannot be empty"));
    }
    return repository.loginWithEmailAndPassword(params);
  }
}
