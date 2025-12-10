import 'package:flutter/foundation.dart';
import '../../domain/services/app_blocking_service.dart';

/// Provider untuk mengelola state blocking aplikasi
class AppBlockingProvider extends ChangeNotifier {
  bool _isBlockingEnabled = false;
  bool _isAccessibilityServiceEnabled = false;
  List<String> _blockedPackages = [];
  List<Map<String, String>> _installedApps = [];
  bool _isLoading = false;
  String? _error;

  bool get isBlockingEnabled => _isBlockingEnabled;
  bool get isAccessibilityServiceEnabled => _isAccessibilityServiceEnabled;
  List<String> get blockedPackages => List.unmodifiable(_blockedPackages);
  List<Map<String, String>> get installedApps => List.unmodifiable(_installedApps);
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load status accessibility service
  Future<void> checkAccessibilityService() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _isAccessibilityServiceEnabled = await AppBlockingService.isAccessibilityServiceEnabled();
    } catch (e) {
      _error = 'Gagal memeriksa status accessibility service: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Buka pengaturan accessibility
  Future<void> openAccessibilitySettings() async {
    await AppBlockingService.openAccessibilitySettings();
  }

  /// Load daftar aplikasi yang terinstall
  Future<void> loadInstalledApps() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _installedApps = await AppBlockingService.getInstalledApps();
    } catch (e) {
      _error = 'Gagal memuat daftar aplikasi: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Tambah aplikasi ke daftar block
  Future<bool> addBlockedApp(String packageName) async {
    if (_blockedPackages.contains(packageName)) {
      return true; // Sudah ada
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _blockedPackages.add(packageName);
      final success = await AppBlockingService.setBlockedApps(_blockedPackages);
      if (!success) {
        _blockedPackages.remove(packageName);
        _error = 'Gagal menambahkan aplikasi ke daftar block';
        return false;
      }
      notifyListeners();
      return true;
    } catch (e) {
      _blockedPackages.remove(packageName);
      _error = 'Error: $e';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Hapus aplikasi dari daftar block
  Future<bool> removeBlockedApp(String packageName) async {
    if (!_blockedPackages.contains(packageName)) {
      return true; // Tidak ada
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _blockedPackages.remove(packageName);
      final success = await AppBlockingService.setBlockedApps(_blockedPackages);
      if (!success) {
        _blockedPackages.add(packageName);
        _error = 'Gagal menghapus aplikasi dari daftar block';
        return false;
      }
      notifyListeners();
      return true;
    } catch (e) {
      _blockedPackages.add(packageName);
      _error = 'Error: $e';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Set daftar blocked packages
  Future<bool> setBlockedPackages(List<String> packages) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _blockedPackages = List.from(packages);
      final success = await AppBlockingService.setBlockedApps(_blockedPackages);
      if (!success) {
        _error = 'Gagal mengupdate daftar aplikasi yang diblokir';
        return false;
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error: $e';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Enable/disable blocking
  Future<bool> setBlockingEnabled(bool enabled) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // PENTING: Jika ingin enable blocking, pastikan Accessibility Service sudah aktif
      if (enabled) {
        // Cek ulang status accessibility service
        await checkAccessibilityService();
        
        if (!_isAccessibilityServiceEnabled) {
          _error = 'Accessibility Service belum diaktifkan. Silakan aktifkan di Settings → Accessibility terlebih dahulu.';
          _isLoading = false;
          notifyListeners();
          return false;
        }
      }
      
      final success = await AppBlockingService.setBlockingEnabled(enabled);
      if (success) {
        _isBlockingEnabled = enabled;
      } else {
        _error = 'Gagal mengubah status blocking';
      }
      notifyListeners();
      return success;
    } catch (e) {
      _error = 'Error: $e';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Initialize provider
  Future<void> initialize() async {
    await Future.wait([
      checkAccessibilityService(),
      loadInstalledApps(),
    ]);
  }

  /// Refresh status - dipanggil ketika aplikasi kembali ke foreground
  Future<void> refreshStatus() async {
    await checkAccessibilityService();
    // Jika blocking enabled tapi service tidak aktif, nonaktifkan blocking
    if (_isBlockingEnabled && !_isAccessibilityServiceEnabled) {
      _isBlockingEnabled = false;
      await AppBlockingService.setBlockingEnabled(false);
      notifyListeners();
    }
  }
}

