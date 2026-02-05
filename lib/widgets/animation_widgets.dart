import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Enum defining available animation scenarios
enum AnimationScenario {
  plantGrowth,
  mountainClimb,
  bulbLadder,
  bridgeBuilder,
  cliffClimb,
  waterTank,
}

extension AnimationScenarioExtension on AnimationScenario {
  String get title {
    switch (this) {
      case AnimationScenario.plantGrowth:
        return "GROWTH";
      case AnimationScenario.mountainClimb:
        return "STRUGGLE";
      case AnimationScenario.bulbLadder:
        return "ASCENSION";
      case AnimationScenario.bridgeBuilder:
        return "CONNECTION";
      case AnimationScenario.cliffClimb:
        return "GRIT";
      case AnimationScenario.waterTank:
        return "PATIENCE";
    }
  }

  String get description {
    switch (this) {
      case AnimationScenario.plantGrowth:
        return "Watering a plant";
      case AnimationScenario.mountainClimb:
        return "The Sisyphus Tyre Flip";
      case AnimationScenario.bulbLadder:
        return "Lighting up the path";
      case AnimationScenario.bridgeBuilder:
        return "Building bridges";
      case AnimationScenario.cliffClimb:
        return "Don't look down";
      case AnimationScenario.waterTank:
        return "Drop by drop";
    }
  }
}

/// Abstract base class for animation widgets
abstract class BaseAnimationWidget extends StatefulWidget {
  final double progress;
  final bool isRunning;
  final bool isCompleted;

  const BaseAnimationWidget({
    super.key,
    required this.progress,
    required this.isRunning,
    required this.isCompleted,
  });
}

/// Helper for organic noise
double _noise(double time, {double scale = 1.0}) {
  return (sin(time) * 0.5 + sin(time * 2.3) * 0.3 + sin(time * 4.7) * 0.2) *
      scale;
}

// ----------------------------------------------------------------------------
// Existing Scenarios (Condensed)
// ----------------------------------------------------------------------------

// 1. MOUNTAIN CLIMB (SISYPHUS TYRE)
class MountainClimbWidget extends BaseAnimationWidget {
  const MountainClimbWidget({
    super.key,
    required super.progress,
    required super.isRunning,
    required super.isCompleted,
  });
  @override
  State<MountainClimbWidget> createState() => _MountainClimbWidgetState();
}

class _MountainClimbWidgetState extends State<MountainClimbWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pushController;
  @override
  void initState() {
    super.initState();
    _pushController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    if (widget.isRunning) _pushController.repeat();
  }

  @override
  void didUpdateWidget(MountainClimbWidget old) {
    super.didUpdateWidget(old);
    if (widget.isRunning != old.isRunning) {
      if (widget.isRunning) {
        _pushController.repeat();
      } else {
        _pushController.stop();
      }
    }
  }

  @override
  void dispose() {
    _pushController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pushController,
      builder: (_, child) => CustomPaint(
        painter: _TyrePainter(
          progress: widget.progress,
          isCompleted: widget.isCompleted,
          time: _pushController.value,
        ),
        size: const Size(double.infinity, 300),
      ),
    );
  }
}

