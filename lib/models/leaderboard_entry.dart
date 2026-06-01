/// Lightweight view-model for a single leaderboard row.
class LeaderboardEntry {
  const LeaderboardEntry({
    required this.uid,
    required this.displayName,
    required this.xp,
  });

  final String uid;
  final String displayName;
  final int xp;
}
