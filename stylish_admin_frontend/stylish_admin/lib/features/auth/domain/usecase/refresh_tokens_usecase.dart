import 'package:dartz/dartz.dart';
import 'package:stylish_admin/core/errors/failures.dart';
import 'package:stylish_admin/core/usecases/usecase.dart';
import 'package:stylish_admin/features/auth/domain/entities/auth_tokens.dart';
import 'package:stylish_admin/features/auth/domain/repositories/auth_repository.dart';

class RefreshTokensUseCase implements UseCase<AuthTokens, NoParams> {
  final AuthRepository repository;

  RefreshTokensUseCase(this.repository);
  @override
  Future<Either<Failure, AuthTokens>> call(NoParams params) {
    return repository.refreshTokens();
  }
}