class _TyrePainter extends CustomPainter {
  final double progress;
  final bool isCompleted;
  final double time;
  _TyrePainter({
    required this.progress,
    required this.isCompleted,
    required this.time,
  });
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final mountainPaint = Paint()
      ..color = AppColors.surfaceLight
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    // Linear Slope
    final pStart = Offset(0, h);
    final pEnd = Offset(w * 0.9, h * 0.2);
    final path = Path();
    path.moveTo(pStart.dx, pStart.dy);
    path.lineTo(pEnd.dx, pEnd.dy);
    if (isCompleted) {
      path.lineTo(w, pEnd.dy);
    } else {
      path.lineTo(pEnd.dx + 20, pStart.dy);
    }
    canvas.drawPath(path, mountainPaint);
    if (isCompleted) {
      _drawVictory(canvas, pEnd.dx + 40, pEnd.dy);
      _drawStickman(canvas, pEnd.dx + 20, pEnd.dy, 0, 0, true);
      return;
    }
    double cycle = (time * 2 * pi);
    double slip = max(0, sin(cycle)) * 0.005;
    double t = (progress - slip).clamp(0.0, 1.0);
    double bx = pStart.dx + (pEnd.dx - pStart.dx) * t;
    double by = pStart.dy + (pEnd.dy - pStart.dy) * t;
    double angle = atan2(pEnd.dy - pStart.dy, pEnd.dx - pStart.dx);
    double radius = 22.0;
    double dist = sqrt(pow(bx - pStart.dx, 2) + pow(by - pStart.dy, 2));
    double rotation = dist / radius;
    double cx = bx + cos(angle - pi / 2) * radius;
    double cy = by + sin(angle - pi / 2) * radius;
    _drawTyre(canvas, Offset(cx, cy), rotation);
    double stickmanOffset = 45.0;
    double sx = bx - cos(angle) * stickmanOffset;
    double sy = by - sin(angle) * stickmanOffset;
    _drawStickman(canvas, sx, sy, angle, time, false);
  }

  void _drawTyre(Canvas canvas, Offset center, double rotation) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    double r = 22.0;
    canvas.drawCircle(
      Offset.zero,
      r - 7,
      Paint()
        ..color = const Color(0xFF222222)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14,
    );
    final treadPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (int i = 0; i < 12; i++) {
      double a = (i / 12) * 2 * pi;
      canvas.drawLine(
        Offset(cos(a) * r, sin(a) * r),
        Offset(cos(a) * (r - 10), sin(a) * (r - 10)),
        treadPaint,
      );
    }
    canvas.drawCircle(
      Offset.zero,
      r - 14,
      Paint()
        ..color = Colors.grey[800]!
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(Offset.zero, 3, Paint()..color = Colors.grey);
    canvas.restore();
  }

  void _drawStickman(
    Canvas canvas,
    double x,
    double y,
    double angle,
    double anim,
    bool victory,
  ) {
    final p = Paint()
      ..color = AppColors.textWhite
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.save();
    if (!victory) {
      canvas.translate(x, y);
      canvas.rotate(angle);
    } else {
      canvas.translate(x, y);
    }
    double jitter = _noise(anim * 10);
    if (victory) {
      canvas.drawCircle(const Offset(0, -35), 8, p);
      canvas.drawLine(const Offset(0, -27), const Offset(0, -15), p);
      canvas.drawLine(const Offset(0, -15), const Offset(-10, 0), p);
      canvas.drawLine(const Offset(0, -15), const Offset(10, 0), p);
      canvas.drawLine(const Offset(0, -25), const Offset(-20, -50), p);
      canvas.drawLine(const Offset(0, -25), const Offset(20, -50), p);
    } else {
      double headY = -30 + jitter;
      canvas.drawCircle(Offset(10, headY), 6, p);
      canvas.drawLine(Offset(10, headY + 6), const Offset(-10, -5), p);
      double l1 = sin(anim * pi * 4) * 5;
      double l2 = -l1;
      canvas.drawLine(const Offset(-10, -5), Offset(-25 + l1, 0), p);
      canvas.drawLine(const Offset(-10, -5), Offset(-15 + l2, 0), p);
      canvas.drawLine(Offset(5, -20), Offset(35, -10 + jitter), p);
    }
    canvas.restore();
  }

  void _drawVictory(Canvas canvas, double x, double y) {
    canvas.drawLine(
      Offset(x, y),
      Offset(x, y - 40),
      Paint()
        ..color = Colors.white
        ..strokeWidth = 2,
    );
    canvas.drawRect(
      Rect.fromLTWH(x, y - 40, 20, 15),
      Paint()..color = AppColors.success,
    );
  }

  @override
  bool shouldRepaint(covariant _TyrePainter old) => true;
}

// 2. BULB LADDER (ASCENSION)
class BulbLadderWidget extends BaseAnimationWidget {
  const BulbLadderWidget({
    super.key,
    required super.progress,
    required super.isRunning,
    required super.isCompleted,
  });
  @override
  State<BulbLadderWidget> createState() => _BLState();
}

