// ignore_for_file: deprecated_member_use
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/custom_animation.dart';

/// Renders custom AI-generated animations using CustomPaint
class CustomAnimationRenderer extends StatefulWidget {
  final AnimationConfig config;
  final bool autoPlay;

  const CustomAnimationRenderer({
    super.key,
    required this.config,
    this.autoPlay = true,
  });

  @override
  State<CustomAnimationRenderer> createState() =>
      _CustomAnimationRendererState();
}

class _CustomAnimationRendererState extends State<CustomAnimationRenderer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.config.durationMs),
    );
    if (widget.autoPlay) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(CustomAnimationRenderer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.config != widget.config) {
      _controller.duration = Duration(milliseconds: widget.config.durationMs);
      if (widget.autoPlay) {
        _controller.repeat();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: AnimationPainter(
            config: widget.config,
            progress: _controller.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

/// Custom painter for rendering animation elements
class AnimationPainter extends CustomPainter {
  final AnimationConfig config;
  final double progress;

  AnimationPainter({required this.config, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    // Draw background
    final bgColor = _parseColor(config.backgroundColor);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = bgColor,
    );

    // Draw each element
    for (final element in config.elements) {
      _drawElement(canvas, size, element);
    }
  }

  void _drawElement(Canvas canvas, Size size, AnimationElement element) {
    // Calculate current position based on movements
    double x = element.initialX * size.width;
    double y = element.initialY * size.height;
    double scale = element.scale;
    double rotation = element.rotation;
    double opacity = 1.0;

    // Apply movements
    for (final movement in element.movements) {
      if (progress >= movement.startTime && progress <= movement.endTime) {
        final movementProgress =
            (progress - movement.startTime) /
            (movement.endTime - movement.startTime);
        final value = _lerp(
          movement.startValue,
          movement.endValue,
          movementProgress,
        );

        switch (movement.type) {
          case MovementType.linear:
            if (movement.axis == 'x') x = value * size.width;
            if (movement.axis == 'y') y = value * size.height;
            break;
          case MovementType.wave:
            final waveValue = math.sin(movementProgress * math.pi * 4) * 0.1;
            if (movement.axis == 'y') y += waveValue * size.height;
            if (movement.axis == 'x') x += waveValue * size.width;
            break;
          case MovementType.bounce:
            final bounceValue =
                (1 - math.pow(1 - movementProgress, 2).abs()) *
                (movement.endValue - movement.startValue);
            if (movement.axis == 'y') {
              y = (movement.startValue + bounceValue) * size.height;
            }
            break;
          case MovementType.rotate:
            rotation = _lerp(
              movement.startValue,
              movement.endValue,
              movementProgress,
            );
            break;
          case MovementType.scale:
            scale = _lerp(
              movement.startValue,
              movement.endValue,
              movementProgress,
            );
            break;
          case MovementType.fade:
            opacity = _lerp(
              movement.startValue,
              movement.endValue,
              movementProgress,
            );
            break;
          case MovementType.walk:
          case MovementType.run:
            if (movement.axis == 'x') x = value * size.width;
            if (movement.axis == 'y') y = value * size.height;
            break;
          case MovementType.jump:
            if (movementProgress < 0.5) {
              y -= math.sin(movementProgress * math.pi) * 0.15 * size.height;
            } else {
              y -= math.sin(movementProgress * math.pi) * 0.15 * size.height;
            }
            if (movement.axis == 'x') x = value * size.width;
            break;
        }
      }
    }

    // Save canvas state
    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(rotation * math.pi / 180);
    canvas.scale(scale);

    final paint = Paint()
      ..color = _parseColor(element.color).withOpacity(opacity)
      ..strokeWidth = element.strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw based on element type
    switch (element.type) {
      case ElementType.stickman:
        _drawStickman(canvas, paint, element, progress);
        break;
      case ElementType.circle:
        _drawCircle(canvas, paint, element);
        break;
      case ElementType.rectangle:
        _drawRectangle(canvas, paint, element);
        break;
      case ElementType.line:
        _drawLine(canvas, paint, element);
        break;
      case ElementType.tree:
        _drawTree(canvas, paint, element);
        break;
      case ElementType.sun:
        _drawSun(canvas, paint, element);
        break;
      case ElementType.moon:
        _drawMoon(canvas, paint, element);
        break;
      case ElementType.star:
        _drawStar(canvas, paint, element);
        break;
      case ElementType.cloud:
        _drawCloud(canvas, paint, element);
        break;
      case ElementType.mountain:
        _drawMountain(canvas, paint, element);
        break;
      case ElementType.wave:
        _drawWave(canvas, paint, element, progress);
        break;
      case ElementType.text:
        _drawText(canvas, element);
        break;
    }

    canvas.restore();
  }

  void _drawStickman(
    Canvas canvas,
    Paint paint,
    AnimationElement element,
    double progress,
  ) {
    final pose = element.properties['pose'] ?? 'standing';

    // Body proportions
    const headRadius = 15.0;
    const bodyLength = 40.0;
    const armLength = 25.0;
    const legLength = 35.0;

    // Calculate walking animation offset
    double legOffset = 0;
    double armOffset = 0;
    bool isAnimated = element.movements.any(
      (m) =>
          m.type == MovementType.walk ||
          m.type == MovementType.run ||
          m.type == MovementType.jump,
    );

    if (isAnimated) {
      legOffset = math.sin(progress * math.pi * 8) * 20;
      armOffset = math.sin(progress * math.pi * 8 + math.pi) * 15;
    }

    // Head
    canvas.drawCircle(Offset(0, -bodyLength - headRadius), headRadius, paint);

    // Body
    canvas.drawLine(Offset(0, -bodyLength), const Offset(0, 0), paint);

    // Arms
    if (pose == 'waving') {
      // Left arm normal
      canvas.drawLine(
        Offset(0, -bodyLength + 10),
        Offset(-armLength, -bodyLength + 20),
        paint,
      );
      // Right arm waving
      final waveAngle = math.sin(progress * math.pi * 4) * 0.3;
      canvas.drawLine(
        Offset(0, -bodyLength + 10),
        Offset(
          armLength * math.cos(-0.5 + waveAngle),
          -bodyLength - armLength * math.sin(-0.5 + waveAngle),
        ),
        paint,
      );
    } else {
      // Left arm
      canvas.drawLine(
        Offset(0, -bodyLength + 10),
        Offset(-armLength, -bodyLength + 20 + armOffset),
        paint,
      );
      // Right arm
      canvas.drawLine(
        Offset(0, -bodyLength + 10),
        Offset(armLength, -bodyLength + 20 - armOffset),
        paint,
      );
    }

    // Legs
    if (pose == 'sitting') {
      // Sitting legs
      canvas.drawLine(const Offset(0, 0), const Offset(-20, 20), paint);
      canvas.drawLine(const Offset(0, 0), const Offset(20, 20), paint);
    } else {
      // Left leg
      canvas.drawLine(
        const Offset(0, 0),
        Offset(-15 + legOffset * 0.5, legLength),
        paint,
      );
      // Right leg
      canvas.drawLine(
        const Offset(0, 0),
        Offset(15 - legOffset * 0.5, legLength),
        paint,
      );
    }
  }

  void _drawCircle(Canvas canvas, Paint paint, AnimationElement element) {
    final radius = (element.properties['radius'] ?? 20.0).toDouble();
    final filled = element.properties['filled'] ?? false;
    if (filled) paint.style = PaintingStyle.fill;
    canvas.drawCircle(Offset.zero, radius, paint);
  }

  void _drawRectangle(Canvas canvas, Paint paint, AnimationElement element) {
    final width = (element.properties['width'] ?? 40.0).toDouble();
    final height = (element.properties['height'] ?? 30.0).toDouble();
    final filled = element.properties['filled'] ?? false;
    if (filled) paint.style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromCenter(center: Offset.zero, width: width, height: height),
      paint,
    );
  }

  void _drawLine(Canvas canvas, Paint paint, AnimationElement element) {
    final x2 = (element.properties['endX'] ?? 50.0).toDouble();
    final y2 = (element.properties['endY'] ?? 0.0).toDouble();
    canvas.drawLine(Offset.zero, Offset(x2, y2), paint);
  }

  void _drawTree(Canvas canvas, Paint paint, AnimationElement element) {
    // Trunk
    final trunkPaint = Paint()
      ..color = const Color(0xFF8B4513)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(0, 0), const Offset(0, 50), trunkPaint);

    // Leaves (triangle)
    final leavesPaint = Paint()
      ..color = _parseColor(element.color)
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(0, -50)
      ..lineTo(-30, 0)
      ..lineTo(30, 0)
      ..close();
    canvas.drawPath(path, leavesPaint);
  }

  void _drawSun(Canvas canvas, Paint paint, AnimationElement element) {
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(Offset.zero, 25, paint);

    // Rays
    paint.style = PaintingStyle.stroke;
    for (int i = 0; i < 8; i++) {
      final angle = i * math.pi / 4;
      canvas.drawLine(
        Offset(math.cos(angle) * 30, math.sin(angle) * 30),
        Offset(math.cos(angle) * 45, math.sin(angle) * 45),
        paint,
      );
    }
  }

  void _drawMoon(Canvas canvas, Paint paint, AnimationElement element) {
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(Offset.zero, 25, paint);
    // Crescent effect
    final bgPaint = Paint()..color = _parseColor(config.backgroundColor);
    canvas.drawCircle(const Offset(10, -5), 20, bgPaint);
  }

  void _drawStar(Canvas canvas, Paint paint, AnimationElement element) {
    paint.style = PaintingStyle.fill;
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final angle = (i * 144 - 90) * math.pi / 180;
      if (i == 0) {
        path.moveTo(math.cos(angle) * 20, math.sin(angle) * 20);
      } else {
        path.lineTo(math.cos(angle) * 20, math.sin(angle) * 20);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawCloud(Canvas canvas, Paint paint, AnimationElement element) {
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(-20, 0), 15, paint);
    canvas.drawCircle(const Offset(0, -5), 20, paint);
    canvas.drawCircle(const Offset(20, 0), 15, paint);
    canvas.drawCircle(const Offset(0, 10), 15, paint);
  }

  void _drawMountain(Canvas canvas, Paint paint, AnimationElement element) {
    paint.style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(0, -50)
      ..lineTo(-50, 30)
      ..lineTo(50, 30)
      ..close();
    canvas.drawPath(path, paint);

    // Snow cap
    final snowPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final snowPath = Path()
      ..moveTo(0, -50)
      ..lineTo(-15, -20)
      ..lineTo(15, -20)
      ..close();
    canvas.drawPath(snowPath, snowPaint);
  }

  void _drawWave(
    Canvas canvas,
    Paint paint,
    AnimationElement element,
    double progress,
  ) {
    final path = Path();
    path.moveTo(-100, 0);
    for (double x = -100; x <= 100; x += 5) {
      final y = math.sin((x / 20) + progress * math.pi * 2) * 15;
      path.lineTo(x, y);
    }
    canvas.drawPath(path, paint);
  }

  void _drawText(Canvas canvas, AnimationElement element) {
    final textContent = element.properties['content'] ?? 'Text';
    final textPainter = TextPainter(
      text: TextSpan(
        text: textContent,
        style: TextStyle(
          color: _parseColor(element.color),
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(-textPainter.width / 2, -textPainter.height / 2),
    );
  }

  Color _parseColor(String hex) {
    try {
      final colorStr = hex.replaceAll('#', '');
      return Color(int.parse('FF$colorStr', radix: 16));
    } catch (e) {
      return Colors.white;
    }
  }

  double _lerp(double a, double b, double t) => a + (b - a) * t;

  @override
  bool shouldRepaint(AnimationPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.config != config;
}
