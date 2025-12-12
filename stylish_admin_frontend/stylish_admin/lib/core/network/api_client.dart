import 'package:dio/dio.dart';
import 'package:stylish_admin/core/auth/token_manager.dart';
import 'package:stylish_admin/core/constants/api_endpoints.dart';

import 'package:stylish_admin/core/network/interceptors/auth_interceptor.dart';

class ApiClient {
  final Dio _dio;
  final TokenManager tokenManager;
  final Function()? onAuthenticationFailed;

  ApiClient({
    required Dio dio,
    required this.tokenManager,
    this.onAuthenticationFailed,
  }) : _dio = dio {
    // set base options
    _dio.options = BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );

    // Add interceptors
    _dio.interceptors.addAll([
      AuthInterceptor(
        getAccessToken: tokenManager.getAccessToken,
        refreshTokens: tokenManager.refreshTokens,
        onAuthError: (DioException error) {
          tokenManager.clearTokens();
          onAuthenticationFailed?.call();
        },
      ),
    ]);
  }

  // Create options with withCredentials for web cookied handling
  Options _createOptions({Options? options}) {
    return Options(
      headers: options?.headers,
      method: options?.method,
      sendTimeout: options?.sendTimeout,
      receiveTimeout: options?.receiveTimeout,
      extra: options?.extra,
      followRedirects: options?.followRedirects,
      validateStatus: options?.validateStatus,
      receiveDataWhenStatusError: options?.receiveDataWhenStatusError,
      listFormat: options?.listFormat,
      responseType: options?.responseType,
      contentType: options?.contentType,
    )..extra = {
        ...?options?.extra,
        'withCredentials': true, // enable cookies for web
      };
  }

  // Generic request handler
  Future<dynamic> _request(Future<Response> Function() requestMaker) async {
    final response = await requestMaker();
    return response.data;
  }

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    final requestOptions = _createOptions(options: options);
    return _request(
      () => _dio.get(
        path,
        queryParameters: queryParameters,
        options: requestOptions,
      ),
    );
  }

  Future<dynamic> post(String path, {dynamic data, Options? options}) {
    final requestOptions = _createOptions(options: options);
    return _request(() => _dio.post(path, data: data, options: requestOptions));
  }

  Future<dynamic> put(String path, {dynamic data, Options? options}) {
    final requestOptions = _createOptions(options: options);
    return _request(() => _dio.put(path, data: data, options: requestOptions));
  }

  Future<dynamic> patch(String path, {dynamic data, Options? options}) {
    final requestOptions = _createOptions(options: options);
    return _request(
        () => _dio.patch(path, data: data, options: requestOptions));
  }

  Future<dynamic> delete(String path, {dynamic data, Options? options}) {
    final requestOptions = _createOptions(options: options);
    return _request(
        () => _dio.delete(path, data: data, options: requestOptions));
  }
}