class _BLState extends State<BulbLadderWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    if (widget.isRunning) _c.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(BulbLadderWidget old) {
    super.didUpdateWidget(old);
    if (widget.isRunning != old.isRunning) {
      if (widget.isRunning) {
        _c.repeat(reverse: true);
      } else {
        _c.stop();
      }
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) => CustomPaint(
        painter: _LadderPainter(
          progress: widget.progress,
          isCompleted: widget.isCompleted,
          climbAnim: _c.value,
        ),
        size: const Size(double.infinity, 300),
      ),
    );
  }
}

class _LadderPainter extends CustomPainter {
  final double progress;
  final bool isCompleted;
  final double climbAnim;
  _LadderPainter({
    required this.progress,
    required this.isCompleted,
    required this.climbAnim,
  });
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final bottomY = size.height;
    final topY = 20.0;
    final totalH = bottomY - topY;
    final ladderX = cx - 40;
    final poleX = cx + 60;
    final paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(ladderX - 20, topY),
      Offset(ladderX - 20, bottomY),
      paint,
    );
    canvas.drawLine(
      Offset(ladderX + 20, topY),
      Offset(ladderX + 20, bottomY),
      paint,
    );
    for (int i = 0; i <= 15; i++) {
      double y = bottomY - i * (totalH / 15);
      canvas.drawLine(Offset(ladderX - 20, y), Offset(ladderX + 20, y), paint);
    }
    canvas.drawLine(
      Offset(poleX, topY),
      Offset(poleX, bottomY),
      Paint()
        ..color = Colors.brown[700]!
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round,
    );
    double currentY = bottomY - (progress * totalH);
    int bulbCount = 8;
    double bulbSpacing = totalH / (bulbCount + 1);
    for (int i = 1; i <= bulbCount; i++) {
      double by = bottomY - i * bulbSpacing;
      bool isOn = currentY <= by + 10 || isCompleted;
      _drawBulb(canvas, poleX, by, isOn);
    }
    _drawClimbingStickman(canvas, ladderX, currentY, climbAnim, isCompleted);
  }

  void _drawBulb(Canvas canvas, double x, double y, bool isOn) {
    canvas.drawLine(
      Offset(x, y),
      Offset(x - 20, y),
      Paint()
        ..color = Colors.black
        ..strokeWidth = 2,
    );
    final bulbP = Paint()
      ..color = isOn ? const Color(0xFFFFF176) : Colors.grey[400]!
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(x - 25, y), 8, bulbP);
    if (isOn) {
      canvas.drawCircle(
        Offset(x - 25, y),
        15,
        Paint()
          ..color = const Color(0x66FFF59D)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      );
    }
  }

  void _drawClimbingStickman(
    Canvas canvas,
    double x,
    double y,
    double anim,
    bool victory,
  ) {
    final p = Paint()
      ..color = AppColors.textWhite
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.save();
    canvas.translate(x, y);
    if (victory) {
      canvas.drawCircle(const Offset(0, -35), 8, p);
      canvas.drawLine(const Offset(0, -27), const Offset(0, -15), p);
      canvas.drawLine(const Offset(0, -15), const Offset(-15, -35), p);
      canvas.drawLine(const Offset(0, -15), const Offset(15, -35), p);
      canvas.drawLine(const Offset(0, -15), const Offset(-10, 0), p);
      canvas.drawLine(const Offset(0, -15), const Offset(10, 0), p);
    } else {
      double off = sin(anim * pi * 2);
      canvas.drawCircle(const Offset(0, -35), 6, p);
      canvas.drawLine(const Offset(0, -29), const Offset(0, -10), p);
      canvas.drawLine(const Offset(0, -25), Offset(-15, -35 + off * 10), p);
      canvas.drawLine(const Offset(0, -25), Offset(15, -35 - off * 10), p);
      canvas.drawLine(const Offset(0, -10), Offset(-15, 5 + off * 10), p);
      canvas.drawLine(const Offset(0, -10), Offset(15, 5 - off * 10), p);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _LadderPainter old) => true;
}

// 3. BRIDGE BUILDER
class BridgeBuilderWidget extends BaseAnimationWidget {
  const BridgeBuilderWidget({
    super.key,
    required super.progress,
    required super.isRunning,
    required super.isCompleted,
  });
  @override
  State<BridgeBuilderWidget> createState() => _BridgeBuilderState();
}

