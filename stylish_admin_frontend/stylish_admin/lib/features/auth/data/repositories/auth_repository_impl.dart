import 'package:dartz/dartz.dart';
import 'package:stylish_admin/core/auth/token_manager.dart';
import 'package:stylish_admin/core/errors/exceptions.dart';
import 'package:flutter/foundation.dart';
import 'package:stylish_admin/core/errors/failures.dart';
import 'package:stylish_admin/core/network/network_info.dart';
import 'package:stylish_admin/features/auth/data/data_sources/auth_local_data_source.dart';
import 'package:stylish_admin/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:stylish_admin/features/auth/data/models/auth_tokens_model.dart';
import 'package:stylish_admin/features/auth/data/models/user_model.dart';
import 'package:stylish_admin/features/auth/domain/entities/auth_credentials.dart';
import 'package:stylish_admin/features/auth/domain/entities/auth_tokens.dart';
import 'package:stylish_admin/features/auth/domain/entities/user_entity.dart';
import 'package:stylish_admin/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final TokenManager tokenManager;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.tokenManager,
    required this.networkInfo,
  });
  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final cachedUser = await localDataSource.getUser();
      if (cachedUser != null) {
        // Validate token to ensure user is still authenticated
        if (await networkInfo.isConnected) {
          try {
            final isValid = await remoteDataSource.validateToken();
            if (isValid) {
              return Right(cachedUser);
            } else {
              return await _refreshAndGetUser();
            }
          } catch (e) {
            return Right(cachedUser);
          }
        } else {
          return Right(cachedUser);
        }
      } else {
        if (await networkInfo.isConnected) {
          try {
            final user = await remoteDataSource.getUserProfile();
            await localDataSource.cacheUser(user);
            return Right(user);
          } catch (e) {
            return const Right(null);
          }
        } else {
          return const Right(null);
        }
      }
    } on CacheException {
      return const Right(null);
    } catch (e) {
      return const Right(null);
    }
  }

  // Helper method to refresh tokens and get user
  Future<Either<Failure, UserEntity?>> _refreshAndGetUser() async {
    final refreshResult = await refreshTokens();
    return refreshResult.fold((failure) => Left(failure), (tokens) async {
      try {
        final user = await remoteDataSource.getUserProfile();
        await localDataSource.cacheUser(user);
        return Right(user);
      } catch (e) {
        return const Right(null);
      }
    });
  }

  @override
  Future<Either<Failure, UserEntity>> loginWithEmailAndPassword(
    AuthCredentials credentials,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.login(
          credentials.email,
          credentials.password,
        );

        // Extract user and tokens from result
        final user = UserModel.fromJson(result['user']);
        final tokens = AuthTokensModel.fromJson(result['tokens']);

        // cache user and tokens
        await localDataSource.cacheUser(user);
        await localDataSource.cacheTokens(tokens);
        return Right(user);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } on AuthenticationException catch (e) {
        return Left(AuthenticationFailure(message: e.message));
      } catch (e, stackTrace) {
        debugPrint("Login Error in Repository: $e");
        debugPrintStack(stackTrace: stackTrace);
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      if (await networkInfo.isConnected) {
        try {
          await remoteDataSource.logout();
        } catch (e) {
          // continue with local logout even if remote fails
        }
      }
      // always clear local auth data
      await localDataSource.clearAuthData();
      return const Right(null);
    } on CacheException {
      return Left(CacheFailure());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthTokens>> refreshTokens() async {
    if (await networkInfo.isConnected) {
      try {
        final newTokens = await remoteDataSource.refreshTokens();
        // Cache new tokens
        await localDataSource.cacheTokens(newTokens);

        return Right(newTokens);
      } on ServerException catch (e) {
        await localDataSource.clearAuthData();
        return Left(AuthenticationFailure(message: e.message));
      } on CacheException {
        return Left(CacheFailure());
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, UserEntity>> registerWithEmailAndPassword(
    AuthCredentials credentials,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.register(
          credentials.email,
          credentials.password,
          credentials.phoneNumber,
          credentials.firstName,
          credentials.lastName,
        );

        // Extract user and tokens from result
        final user = UserModel.fromJson(result['user']);
        final tokens = AuthTokensModel.fromJson(result['tokens']);

        final bool isVerified = result['email_verified'] ?? false;

        // Update user verification status from backend
        if (user.isVerified != isVerified) {
          final updatedUser = UserModel(
            id: user.id,
            email: user.email,
            username: user.username,
            firstName: user.firstName,
            lastName: user.lastName,
            phoneNumber: user.phoneNumber,
            profilePictureUrl: user.profilePictureUrl,
            isVerified: isVerified,
          );
          await localDataSource.cacheUser(updatedUser);
          await localDataSource.cacheTokens(tokens);
          return Right(updatedUser);
        }

        // cache user and tokens
        await localDataSource.cacheUser(user);
        await localDataSource.cacheTokens(tokens);
        return Right(user);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } on AuthenticationException catch (e) {
        return Left(AuthenticationFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateUserProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    profileImage,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final user = await remoteDataSource.updateUserProfile(
          firstName,
          lastName,
          phoneNumber,
          profileImage,
        );
        await localDataSource.cacheUser(user);
        return Right(user);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } on AuthenticationFailure catch (e) {
        return Left(AuthenticationFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> validateToken() async {
    if (await networkInfo.isConnected) {
      try {
        if (!await tokenManager.hasTokens()) {
          return const Right(false);
        }

        // Check if tokens are expired locally first
        final authStatus = await tokenManager.getAuthStatus();

        switch (authStatus) {
          case AuthStatus.authenticated:
            break;
          case AuthStatus.expired:
            final refreshed = await tokenManager.refreshTokens();
            if (!refreshed) {
              return const Right(false);
            }

            break;
          case AuthStatus.unauthenticated:
            return const Right(false);
        }
        final isValid = await remoteDataSource.validateToken();
        return Right(isValid);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      try {
        if (!await tokenManager.hasTokens()) {
          return const Right(false);
        }

        final authStatus = await tokenManager.getAuthStatus();
        return Right(authStatus == AuthStatus.authenticated);
      } on CacheException {
        return Left(CacheFailure());
      } catch (e) {
        return Left(CacheFailure());
      }
    }
  }
}
