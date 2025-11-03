/// API Constants
/// Mengikuti konsep Single Responsibility Principle
/// Menyimpan semua konstanta API di satu tempat
/// 
/// PENTING: JANGAN COMMIT API KEYS KE GITHUB!
/// Untuk production, gunakan environment variables atau .env file
class ApiConstants {
  /// Base URL Supabase
  /// Akan diambil dari environment variable atau hardcode untuk development
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'YOUR_SUPABASE_URL_HERE',
  );

  /// Supabase Anonymous Key
  /// Akan diambil dari environment variable atau hardcode untuk development
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'YOUR_SUPABASE_ANON_KEY_HERE',
  );
}

