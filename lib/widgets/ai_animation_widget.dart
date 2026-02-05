import 'dart:math';
import 'package:flutter/material.dart';
import '../models/ai_animation_config.dart';
import '../theme/app_theme.dart';

/// Renders dynamic shapes defined by Gemini
class AIAnimationWidget extends StatefulWidget {
  final AIAnimationConfig config;
  final double progress;
  final bool isRunning;
  final bool isCompleted;

  const AIAnimationWidget({
    super.key,
    required this.config,
    required this.progress,
    required this.isRunning,
    required this.isCompleted,
  });

  @override
  State<AIAnimationWidget> createState() => _AIAnimationWidgetState();
}

class _AIAnimationWidgetState extends State<AIAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // Standard cycle
    );
    if (widget.isRunning) _animController.repeat();
  }

  @override
  void didUpdateWidget(AIAnimationWidget old) {
    super.didUpdateWidget(old);
    if (widget.isRunning != old.isRunning) {
      if (widget.isRunning) {
        _animController.repeat();
      } else {
        _animController.stop();
      }
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _parseColor(widget.config.backgroundColor),
      child: AnimatedBuilder(
        animation: _animController,
        builder: (_, child) => CustomPaint(
          painter: _DynamicShapePainter(
            config: widget.config,
            progress: widget.progress,
            isCompleted: widget.isCompleted,
            animValue: _animController.value,
          ),
          size: const Size(double.infinity, 300),
        ),
      ),
    );
  }

  Color _parseColor(String hexString) {
    try {
      final hex = hexString.replaceAll('#', '');
      if (hex.length == 6) {
        return Color(int.parse('FF$hex', radix: 16));
      } else if (hex.length == 8) {
        return Color(int.parse(hex, radix: 16));
      }
      return AppColors.backgroundBlack;
    } catch (_) {
      return AppColors.backgroundBlack;
    }
  }
}

class _DynamicShapePainter extends CustomPainter {
  final AIAnimationConfig config;
  final double progress;
  final bool isCompleted;
  final double animValue;

  _DynamicShapePainter({
    required this.config,
    required this.progress,
    required this.isCompleted,
    required this.animValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    for (final element in config.elements) {
      _drawElement(canvas, element, w, h);
    }
  }

  void _drawElement(Canvas canvas, DynamicElement element, double w, double h) {
    final paint = Paint()
      ..color = _parseColor(element.color)
      ..style = element.filled ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = element.strokeWidth;

    if (element is CircleElement) {
      double cx = _animate(element, 'cx', element.cx);
      double cy = _animate(element, 'cy', element.cy);
      double r = _animate(element, 'r', element.r);

      canvas.drawCircle(Offset(cx * w, cy * h), r * min(w, h), paint);
    } else if (element is LineElement) {
      double x1 = _animate(element, 'x1', element.x1);
      double y1 = _animate(element, 'y1', element.y1);
      double x2 = _animate(element, 'x2', element.x2);
      double y2 = _animate(element, 'y2', element.y2);

      canvas.drawLine(Offset(x1 * w, y1 * h), Offset(x2 * w, y2 * h), paint);
    } else if (element is RectElement) {
      double x = _animate(element, 'x', element.x);
      double y = _animate(element, 'y', element.y);
      double rw = _animate(element, 'w', element.w);
      double rh = _animate(element, 'h', element.h);

      canvas.drawRect(Rect.fromLTWH(x * w, y * h, rw * w, rh * h), paint);
    }
  }

  double _animate(DynamicElement element, String property, double baseValue) {
    double value = baseValue;

    for (final anim in element.animations) {
      if (anim.property == property) {
        double delta = 0;

        if (anim.type == 'sine') {
          // Sine wave based on time (animValue 0->1)
          // Use speed as frequency multiplier
          delta = sin(animValue * 2 * pi * anim.speed) * anim.magnitude;
        } else if (anim.type == 'linear') {
          // Linear progression based on time
          double t = (animValue * anim.speed) % 1.0;
          delta = t * anim.magnitude; // Moves from 0 to magnitude
        } else if (anim.type == 'progress') {
          // Based on TIMER progress (0--->1)
          delta = progress * anim.magnitude;
        } else if (anim.type == 'pulse') {
          // Smooth pulse
          delta = (sin(animValue * 2 * pi * anim.speed).abs()) * anim.magnitude;
        }

        value += delta;
      }
    }
    return value;
  }

  Color _parseColor(String hexString) {
    try {
      final hex = hexString.replaceAll('#', '');
      if (hex.length == 6) {
        return Color(int.parse('FF$hex', radix: 16));
      }
      return Colors.white;
    } catch (_) {
      return Colors.white;
    }
  }

  @override
  bool shouldRepaint(covariant _DynamicShapePainter old) {
    return old.progress != progress || old.animValue != animValue;
  }
}
