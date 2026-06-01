import 'package:flutter/foundation.dart';

import '../core/constants.dart';
import '../models/daily_check_result.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';

/// User state backed by Firestore.
///
/// The public API (addXp, submitQuizResult, onCoolSpotCheckIn) is unchanged
/// from the in-memory version so existing UI code keeps working.
class UserProvider extends ChangeNotifier {
  UserProvider({required FirestoreService firestoreService})
      : _firestoreService = firestoreService;

  final FirestoreService _firestoreService;

  SolUser _user = const SolUser();
  String? _uid;
  bool _loading = false;

  /// The current user snapshot.
  SolUser get user => _user;

  /// Stored XP (before any display penalty).
  int get xp => _user.xp;

  /// Whether the initial Firestore load is in progress.
  bool get loading => _loading;

  /// Whether the quiz was already played today.
  bool get quizPlayedToday => _isSameDay(_user.lastQuizDate, DateTime.now());

  // ── Firestore lifecycle ──────────────────────────────────────────

  /// Loads (or creates) the user document from Firestore.
  Future<void> loadForUser(String uid) async {
    _uid = uid;
    _loading = true;
    notifyListeners();

    final fetched = await _firestoreService.fetchUser(uid);
    _user = fetched ?? const SolUser();
    _loading = false;
    notifyListeners();
  }

  /// Applies all once-per-day game rules and returns a summary of changes.
  ///
  /// Idempotent — safe to call multiple times on the same calendar day;
  /// each section guards itself via a stored date field.
  ///
  /// Temperature penalty is based on the current temperature at app start,
  /// not the day's maximum (fetching historical data would require extra
  /// API calls).
  Future<DailyCheckResult> runDailyCheck(double currentTemp) async {
    final now = DateTime.now();
    var u = _user;

    if (_isSameDay(u.lastLoginDate, now) &&
        _isSameDay(u.lastTempPenaltyDate, now)) {
      return const DailyCheckResult(alreadyRanToday: true);
    }

    var dailyLoginXp = 0;
    var streakBonus = 0;
    var inactivityPen = 0;
    var tempPen = 0;
    var streak = u.currentStreak;

    // ── a) Daily login / streak ──────────────────────────────────
    if (!_isSameDay(u.lastLoginDate, now)) {
      final yesterday = now.subtract(const Duration(days: 1));
      if (_isSameDay(u.lastLoginDate, yesterday)) {
        streak = u.currentStreak + 1;
        dailyLoginXp = XpReward.dailyLogin;
        if (streak % 7 == 0) streakBonus = XpReward.sevenDayStreak;
        u = u.copyWith(
          xp: u.xp + dailyLoginXp + streakBonus,
          currentStreak: streak,
          lastLoginDate: now,
        );
      } else {
        streak = 1;
        dailyLoginXp = XpReward.dailyLogin;
        u = u.copyWith(
          xp: u.xp + dailyLoginXp,
          currentStreak: 1,
          lastLoginDate: now,
        );
      }
    }

    // ── b) Inactivity penalty ────────────────────────────────────
    if (u.lastActiveDate != null) {
      final daysSinceActive = now.difference(u.lastActiveDate!).inDays;
      if (daysSinceActive > 3) {
        inactivityPen = XpPenalty.inactivity3Days;
        final penalised = u.xp + inactivityPen;
        u = u.copyWith(xp: penalised < 0 ? 0 : penalised);
      }
    }
    u = u.copyWith(lastActiveDate: now);

    // ── c) Daily temperature penalty ─────────────────────────────
    if (!_isSameDay(u.lastTempPenaltyDate, now)) {
      if (currentTemp > TemperatureThreshold.extremeThreshold) {
        tempPen = XpPenalty.tempAbove38;
      } else if (currentTemp > TemperatureThreshold.hotThreshold) {
        tempPen = XpPenalty.tempAbove34;
      }
      if (tempPen != 0) {
        final penalised = u.xp + tempPen;
        u = u.copyWith(xp: penalised < 0 ? 0 : penalised);
      }
      u = u.copyWith(lastTempPenaltyDate: now);
    }

    _user = u;
    notifyListeners();
    await _save();

    return DailyCheckResult(
      dailyLoginXp: dailyLoginXp,
      streakBonus: streakBonus,
      currentStreak: streak,
      inactivityPenalty: inactivityPen,
      tempPenalty: tempPen,
    );
  }

  // ── Public mutators (API unchanged) ──────────────────────────────

  /// Adds [amount] to the stored XP (clamped to >= 0).
  void addXp(int amount) {
    final newXp = _user.xp + amount;
    _user = _user.copyWith(xp: newXp < 0 ? 0 : newXp);
    notifyListeners();
    _save();
  }

  /// Scores a completed quiz session.
  ///
  /// Awards [XpReward.quizCorrect] per correct answer and an additional
  /// [XpReward.quizPerfect] bonus when all answers are correct.
  void submitQuizResult(int correctCount, int totalCount) {
    var newXp = _user.xp;
    for (var i = 0; i < correctCount; i++) {
      newXp += XpReward.quizCorrect;
    }
    if (correctCount == totalCount) {
      newXp += XpReward.quizPerfect;
    }
    _user = _user.copyWith(
      xp: newXp,
      quizzesPlayed: _user.quizzesPlayed + 1,
      lastQuizDate: DateTime.now(),
    );
    notifyListeners();
    _save();
  }

  /// Checks in at [spotId]. Returns `true` if this is a new visit.
  bool onCoolSpotCheckIn(String spotId) {
    if (_user.visitedSpotIds.contains(spotId)) return false;
    final newXp = _user.xp + XpReward.coolSpotCheckIn;
    _user = _user.copyWith(
      xp: newXp,
      visitedSpotIds: {..._user.visitedSpotIds, spotId},
      lastActiveDate: DateTime.now(),
    );
    notifyListeners();
    _save();
    return true;
  }

  // ── Helpers ──────────────────────────────────────────────────────

  Future<void> _save() async {
    final uid = _uid;
    if (uid == null) return;
    await _firestoreService.saveUser(uid, _user);
  }

  static bool _isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
