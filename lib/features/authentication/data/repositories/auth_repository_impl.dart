import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/auth_user_model.dart';

/// Implementation dari AuthRepository
/// Mengikuti konsep Clean Architecture - Data Layer
/// Menggunakan dependency injection untuk AuthRemoteDatasource
/// Convert exceptions ke failures (Domain Layer pattern)
/// 
/// PENTING: Tidak ada local storage atau cache mechanism
/// Semua data langsung ke Supabase (online database)
/// State user hanya disimpan di memory (Provider), tidak persist
class AuthRepositoryImpl implements AuthRepository {
  /// Instance dari AuthRemoteDatasource
  /// Menggunakan dependency injection untuk loose coupling
  /// Hanya menggunakan remote datasource (Supabase), tidak ada local datasource
  final AuthRemoteDatasource remoteDatasource;

  /// Constructor untuk AuthRepositoryImpl
  /// [remoteDatasource] adalah instance dari AuthRemoteDatasource
  AuthRepositoryImpl(this.remoteDatasource);

  /// Method untuk sign in user dengan email dan password
  /// Convert exception ke failure sesuai dengan Clean Architecture
  @override
  Future<Either<Failure, AuthUser>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      /// Memanggil remote datasource untuk sign in
      final result = await remoteDatasource.signIn(
        email: email,
        password: password,
      );

      /// Jika berhasil, return Right dengan AuthUser
      return Right(result);
    } on AuthException catch (e) {
      /// Jika terjadi AuthException, convert ke AuthFailure
      return Left(AuthFailure(e.message));
    } catch (e) {
      /// Jika terjadi error lain, convert ke ServerFailure
      return Left(ServerFailure('Gagal melakukan sign in: ${e.toString()}'));
    }
  }

  /// Method untuk sign up user baru
  /// Convert exception ke failure sesuai dengan Clean Architecture
  @override
  Future<Either<Failure, AuthUser>> signUp({
    required String email,
    required String password,
    String? fullName,
    String? username,
  }) async {
    try {
      /// Memanggil remote datasource untuk sign up
      final result = await remoteDatasource.signUp(
        email: email,
        password: password,
        fullName: fullName,
        username: username,
      );

      /// Jika berhasil, return Right dengan AuthUser
      return Right(result);
    } on AuthException catch (e) {
      /// Jika terjadi AuthException, convert ke AuthFailure
      return Left(AuthFailure(e.message));
    } catch (e) {
      /// Jika terjadi error lain, convert ke ServerFailure
      return Left(ServerFailure('Gagal melakukan sign up: ${e.toString()}'));
    }
  }

  /// Method untuk sign out user
  /// Convert exception ke failure sesuai dengan Clean Architecture
  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      /// Memanggil remote datasource untuk sign out
      await remoteDatasource.signOut();

      /// Jika berhasil, return Right dengan void
      return const Right(null);
    } on AuthException catch (e) {
      /// Jika terjadi AuthException, convert ke AuthFailure
      return Left(AuthFailure(e.message));
    } catch (e) {
      /// Jika terjadi error lain, convert ke ServerFailure
      return Left(ServerFailure('Gagal melakukan sign out: ${e.toString()}'));
    }
  }

  /// Method untuk mendapatkan user yang sedang login
  /// Convert exception ke failure sesuai dengan Clean Architecture
  @override
  Future<Either<Failure, AuthUser?>> getCurrentUser() async {
    try {
      /// Memanggil remote datasource untuk get current user
      final result = await remoteDatasource.getCurrentUser();

      /// Jika berhasil, return Right dengan AuthUser? (bisa null)
      return Right(result);
    } catch (e) {
      /// Jika terjadi error, convert ke ServerFailure
      return Left(ServerFailure('Gagal mendapatkan current user: ${e.toString()}'));
    }
  }

  /// Method untuk update data user
  /// Convert exception ke failure sesuai dengan Clean Architecture
  @override
  Future<Either<Failure, AuthUser>> updateUser(AuthUser user) async {
    try {
      /// Convert AuthUser entity ke AuthUserModel untuk datasource
      final userModel = AuthUserModel.fromEntity(user);
      
      /// Memanggil remote datasource untuk update user
      final result = await remoteDatasource.updateUser(userModel);

      /// Jika berhasil, return Right dengan AuthUser yang sudah diupdate
      return Right(result);
    } on AuthException catch (e) {
      /// Jika terjadi AuthException, convert ke AuthFailure
      return Left(AuthFailure(e.message));
    } catch (e) {
      /// Jika terjadi error lain, convert ke ServerFailure
      return Left(ServerFailure('Gagal melakukan update user: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, AuthUser>> updateCredentials({String? email, String? password}) async {
    try {
      final result = await remoteDatasource.updateCredentials(email: email, password: password);
      return Right(result);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Gagal memperbarui kredensial: ${e.toString()}'));
    }
  }
}

