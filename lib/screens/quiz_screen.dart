import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants.dart';
import '../core/quiz_questions.dart';
import '../models/quiz_question.dart';
import '../providers/user_provider.dart';
import '../widgets/state_views.dart';

enum _Phase { start, question, result }

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  static const _questionsPerSession = 3;
  final _random = Random();

  _Phase _phase = _Phase.start;
  List<QuizQuestion> _sessionQuestions = const [];
  int _currentIndex = 0;
  int _correctCount = 0;
  int? _selectedIndex;
  bool _submitted = false;

  // ── Session lifecycle ─────────────────────────────────────────────

  void _startSession() {
    if (context.read<UserProvider>().quizPlayedToday) return;
    final picked = _pickQuestions();
    setState(() {
      _phase = _Phase.question;
      _sessionQuestions = picked;
      _currentIndex = 0;
      _correctCount = 0;
      _selectedIndex = null;
      _submitted = false;
    });
  }

  List<QuizQuestion> _pickQuestions() {
    final byCube = <ClimateCube, List<QuizQuestion>>{};
    for (final q in quizCatalog) {
      byCube.putIfAbsent(q.cube, () => []).add(q);
    }
    final picked = <QuizQuestion>[];
    for (final cube in ClimateCube.values) {
      final pool = byCube[cube];
      if (pool != null && pool.isNotEmpty) {
        picked.add(pool[_random.nextInt(pool.length)]);
      }
    }
    picked.shuffle(_random);
    return picked.take(_questionsPerSession).toList();
  }

  void _selectOption(int index) {
    if (_selectedIndex != null) return;
    final correct = _sessionQuestions[_currentIndex].correctIndex == index;
    setState(() {
      _selectedIndex = index;
      if (correct) _correctCount++;
    });
  }

  void _next() {
    if (_currentIndex < _questionsPerSession - 1) {
      setState(() {
        _currentIndex++;
        _selectedIndex = null;
      });
    } else {
      _finishSession();
    }
  }

  void _finishSession() {
    if (!_submitted) {
      _submitted = true;
      context
          .read<UserProvider>()
          .submitQuizResult(_correctCount, _questionsPerSession);
    }
    setState(() => _phase = _Phase.result);
  }

  // ── UI ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz')),
      body: switch (_phase) {
        _Phase.start => _buildStart(),
        _Phase.question => _buildQuestion(),
        _Phase.result => _buildResult(),
      },
    );
  }

  Widget _buildStart() {
    final playedToday = context.watch<UserProvider>().quizPlayedToday;

    if (playedToday) {
      return const EmptyView(
        icon: Icons.timer_outlined,
        message: 'Already played today — come back tomorrow!',
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: kScreenPadding * 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.quiz_rounded,
                size: 72, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 24),
            Text(
              'Heat Awareness Quiz',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Answer 3 questions about heat, health, and solutions '
              'to earn XP for Sol!',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _startSession,
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Start Quiz'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestion() {
    final question = _sessionQuestions[_currentIndex];
    final answered = _selectedIndex != null;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(kScreenPadding + 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Progress + cube badge
            Row(
              children: [
                _CubeBadge(cube: question.cube),
                const Spacer(),
                Text(
                  'Question ${_currentIndex + 1}/$_questionsPerSession',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: (_currentIndex + 1) / _questionsPerSession,
              borderRadius: BorderRadius.circular(4),
            ),

            const SizedBox(height: 24),
            Text(
              question.questionText,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 20),

            // Options
            ...List.generate(question.options.length, (i) {
              final isCorrect = i == question.correctIndex;
              final isSelected = i == _selectedIndex;

              Color? tileColor;
              if (answered) {
                if (isCorrect) {
                  tileColor = Colors.green.shade50;
                } else if (isSelected) {
                  tileColor = Colors.red.shade50;
                }
              }

              IconData? trailing;
              if (answered) {
                if (isCorrect) {
                  trailing = Icons.check_circle;
                } else if (isSelected) {
                  trailing = Icons.cancel;
                }
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Material(
                  color: tileColor ?? Theme.of(context).colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: answered ? null : () => _selectOption(i),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(question.options[i]),
                          ),
                          if (trailing != null)
                            Icon(trailing,
                                color: isCorrect ? Colors.green : Colors.red),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),

            const Spacer(),
            if (answered)
              FilledButton(
                onPressed: _next,
                child: Text(
                  _currentIndex < _questionsPerSession - 1
                      ? 'Next'
                      : 'See Result',
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildResult() {
    final xpEarned = _correctCount * XpReward.quizCorrect +
        (_correctCount == _questionsPerSession ? XpReward.quizPerfect : 0);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _correctCount == _questionsPerSession
                  ? Icons.emoji_events_rounded
                  : Icons.check_circle_outline_rounded,
              size: 72,
              color: _correctCount == _questionsPerSession
                  ? Colors.amber
                  : Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              '$_correctCount / $_questionsPerSession correct',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              '+$xpEarned XP',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (_correctCount == _questionsPerSession) ...[
              const SizedBox(height: 4),
              const Text('Perfect bonus included!'),
            ],
            const SizedBox(height: 32),
            Text(
              'Already played today — come back tomorrow!',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _CubeBadge extends StatelessWidget {
  const _CubeBadge({required this.cube});

  final ClimateCube cube;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: cube.color.withAlpha(30),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cube.color, width: 1.2),
      ),
      child: Text(
        cube.label,
        style: TextStyle(
          color: cube.color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
