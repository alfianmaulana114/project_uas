import 'package:flutter/foundation.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/sign_up_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/update_user_usecase.dart';
import '../../domain/usecases/update_credentials_usecase.dart';

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
  final UpdateUserUsecase updateUserUsecase;
  final UpdateCredentialsUsecase updateCredentialsUsecase;

  /// Current user yang sedang login
  /// Hanya disimpan di memory, tidak persist ke local storage
  AuthUser? _currentUser;

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
    required this.updateCredentialsUsecase,
  });

  /// Getter untuk current user
  AuthUser? get currentUser => _currentUser;

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

  Future<bool> updateUser(AuthUser user) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await updateUserUsecase(user);

    _isLoading = false;

    return result.fold(
      (failure) {
        _error = failure.message;
        notifyListeners();
        return false;
      },
      (updated) {
        _currentUser = updated;
        _error = null;
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> updateProfile({
    String? fullName,
    String? email,
    String? newPassword,
  }) async {
    if (_currentUser == null) {
      _error = 'Tidak ada user yang login';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    var localUser = _currentUser!;
    final needsProfileUpdate = (fullName != null && fullName != localUser.fullName) ||
        (email != null && email != localUser.email);

    if (needsProfileUpdate) {
      final updatedEntity = localUser.copyWith(
        fullName: fullName ?? localUser.fullName,
        email: email ?? localUser.email,
      );
      final res = await updateUserUsecase(updatedEntity);
      final ok = res.fold(
        (f) {
          _error = f.message;
          return false;
        },
        (u) {
          localUser = u;
          return true;
        },
      );
      if (!ok) {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    }

    if ((email != null && email != _currentUser!.email) ||
        (newPassword != null && newPassword.isNotEmpty)) {
      final res2 = await updateCredentialsUsecase(
        UpdateCredentialsParams(email: email, password: newPassword),
      );
      final ok2 = res2.fold(
        (f) {
          _error = f.message;
          return false;
        },
        (u) {
          localUser = u;
          return true;
        },
      );
      if (!ok2) {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    }

    _currentUser = localUser;
    _isLoading = false;
    _error = null;
    notifyListeners();
    return true;
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

