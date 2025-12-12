import 'dart:async';

import 'package:dio/dio.dart';
import 'package:stylish_admin/core/constants/api_endpoints.dart';
import 'package:stylish_admin/features/auth/data/data_sources/auth_local_data_source.dart';
import 'package:stylish_admin/features/auth/data/models/auth_tokens_model.dart';

class TokenManager {
  final AuthLocalDataSource _localDataSource;
  final Dio _authDio;

  bool _isRefreshing = false;
  Completer<bool>? _refreshCompleter;

  TokenManager({required AuthLocalDataSource localDataSource})
    : _localDataSource = localDataSource,
      _authDio = Dio(
        BaseOptions(
          baseUrl: ApiEndpoints.baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

  /// Get the current access token
  Future<String?> getAccessToken() async {
    try {
      if (!await _localDataSource.hasTokes()) {
        return null;
      }

      final tokens = await _localDataSource.getTokens();
      return tokens.accessToken;
    } catch (e) {
      return null;
    }
  }

  /// Store tokens in memory
  Future<void> storeTokens(AuthTokensModel tokens) async {
    await _localDataSource.cacheTokens(tokens);
  }

  /// Refresh tokens using the HttpOnly cookie.
  Future<bool> refreshTokens() async {
    if (_isRefreshing) {
      return await _refreshCompleter!.future;
    }
    _isRefreshing = true;
    _refreshCompleter = Completer<bool>();

    try {
      final response = await _authDio.post(
        ApiEndpoints.refreshToken,
        options: Options(extra: {'withCredentials': true}),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final newAccessToken = response.data['data']['access_token'];

        final oldTokens = await _localDataSource.getTokens();
        final newTokens = AuthTokensModel(
          accessToken: newAccessToken,
          refreshToken: '',
          accessExpiry: DateTime.now().add(const Duration(minutes: 15)),
          refreshExpiry: oldTokens.refreshExpiry,
        );

        await storeTokens(newTokens);
        _refreshCompleter!.complete(true);
        return true;
      } else {
        _refreshCompleter!.complete(false);
        return false;
      }
    } catch (e) {
      _refreshCompleter!.complete(false);
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  /// Clear all tokens from memory
  Future<void> clearTokens() async {
    await _localDataSource.clearAuthData();
  }

  /// check if we have tokens stored.
  Future<bool> hasTokens() async {
    return await _localDataSource.hasTokes();
  }

  /// Check if access token is expired based on stored expiry time
  Future<bool> isAccessTokenExpired() async {
    try {
      if (!await hasTokens()) {
        return true;
      }

      final tokens = await _localDataSource.getTokens();
      return tokens.accessExpiry.isBefore(DateTime.now());
    } catch (e) {
      return true;
    }
  }

  /// Check if refresh token is expired based on stored expiry time
  Future<bool> isRefreshTokenExpired() async {
    try {
      if (!await hasTokens()) {
        return true;
      }

      final tokens = await _localDataSource.getTokens();
      return tokens.refreshExpiry.isBefore(DateTime.now());
    } catch (e) {
      return true;
    }
  }

  /// Get authentication status
  Future<AuthStatus> getAuthStatus() async {
    try {
      if (!await hasTokens()) {
        return AuthStatus.unauthenticated;
      }

      if (!await isAccessTokenExpired()) {
        return AuthStatus.authenticated;
      }

      if (!await isRefreshTokenExpired()) {
        return AuthStatus.expired;
      }

      return AuthStatus.unauthenticated;
    } catch (e) {
      return AuthStatus.unauthenticated;
    }
  }
}

enum AuthStatus {
  authenticated, // Valid access token
  expired, // Access token expired but refresh token valid
  unauthenticated, // No tokens or both expired
}
