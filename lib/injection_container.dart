import 'package:get_it/get_it.dart';
import 'features/authentication/data/datasources/auth_remote_datasource.dart';
import 'features/authentication/data/repositories/auth_repository_impl.dart';
import 'features/authentication/domain/repositories/auth_repository.dart';
import 'features/authentication/domain/usecases/sign_in_usecase.dart';
import 'features/authentication/domain/usecases/sign_up_usecase.dart';
import 'features/authentication/domain/usecases/sign_out_usecase.dart';
import 'features/authentication/domain/usecases/get_current_user_usecase.dart';
import 'features/authentication/presentation/providers/auth_provider.dart';
import 'features/challenge/data/datasources/challenge_remote_datasource.dart';
import 'features/challenge/data/repositories/challenge_repository_impl.dart';
import 'features/challenge/domain/repositories/challenge_repository.dart';
import 'features/challenge/domain/usecases/get_all_challenges_usecase.dart';
import 'features/challenge/domain/usecases/get_active_challenge_usecase.dart';
import 'features/challenge/domain/usecases/start_challenge_usecase.dart';
import 'features/challenge/domain/usecases/check_in_usecase.dart';
import 'features/challenge/presentation/providers/challenge_provider.dart';
import 'features/reward/data/datasources/reward_remote_datasource.dart';
import 'features/reward/data/repositories/reward_repository_impl.dart';
import 'features/reward/domain/repositories/reward_repository.dart';
import 'features/reward/domain/usecases/get_all_achievements_usecase.dart';
import 'features/reward/domain/usecases/get_user_achievements_usecase.dart';
import 'features/reward/domain/usecases/check_achievements_usecase.dart';
import 'features/reward/presentation/providers/reward_provider.dart';
import 'features/analytics/data/datasources/analytics_remote_datasource.dart';
import 'features/analytics/data/repositories/analytics_repository_impl.dart';
import 'features/analytics/domain/repositories/analytics_repository.dart';
import 'features/analytics/domain/usecases/get_user_stats_usecase.dart';
import 'features/analytics/domain/usecases/get_weekly_checkins_usecase.dart';
import 'features/analytics/presentation/providers/analytics_provider.dart';

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

  /// Challenge Remote Datasource
  sl.registerLazySingleton<ChallengeRemoteDatasource>(
    () => ChallengeRemoteDatasourceImpl(),
  );

  /// Reward Remote Datasource
  sl.registerLazySingleton<RewardRemoteDatasource>(
    () => RewardRemoteDatasourceImpl(),
  );

  /// Analytics Remote Datasource
  sl.registerLazySingleton<AnalyticsRemoteDataSource>(
    () => AnalyticsRemoteDataSourceImpl(),
  );

  // ============ Repositories ============
  /// Register AuthRepository dengan implementasinya
  /// Menggunakan AuthRemoteDatasource yang sudah di-register sebelumnya
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      sl<AuthRemoteDatasource>(),
    ),
  );

  /// Challenge Repository
  sl.registerLazySingleton<ChallengeRepository>(
    () => ChallengeRepositoryImpl(
      sl<ChallengeRemoteDatasource>(),
    ),
  );

  /// Reward Repository
  sl.registerLazySingleton<RewardRepository>(
    () => RewardRepositoryImpl(
      sl<RewardRemoteDatasource>(),
    ),
  );

  /// Analytics Repository
  sl.registerLazySingleton<AnalyticsRepository>(
    () => AnalyticsRepositoryImpl(
      sl<AnalyticsRemoteDataSource>(),
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

  /// Challenge Use Cases
  sl.registerLazySingleton(
    () => GetAllChallengesUsecase(sl<ChallengeRepository>()),
  );
  sl.registerLazySingleton(
    () => GetActiveChallengeUsecase(sl<ChallengeRepository>()),
  );
  sl.registerLazySingleton(
    () => StartChallengeUsecase(sl<ChallengeRepository>()),
  );
  sl.registerLazySingleton(
    () => CheckInUsecase(sl<ChallengeRepository>()),
  );

  /// Reward Use Cases
  sl.registerLazySingleton(
    () => GetAllAchievementsUsecase(sl<RewardRepository>()),
  );
  sl.registerLazySingleton(
    () => GetUserAchievementsUsecase(sl<RewardRepository>()),
  );
  sl.registerLazySingleton(
    () => CheckAchievementsUsecase(sl<RewardRepository>()),
  );

  /// Analytics Use Cases
  sl.registerLazySingleton(
    () => GetUserStatsUsecase(sl<AnalyticsRepository>()),
  );
  sl.registerLazySingleton(
    () => GetWeeklyCheckInsUsecase(sl<AnalyticsRepository>()),
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

  /// Challenge Provider
  sl.registerFactory(
    () => ChallengeProvider(
      getAllChallengesUsecase: sl<GetAllChallengesUsecase>(),
      getActiveChallengeUsecase: sl<GetActiveChallengeUsecase>(),
      startChallengeUsecase: sl<StartChallengeUsecase>(),
      checkInUsecase: sl<CheckInUsecase>(),
    ),
  );

  /// Reward Provider
  sl.registerFactory(
    () => RewardProvider(
      getAllAchievementsUsecase: sl<GetAllAchievementsUsecase>(),
      getUserAchievementsUsecase: sl<GetUserAchievementsUsecase>(),
      checkAchievementsUsecase: sl<CheckAchievementsUsecase>(),
      authProvider: sl<AuthProvider>(),
    ),
  );

  /// Analytics Provider
  sl.registerFactory(
    () => AnalyticsProvider(
      getUserStatsUsecase: sl<GetUserStatsUsecase>(),
      getWeeklyCheckInsUsecase: sl<GetWeeklyCheckInsUsecase>(),
    ),
  );
}

