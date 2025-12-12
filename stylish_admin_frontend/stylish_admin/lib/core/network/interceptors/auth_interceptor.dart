import 'package:dio/dio.dart';
import 'package:stylish_admin/core/constants/api_endpoints.dart';

class AuthInterceptor extends Interceptor {
  final Future<String?> Function() getAccessToken;
  final Future<bool> Function() refreshTokens;
  final Function(DioException error) onAuthError;

  // Flag to prevent infinite loops with 401 errors
  bool _isRetrying = false;

  AuthInterceptor({
    required this.getAccessToken,
    required this.refreshTokens,
    required this.onAuthError,
  });

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final publicEndpoints = [
      ApiEndpoints.login,
      ApiEndpoints.register,
      ApiEndpoints.passwordReset,
    ];

    // check if this is a public endpoint
    final isPublicEndpoint = publicEndpoints.any(
      (endpoint) => options.path.contains(endpoint),
    );

    if (isPublicEndpoint) {
      return handler.next(options);
    }

    // for protected endpoints, try to add token
    try {
      final token = await getAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }

      return handler.next(options);
    } catch (e) {
      return handler.next(options);
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (_isRetrying) {
      _isRetrying = false;
      return handler.next(err);
    }

    // Handle 401 errors with token refresh
    if (err.response?.statusCode == 401) {
      _isRetrying = true;

      try {
        final currentToken = await getAccessToken();
        if (currentToken == null || currentToken.isEmpty) {
          onAuthError(err);
          _isRetrying = false;
          return handler.next(err);
        }

        // Attempt to refresh tokens
        final refreshed = await refreshTokens();

        if (refreshed) {
          final token = await getAccessToken();
          // Retry original request with new token
          if (token != null && token.isNotEmpty) {
            final options = err.requestOptions;
            options.headers['Authorization'] = 'Bearer $token';

            // create a new Dio instance just for this retry to avoid interceptor loops

            final retryResponse = await Dio().fetch(options);
            _isRetrying = false;
            return handler.resolve(retryResponse);
          }
        }
        onAuthError(err);
        _isRetrying = false;
        return handler.next(err);
      } catch (e) {
        onAuthError(err);
        _isRetrying = false;
        return handler.next(err);
      }
    }

    return handler.next(err);
  }
}
