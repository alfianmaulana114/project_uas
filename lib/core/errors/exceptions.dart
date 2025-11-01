/// Base exception class untuk semua custom exceptions
/// Mengikuti konsep OOP dengan inheritance
abstract class AppException implements Exception {
  /// Message error yang dapat ditampilkan ke user
  final String message;

  /// Constructor untuk AppException
  const AppException(this.message);
}

/// Exception untuk server errors
class ServerException extends AppException {
  /// Constructor untuk ServerException
  const ServerException([super.message = 'Server error occurred']);
}

/// Exception untuk network errors
class NetworkException extends AppException {
  /// Constructor untuk NetworkException
  const NetworkException([super.message = 'Network error occurred']);
}

/// Exception untuk cache errors
class CacheException extends AppException {
  /// Constructor untuk CacheException
  const CacheException([super.message = 'Cache error occurred']);
}

/// Exception untuk authentication errors
class AuthException extends AppException {
  /// Constructor untuk AuthException
  const AuthException([super.message = 'Authentication error occurred']);
}