class _BridgeBuilderState extends State<BridgeBuilderWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ac;
  @override
  void initState() {
    super.initState();
    _ac = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat();
  } // Slower loop for detailed work

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ac,
      builder: (context, child) => CustomPaint(
        painter: _BridgePainter(
          progress: widget.progress,
          isCompleted: widget.isCompleted,
          anim: _ac.value,
        ),
        size: const Size(double.infinity, 300),
      ),
    );
  }
}

class _BridgePainter extends CustomPainter {
  final double progress;
  final bool isCompleted;
  final double anim;
  _BridgePainter({
    required this.progress,
    required this.isCompleted,
    required this.anim,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cliffL = w * 0.2;
    final cliffR = w * 0.8;

    // Cliffs
    final cliffP = Paint()
      ..color = const Color(0xFF4E342E)
      ..style = PaintingStyle.fill;
    final grassP = Paint()
      ..color = Colors.green[800]!
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    // Left Cliff
    canvas.drawRect(Rect.fromLTWH(0, h * 0.6, cliffL, h * 0.4), cliffP);
    canvas.drawLine(Offset(0, h * 0.6), Offset(cliffL, h * 0.6), grassP);

    // Right Cliff
    canvas.drawRect(Rect.fromLTWH(cliffR, h * 0.6, w * 0.2, h * 0.4), cliffP);
    canvas.drawLine(Offset(cliffR, h * 0.6), Offset(w, h * 0.6), grassP);

    // Abyss
    final abyssP = Paint()
      ..shader = LinearGradient(
        colors: [Colors.black, Colors.blueGrey[900]!],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, h * 0.6, w, h * 0.4));
    canvas.drawRect(
      Rect.fromLTWH(cliffL, h * 0.6, cliffR - cliffL, h * 0.4),
      abyssP,
    );

    // Bridge Construction
    final bridgeLen = cliffR - cliffL;
    final plankW = 15.0;
    int totalPlanks = (bridgeLen / plankW).ceil();
    int currentPlanks = (progress * totalPlanks).floor();

    final plankP = Paint()
      ..color = const Color(0xFF8D6E63)
      ..style = PaintingStyle.fill;
    final plankBorder = Paint()
      ..color = const Color(0xFF5D4037)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 0; i < currentPlanks; i++) {
      Rect r = Rect.fromLTWH(cliffL + i * plankW, h * 0.6 - 2, plankW, 8);
      canvas.drawRect(r, plankP);
      canvas.drawRect(r, plankBorder);
      // Nail heads
      canvas.drawCircle(
        Offset(cliffL + i * plankW + 3, h * 0.6 + 2),
        1,
        Paint()..color = Colors.black26,
      );
      canvas.drawCircle(
        Offset(cliffL + i * plankW + 12, h * 0.6 + 2),
        1,
        Paint()..color = Colors.black26,
      );
    }

    // Stickman Worker Logic
    double workX = cliffL + currentPlanks * plankW;
    if (workX > cliffR - 20) workX = cliffR - 20;

    double manX = workX - 20; // Default at work edge

    double cycle = anim;
    bool carrying = cycle > 0.3 && cycle < 0.6;
    bool hammering = cycle > 0.8;
    bool walkingBack = cycle < 0.3;

    if (isCompleted) {
      manX = cliffR - 40; // Static near cliff edge
    } else {
      if (walkingBack) manX -= cycle * 100; // Walk back
      if (carrying) {
        manX = (workX - 50) + (cycle - 0.3) * 160;
      } // Walk forward with plank
      if (manX > workX - 10) manX = workX - 10;
    }

    _drawWorker(canvas, manX, h * 0.6, isCompleted, cycle, carrying, hammering);

