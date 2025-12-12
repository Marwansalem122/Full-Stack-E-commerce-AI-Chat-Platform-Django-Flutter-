import 'package:stylish_admin/features/auth/domain/entities/auth_tokens.dart';

class AuthTokensModel extends AuthTokens {
  const AuthTokensModel({
    required super.accessToken,
    required super.refreshToken,
    required super.accessExpiry,
    required super.refreshExpiry,
  });

  /// Deserializes from the API response
  factory AuthTokensModel.fromJson(Map<String, dynamic> json) {
    final int accessExpiresIn = json['expires_in'] is int
        ? json['expires_in']
        : int.tryParse(json['expires_in'].toString()) ?? 900;
    final int refreshExpiresIn = json['refresh_expires_in'] is int
        ? json['refresh_expires_in']
        : int.tryParse(json['refresh_expires_in']?.toString() ?? '') ?? 1209600;
    return AuthTokensModel(
      accessToken: json['access_token'] ?? '',
      refreshToken: json['refresh_token'] ?? '',
      accessExpiry: DateTime.now().add(Duration(seconds: accessExpiresIn)),
      refreshExpiry: DateTime.now().add(Duration(seconds: refreshExpiresIn)),
    );
  }

  /// Deserializes from local stroge (SharedPreferences)
  factory AuthTokensModel.fromStorage(Map<String, dynamic> json) {
    return AuthTokensModel(
      accessToken: json['access_token'] ?? '',
      refreshToken: json['refresh_token'] ?? "",
      accessExpiry:
          DateTime.tryParse(json['access_expiry'] ?? '') ?? DateTime.now(),
      refreshExpiry:
          DateTime.tryParse(json['refresh_token'] ?? '') ?? DateTime.now(),
    );
  }

  /// serializes for storing locally
  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'access_expiry': accessExpiry.toIso8601String(),
      'refresh_expiry': refreshExpiry.toIso8601String(),
    };
  }

  factory AuthTokensModel.fromEntity(AuthTokens entity) {
    return AuthTokensModel(
      accessToken: entity.accessToken,
      refreshToken: entity.refreshToken,
      accessExpiry: entity.accessExpiry,
      refreshExpiry: entity.refreshExpiry,
    );
  }
}
