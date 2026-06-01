import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants.dart';
import 'sol_stage.dart';

/// Immutable user profile for SolBuddy.
class SolUser {
  const SolUser({
    this.displayName = '',
    this.xp = 0,
    this.currentStreak = 0,
    this.lastLoginDate,
    this.lastActiveDate,
    this.lastTempPenaltyDate,
    this.lastQuizDate,
    this.visitedSpotIds = const {},
    this.quizzesPlayed = 0,
  });

  final String displayName;
  final int xp;
  final int currentStreak;
  final DateTime? lastLoginDate;
  final DateTime? lastActiveDate;
  final DateTime? lastTempPenaltyDate;
  final DateTime? lastQuizDate;
  final Set<String> visitedSpotIds;
  final int quizzesPlayed;

  /// Current avatar stage derived from stored XP (no temp penalty).
  SolStage get solStage => SolStage.fromValue(xp);

  /// Effective state value after applying the live temperature penalty.
  int effectiveStateValue(double currentTemp) {
    final value = xp - tempPenalty(currentTemp);
    return value < 0 ? 0 : value;
  }

  /// Avatar stage reflecting stored XP minus the current temp penalty.
  SolStage stageFor(double currentTemp) =>
      SolStage.fromValue(effectiveStateValue(currentTemp));

  SolUser copyWith({
    String? displayName,
    int? xp,
    int? currentStreak,
    DateTime? lastLoginDate,
    DateTime? lastActiveDate,
    DateTime? lastTempPenaltyDate,
    DateTime? lastQuizDate,
    Set<String>? visitedSpotIds,
    int? quizzesPlayed,
  }) {
    return SolUser(
      displayName: displayName ?? this.displayName,
      xp: xp ?? this.xp,
      currentStreak: currentStreak ?? this.currentStreak,
      lastLoginDate: lastLoginDate ?? this.lastLoginDate,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      lastTempPenaltyDate: lastTempPenaltyDate ?? this.lastTempPenaltyDate,
      lastQuizDate: lastQuizDate ?? this.lastQuizDate,
      visitedSpotIds: visitedSpotIds ?? this.visitedSpotIds,
      quizzesPlayed: quizzesPlayed ?? this.quizzesPlayed,
    );
  }

  /// Deserialize from a Firestore document map.
  factory SolUser.fromMap(Map<String, dynamic> map) {
    return SolUser(
      displayName: map['displayName'] as String? ?? '',
      xp: map['xp'] as int? ?? 0,
      currentStreak: map['currentStreak'] as int? ?? 0,
      lastLoginDate: _dateFromField(map['lastLoginDate']),
      lastActiveDate: _dateFromField(map['lastActiveDate']),
      lastTempPenaltyDate: _dateFromField(map['lastTempPenaltyDate']),
      lastQuizDate: _dateFromField(map['lastQuizDate']),
      visitedSpotIds:
          (map['visitedSpotIds'] as List<dynamic>?)?.cast<String>().toSet() ??
              const {},
      quizzesPlayed: map['quizzesPlayed'] as int? ?? 0,
    );
  }

  /// Serialize to a Firestore document map.
  Map<String, dynamic> toMap() {
    return {
      'displayName': displayName,
      'xp': xp,
      'currentStreak': currentStreak,
      'lastLoginDate': _dateToTimestamp(lastLoginDate),
      'lastActiveDate': _dateToTimestamp(lastActiveDate),
      'lastTempPenaltyDate': _dateToTimestamp(lastTempPenaltyDate),
      'lastQuizDate': _dateToTimestamp(lastQuizDate),
      'visitedSpotIds': visitedSpotIds.toList(),
      'quizzesPlayed': quizzesPlayed,
    };
  }

  static DateTime? _dateFromField(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  static Timestamp? _dateToTimestamp(DateTime? date) {
    if (date == null) return null;
    return Timestamp.fromDate(date);
  }
}
