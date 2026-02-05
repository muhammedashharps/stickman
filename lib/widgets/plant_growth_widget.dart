// ignore_for_file: deprecated_member_use, curly_braces_in_flow_control_structures, no_leading_underscores_for_local_identifiers
import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PlantGrowthWidget extends StatefulWidget {
  final double progress;
  final bool isRunning;
  final bool isCompleted;

  const PlantGrowthWidget({
    super.key,
    required this.progress,
    required this.isRunning,
    required this.isCompleted,
  });

  @override
  State<PlantGrowthWidget> createState() => _PlantGrowthWidgetState();
}

class _PlantGrowthWidgetState extends State<PlantGrowthWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _wateringController;

  @override
  void initState() {
    super.initState();
    _wateringController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    if (widget.isRunning) {
      _wateringController.repeat();
    }
  }

  @override
  void didUpdateWidget(PlantGrowthWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRunning != oldWidget.isRunning) {
      if (widget.isRunning) {
        _wateringController.repeat();
      } else {
        _wateringController.stop();
        _wateringController.value = 0;
      }
    }
    if (widget.isCompleted && !oldWidget.isCompleted) {
      _wateringController.stop();
    }
  }

  @override
  void dispose() {
    _wateringController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _wateringController,
      builder: (context, child) {
        return CustomPaint(
          painter: _PlantPainter(
            progress: widget.progress,
            isCompleted: widget.isCompleted,
            wateringAnimValue: _wateringController.value,
          ),
          size: const Size(double.infinity, 300),
        );
      },
    );
  }
}

class _PlantPainter extends CustomPainter {
  final double progress;
  final bool isCompleted;
  final double wateringAnimValue;

  _PlantPainter({
    required this.progress,
    required this.isCompleted,
    required this.wateringAnimValue,
  });

  // Helper for organic motion
  double _noise(double time) {
    return sin(time) * 0.5 + sin(time * 2.3) * 0.3 + sin(time * 4.7) * 0.2;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final groundY = size.height * 0.85;

    // Ground
    final groundPaint = Paint()
      ..color = AppColors.surfaceLight
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, groundY);
    for (double i = 0; i <= size.width; i += 20) {
      path.lineTo(i, groundY + sin(i / 50) * 2);
    }
    canvas.drawPath(path, groundPaint);

    //  Draw Stickman (Watering with Locomotion)
    if (!isCompleted) {
      double cycle = wateringAnimValue; // 0..1
      double offset = -90 + sin(cycle * 2 * pi) * 5;

      _drawStickman(canvas, centerX + offset, groundY, wateringAnimValue);

      double spoutOffX = centerX + offset + 40; // approx hand pos
      double spoutOffY = groundY - 60;

      if (wateringAnimValue > 0) {
        _drawWaterStream(canvas, spoutOffX, spoutOffY, wateringAnimValue);
      }
    }

    _drawPlant(canvas, centerX, groundY, progress);

