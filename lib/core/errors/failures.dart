import 'package:equatable/equatable.dart';

/// Base failure class untuk semua failures
/// Menggunakan Equatable untuk value comparison
/// Mengikuti konsep OOP dengan inheritance
abstract class Failure extends Equatable {
  /// Message error yang dapat ditampilkan ke user
  final String message;

  /// Constructor untuk Failure
  const Failure(this.message);

  /// Override props untuk Equatable comparison
  @override
  List<Object> get props => [message];
}

/// Failure untuk server errors
class ServerFailure extends Failure {
  /// Constructor untuk ServerFailure
  const ServerFailure([super.message = 'Server error occurred']);
}

/// Failure untuk network errors
class NetworkFailure extends Failure {
  /// Constructor untuk NetworkFailure
  const NetworkFailure([super.message = 'Network error occurred']);
}

/// Failure untuk cache errors
class CacheFailure extends Failure {
  /// Constructor untuk CacheFailure
  const CacheFailure([super.message = 'Cache error occurred']);
}

/// Failure untuk authentication errors
class AuthFailure extends Failure {
  /// Constructor untuk AuthFailure
  const AuthFailure([super.message = 'Authentication error occurred']);
}