    // Stickgirl waiting
    _drawGirl(canvas, cliffR + 30, h * 0.6, isCompleted, anim);
  }

  void _drawWorker(
    Canvas canvas,
    double x,
    double y,
    bool completed,
    double anim,
    bool carrying,
    bool hammering,
  ) {
    final p = Paint()
      ..color = AppColors.textWhite
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.save();
    canvas.translate(x, y);

    if (completed) {
      // Hugging / Meeting
      canvas.translate(45, 0); // Move closer
      // Hearts (Love)
      final heartP = Paint()
        ..color = Colors.red
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(0, -50), 4, heartP);
      canvas.drawCircle(Offset(8, -50), 4, heartP);
      canvas.drawPath(
        Path()
          ..moveTo(-4, -48)
          ..lineTo(4, -40)
          ..lineTo(12, -48),
        heartP,
      );

      canvas.drawCircle(const Offset(0, -35), 6, p);
      canvas.drawLine(const Offset(0, -29), const Offset(0, -10), p);

      // Right Arm reaching to hold hand
      canvas.drawLine(const Offset(0, -25), const Offset(20, -20), p);
      canvas.drawLine(
        const Offset(0, -25),
        const Offset(-5, -20),
        p,
      ); // Left arm down

      // Legs (Standing still)
      canvas.drawLine(const Offset(0, -10), const Offset(-5, 0), p);
      canvas.drawLine(const Offset(0, -10), const Offset(5, 0), p);
    } else {
      // Bending if placement
      bool placing = anim > 0.6 && anim < 0.8;
      double bend = placing || hammering ? 15.0 : 0.0;

      canvas.drawCircle(Offset(bend / 2, -35 + bend), 6, p);
      canvas.drawLine(Offset(bend / 2, -29 + bend), Offset(0, -10), p);

      // Legs (walking)
      double leg = sin(anim * pi * 8) * 5;
      if (placing || hammering) leg = 0; // Stand still-ish
      canvas.drawLine(const Offset(0, -10), Offset(-5 + leg, 0), p);
      canvas.drawLine(const Offset(0, -10), Offset(5 - leg, 0), p);

      // Arms
      if (carrying) {
        // Holding plank overhead
        canvas.drawLine(Offset(0, -25), Offset(5, -45), p);
        canvas.drawLine(Offset(0, -25), Offset(-5, -45), p);
        // The Plank
        canvas.drawRect(
          Rect.fromLTWH(-10, -50, 20, 5),
          Paint()
            ..color = const Color(0xFF8D6E63)
            ..style = PaintingStyle.fill,
        );
      } else if (hammering) {
        // Hammering motion
        double hammerArg = -sin(anim * pi * 20) * 15;
        canvas.drawLine(Offset(0, -20), Offset(15, -10 + hammerArg), p); // Arm
        canvas.drawLine(
          Offset(15, -10 + hammerArg),
          Offset(20, -5 + hammerArg),
          Paint()
            ..color = Colors.grey
            ..strokeWidth = 4,
        ); // Hammer
      } else {
        // Walking arms
        canvas.drawLine(Offset(0, -25), Offset(-5, -15), p);
        canvas.drawLine(Offset(0, -25), Offset(5, -15), p);
      }

      // Sweat drops if working hard
      if (hammering) {
        canvas.drawCircle(
          Offset(-5, -45),
          1,
          Paint()..color = Colors.blueAccent,
        );
        canvas.drawCircle(
          Offset(5, -45),
          1,
          Paint()..color = Colors.blueAccent,
        );
      }
    }
    canvas.restore();
  }

  void _drawGirl(
    Canvas canvas,
    double x,
    double y,
    bool completed,
    double anim,
  ) {
    final p = Paint()
      ..color = Colors.pinkAccent
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.save();
    canvas.translate(x, y);

    canvas.drawCircle(const Offset(0, -33), 6, p); // Head
    canvas.drawLine(const Offset(0, -27), const Offset(0, -10), p); // Body
    // Skirt
    canvas.drawLine(const Offset(0, -15), const Offset(-6, -5), p);
    canvas.drawLine(const Offset(0, -15), const Offset(6, -5), p);
    canvas.drawLine(const Offset(-6, -5), const Offset(6, -5), p);

    if (completed) {
      // Holding hand (Left arm reach left)
      canvas.drawLine(const Offset(0, -25), const Offset(-20, -20), p);
      canvas.drawLine(
        const Offset(0, -25),
        const Offset(10, -15),
        p,
      ); // Other arm down
    } else {
      // Arms (Waving)
      double wave = sin(anim * 5) * 5;
      canvas.drawLine(const Offset(0, -25), Offset(-10, -35 + wave), p);
      canvas.drawLine(const Offset(0, -25), Offset(10, -15), p);
    }

    // Legs
    canvas.drawLine(const Offset(0, -10), const Offset(-3, 0), p);
    canvas.drawLine(const Offset(0, -10), const Offset(3, 0), p);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _BridgePainter old) => true;
}

