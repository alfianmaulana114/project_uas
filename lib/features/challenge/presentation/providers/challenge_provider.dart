import 'package:flutter/foundation.dart';
import '../../domain/entities/challenge.dart';
import '../../domain/entities/user_challenge.dart';
import '../../domain/usecases/get_all_challenges_usecase.dart';
import '../../domain/usecases/get_active_challenge_usecase.dart';
import '../../domain/usecases/start_challenge_usecase.dart';
import '../../domain/usecases/check_in_usecase.dart';
import '../../domain/usecases/has_checked_in_today_usecase.dart';
import '../../domain/entities/check_in_result.dart';

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
  final CheckInUsecase checkInUsecase;
  final HasCheckedInTodayUsecase hasCheckedInTodayUsecase;

  /// Constructor untuk ChallengeProvider
  /// Menggunakan dependency injection untuk use cases
  ChallengeProvider({
    required this.getAllChallengesUsecase,
    required this.getActiveChallengeUsecase,
    required this.startChallengeUsecase,
    required this.checkInUsecase,
    required this.hasCheckedInTodayUsecase,
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

  // Track last check-in date per active challenge to disable button until tomorrow
  final Map<String, DateTime> _lastCheckInDate = {};
  DateTime _lastMidnight = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

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

  /// Check if user has checked in today
  /// First checks memory (_lastCheckInDate), then checks database if not found
  /// This ensures persistence across app restarts and logins
  Future<bool> hasCheckedInToday(String userChallengeId) async {
    // First check memory cache
    final d = _lastCheckInDate[userChallengeId];
    if (d != null) {
      final now = DateTime.now();
      if (d.year == now.year && d.month == now.month && d.day == now.day) {
        return true;
      }
    }
    
    // If not in memory, check database
    try {
      final result = await hasCheckedInTodayUsecase(userChallengeId);
      return result.fold(
        (failure) => false, // If error, assume not checked in
        (hasChecked) {
          // Update memory cache if checked in
          if (hasChecked) {
            _lastCheckInDate[userChallengeId] = DateTime.now();
          }
          return hasChecked;
        },
      );
    } catch (e) {
      // If error, assume not checked in
      return false;
    }
  }
  
  /// Synchronous version for immediate UI updates (uses memory cache only)
  /// Use this for initial render, then async version will update from database
  bool hasCheckedInTodaySync(String userChallengeId) {
    final d = _lastCheckInDate[userChallengeId];
    if (d == null) return false;
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  /// Calculate currentDay based on real-time date difference
  /// currentDay should only increase when a new day arrives (at midnight), not when check-in
  /// Returns: days between startDate and today (inclusive) = (today - startDate) + 1
  int _calculateCurrentDay(DateTime startDate, DateTime? endDate) {
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final base = today.difference(start).inDays + 1;
    if (endDate != null) {
      final total = endDate.difference(startDate).inDays + 1;
      return base.clamp(1, total);
    } else {
      return base.clamp(1, 3650);
    }
  }

  void _rolloverIfNewDay() {
    final nowMidnight = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    if (nowMidnight.isAfter(_lastMidnight)) {
      _lastMidnight = nowMidnight;
      _lastCheckInDate.clear();
    }
  }

  /// Method untuk load challenges dan active challenges
  /// [category] adalah kategori untuk filter (opsional, null berarti semua kategori)
  Future<void> load({String? category}) async {
    _rolloverIfNewDay();
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
    await act.fold(
      /// Jika gagal (Left = Failure)
      (failure) async {
        _error = failure.message;
        _active.clear();
      },
      /// Jika berhasil (Right = List<UserChallenge>)
      (active) async {
        _active.clear();
        // Recalculate currentDay based on real-time date difference
        // This ensures currentDay is always correct, regardless of database value
        for (final challenge in active) {
          final computedCurrentDay = _calculateCurrentDay(challenge.startDate, challenge.endDate);
          
          // Create updated challenge with correct currentDay
          final updatedChallenge = UserChallenge(
            id: challenge.id,
            userId: challenge.userId,
            challengeId: challenge.challengeId,
            category: challenge.category,
            startDate: challenge.startDate,
            endDate: challenge.endDate,
            status: challenge.status,
            currentDay: computedCurrentDay,
            successDays: challenge.successDays,
            pointsEarned: challenge.pointsEarned,
            bookName: challenge.bookName,
            eventName: challenge.eventName,
            completedAt: challenge.completedAt,
            createdAt: challenge.createdAt,
          );
          _active.add(updatedChallenge);
          
          // Load check-in status from database for each challenge
          // This ensures persistence across app restarts and logins
          final hasChecked = await hasCheckedInTodayUsecase(challenge.id);
          hasChecked.fold(
            (failure) {
              // If error, don't update cache (keep as is)
            },
            (checked) {
              if (checked) {
                _lastCheckInDate[challenge.id] = DateTime.now();
              }
            },
          );
        }
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

  /// Daily check-in: mark success/failed and update state
  Future<CheckInResult?> checkIn({
    required String userChallengeId,
    required bool isSuccess,
    DateTime? checkInDate,
    int durationMinutes = 0,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();

    // Validation: must exist in active list
    final idx = _active.indexWhere((uc) => uc.id == userChallengeId);
    if (idx < 0) {
      _error = 'Tidak ada challenge aktif';
      _loading = false;
      notifyListeners();
      return null;
    }

    final res = await checkInUsecase(
      userChallengeId: userChallengeId,
      isSuccess: isSuccess,
      checkInDate: checkInDate,
      durationMinutes: durationMinutes,
    );

    final result = res.fold<CheckInResult?>(
      (l) {
        _error = l.message;
        return null;
      },
      (r) => r,
    );

    // Apply state updates
    if (result != null) {
      // Mark as checked-in today (even if server says already checked-in)
      // PASTIKAN di-set SEBELUM update challenge untuk memastikan hasCheckedInToday() return true
      _lastCheckInDate[userChallengeId] = DateTime.now();

      // Replace updated challenge in active list or remove if completed
      final updated = _active[idx];
      // Calculate currentDay based on real-time date difference, not from database
      final computedCurrentDay = _calculateCurrentDay(updated.startDate, updated.endDate);
      final updatedChallenge = UserChallenge(
        id: updated.id,
        userId: updated.userId,
        challengeId: updated.challengeId,
        category: updated.category,
        startDate: updated.startDate,
        endDate: updated.endDate,
        status: result.status,
        currentDay: computedCurrentDay,
        successDays: result.successDays,
        pointsEarned: updated.pointsEarned + result.pointsAwarded,
        bookName: updated.bookName,
        eventName: updated.eventName,
        completedAt: result.challengeCompleted ? DateTime.now() : updated.completedAt,
        createdAt: updated.createdAt,
      );

      if (result.status == 'completed' || result.challengeCompleted) {
        _active.removeAt(idx);
      } else {
        _active[idx] = updatedChallenge;
      }
    } else {
      // Jika result null (error), tetap update _lastCheckInDate jika sudah pernah check-in hari ini
      // Ini untuk memastikan UI tetap menampilkan status yang benar
      // Tapi hanya jika error bukan karena "sudah check-in hari ini"
      if (_error != null && _error!.contains('sudah check-in')) {
        _lastCheckInDate[userChallengeId] = DateTime.now();
      }
    }

    _loading = false;
    notifyListeners(); // PASTIKAN notifyListeners() dipanggil SETELAH semua state update
    return result;
  }
}


