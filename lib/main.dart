import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/config/supabase_config.dart';
import 'injection_container.dart' as di;
import 'app/routes.dart';
import 'app/theme.dart';
import 'features/authentication/presentation/providers/auth_provider.dart';

/// Main entry point aplikasi
/// Mengikuti konsep Single Responsibility Principle
void main() async {
  /// Memastikan Flutter binding sudah diinisialisasi
  WidgetsFlutterBinding.ensureInitialized();

  try {
    /// Inisialisasi Supabase dengan URL dan API key
    await SupabaseConfig.init(
      supabaseUrl: 'https://ksizwnhqotjwcaapxoeq.supabase.co',
      supabaseAnonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtzaXp3bmhxb3Rqd2NhYXB4b2VxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE4NzMyODQsImV4cCI6MjA3NzQ0OTI4NH0.k9aLRot8vN8oA62VAkYpA_lgss2rO0O6LL7Q9CnTdMY',
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
