import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser;
import '../../../../core/config/supabase_config.dart';
import '../../domain/entities/auth_user.dart' as auth_entity;
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/sign_up_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/update_user_usecase.dart';

/// AuthProvider untuk mengelola state authentication
/// Menggunakan ChangeNotifier untuk state management
/// Mengikuti konsep Provider pattern dan Single Responsibility Principle
/// 
/// PENTING: State hanya disimpan di memory, TIDAK ADA PERSISTENCE
/// Data user tidak disimpan di local storage atau cache
/// Semua data langsung dari Supabase (online database)
/// Setelah app di-close, state akan hilang dan harus fetch ulang dari Supabase
class AuthProvider extends ChangeNotifier {
  /// Instance dari SignInUsecase
  final SignInUsecase signInUsecase;

  /// Instance dari SignUpUsecase
  final SignUpUsecase signUpUsecase;

  /// Instance dari SignOutUsecase
  final SignOutUsecase signOutUsecase;

  /// Instance dari GetCurrentUserUsecase
  final GetCurrentUserUsecase getCurrentUserUsecase;

  /// Instance dari UpdateUserUsecase
  final UpdateUserUsecase updateUserUsecase;

  /// Current user yang sedang login
  /// Hanya disimpan di memory, tidak persist ke local storage
  auth_entity.AuthUser? _currentUser;

  /// Error message jika terjadi error
  String? _error;

  /// Apakah sedang loading
  bool _isLoading = false;

  /// Constructor untuk AuthProvider
  /// Menggunakan dependency injection untuk use cases
  AuthProvider({
    required this.signInUsecase,
    required this.signUpUsecase,
    required this.signOutUsecase,
    required this.getCurrentUserUsecase,
    required this.updateUserUsecase,
  });

  /// Getter untuk current user
  auth_entity.AuthUser? get currentUser => _currentUser;

  /// Getter untuk error message
  String? get error => _error;

  /// Getter untuk loading state
  bool get isLoading => _isLoading;

  /// Getter untuk check apakah user sudah login
  bool get isAuthenticated => _currentUser != null;

  /// Method untuk sign in user
  /// [email] adalah email user
  /// [password] adalah password user
  /// Mengembalikan true jika berhasil, false jika gagal
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    /// Set loading state menjadi true
    _isLoading = true;
    _error = null;
    notifyListeners();

    /// Memanggil sign in use case
    final result = await signInUsecase(
      SignInParams(email: email, password: password),
    );

    /// Set loading state menjadi false
    _isLoading = false;