// 4. CLIFF CLIMB
class CliffClimbWidget extends BaseAnimationWidget {
  const CliffClimbWidget({
    super.key,
    required super.progress,
    required super.isRunning,
    required super.isCompleted,
  });
  @override
  State<CliffClimbWidget> createState() => _CliffState();
}

class _CliffState extends State<CliffClimbWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ac;
  @override
  void initState() {
    super.initState();
    _ac = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat();
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ac,
      builder: (context, child) => CustomPaint(
        painter: _CliffPainter(
          progress: widget.progress,
          isCompleted: widget.isCompleted,
          anim: _ac.value,
        ),
        size: const Size(double.infinity, 300),
      ),
    );
  }
}

class _CliffPainter extends CustomPainter {
  final double progress;
  final bool isCompleted;
  final double anim;
  _CliffPainter({
    required this.progress,
    required this.isCompleted,
    required this.anim,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final h = size.height;
    // Rugged Cliff Face
    final topMargin = 70.0;
    final paint = Paint()
      ..color = const Color(0xFF3E2723)
      ..style = PaintingStyle.fill;
    final path = Path();
    path.moveTo(cx - 40, topMargin);
    // Jagged edge
    bool toggle = true;
    for (double i = topMargin; i <= h; i += 20) {
      path.lineTo(cx + (toggle ? -10 : 10), i);
      toggle = !toggle;
    }
    path.lineTo(size.width, h);
    path.lineTo(size.width, topMargin);
    path.close();
    canvas.drawPath(path, paint);

    // Cracks and Details
    final detailP = Paint()
      ..color = Colors.black26
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    for (int i = 0; i < 15; i++) {
      double dy = topMargin + ((i / 15) * (h - topMargin));
      canvas.drawPath(
        Path()
          ..moveTo(cx + 20, dy)
          ..quadraticBezierTo(cx + 40, dy + 10, cx + 30, dy + 20),
        detailP,
      );
    }

    // Stickman Logic
    double climbY = h - (progress * (h - topMargin));

    if (isCompleted) {
      _drawStickman(
        canvas,
        cx + 20,
        topMargin,
        true,
        anim,
        true,
      ); // On top (solid ground)
    } else {
      // Physics:
      // 0.0-0.4: Reach Hand
      // 0.4-0.6: Pull Up
      // 0.6-0.7: Slip check
      // 0.7-1.0: Hold/Rest

      bool slipping =
          (anim > 0.65 && anim < 0.75) &&
          (progress < 0.8 && progress > 0.2); // Random slip zone
      double slipOffset = slipping ? 15.0 : 0.0;

      if (slipping) {
        // Debris falls
        canvas.drawCircle(
          Offset(cx, climbY + 20),
          3,
          Paint()..color = Colors.grey,
        );
        canvas.drawCircle(
          Offset(cx + 10, climbY + 30),
          2,
          Paint()..color = Colors.grey,
        );
      }

      _drawStickman(
        canvas,
        cx,
        climbY + slipOffset,
        false,
        anim,
        false,
        slipping: slipping,
      );
    }
  }

  void _drawStickman(
    Canvas canvas,
    double x,
    double y,
    bool completed,
    double anim,
    bool standing, {
    bool slipping = false,
  }) {
    final p = Paint()
      ..color = AppColors.textWhite
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.save();
    canvas.translate(x, y);

    if (standing) {
      // Backpack
      canvas.drawRect(
        Rect.fromLTWH(0, -30, 12, 18),
        Paint()
          ..color = Colors.brown[700]!
          ..style = PaintingStyle.fill,
      );
      canvas.drawRect(
        Rect.fromLTWH(0, -30, 12, 18),
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );

      canvas.drawCircle(const Offset(0, -35), 6, p);
      canvas.drawLine(const Offset(0, -29), const Offset(0, -10), p);
      canvas.drawLine(const Offset(0, -10), const Offset(-5, 0), p);
      canvas.drawLine(const Offset(0, -10), const Offset(5, 0), p);
      // Flag
      canvas.drawLine(const Offset(5, -20), const Offset(5, -50), p);
      canvas.drawRect(
        Rect.fromLTWH(5, -50, 15, 10),
        Paint()
          ..color = AppColors.accent
          ..style = PaintingStyle.fill,
      );
    } else {
      // Climbing
      // Dynamic limb placement
      double leftHandY = -45;
      double rightHandY = -45;

      if (slipping) {
        leftHandY = -55; // Flailing
        rightHandY = -35;
        canvas.rotate(0.2); // Tilted back
      } else {
        // Reaching
        leftHandY += sin(anim * 2 * pi) * 10;
        rightHandY -= sin(anim * 2 * pi) * 10;
      }

      // Backpack (Climbing)
      canvas.drawRect(
        Rect.fromLTWH(-25, -30, 10, 16),
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill,
      );
      canvas.drawRect(
        Rect.fromLTWH(-25, -30, 10, 16),
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );

      canvas.drawCircle(const Offset(-15, -35), 6, p); // Head away from wall
      canvas.drawLine(
        const Offset(-15, -29),
        const Offset(-10, -10),
        p,
      ); // Body

      // Arms
      canvas.drawLine(const Offset(-15, -25), Offset(0, leftHandY), p);
      canvas.drawLine(const Offset(-15, -25), Offset(0, rightHandY), p);

      // Legs
      canvas.drawLine(const Offset(-10, -10), const Offset(0, 0), p);
      canvas.drawLine(const Offset(-10, -10), const Offset(0, -15), p);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CliffPainter old) => true;
}

// 6. WATER TANK
class WaterTankWidget extends BaseAnimationWidget {
  const WaterTankWidget({
    super.key,
    required super.progress,
    required super.isRunning,
    required super.isCompleted,
  });
  @override
  State<WaterTankWidget> createState() => _WaterTankState();
}

class _WaterTankState extends State<WaterTankWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ac;
  @override
  void initState() {
    super.initState();
    _ac = AnimationController(vsync: this, duration: const Duration(seconds: 5))
      ..repeat();
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ac,
      builder: (context, child) => CustomPaint(
        painter: _WaterTankPainter(
          progress: widget.progress,
          isCompleted: widget.isCompleted,
          anim: _ac.value,
        ),
        size: const Size(double.infinity, 300),
      ),
    );
  }
}

