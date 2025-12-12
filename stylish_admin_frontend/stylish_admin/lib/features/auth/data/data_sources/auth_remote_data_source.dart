import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:stylish_admin/core/auth/token_manager.dart';
import 'package:stylish_admin/core/constants/api_endpoints.dart';
import 'package:stylish_admin/core/errors/exceptions.dart';
import 'package:stylish_admin/core/network/api_client.dart';
import 'package:stylish_admin/features/auth/data/models/auth_tokens_model.dart';
import 'package:stylish_admin/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> register(
    String email,
    String password,
    String? phoneNumber,
    String? firstName,
    String? lastName,
  );

  Future<Map<String, dynamic>> login(String email, String password);
  Future<UserModel> getUserProfile();

  Future<UserModel> updateUserProfile(
    String? firstName,
    String? lastName,
    String? phoneNumber,
    Uint8List? profileImageBytes,
  );

  Future<AuthTokensModel> refreshTokens();
  Future<bool> validateToken();
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;
  final TokenManager tokenManager;

  AuthRemoteDataSourceImpl({
    required this.apiClient,
    required this.tokenManager,
  });

  @override
  Future<UserModel> getUserProfile() async {
    try {
      final responseData = await apiClient.get(ApiEndpoints.profile);

      if (responseData['success'] != true) {
        throw ServerException(
          message: responseData['error'] ?? "Failed to get user profile",
        );
      }

      return UserModel.fromJson(responseData['data']);
    } on DioException catch (e) {
      final errorMessage = _handleDioError(e);
      throw ServerException(message: errorMessage);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final responseData = await apiClient.post(
        ApiEndpoints.login,
        data: {'email': email, 'password': password},
      );
      if (responseData['success'] != true) {
        throw ServerException(message: responseData['error'] ?? 'Login failed');
      }

      final data = responseData['data'];
      debugPrint("Login Raw Data: $data");

      AuthTokensModel tokens;
      try {
        tokens = AuthTokensModel.fromJson(data['tokens']);
      } catch (e) {
        debugPrint("Error parsing tokens: $e");
        rethrow;
      }

      UserModel user;
      try {
        user = UserModel.fromJson(data['user']);
      } catch (e) {
        debugPrint("Error parsing user: $e");
        rethrow;
      }

      await tokenManager.storeTokens(tokens);
      return data;
    } on DioException catch (e) {
      final errorMessage = _handleDioError(e);
      throw ServerException(message: errorMessage);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  String _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout) {
      return 'Connection timeout. Please check your internet connection';
    } else if (e.type == DioExceptionType.receiveTimeout) {
      return 'Server is taking too long to respond. Please try again later.';
    } else if (e.type == DioExceptionType.connectionError) {
      return 'Connection error.Please check your internet connection.';
    } else if (e.response != null) {
      final statusCode = e.response!.statusCode;
      final data = e.response!.data;
      // Handle specific error responses
      if (data is Map && data.containsKey('error')) {
        final errorMessage = data['error'].toString();
        // check for specific error patterns
        if (errorMessage.contains('locked')) {
          return "Your account has been temporarily locked due to multiple failed login attempts. Please try again later.";
        } else if (errorMessage.contains('Invalid email or pasword')) {
          return 'The email or password you entered is incorrect. Please try again.';
        } else if (errorMessage.contains('disabled')) {
          return 'Your account has been disabled. Please contact support for assistance.';
        }
        return errorMessage;
      } else if (statusCode == 401) {
        return "Invalid email or password. Please check credentials and try again.";
      } else if (statusCode == 403) {
        if (data is Map &&
            data.containsKey('lockout') &&
            data['lockout'] == true) {
          return "Account temporarily locked due to multiple failed attempts. Try again later.";
        }

        return "Access denied. Please contact support if this problem persists";
      } else if (statusCode == 404) {
        return "Service not found. Please check your connection and try again.";
      } else if (statusCode == 400) {
        return "Invalid request. Please check your inputs and try again.";
      } else if (statusCode == 500) {
        return "Server error. Please try again later or contact support";
      } else {
        return "Server error ($statusCode). Please try again later";
      }
    }
    return "Network error. Please check your connection and try again. ";
  }

  @override
  Future<void> logout() async {
    try {
      try {
        await apiClient.post(ApiEndpoints.logout);
      } catch (e) {
        debugPrint('Backend logout failed, proceeding with local cleanup: $e');
      }
      // Always clear local tokens regardles of backend call success
      await tokenManager.clearTokens();
    } catch (e) {
      debugPrint("Error during logou: $e");
      await tokenManager.clearTokens();
    }
  }

  @override
  Future<AuthTokensModel> refreshTokens() async {
    try {
      final responseData = await apiClient.post(ApiEndpoints.refreshToken);

      if (responseData['success'] != true) {
        throw ServerException(
          message: responseData['error'] ?? "Token refresh failed",
        );
      }

      final accessToken = responseData['data']['access_token'];
      return AuthTokensModel.fromJson({
        'access_token': accessToken,
        'refersh_token': '',
        'expires_in': 900,
        'refresh_expires_in': 0,
      });
    } on DioException catch (e) {
      final errorMessage = _handleDioError(e);
      throw ServerException(message: errorMessage);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> register(
    String email,
    String password,
    String? phoneNumber,
    String? firstName,
    String? lastName,
  ) async {
    try {
      final Map<String, dynamic> registrationData = {
        'email': email,
        'password': password,
      };

      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        registrationData['phone_number'] = phoneNumber;
      }

      if (firstName != null && firstName.isNotEmpty) {
        registrationData['first_name'] = firstName;
      }
      if (lastName != null && lastName.isNotEmpty) {
        registrationData['last_name'] = lastName;
      }

      final responseData = await apiClient.post(
        ApiEndpoints.register,
        data: registrationData,
      );

      final data = responseData['data'];
      final tokens = AuthTokensModel.fromJson(data['tokens']);
      await tokenManager.storeTokens(tokens);

      return data;
    } on DioException catch (e) {
      final errorMessage = _handleDioError(e);
      throw ServerException(message: errorMessage);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<UserModel> updateUserProfile(
    String? firstName,
    String? lastName,
    String? phoneNumber,
    Uint8List? profileImageBytes,
  ) async {
    try {
      final updateData = <String, dynamic>{};

      if (firstName != null) updateData['first_name'] = firstName;
      if (lastName != null) updateData['last_name'] = lastName;
      if (phoneNumber != null) updateData['phone_number'] = phoneNumber;

      // Handle profile image as base64 data if provided
      if (profileImageBytes != null) {
        final base64Image = base64Encode(profileImageBytes);
        // Send as JSON array that django expects
        updateData['image_data'] = jsonEncode([
          {
            'data': 'data:image/jpeg;base64,$base64Image',
            'name': 'profile_image.jpg',
            'type': 'image/jpeg',
          },
        ]);
      }

      final responseData = await apiClient.put(
        ApiEndpoints.profile,
        data: updateData,
      );

      if (responseData['success'] != true) {
        throw ServerException(
          message: responseData['error'] ?? "profile update failed",
        );
      }

      return UserModel.fromJson(responseData['data']);
    } on DioException catch (e) {
      final errorMessage = _handleDioError(e);
      throw ServerException(message: errorMessage);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<bool> validateToken() async {
    try {
      final responseData = await apiClient.get(ApiEndpoints.validateToken);
      if (responseData['success'] != true) {
        return false;
      }
      return responseData['data']['valid'] ?? false;
    } on DioException catch (e) {
      debugPrint('Token validation DioException: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('Token validation error: $e');
      return false;
    }
  }
}
