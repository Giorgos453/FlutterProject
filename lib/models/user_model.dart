import 'sol_stage.dart';

/// Immutable user profile for SolBuddy.
class SolUser {
  const SolUser({
    this.xp = 0,
    this.currentStreak = 0,
    this.lastLoginDate,
    this.visitedSpotIds = const {},
    this.quizzesPlayed = 0,
  });

  final int xp;
  final int currentStreak;
  final DateTime? lastLoginDate;
  final Set<String> visitedSpotIds;
  final int quizzesPlayed;

  /// Current avatar stage derived from XP.
  SolStage get solStage => SolStage.fromValue(xp);

  SolUser copyWith({
    int? xp,
    int? currentStreak,
    DateTime? lastLoginDate,
    Set<String>? visitedSpotIds,
    int? quizzesPlayed,
  }) {
    return SolUser(
      xp: xp ?? this.xp,
      currentStreak: currentStreak ?? this.currentStreak,
      lastLoginDate: lastLoginDate ?? this.lastLoginDate,
      visitedSpotIds: visitedSpotIds ?? this.visitedSpotIds,
      quizzesPlayed: quizzesPlayed ?? this.quizzesPlayed,
    );
  }

  /// Deserialize from a Firestore-style map.
  factory SolUser.fromMap(Map<String, dynamic> map) {
    return SolUser(
      xp: map['xp'] as int? ?? 0,
      currentStreak: map['currentStreak'] as int? ?? 0,
      lastLoginDate: map['lastLoginDate'] != null
          ? DateTime.parse(map['lastLoginDate'] as String)
          : null,
      visitedSpotIds:
          (map['visitedSpotIds'] as List<dynamic>?)?.cast<String>().toSet() ??
              const {},
      quizzesPlayed: map['quizzesPlayed'] as int? ?? 0,
    );
  }

  /// Serialize to a Firestore-style map.
  Map<String, dynamic> toMap() {
    return {
      'xp': xp,
      'currentStreak': currentStreak,
      'lastLoginDate': lastLoginDate?.toIso8601String(),
      'visitedSpotIds': visitedSpotIds.toList(),
      'quizzesPlayed': quizzesPlayed,
    };
  }
}
