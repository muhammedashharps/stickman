import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// Beautiful loading screen for animation generation/refinement
class GeneratingScreen extends StatefulWidget {
  final bool isRefining;

  const GeneratingScreen({super.key, this.isRefining = false});

  @override
  State<GeneratingScreen> createState() => _GeneratingScreenState();
}

class _GeneratingScreenState extends State<GeneratingScreen>
    with SingleTickerProviderStateMixin {
  int _messageIndex = 0;
  int _poseIndex = 0;
  Timer? _messageTimer;
  Timer? _poseTimer;

  final List<String> _generatingMessages = [
    'Sketching your stickman...',
    'Adding personality...',
    'Crafting the animation...',
    'Making it come alive...',
    'Almost there...',
  ];

  final List<String> _refiningMessages = [
    'Understanding your changes...',
    'Adjusting the animation...',
    'Fine-tuning details...',
    'Polishing the result...',
    'Almost done...',
  ];

  List<String> get _messages =>
      widget.isRefining ? _refiningMessages : _generatingMessages;

  @override
  void initState() {
    super.initState();

    // Cycle through messages every 2 seconds
    _messageTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (mounted) {
        setState(() {
          _messageIndex = (_messageIndex + 1) % _messages.length;
        });
      }
    });

    // Cycle through poses every 800ms
    _poseTimer = Timer.periodic(const Duration(milliseconds: 800), (_) {
      if (mounted) {
        setState(() {
          _poseIndex = (_poseIndex + 1) % 5; // 5 different poses
        });
      }
    });
  }

  @override
  void dispose() {
    _messageTimer?.cancel();
    _poseTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Stickman - cycles through poses
            Container(
              width: 120,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.accent.withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: CustomPaint(
                    key: ValueKey<int>(_poseIndex),
                    size: const Size(80, 100),
                    painter: _StickmanPosePainter(pose: _poseIndex),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Title
            Text(
              widget.isRefining ? 'Refining Animation' : 'Creating Animation',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            // Rotating message
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: Text(
                _messages[_messageIndex],
                key: ValueKey<int>(_messageIndex),
                style: GoogleFonts.outfit(
                  color: AppColors.textGrey,
                  fontSize: 16,
                ),
              ),
            ),

            const SizedBox(height: 48),

            // Progress indicator
            SizedBox(
              width: 200,
              child: LinearProgressIndicator(
                backgroundColor: AppColors.surfaceLight,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                minHeight: 4,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Paints stickman in different poses
class _StickmanPosePainter extends CustomPainter {
  final int pose;

  _StickmanPosePainter({required this.pose});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.accent
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final cx = size.width / 2;
    final headY = 15.0;
    final headRadius = 12.0;
    final bodyTop = headY + headRadius;
    final bodyBottom = bodyTop + 35;

    // Head (always same)
    canvas.drawCircle(Offset(cx, headY), headRadius, paint);

    switch (pose) {
      case 0: // Standing pose
        // Body
        canvas.drawLine(Offset(cx, bodyTop), Offset(cx, bodyBottom), paint);
        // Arms down
        canvas.drawLine(
          Offset(cx, bodyTop + 10),
          Offset(cx - 20, bodyTop + 35),
          paint,
        );
        canvas.drawLine(
          Offset(cx, bodyTop + 10),
          Offset(cx + 20, bodyTop + 35),
          paint,
        );
        // Legs straight
        canvas.drawLine(
          Offset(cx, bodyBottom),
          Offset(cx - 15, bodyBottom + 35),
          paint,
        );
        canvas.drawLine(
          Offset(cx, bodyBottom),
          Offset(cx + 15, bodyBottom + 35),
          paint,
        );
        break;

      case 1: // Walking pose (mid-step)
        // Body
        canvas.drawLine(Offset(cx, bodyTop), Offset(cx, bodyBottom), paint);
        // Arms swinging
        canvas.drawLine(
          Offset(cx, bodyTop + 10),
          Offset(cx + 25, bodyTop + 25),
          paint,
        );
        canvas.drawLine(
          Offset(cx, bodyTop + 10),
          Offset(cx - 15, bodyTop + 30),
          paint,
        );
        // Legs walking
        canvas.drawLine(
          Offset(cx, bodyBottom),
          Offset(cx - 20, bodyBottom + 30),
          paint,
        );
        canvas.drawLine(
          Offset(cx, bodyBottom),
          Offset(cx + 18, bodyBottom + 35),
          paint,
        );
        break;

      case 2: // Sitting pose
        // Body (slightly shorter)
        canvas.drawLine(Offset(cx, bodyTop), Offset(cx, bodyBottom - 5), paint);
        // Arms on lap
        canvas.drawLine(
          Offset(cx, bodyTop + 15),
          Offset(cx - 18, bodyTop + 25),
          paint,
        );
        canvas.drawLine(
          Offset(cx, bodyTop + 15),
          Offset(cx + 18, bodyTop + 25),
          paint,
        );
        // Legs bent (sitting)
        canvas.drawLine(
          Offset(cx, bodyBottom - 5),
          Offset(cx - 25, bodyBottom + 5),
          paint,
        );
        canvas.drawLine(
          Offset(cx - 25, bodyBottom + 5),
          Offset(cx - 25, bodyBottom + 30),
          paint,
        );
        canvas.drawLine(
          Offset(cx, bodyBottom - 5),
          Offset(cx + 25, bodyBottom + 5),
          paint,
        );
        canvas.drawLine(
          Offset(cx + 25, bodyBottom + 5),
          Offset(cx + 25, bodyBottom + 30),
          paint,
        );
        break;

      case 3: // Arms raised (celebrating)
        // Body
        canvas.drawLine(Offset(cx, bodyTop), Offset(cx, bodyBottom), paint);
        // Arms raised up
        canvas.drawLine(
          Offset(cx, bodyTop + 8),
          Offset(cx - 22, bodyTop - 10),
          paint,
        );
        canvas.drawLine(
          Offset(cx, bodyTop + 8),
          Offset(cx + 22, bodyTop - 10),
          paint,
        );
        // Legs apart
        canvas.drawLine(
          Offset(cx, bodyBottom),
          Offset(cx - 18, bodyBottom + 35),
          paint,
        );
        canvas.drawLine(
          Offset(cx, bodyBottom),
          Offset(cx + 18, bodyBottom + 35),
          paint,
        );
        break;

      case 4: // Jumping pose
        // Body
        canvas.drawLine(
          Offset(cx, bodyTop - 5),
          Offset(cx, bodyBottom - 5),
          paint,
        );
        // Head higher
        canvas.drawCircle(Offset(cx, headY - 5), headRadius, paint);
        // Arms spread wide
        canvas.drawLine(
          Offset(cx, bodyTop + 5),
          Offset(cx - 28, bodyTop + 5),
          paint,
        );
        canvas.drawLine(
          Offset(cx, bodyTop + 5),
          Offset(cx + 28, bodyTop + 5),
          paint,
        );
        // Legs bent up (jumping)
        canvas.drawLine(
          Offset(cx, bodyBottom - 5),
          Offset(cx - 15, bodyBottom + 15),
          paint,
        );
        canvas.drawLine(
          Offset(cx - 15, bodyBottom + 15),
          Offset(cx - 25, bodyBottom + 5),
          paint,
        );
        canvas.drawLine(
          Offset(cx, bodyBottom - 5),
          Offset(cx + 15, bodyBottom + 15),
          paint,
        );
        canvas.drawLine(
          Offset(cx + 15, bodyBottom + 15),
          Offset(cx + 25, bodyBottom + 5),
          paint,
        );
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _StickmanPosePainter oldDelegate) =>
      oldDelegate.pose != pose;
}
