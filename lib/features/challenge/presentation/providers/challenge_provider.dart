import 'package:flutter/foundation.dart';
import '../../domain/entities/challenge.dart';
import '../../domain/entities/user_challenge.dart';
import '../../domain/usecases/get_all_challenges_usecase.dart';
import '../../domain/usecases/get_active_challenge_usecase.dart';
import '../../domain/usecases/start_challenge_usecase.dart';

/// ChallengeProvider untuk mengelola state challenge
/// Menggunakan ChangeNotifier untuk state management
/// Mengikuti konsep Provider pattern dan Single Responsibility Principle
/// 
/// PENTING: State hanya disimpan di memory, TIDAK ADA PERSISTENCE
/// Data challenge tidak disimpan di local storage atau cache
/// Semua data langsung dari Supabase (online database)
/// Setelah app di-close, state akan hilang dan harus fetch ulang dari Supabase
class ChallengeProvider extends ChangeNotifier {
  /// Instance dari GetAllChallengesUsecase
  final GetAllChallengesUsecase getAllChallengesUsecase;

  /// Instance dari GetActiveChallengeUsecase
  final GetActiveChallengeUsecase getActiveChallengeUsecase;

  /// Instance dari StartChallengeUsecase
  final StartChallengeUsecase startChallengeUsecase;

  /// Constructor untuk ChallengeProvider
  /// Menggunakan dependency injection untuk use cases
  ChallengeProvider({
    required this.getAllChallengesUsecase,
    required this.getActiveChallengeUsecase,
    required this.startChallengeUsecase,
  });

  /// List challenges yang tersedia
  /// Hanya disimpan di memory, tidak persist ke local storage
  final List<Challenge> _challenges = [];

  /// List active challenges user
  /// Hanya disimpan di memory, tidak persist ke local storage
  final List<UserChallenge> _active = [];

  /// Error message jika terjadi error
  String? _error;

  /// Apakah sedang loading
  bool _loading = false;

  /// Kategori yang dipilih untuk filter (null = semua kategori)
  String? _selectedCategory;

  /// Getter untuk challenges
  List<Challenge> get challenges => List.unmodifiable(_challenges);

  /// Getter untuk active challenges
  List<UserChallenge> get activeChallenges => List.unmodifiable(_active);

  /// Getter untuk error message
  String? get error => _error;

  /// Getter untuk loading state
  bool get isLoading => _loading;

  /// Getter untuk selected category
  String? get selectedCategory => _selectedCategory;

  /// Method untuk load challenges dan active challenges
  /// [category] adalah kategori untuk filter (opsional, null berarti semua kategori)
  Future<void> load({String? category}) async {
    /// Set loading state menjadi true
    _loading = true;
    _error = null;
    _selectedCategory = category;
    notifyListeners();

    /// Memanggil get all challenges use case
    final res = await getAllChallengesUsecase(
      GetAllChallengesParams(category: category),
    );
    res.fold(
      /// Jika gagal (Left = Failure)
      (failure) {
        _error = failure.message;
        _challenges.clear();
      },
      /// Jika berhasil (Right = List<Challenge>)
      (challenges) {
        _challenges
          ..clear()
          ..addAll(challenges);
      },
    );

    /// Memanggil get active challenges use case
    final act = await getActiveChallengeUsecase(
      GetActiveChallengeParams(category: category),
    );
    act.fold(
      /// Jika gagal (Left = Failure)
      (failure) {
        _error = failure.message;
        _active.clear();
      },
      /// Jika berhasil (Right = List<UserChallenge>)
      (active) {
        _active
          ..clear()
          ..addAll(active);
      },
    );

    /// Set loading state menjadi false
    _loading = false;
    notifyListeners();
  }

  /// Method untuk memulai challenge baru
  /// [challengeId] adalah ID challenge yang akan dimulai
  /// [bookName] adalah nama buku untuk challenge membaca_buku (opsional)
  /// [eventName] adalah nama event untuk challenge bersosialisasi (opsional)
  /// Mengembalikan true jika berhasil, false jika gagal
  Future<bool> start({
    required String challengeId,
    String? bookName,
    String? eventName,
  }) async {
    /// Set loading state menjadi true
    _loading = true;
    _error = null;
    notifyListeners();

    /// Memanggil start challenge use case
    final res = await startChallengeUsecase(
      StartChallengeParams(
        challengeId: challengeId,
        bookName: bookName,
        eventName: eventName,
      ),
    );

    /// Handle result
    final ok = res.fold(
      /// Jika gagal (Left = Failure)
      (failure) {
        _error = failure.message;
        return false;
      },
      /// Jika berhasil (Right = UserChallenge)
      (userChallenge) {
        _active.add(userChallenge);
        return true;
      },
    );

    /// Set loading state menjadi false
    _loading = false;
    notifyListeners();
    return ok;
  }

  /// Method untuk clear error
  /// Digunakan untuk menghapus error message dari UI
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Method untuk refresh data
  /// Memanggil load dengan category yang sudah dipilih
  Future<void> refresh() async {
    await load(category: _selectedCategory);
  }
}


