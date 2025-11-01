import 'package:get_it/get_it.dart';
import 'features/authentication/data/datasources/auth_remote_datasource.dart';
import 'features/authentication/data/repositories/auth_repository_impl.dart';
import 'features/authentication/domain/repositories/auth_repository.dart';
import 'features/authentication/domain/usecases/sign_in_usecase.dart';
import 'features/authentication/domain/usecases/sign_up_usecase.dart';
import 'features/authentication/domain/usecases/sign_out_usecase.dart';
import 'features/authentication/domain/usecases/get_current_user_usecase.dart';
import 'features/authentication/presentation/providers/auth_provider.dart';

/// Service Locator menggunakan GetIt
/// Mengikuti konsep Dependency Injection (SOLID - Dependency Inversion Principle)
/// Semua dependencies di-register di sini untuk loose coupling
final sl = GetIt.instance;

/// Method untuk menginisialisasi semua dependencies
/// Harus dipanggil sebelum menggunakan dependencies
/// Mengikuti konsep Inversion of Control
Future<void> init() async {
  // ============ Data Sources ============
  /// Register AuthRemoteDatasource sebagai singleton
  /// Singleton berarti hanya ada satu instance untuk seluruh aplikasi
  sl.registerLazySingleton<AuthRemoteDatasource>(
    () => AuthRemoteDatasourceImpl(),
  );

  // ============ Repositories ============
  /// Register AuthRepository dengan implementasinya
  /// Menggunakan AuthRemoteDatasource yang sudah di-register sebelumnya
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      sl<AuthRemoteDatasource>(),
    ),
  );

  // ============ Use Cases ============
  /// Register SignInUsecase
  /// Menggunakan AuthRepository yang sudah di-register sebelumnya
  sl.registerLazySingleton(
    () => SignInUsecase(sl<AuthRepository>()),
  );

  /// Register SignUpUsecase
  /// Menggunakan AuthRepository yang sudah di-register sebelumnya
  sl.registerLazySingleton(
    () => SignUpUsecase(sl<AuthRepository>()),
  );

  /// Register SignOutUsecase
  /// Menggunakan AuthRepository yang sudah di-register sebelumnya
  sl.registerLazySingleton(
    () => SignOutUsecase(sl<AuthRepository>()),
  );

  /// Register GetCurrentUserUsecase
  /// Menggunakan AuthRepository yang sudah di-register sebelumnya
  sl.registerLazySingleton(
    () => GetCurrentUserUsecase(sl<AuthRepository>()),
  );

  // ============ Providers ============
  /// Register AuthProvider sebagai factory
  /// Factory berarti setiap kali dipanggil akan membuat instance baru
  /// Ini diperlukan karena AuthProvider menggunakan ChangeNotifier
  sl.registerFactory(
    () => AuthProvider(
      signInUsecase: sl<SignInUsecase>(),
      signUpUsecase: sl<SignUpUsecase>(),
      signOutUsecase: sl<SignOutUsecase>(),
      getCurrentUserUsecase: sl<GetCurrentUserUsecase>(),
    ),
  );
}

