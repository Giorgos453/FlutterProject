import '../core/constants.dart';

/// Avatar evolution stage based on the user's effective XP.
enum SolStage {
  melting,
  hot,
  warm,
  cool,
  radiant;

  /// Returns the stage matching the given XP [value].
  static SolStage fromValue(int value) {
    if (value >= StageThreshold.radiant) return SolStage.radiant;
    if (value >= StageThreshold.cool) return SolStage.cool;
    if (value >= StageThreshold.warm) return SolStage.warm;
    if (value >= StageThreshold.hot) return SolStage.hot;
    return SolStage.melting;
  }
}
