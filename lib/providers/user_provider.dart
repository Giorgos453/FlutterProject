import 'package:flutter/foundation.dart';

import '../core/constants.dart';
import '../models/user_model.dart';

/// In-memory user state — no persistence yet.
class UserProvider extends ChangeNotifier {
  SolUser _user = const SolUser();

  /// The current user snapshot.
  SolUser get user => _user;

  /// Stored XP (before any display penalty).
  int get xp => _user.xp;

  /// Adds [amount] to the stored XP (clamped to >= 0).
  void addXp(int amount) {
    final newXp = _user.xp + amount;
    _user = _user.copyWith(xp: newXp < 0 ? 0 : newXp);
    notifyListeners();
  }

  /// Awards XP for a single correct quiz answer.
  void onQuizCorrect() => addXp(XpReward.quizCorrect);

  /// Awards the bonus XP for a perfect quiz.
  void onQuizPerfect() => addXp(XpReward.quizPerfect);

  /// Scores a completed quiz session.
  ///
  /// Awards [XpReward.quizCorrect] per correct answer and an additional
  /// [XpReward.quizPerfect] bonus when all answers are correct.
  void submitQuizResult(int correctCount, int totalCount) {
    for (var i = 0; i < correctCount; i++) {
      onQuizCorrect();
    }
    if (correctCount == totalCount) {
      onQuizPerfect();
    }
    _user = _user.copyWith(quizzesPlayed: _user.quizzesPlayed + 1);
    notifyListeners();
  }

  /// Checks in at [spotId]. Returns `true` if this is a new visit.
  bool onCoolSpotCheckIn(String spotId) {
    if (_user.visitedSpotIds.contains(spotId)) return false;
    _user = _user.copyWith(
      visitedSpotIds: {..._user.visitedSpotIds, spotId},
    );
    addXp(XpReward.coolSpotCheckIn);
    return true;
  }
}