class _WaterTankPainter extends CustomPainter {
  final double progress;
  final bool isCompleted;
  final double anim;
  _WaterTankPainter({
    required this.progress,
    required this.isCompleted,
    required this.anim,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final groundY = h * 0.85;

    // Ground
    canvas.drawLine(
      Offset(0, groundY),
      Offset(w, groundY),
      Paint()
        ..color = AppColors.surfaceLight
        ..strokeWidth = 2,
    );

    // Well (left side)
    final wellX = w * 0.15;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(wellX, groundY - 10),
        width: 50,
        height: 20,
      ),
      Paint()..color = Colors.grey[700]!,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(wellX, groundY - 10),
        width: 40,
        height: 15,
      ),
      Paint()..color = Colors.blue[800]!,
    );

    // Tank (right side)
    final tankX = w * 0.75;
    final tankWidth = 80.0;
    final tankHeight = 100.0;
    final tankTop = groundY - tankHeight;
    canvas.drawRect(
      Rect.fromLTWH(tankX - tankWidth / 2, tankTop, tankWidth, tankHeight),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    // Water level
    final waterHeight = tankHeight * progress;
    canvas.drawRect(
      Rect.fromLTWH(
        tankX - tankWidth / 2 + 3,
        groundY - waterHeight,
        tankWidth - 6,
        waterHeight - 3,
      ),
      Paint()..color = Colors.blue.withValues(alpha: 0.6),
    );

    // Percentage
    final textP = TextPainter(
      text: TextSpan(
        text: '${(progress * 100).toInt()}%',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textP.layout();
    textP.paint(canvas, Offset(tankX - textP.width / 2, tankTop + 5));

    if (isCompleted) {
      _drawStickman(canvas, tankX - 60, groundY, 0, true);
    } else {
      // Stickman walks carrying bucket
      double manX;
      bool carrying;
      bool pouring = false;
      if (anim < 0.25) {
        manX = wellX + 30;
        carrying = false;
      } else if (anim < 0.5) {
        manX =
            (wellX + 30) + (tankX - 60 - wellX - 30) * ((anim - 0.25) / 0.25);
        carrying = true;
      } else if (anim < 0.75) {
        manX = tankX - 60;
        carrying = true;
        pouring = true;
      } else {
        manX =
            (tankX - 60) - (tankX - 60 - wellX - 30) * ((anim - 0.75) / 0.25);
        carrying = false;
      }

      _drawStickman(
        canvas,
        manX,
        groundY,
        anim,
        false,
        carrying: carrying,
        pouring: pouring,
      );

      if (carrying && !pouring) {
        _drawBucket(canvas, manX + 15, groundY - 25, true);
      } else if (pouring) {
        _drawBucket(canvas, manX + 20, groundY - 45, false, tilted: true);
        canvas.drawLine(
          Offset(manX + 25, groundY - 40),
          Offset(tankX - tankWidth / 2 + 10, tankTop + 20),
          Paint()
            ..color = Colors.blue
            ..strokeWidth = 3,
        );
      } else if (anim < 0.25) {
        _drawBucket(canvas, wellX, groundY - 20, false);
      }
    }
  }

  void _drawBucket(
    Canvas canvas,
    double x,
    double y,
    bool full, {
    bool tilted = false,
  }) {
    canvas.save();
    canvas.translate(x, y);
    if (tilted) canvas.rotate(-0.5);
    canvas.drawPath(
      Path()
        ..moveTo(-8, 0)
        ..lineTo(-10, 15)
        ..lineTo(10, 15)
        ..lineTo(8, 0)
        ..close(),
      Paint()..color = Colors.grey[400]!,
    );
    canvas.drawArc(
      Rect.fromLTWH(-6, -8, 12, 12),
      3.14,
      3.14,
      false,
      Paint()
        ..color = Colors.grey[600]!
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    if (full) {
      canvas.drawRect(
        Rect.fromLTWH(-7, 3, 14, 10),
        Paint()..color = Colors.blue.withValues(alpha: 0.7),
      );
    }
    canvas.restore();
  }

  void _drawStickman(
    Canvas canvas,
    double x,
    double y,
    double anim,
    bool completed, {
    bool carrying = false,
    bool pouring = false,
  }) {
    final p = Paint()
      ..color = AppColors.textWhite
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.save();
    canvas.translate(x, y);
    canvas.drawCircle(const Offset(0, -50), 6, p);
    canvas.drawLine(const Offset(0, -44), const Offset(0, -20), p);
    if (completed) {
      canvas.drawLine(const Offset(0, -40), const Offset(-15, -55), p);
      canvas.drawLine(const Offset(0, -40), const Offset(15, -55), p);
      canvas.drawLine(const Offset(0, -20), const Offset(-8, 0), p);
      canvas.drawLine(const Offset(0, -20), const Offset(8, 0), p);
    } else if (pouring) {
      canvas.drawLine(const Offset(0, -40), const Offset(20, -35), p);
      canvas.drawLine(const Offset(0, -40), const Offset(15, -30), p);
      canvas.drawLine(const Offset(0, -20), const Offset(-8, 0), p);
      canvas.drawLine(const Offset(0, -20), const Offset(8, 0), p);
    } else {
      double leg = sin(anim * pi * 16) * 8;
      canvas.drawLine(const Offset(0, -20), Offset(-8 + leg, 0), p);
      canvas.drawLine(const Offset(0, -20), Offset(8 - leg, 0), p);
      if (carrying) {
        canvas.drawLine(const Offset(0, -40), const Offset(15, -25), p);
        canvas.drawLine(const Offset(0, -40), const Offset(10, -20), p);
      } else {
        canvas.drawLine(const Offset(0, -40), Offset(-10 + leg, -30), p);
        canvas.drawLine(const Offset(0, -40), Offset(10 - leg, -30), p);
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _WaterTankPainter old) => true;
}