    /// Handle result
    return result.fold(
      /// Jika gagal (Left = Failure)
      (failure) {
        _error = failure.message;
        notifyListeners();
        return false;
      },
      /// Jika berhasil (Right = AuthUser)
      (user) {
        _currentUser = user;
        _error = null;
        notifyListeners();
        return true;
      },
    );
  }

  /// Method untuk sign up user
  /// [email] adalah email user
  /// [password] adalah password user
  /// [fullName] adalah nama lengkap user (opsional)
  /// [username] adalah username user (opsional)
  /// Mengembalikan true jika berhasil, false jika gagal
  Future<bool> signUp({
    required String email,
    required String password,
    String? fullName,
    String? username,
  }) async {
    /// Set loading state menjadi true
    _isLoading = true;
    _error = null;
    notifyListeners();

    /// Memanggil sign up use case
    final result = await signUpUsecase(
      SignUpParams(
        email: email,
        password: password,
        fullName: fullName,
        username: username,
      ),
    );

    /// Set loading state menjadi false
    _isLoading = false;

    /// Handle result
    return result.fold(
      /// Jika gagal (Left = Failure)
      (failure) {
        _error = failure.message;
        notifyListeners();
        return false;
      },
      /// Jika berhasil (Right = AuthUser)
      (user) {
        _currentUser = user;
        _error = null;
        notifyListeners();
        return true;
      },
    );
  }

  /// Method untuk sign out user
  /// Mengembalikan true jika berhasil, false jika gagal
  Future<bool> signOut() async {
    /// Set loading state menjadi true
    _isLoading = true;
    _error = null;
    notifyListeners();

    /// Memanggil sign out use case
    final result = await signOutUsecase();

    /// Set loading state menjadi false
    _isLoading = false;

    /// Handle result
    return result.fold(
      /// Jika gagal (Left = Failure)
      (failure) {
        _error = failure.message;
        notifyListeners();
        return false;
      },
      /// Jika berhasil (Right = void)
      (_) {
        _currentUser = null;
        _error = null;
        notifyListeners();
        return true;
      },
    );
  }

  /// Method untuk mendapatkan current user
  /// Biasanya dipanggil saat app pertama kali dibuka
  Future<void> getCurrentUser() async {
    /// Set loading state menjadi true
    _isLoading = true;
    _error = null;
    notifyListeners();

    /// Memanggil get current user use case
    final result = await getCurrentUserUsecase();

    /// Set loading state menjadi false
    _isLoading = false;

    /// Handle result
    result.fold(
      /// Jika gagal (Left = Failure)
      (failure) {
        _error = failure.message;
        _currentUser = null;
      },
      /// Jika berhasil (Right = AuthUser?)
      (user) {
        _currentUser = user;
        _error = null;
      },
    );

    notifyListeners();
  }

  /// Method untuk clear error
  /// Digunakan untuk menghapus error message dari UI
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Method untuk update user
  /// [user] adalah user yang akan diupdate
  /// Mengembalikan true jika berhasil, false jika gagal
  Future<bool> updateUser(auth_entity.AuthUser user) async {
    /// Set loading state menjadi true
    _isLoading = true;
    _error = null;
    notifyListeners();

    /// Memanggil update user use case
    final result = await updateUserUsecase(user);

    /// Set loading state menjadi false
    _isLoading = false;

    /// Handle result
    return result.fold(
      /// Jika gagal (Left = Failure)
      (failure) {
        _error = failure.message;
        notifyListeners();
        return false;
      },
      /// Jika berhasil (Right = AuthUser)
      (updatedUser) {
        _currentUser = updatedUser;
        _error = null;
        notifyListeners();
        return true;
      },
    );
  }

  /// Method untuk update email user
  /// [newEmail] adalah email baru
  /// Mengembalikan true jika berhasil, false jika gagal
  Future<bool> updateEmail(String newEmail) async {
    /// Set loading state menjadi true
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      /// Update email di Supabase Auth
      await SupabaseConfig.client.auth.updateUser(
        UserAttributes(email: newEmail),
      );

      /// Set loading state menjadi false
      _isLoading = false;
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      /// Set loading state menjadi false
      _isLoading = false;
      _error = 'Gagal memperbarui email: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Method untuk change password user
  /// [currentPassword] adalah password saat ini
  /// [newPassword] adalah password baru
  /// Mengembalikan true jika berhasil, false jika gagal
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    /// Set loading state menjadi true
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      /// Update password di Supabase Auth
      /// Supabase memerlukan re-authentication untuk change password
      final currentUser = SupabaseConfig.client.auth.currentUser;
      if (currentUser?.email == null) {
        _isLoading = false;
        _error = 'User tidak ditemukan';
        notifyListeners();
        return false;
      }

      /// Re-authenticate dengan password saat ini
      await SupabaseConfig.client.auth.signInWithPassword(
        email: currentUser!.email!,
        password: currentPassword,
      );

      /// Update password
      await SupabaseConfig.client.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      /// Set loading state menjadi false
      _isLoading = false;
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      /// Set loading state menjadi false
      _isLoading = false;
      final errorMsg = e.toString().toLowerCase();
      if (errorMsg.contains('invalid') || errorMsg.contains('password')) {
        _error = 'Password saat ini salah';
      } else {
        _error = 'Gagal mengubah password: ${e.toString()}';
      }
      notifyListeners();
      return false;
    }
  }

  /// Apply stats update after actions like check-in
  void applyStatsUpdate({
    int? currentStreak,
    int? longestStreak,
    int? totalPoints,
  }) {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      totalPoints: totalPoints,
    );
    notifyListeners();
  }
}

