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

  /// XP threshold to enter this stage.
  int get threshold => switch (this) {
        SolStage.melting => StageThreshold.melting,
        SolStage.hot => StageThreshold.hot,
        SolStage.warm => StageThreshold.warm,
        SolStage.cool => StageThreshold.cool,
        SolStage.radiant => StageThreshold.radiant,
      };

  /// The next higher stage, or `null` for [radiant].
  SolStage? get next => switch (this) {
        SolStage.melting => SolStage.hot,
        SolStage.hot => SolStage.warm,
        SolStage.warm => SolStage.cool,
        SolStage.cool => SolStage.radiant,
        SolStage.radiant => null,
      };
}
