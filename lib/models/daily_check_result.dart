/// Summary of XP changes applied by a single daily check run.
class DailyCheckResult {
  const DailyCheckResult({
    this.dailyLoginXp = 0,
    this.streakBonus = 0,
    this.currentStreak = 0,
    this.inactivityPenalty = 0,
    this.tempPenalty = 0,
    this.alreadyRanToday = false,
  });

  final int dailyLoginXp;
  final int streakBonus;
  final int currentStreak;
  final int inactivityPenalty;
  final int tempPenalty;
  final bool alreadyRanToday;

  /// Total XP delta from all daily check operations.
  int get totalDelta => dailyLoginXp + streakBonus + inactivityPenalty + tempPenalty;

  /// Whether any changes were actually applied.
  bool get hasChanges => !alreadyRanToday && totalDelta != 0;
}
