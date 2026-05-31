import 'package:flutter/material.dart';

import '../models/sol_stage.dart';

/// Animated progress bar showing XP toward the next [SolStage].
class XpBar extends StatelessWidget {
  const XpBar({super.key, required this.xp, required this.stage});

  final int xp;
  final SolStage stage;

  @override
  Widget build(BuildContext context) {
    final nextStage = stage.next;
    final currentThreshold = stage.threshold;
    final nextThreshold = nextStage?.threshold;

    final double progress;
    if (nextThreshold == null) {
      progress = 1.0;
    } else {
      final range = nextThreshold - currentThreshold;
      progress = range > 0
          ? ((xp - currentThreshold) / range).clamp(0.0, 1.0)
          : 1.0;
    }

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              stage.name.toUpperCase(),
              style: textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            Text(
              nextThreshold != null ? '$xp / $nextThreshold XP' : '$xp XP',
              style: textTheme.labelMedium,
            ),
          ],
        ),
        const SizedBox(height: 6),
        TweenAnimationBuilder<double>(
          tween: Tween(end: progress),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          builder: (context, value, _) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: value,
                minHeight: 10,
                backgroundColor: colorScheme.primary.withAlpha(40),
                valueColor: AlwaysStoppedAnimation(colorScheme.primary),
              ),
            );
          },
        ),
      ],
    );
  }
}
