class ServerException implements Exception {
  final String message;
  ServerException({this.message = ''});
}

class CacheException implements Exception {}

class NetworkException implements Exception {}

class AuthenticationException implements Exception {
  final String message;
  AuthenticationException({this.message = 'Authentication failed'});
  @override
  String toString() => message;
}
