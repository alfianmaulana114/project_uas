import 'package:flutter/services.dart';

/// Service untuk mengelola blocking aplikasi
/// Berkomunikasi dengan native Android melalui Method Channel
class AppBlockingService {
  static const MethodChannel _channel = MethodChannel('com.example.project_uas/app_blocking');

  /// Set daftar aplikasi yang diblokir
  /// [packageNames] adalah list package name aplikasi yang akan diblokir
  static Future<bool> setBlockedApps(List<String> packageNames) async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'setBlockedApps',
        {'packages': packageNames},
      );
      return result ?? false;
    } on PlatformException catch (e) {
      print('Error setting blocked apps: ${e.message}');
      return false;
    }
  }

  /// Enable/disable blocking
  static Future<bool> setBlockingEnabled(bool enabled) async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'setBlockingEnabled',
        {'enabled': enabled},
      );
      return result ?? false;
    } on PlatformException catch (e) {
      print('Error setting blocking enabled: ${e.message}');
      return false;
    }
  }

  /// Cek apakah Accessibility Service sudah diaktifkan
  static Future<bool> isAccessibilityServiceEnabled() async {
    try {
      final result = await _channel.invokeMethod<bool>('isAccessibilityServiceEnabled');
      return result ?? false;
    } on PlatformException catch (e) {
      print('Error checking accessibility service: ${e.message}');
      return false;
    }
  }

  /// Buka pengaturan Accessibility Service
  static Future<bool> openAccessibilitySettings() async {
    try {
      final result = await _channel.invokeMethod<bool>('openAccessibilitySettings');
      return result ?? false;
    } on PlatformException catch (e) {
      print('Error opening accessibility settings: ${e.message}');
      return false;
    }
  }

  /// Dapatkan daftar aplikasi yang terinstall
  static Future<List<Map<String, String>>> getInstalledApps() async {
    try {
      final result = await _channel.invokeMethod<List<dynamic>>('getInstalledApps');
      if (result == null) return [];
      
      return result.map((app) => Map<String, String>.from(app)).toList();
    } on PlatformException catch (e) {
      print('Error getting installed apps: ${e.message}');
      return [];
    }
  }
}