    if (isCompleted) {
      _drawHappyStickman(canvas, centerX - 80, groundY);
      _drawFlower(canvas, centerX, groundY - 140);
    } else if (progress >= 0.99) {
      _drawFlower(canvas, centerX, groundY - 140);
    }
  }

  void _drawPlant(Canvas canvas, double rootX, double rootY, double growth) {
    if (growth <= 0) return;

    final paint = Paint()
      ..color = AppColors.health
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    // Max height of the main stem
    double maxHeight = 120.0;
    double currentHeight = maxHeight * growth;

    // Main Stem
    Path stemPath = Path();
    stemPath.moveTo(rootX, rootY);
    // Organic curve
    stemPath.quadraticBezierTo(
      rootX + 10 * sin(growth * pi),
      rootY - currentHeight / 2,
      rootX,
      rootY - currentHeight,
    );
    canvas.drawPath(stemPath, paint);

    // Leaves
    final leafPaint = Paint()
      ..color = AppColors.health
      ..style = PaintingStyle.fill;

    if (growth > 0.3)
      _drawLeaf(canvas, rootX, rootY - currentHeight * 0.3, true, leafPaint);
    if (growth > 0.6)
      _drawLeaf(canvas, rootX, rootY - currentHeight * 0.6, false, leafPaint);
    if (growth > 0.8)
      _drawLeaf(canvas, rootX, rootY - currentHeight * 0.8, true, leafPaint);
  }

  void _drawLeaf(Canvas canvas, double x, double y, bool isRight, Paint paint) {
    canvas.save();
    canvas.translate(x, y);
    if (!isRight) canvas.scale(-1, 1);
    Path leaf = Path();
    leaf.moveTo(0, 0);
    leaf.quadraticBezierTo(20, -10, 30, 0);
    leaf.quadraticBezierTo(20, 10, 0, 0);
    canvas.drawPath(leaf, paint);
    canvas.restore();
  }

  void _drawFlower(Canvas canvas, double x, double y) {
    final petalPaint = Paint()
      ..color = Colors.pinkAccent
      ..style = PaintingStyle.fill;
    final centerPaint = Paint()
      ..color = Colors.yellow
      ..style = PaintingStyle.fill;
    for (int i = 0; i < 5; i++) {
      double angle = (i * 72) * pi / 180;
      double px = x + cos(angle) * 15;
      double py = y + sin(angle) * 15;
      canvas.drawCircle(Offset(px, py), 10, petalPaint);
    }
    canvas.drawCircle(Offset(x, y), 8, centerPaint);
  }

  void _drawStickman(Canvas canvas, double x, double y, double animValue) {
    final paint = Paint()
      ..color = AppColors.textWhite
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    double jitter = _noise(animValue * 10) * 2;

    // Body parts
    final headPos = Offset(x, y - 70 + jitter);
    final hipPos = Offset(x, y - 35 + jitter);
    final shoulderPos = Offset(x, y - 55 + jitter);

    canvas.drawCircle(headPos, 8, paint);
    canvas.drawLine(headPos.translate(0, 8), hipPos, paint);

    // Legs (walking)
    double legStride = sin(animValue * pi * 4) * 10;
    canvas.drawLine(hipPos, Offset(x - 5 + legStride, y), paint);
    canvas.drawLine(hipPos, Offset(x + 5 - legStride, y), paint);

    // Arms
    // Pouring motion
    double armAngle = -pi / 6;
    double pourOffset = sin(animValue * 4 * pi) * 0.2;

    final handPos = Offset(
      shoulderPos.dx + 25,
      shoulderPos.dy + 10 + (pourOffset * 15),
    );
    canvas.drawLine(shoulderPos, handPos, paint);
    _drawWateringCan(canvas, handPos, armAngle + pourOffset);

    // Back arm swing
    canvas.drawLine(
      shoulderPos,
      Offset(x - 15 - legStride, y - 40 + jitter),
      paint,
    );
  }

  void _drawHappyStickman(Canvas canvas, double x, double y) {
    final paint = Paint()
      ..color = AppColors.textWhite
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    double jump = 15.0;

    canvas.drawCircle(Offset(x, y - 70 - jump), 8, paint);
    canvas.drawLine(Offset(x, y - 62 - jump), Offset(x, y - 35 - jump), paint);
    canvas.drawLine(Offset(x, y - 35 - jump), Offset(x - 15, y - jump), paint);
    canvas.drawLine(Offset(x, y - 35 - jump), Offset(x + 15, y - jump), paint);

    canvas.drawLine(
      Offset(x, y - 55 - jump),
      Offset(x - 20, y - 85 - jump),
      paint,
    );
    canvas.drawLine(
      Offset(x, y - 55 - jump),
      Offset(x + 20, y - 85 - jump),
      paint,
    );
  }

  void _drawWateringCan(Canvas canvas, Offset handPos, double angle) {
    final paint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.fill;
    canvas.save();
    canvas.translate(handPos.dx, handPos.dy);
    canvas.rotate(angle);
    canvas.drawRect(const Rect.fromLTWH(0, 0, 20, 15), paint);
    final spoutPath = Path();
    spoutPath.moveTo(20, 5);
    spoutPath.lineTo(35, 0);
    spoutPath.lineTo(35, 3);
    spoutPath.lineTo(20, 10);
    canvas.drawPath(spoutPath, paint);
    final handlePath = Path();
    handlePath.moveTo(0, 5);
    handlePath.quadraticBezierTo(-10, 0, 0, 15);
    canvas.drawPath(
      handlePath,
      Paint()
        ..color = Colors.grey
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.restore();
  }

  void _drawWaterStream(
    Canvas canvas,
    double spoutX,
    double spoutY,
    double animValue,
  ) {
    final paint = Paint()
      ..color = Colors.blueAccent.withOpacity(0.6)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 4; i++) {
      double offset = (animValue * 3 + i * 0.25) % 1.0;
      double dropX = spoutX + 35 + (offset * 10);
      double dropY = spoutY + 40 + (offset * 60);
      if (dropY < spoutY + 110) {
        canvas.drawLine(
          Offset(dropX, dropY),
          Offset(dropX + 2, dropY + 5),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PlantPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.wateringAnimValue != wateringAnimValue ||
        oldDelegate.isCompleted != isCompleted;
  }
}
