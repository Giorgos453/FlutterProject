import 'dart:math';

import 'package:flutter/material.dart';

import '../models/sol_stage.dart';

/// Animated sun avatar whose appearance reflects the current [SolStage].
class SolAvatar extends StatelessWidget {
  const SolAvatar({super.key, required this.stage, this.size = 160});

  final SolStage stage;
  final double size;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      child: _PulsingSol(key: ValueKey(stage), stage: stage, size: size),
    );
  }
}

class _PulsingSol extends StatefulWidget {
  const _PulsingSol({super.key, required this.stage, required this.size});

  final SolStage stage;
  final double size;

  @override
  State<_PulsingSol> createState() => _PulsingSolState();
}

class _PulsingSolState extends State<_PulsingSol>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        return CustomPaint(
          size: Size.square(widget.size),
          painter: _SolPainter(stage: widget.stage, pulse: _ctrl.value),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Painter
// ---------------------------------------------------------------------------

class _SolPainter extends CustomPainter {
  _SolPainter({required this.stage, required this.pulse});

  final SolStage stage;
  final double pulse;

  // -- colours ---------------------------------------------------------------

  Color get _bodyColor => switch (stage) {
        SolStage.melting => const Color(0xFFE8A858),
        SolStage.hot => const Color(0xFFF57C00),
        SolStage.warm => const Color(0xFFFFB300),
        SolStage.cool => const Color(0xFFFFD54F),
        SolStage.radiant => const Color(0xFFFFCA28),
      };

  Color get _rayColor => switch (stage) {
        SolStage.melting => const Color(0x66E8A858),
        SolStage.hot => const Color(0xCCFF9800),
        SolStage.warm => const Color(0xCCFFCA28),
        SolStage.cool => const Color(0xCCFFEB3B),
        SolStage.radiant => const Color(0xFFFFD54F),
      };

  // -- paint -----------------------------------------------------------------

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide * 0.28;

    _paintRays(canvas, c, r);
    _paintBody(canvas, c, r);
    _paintFace(canvas, c, r);
  }

  // -- rays ------------------------------------------------------------------

  void _paintRays(Canvas canvas, Offset c, double r) {
    final paint = Paint()
      ..color = _rayColor
      ..strokeWidth = r * 0.12
      ..strokeCap = StrokeCap.round;

    final count = stage == SolStage.radiant ? 16 : 12;
    final pulseOffset = r * 0.08 * pulse;
    final rayStart = r * 1.1;
    final rayEnd =
        r * (stage == SolStage.radiant ? 1.55 : 1.45) + pulseOffset;

    for (var i = 0; i < count; i++) {
      final a = 2 * pi * i / count;
      final dir = Offset(cos(a), sin(a));
      canvas.drawLine(c + dir * rayStart, c + dir * rayEnd, paint);
    }
  }

  // -- body ------------------------------------------------------------------

  void _paintBody(Canvas canvas, Offset c, double r) {
    final paint = Paint()..color = _bodyColor;
    canvas.drawCircle(c, r, paint);

    if (stage == SolStage.melting) {
      _paintDrip(canvas, c.dx - r * 0.3, c.dy + r * 0.85, r * 0.10, r * 0.35,
          paint);
      _paintDrip(canvas, c.dx + r * 0.2, c.dy + r * 0.90, r * 0.08, r * 0.25,
          paint);
    }
  }

  void _paintDrip(
      Canvas canvas, double x, double y, double w, double h, Paint paint) {
    final path = Path()
      ..moveTo(x - w, y)
      ..quadraticBezierTo(x - w, y + h * 0.8, x, y + h)
      ..quadraticBezierTo(x + w, y + h * 0.8, x + w, y);
    canvas.drawPath(path, paint);
  }

  // -- face ------------------------------------------------------------------

  void _paintFace(Canvas canvas, Offset c, double r) {
    if (stage == SolStage.radiant) {
      _paintSunglasses(canvas, c, r);
    } else {
      _paintEyes(canvas, c, r);
    }
    _paintMouth(canvas, c, r);

    switch (stage) {
      case SolStage.melting:
        _paintTear(canvas, c, r);
      case SolStage.hot:
        _paintSweat(canvas, c, r);
      case SolStage.cool:
        _paintParasol(canvas, c, r);
      default:
        break;
    }
  }

  void _paintEyes(Canvas canvas, Offset c, double r) {
    final eyeR = r * 0.10;
    final eyeY = c.dy - r * 0.15;
    final gap = r * 0.28;

    final white = Paint()..color = const Color(0xFFFFFFFF);
    final pupil = Paint()..color = const Color(0xFF3E2723);

    for (final dx in [-gap, gap]) {
      canvas.drawCircle(Offset(c.dx + dx, eyeY), eyeR, white);
      canvas.drawCircle(Offset(c.dx + dx, eyeY), eyeR * 0.55, pupil);
    }

    if (stage == SolStage.melting) {
      final brow = Paint()
        ..color = const Color(0xFF5D4037)
        ..strokeWidth = r * 0.04
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(c.dx - gap - eyeR, eyeY - eyeR * 2.0),
        Offset(c.dx - gap + eyeR, eyeY - eyeR * 1.3),
        brow,
      );
      canvas.drawLine(
        Offset(c.dx + gap + eyeR, eyeY - eyeR * 2.0),
        Offset(c.dx + gap - eyeR, eyeY - eyeR * 1.3),
        brow,
      );
    }
  }

  void _paintMouth(Canvas canvas, Offset c, double r) {
    final paint = Paint()
      ..color = const Color(0xFF5D4037)
      ..strokeWidth = r * 0.05
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final y = c.dy + r * 0.32;
    final w = r * 0.30;

    final path = Path();
    switch (stage) {
      case SolStage.melting:
        path.moveTo(c.dx - w, y + r * 0.06);
        path.quadraticBezierTo(c.dx, y - r * 0.14, c.dx + w, y + r * 0.06);
      case SolStage.hot:
        path.moveTo(c.dx - w * 0.7, y);
        path.lineTo(c.dx + w * 0.7, y);
      case SolStage.warm:
        path.moveTo(c.dx - w * 0.8, y);
        path.quadraticBezierTo(c.dx, y + r * 0.10, c.dx + w * 0.8, y);
      case SolStage.cool:
        path.moveTo(c.dx - w, y);
        path.quadraticBezierTo(c.dx, y + r * 0.16, c.dx + w, y);
      case SolStage.radiant:
        paint.style = PaintingStyle.fill;
        path.moveTo(c.dx - w, y - r * 0.02);
        path.quadraticBezierTo(c.dx, y + r * 0.22, c.dx + w, y - r * 0.02);
        path.close();
    }
    canvas.drawPath(path, paint);
  }

  // -- accessories -----------------------------------------------------------

  void _paintTear(Canvas canvas, Offset c, double r) {
    final paint = Paint()..color = const Color(0xFF42A5F5);
    final tx = c.dx + r * 0.42;
    final ty = c.dy;
    final h = r * 0.18;
    final w = r * 0.07;
    final path = Path()
      ..moveTo(tx, ty)
      ..quadraticBezierTo(tx + w * 1.5, ty + h * 0.7, tx, ty + h)
      ..quadraticBezierTo(tx - w * 1.5, ty + h * 0.7, tx, ty);
    canvas.drawPath(path, paint);
  }

  void _paintSweat(Canvas canvas, Offset c, double r) {
    final paint = Paint()..color = const Color(0xFF42A5F5);
    final sx = c.dx + r * 0.60;
    final sy = c.dy - r * 0.25;
    final h = r * 0.15;
    final w = r * 0.05;
    final path = Path()
      ..moveTo(sx, sy)
      ..quadraticBezierTo(sx + w * 1.5, sy + h * 0.7, sx, sy + h)
      ..quadraticBezierTo(sx - w * 1.5, sy + h * 0.7, sx, sy);
    canvas.drawPath(path, paint);
  }

  void _paintParasol(Canvas canvas, Offset c, double r) {
    final handleX = c.dx + r * 0.40;
    final topY = c.dy - r * 1.35;

    canvas.drawLine(
      Offset(handleX, topY),
      Offset(handleX, c.dy - r * 0.30),
      Paint()
        ..color = const Color(0xFF5D4037)
        ..strokeWidth = r * 0.05
        ..strokeCap = StrokeCap.round,
    );

    final canopy = Paint()..color = const Color(0xFFE53935);
    final rect = Rect.fromCenter(
      center: Offset(handleX, topY),
      width: r * 1.0,
      height: r * 0.55,
    );
    canvas.drawArc(rect, pi, pi, true, canopy);
  }

  void _paintSunglasses(Canvas canvas, Offset c, double r) {
    final glass = Paint()..color = const Color(0xFF212121);
    final eyeY = c.dy - r * 0.15;
    final gap = r * 0.28;
    final lensW = r * 0.22;
    final lensH = r * 0.15;
    final corner = Radius.circular(r * 0.05);

    for (final dx in [-gap, gap]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(c.dx + dx, eyeY),
            width: lensW * 2,
            height: lensH * 2,
          ),
          corner,
        ),
        glass,
      );
    }

    canvas.drawLine(
      Offset(c.dx - gap + lensW, eyeY),
      Offset(c.dx + gap - lensW, eyeY),
      Paint()
        ..color = const Color(0xFF212121)
        ..strokeWidth = r * 0.04,
    );
  }

  @override
  bool shouldRepaint(_SolPainter old) =>
      old.stage != stage || old.pulse != pulse;
}
