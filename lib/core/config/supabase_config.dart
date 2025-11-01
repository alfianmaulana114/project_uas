import 'package:supabase_flutter/supabase_flutter.dart';

/// Class untuk menginisialisasi dan mengelola konfigurasi Supabase
/// Mengikuti konsep Single Responsibility Principle (SOLID)
class SupabaseConfig {
  /// Instance SupabaseClient untuk digunakan di seluruh aplikasi
  static SupabaseClient? _instance;

  /// Getter untuk mendapatkan instance SupabaseClient
  /// Menggunakan lazy initialization pattern
  static SupabaseClient get client {
    if (_instance == null) {
      throw Exception('Supabase belum diinisialisasi. Panggil init() terlebih dahulu.');
    }
    return _instance!;
  }

  /// Method untuk menginisialisasi Supabase
  /// [supabaseUrl] adalah URL dari project Supabase
  /// [supabaseAnonKey] adalah anonymous key dari project Supabase
  static Future<void> init({
    required String supabaseUrl,
    required String supabaseAnonKey,
  }) async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
    _instance = Supabase.instance.client;
  }
}

