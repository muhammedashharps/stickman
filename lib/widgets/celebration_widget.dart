import 'dart:math';
import 'package:flutter/material.dart';

class CelebrationWidget extends StatefulWidget {
  final bool isPlaying;

  const CelebrationWidget({super.key, required this.isPlaying});

  @override
  State<CelebrationWidget> createState() => _CelebrationWidgetState();
}

class _CelebrationWidgetState extends State<CelebrationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_ConfettiParticle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..addListener(() {
            if (mounted) setState(() {});
          });

    if (widget.isPlaying) {
      _startCelebration();
    }
  }

  @override
  void didUpdateWidget(CelebrationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !oldWidget.isPlaying) {
      _startCelebration();
    }
  }

  void _startCelebration() {
    _particles.clear();
    // Spawn particles
    for (int i = 0; i < 50; i++) {
      _particles.add(_createParticle());
    }
    _controller.forward(from: 0);
  }

  _ConfettiParticle _createParticle() {
    final color = Color.fromRGBO(
      _random.nextInt(256),
      _random.nextInt(256),
      _random.nextInt(256),
      1,
    );
    return _ConfettiParticle(
      color: color,
      x: 0.5, // Center
      y: 0.8, // Bottomish
      vx: (_random.nextDouble() - 0.5) * 0.8, // Random X velocity
      vy: -1.0 - (_random.nextDouble() * 1.0), // Upward velocity
      size: 5 + _random.nextDouble() * 5,
      angle: _random.nextDouble() * 2 * pi,
      spin: (_random.nextDouble() - 0.5) * 0.2,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.isAnimating && _controller.isCompleted) {
      return const SizedBox.shrink();
    }

    return IgnorePointer(
      child: CustomPaint(
        painter: _ConfettiPainter(
          particles: _particles,
          progress: _controller.value,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _ConfettiParticle {
  Color color;
  double x; // 0-1
  double y; // 0-1
  double vx;
  double vy;
  double size;
  double angle;
  double spin;

  _ConfettiParticle({
    required this.color,
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.angle,
    required this.spin,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress;

  _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final dt = 0.016; // Approx delta time

    for (var p in particles) {
      // Physics
      p.x += p.vx * dt;
      p.y += p.vy * dt;
      p.vy += 2.0 * dt; // Gravity
      p.angle += p.spin;

      // Draw
      final paint = Paint()..color = p.color;

      canvas.save();
      canvas.translate(p.x * w, p.y * h);
      canvas.rotate(p.angle);

      // Draw Rect or Circle
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: p.size,
          height: p.size * 0.6,
        ),
        paint,
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}
