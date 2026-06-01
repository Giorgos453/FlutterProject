import 'package:flutter/material.dart';

/// The three climate-awareness dimensions.
enum ClimateCube {
  heat('Heat', Color(0xFFE53935)),
  health('Health', Color(0xFFFDD835)),
  solutions('Solutions', Color(0xFF43A047));

  const ClimateCube(this.label, this.color);

  final String label;
  final Color color;
}

/// A single quiz question tied to one [ClimateCube].
class QuizQuestion {
  const QuizQuestion({
    required this.id,
    required this.cube,
    required this.questionText,
    required this.options,
    required this.correctIndex,
  }) : assert(correctIndex >= 0 && correctIndex < 4);

  final String id;
  final ClimateCube cube;
  final String questionText;
  final List<String> options;
  final int correctIndex;
}
