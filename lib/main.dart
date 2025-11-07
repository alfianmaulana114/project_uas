import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/config/supabase_config.dart';
import 'injection_container.dart' as di;
import 'app/routes.dart';
import 'app/theme.dart';
import 'features/authentication/presentation/providers/auth_provider.dart';
import 'features/challenge/presentation/providers/challenge_provider.dart';
import 'features/reward/presentation/providers/reward_provider.dart';
import 'features/analytics/presentation/providers/analytics_provider.dart';

/// Main entry point aplikasi
/// Mengikuti konsep Single Responsibility Principle
void main() async {
  /// Memastikan Flutter binding sudah diinisialisasi
  WidgetsFlutterBinding.ensureInitialized();

  try {
    /// Inisialisasi Supabase dengan URL dan API key
    await SupabaseConfig.init(
      supabaseUrl: 'https://zetqkryzixfxkjubejbw.supabase.co',
      supabaseAnonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpldHFrcnl6aXhmeGtqdWJlamJ3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjIwMDU4NTksImV4cCI6MjA3NzU4MTg1OX0.8FlCSWLBc7_bgpvYA7dIs5jRwtBVC71oNnFvyLdWYsc',
    );
  } catch (e) {
    /// Log error jika Supabase gagal diinisialisasi
    print('Error initializing Supabase: $e');
  }

  /// Inisialisasi dependency injection
  await di.init();

  /// Run aplikasi
  runApp(const MyApp());
}

/// Root widget aplikasi
/// Menggunakan Provider untuk state management
/// Menggunakan MaterialApp untuk routing
class MyApp extends StatelessWidget {
  /// Constructor untuk MyApp
  const MyApp({super.key});

  /// Build method untuk membuat widget tree
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      /// Register semua providers yang dibutuhkan
      providers: [
        /// AuthProvider untuk mengelola authentication state
        ChangeNotifierProvider(
          create: (_) => di.sl<AuthProvider>(),
        ),
        /// ChallengeProvider untuk fitur Challenge
        ChangeNotifierProvider(
          create: (_) => di.sl<ChallengeProvider>(),
        ),
        /// RewardProvider untuk fitur Poin & Achievement
        ChangeNotifierProvider(
          create: (context) => RewardProvider(
            getAllAchievementsUsecase: di.sl(),
            getUserAchievementsUsecase: di.sl(),
            checkAchievementsUsecase: di.sl(),
            authProvider: context.read<AuthProvider>(),
          ),
        ),
        /// AnalyticsProvider untuk fitur Analytics
        ChangeNotifierProvider(
          create: (_) => di.sl<AnalyticsProvider>(),
        ),
      ],
      child: MaterialApp(
        /// Title aplikasi
        title: 'SosialBreak',

        /// Theme aplikasi (light theme)
        theme: AppTheme.lightTheme,

        /// Dark theme (opsional)
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,

        /// Initial route (halaman pertama yang ditampilkan)
        initialRoute: AppRoutes.getInitialRoute(),

        /// Routes configuration
        routes: AppRoutes.getRoutes(),

        /// Debug banner (akan hilang saat release)
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
