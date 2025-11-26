import 'package:flutter/material.dart';
import '../features/authentication/presentation/screens/onboarding_screen.dart';
import '../features/authentication/presentation/screens/login_screen.dart';
import '../features/authentication/presentation/screens/register_screen.dart';
import '../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../features/reward/presentation/screens/achievements_screen.dart';
import '../features/analytics/presentation/screens/analytics_screen.dart';
import '../features/journal/presentation/screens/journal_list_screen.dart';

/// App Routes Configuration
/// Mengikuti konsep Single Responsibility Principle
/// Semua konfigurasi routes aplikasi berada di satu tempat
class AppRoutes {
  /// Route name untuk onboarding screen
  static const String onboarding = '/onboarding';

  /// Route name untuk login screen
  static const String login = '/login';

  /// Route name untuk register screen
  static const String register = '/register';

  /// Route name untuk dashboard screen (placeholder)
  static const String dashboard = '/dashboard';
  /// Route name untuk achievements screen
  static const String achievements = '/achievements';
  /// Route name untuk analytics screen
  static const String analytics = '/analytics';
  /// Route name untuk journal/mood screen
  static const String journal = '/journal';

  /// Method untuk mendapatkan routes map
  /// Mengembalikan Map<String, WidgetBuilder> untuk MaterialApp routes
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      /// Onboarding screen
      onboarding: (context) => const OnboardingScreen(),

      /// Login screen
      login: (context) => const LoginScreen(),

      /// Register screen
      register: (context) => const RegisterScreen(),

      /// Dashboard screen
      dashboard: (context) => const DashboardScreen(),

      /// Achievements screen
      achievements: (context) => const AchievementsScreen(),

      /// Analytics screen
      analytics: (context) => const AnalyticsScreen(),

      /// Journal/Mood screen
      journal: (context) => const JournalListScreen(),
    };
  }

  /// Method untuk mendapatkan initial route
  /// Mengembalikan route yang akan ditampilkan pertama kali
  /// Bisa diganti sesuai kebutuhan (misalnya check jika user sudah login)
  static String getInitialRoute() {
    return onboarding;
  }
}

