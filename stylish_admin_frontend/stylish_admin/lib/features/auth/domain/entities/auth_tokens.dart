import 'package:equatable/equatable.dart';

class AuthTokens extends Equatable {
  final String accessToken;
  final String refreshToken;
  final DateTime accessExpiry;
  final DateTime refreshExpiry;

  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.accessExpiry,
    required this.refreshExpiry,
  });

  @override
  List<Object> get props => [
    accessToken,
    refreshToken,
    accessExpiry,
    refreshExpiry,
  ];

  bool get isAccessTokenExpired => DateTime.now().isAfter(accessExpiry);
  bool get isRefreshTokenExpired => DateTime.now().isAfter(refreshExpiry);
  bool get canRefresh => !isRefreshTokenExpired;

  AuthTokens copyWith({
    String? accessToken,
    String? refreshToken,
    DateTime? accessExpiry,
    DateTime? refreshExpiry,
  }) {
    return AuthTokens(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      accessExpiry: accessExpiry ?? this.accessExpiry,
      refreshExpiry: refreshExpiry ?? this.refreshExpiry,
    );
  }
}
