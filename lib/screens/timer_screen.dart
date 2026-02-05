import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/timer_provider.dart';
import '../providers/statistics_provider.dart';
import '../providers/animation_creator_provider.dart';
import '../models/focus_session.dart';
import '../models/ai_animation_config.dart';
import '../theme/app_theme.dart';
import '../widgets/plant_growth_widget.dart';
import '../widgets/animation_widgets.dart';
import '../widgets/ai_animation_widget.dart';
import '../widgets/celebration_widget.dart';
import 'package:flutter/services.dart';
import '../utils/format_utils.dart';

class TimerScreen extends StatefulWidget {
  final Function(bool visible) onToggleNavigation;
  const TimerScreen({super.key, required this.onToggleNavigation});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  AnimationScenario? _selectedScenario;
  AIAnimationConfig? _selectedCustomAnimation;
  bool _sessionSaved = false;
  String? _sessionName;

  void _saveSession(TimerProvider timer) {
    if (_sessionSaved) return;
    if (_selectedScenario == null && _selectedCustomAnimation == null) return;

    final scenarioName =
        _selectedCustomAnimation?.name ??
        _selectedScenario?.description ??
        'Focus Session';
    final session = FocusSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      scenario: _sessionName ?? scenarioName,
      durationSeconds: timer.totalDuration - timer.remainingTime,
      completedAt: DateTime.now(),
      wasCompleted: timer.isCompleted,
    );

    context.read<StatisticsProvider>().addSession(session);
    _sessionSaved = true;
  }

  Future<void> _showSessionNameDialog(TimerProvider timer) async {
    final controller = TextEditingController();
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          // Added scroll view
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textGrey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Name Your Session',
                style: GoogleFonts.outfit(
                  color: AppColors.textWhite,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'What will you be working on?',
                style: TextStyle(color: AppColors.textGrey, fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'e.g., Study Math, Work on Project...',
                  hintStyle: TextStyle(
                    color: AppColors.textGrey.withValues(alpha: 0.5),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.surfaceLight),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.accent),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final name = controller.text.trim();
                        Navigator.pop(context, name.isEmpty ? null : name);
                      },
                      child: const Text('Start Focus'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (result != null || result == null) {
      // User pressed Start (with or without name)
      if (mounted) {
        setState(() => _sessionName = result);
        timer.start();
      }
    }
  }

  Widget _buildAnimationWidget(TimerProvider timer) {
    // If a custom animation is selected, render it
    if (_selectedCustomAnimation != null) {
      return AIAnimationWidget(
        config: _selectedCustomAnimation!,
        progress: timer.progress,
        isRunning: timer.isRunning,
        isCompleted: timer.isCompleted,
      );
    }

    if (_selectedScenario == null) return const SizedBox();
    switch (_selectedScenario!) {
      case AnimationScenario.plantGrowth:
        return PlantGrowthWidget(
          progress: timer.progress,
          isRunning: timer.isRunning,
          isCompleted: timer.isCompleted,
        );
      case AnimationScenario.mountainClimb:
        return MountainClimbWidget(
          progress: timer.progress,
          isRunning: timer.isRunning,
          isCompleted: timer.isCompleted,
        );
      case AnimationScenario.bulbLadder:
        return BulbLadderWidget(
          progress: timer.progress,
          isRunning: timer.isRunning,
          isCompleted: timer.isCompleted,
        );
      case AnimationScenario.bridgeBuilder:
        return BridgeBuilderWidget(
          progress: timer.progress,
          isRunning: timer.isRunning,
          isCompleted: timer.isCompleted,
        );
      case AnimationScenario.cliffClimb:
        return CliffClimbWidget(
          progress: timer.progress,
          isRunning: timer.isRunning,
          isCompleted: timer.isCompleted,
        );
      case AnimationScenario.waterTank:
        return WaterTankWidget(
          progress: timer.progress,
          isRunning: timer.isRunning,
          isCompleted: timer.isCompleted,
        );
    }
  }

  Widget _buildPreviewWidget(AnimationScenario scenario) {
    switch (scenario) {
      case AnimationScenario.plantGrowth:
        return const PlantGrowthWidget(
          progress: 0.3,
          isRunning: false,
          isCompleted: false,
        );
      case AnimationScenario.mountainClimb:
        return const MountainClimbWidget(
          progress: 0.3,
          isRunning: false,
          isCompleted: false,
        );
      case AnimationScenario.bulbLadder:
        return const BulbLadderWidget(
          progress: 0.3,
          isRunning: false,
          isCompleted: false,
        );
      case AnimationScenario.bridgeBuilder:
        return const BridgeBuilderWidget(
          progress: 0.3,
          isRunning: false,
          isCompleted: false,
        );
      case AnimationScenario.cliffClimb:
        return const CliffClimbWidget(
          progress: 0.3,
          isRunning: false,
          isCompleted: false,
        );
      case AnimationScenario.waterTank:
        return const WaterTankWidget(
          progress: 0.3,
          isRunning: false,
          isCompleted: false,
        );
    }
  }

  // HOME PAGE
  Widget _buildHomePage() {
    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      appBar: AppBar(
        title: Text(
          'Animations',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Container
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.surfaceLight, AppColors.surfaceDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome to Stickman Productivity',
                      style: GoogleFonts.outfit(
                        color: AppColors.accent,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Select a companion below to accompany you while you focus',
                      style: TextStyle(
                        color: AppColors.textWhite.withValues(alpha: 0.8),
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Choose Your Activity',
                style: GoogleFonts.outfit(
                  color: AppColors.textWhite,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                itemCount: AnimationScenario.values.length,
                itemBuilder: (context, index) {
                  final scenario = AnimationScenario.values[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedScenario = scenario);
                      widget.onToggleNavigation(false); // Hide Bottom Nav
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.surfaceDark,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                              child: Container(
                                width: double.infinity,
                                color: AppColors.backgroundBlack,
                                child: FittedBox(
                                  fit: BoxFit.contain,
                                  child: SizedBox(
                                    width: 200,
                                    height: 150,
                                    child: IgnorePointer(
                                      child: _buildPreviewWidget(scenario),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceDark,
                              borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(16),
                              ),
                            ),
                            child: Text(
                              scenario.description,
                              style: GoogleFonts.outfit(
                                color: AppColors.textWhite,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              // Custom Animations Section
              Consumer<AnimationCreatorProvider>(
                builder: (context, animProvider, _) {
                  if (animProvider.animations.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      Text(
                        'Your Creations',
                        style: GoogleFonts.outfit(
                          color: AppColors.textWhite,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.85,
                            ),
                        itemCount: animProvider.animations.length,
                        itemBuilder: (context, index) {
                          final customAnim = animProvider.animations[index];
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedScenario = null;
                                _selectedCustomAnimation = customAnim;
                              });
                              widget.onToggleNavigation(false);
                            },
                            onLongPress: () {
                              // Show delete option
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  backgroundColor: AppColors.surfaceDark,
                                  title: Text(
                                    'Delete Animation?',
                                    style: GoogleFonts.outfit(
                                      color: Colors.white,
                                    ),
                                  ),
                                  content: Text(
                                    'Are you sure you want to delete "${customAnim.name}"?',
                                    style: GoogleFonts.outfit(
                                      color: Colors.white70,
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        animProvider.deleteAnimation(
                                          customAnim.id,
                                        );
                                        Navigator.pop(ctx);
                                      },
                                      child: const Text(
                                        'Delete',
                                        style: TextStyle(
                                          color: Colors.redAccent,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.surfaceLight,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppColors.accent.withValues(
                                    alpha: 0.3,
                                  ),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(16),
                                      ),
                                      child: Container(
                                        width: double.infinity,
                                        color: AppColors.backgroundBlack,
                                        child: AIAnimationWidget(
                                          config: customAnim,
                                          progress: 0.5,
                                          isRunning: true,
                                          isCompleted: false,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceDark,
                                      borderRadius: const BorderRadius.vertical(
                                        bottom: Radius.circular(16),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.auto_awesome,
                                          color: AppColors.accent,
                                          size: 14,
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            customAnim.name,
                                            style: GoogleFonts.outfit(
                                              color: AppColors.textWhite,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // TIMER PAGE
  Widget _buildTimerPage() {
    return Consumer<TimerProvider>(
      builder: (context, timer, child) {
        final bool canGoBack =
            (!timer.isRunning && timer.progress == 0) || timer.isCompleted;

        // Save session when completed
        if (timer.isCompleted && !_sessionSaved) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _saveSession(timer),
          );
        }

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;

            if (canGoBack) {
              // Reset timer and go back
              timer.reset();
              setState(() {
                _selectedScenario = null;
                _selectedCustomAnimation = null;
                _sessionSaved = false;
                _sessionName = null;
              });
              widget.onToggleNavigation(true);
            }
          },
          child: Scaffold(
            backgroundColor: AppColors.backgroundBlack,
            body: SafeArea(
              child: Stack(
                children: [
                  // Main Content
                  Column(
                    children: [
                      // Animation Area
                      Expanded(
                        flex: 5,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              KeyedSubtree(
                                key: ValueKey(
                                  _selectedCustomAnimation?.id ??
                                      _selectedScenario,
                                ),
                                child: _buildAnimationWidget(timer),
                              ),
                              CelebrationWidget(isPlaying: timer.isCompleted),
                            ],
                          ),
                        ),
                      ),

                      // Timer Display & Controls
                      Container(
                        decoration: const BoxDecoration(
                          color: AppColors.surfaceDark,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(30),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black45,
                              blurRadius: 20,
                              offset: Offset(0, -5),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Timer Text
                            Text(
                              timer.displayTime,
                              style: GoogleFonts.outfit(
                                fontSize: 64,
                                fontWeight: FontWeight.bold,
                                color: timer.isRunning
                                    ? AppColors.accent
                                    : AppColors.textWhite,
                                shadows: timer.isRunning
                                    ? [
                                        const BoxShadow(
                                          color: Color(0x40FF5252),
                                          blurRadius: 20,
                                        ),
                                      ]
                                    : [],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Duration Selectors (only before starting)
                            if (!timer.isRunning && timer.progress == 0)
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _CustomDurationChip(),
                                    const SizedBox(width: 12),
                                    _DurationChip(minutes: 15),
                                    const SizedBox(width: 12),
                                    _DurationChip(minutes: 25),
                                    const SizedBox(width: 12),
                                    _DurationChip(minutes: 45),
                                    const SizedBox(width: 12),
                                    _DurationChip(minutes: 60),
                                  ],
                                ),
                              ),
                            const SizedBox(height: 20),

                            // Controls
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (!timer.isRunning && !timer.isCompleted)
                                  if (timer.remainingTime < timer.totalDuration)
                                    ElevatedButton(
                                      onPressed: timer.start,
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 40,
                                          vertical: 16,
                                        ),
                                        backgroundColor: AppColors.accent,
                                        foregroundColor: Colors.white,
                                      ),
                                      child: const Text(
                                        "RESUME",
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    )
                                  else
                                    ElevatedButton(
                                      onPressed: () =>
                                          _showSessionNameDialog(timer),
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 40,
                                          vertical: 16,
                                        ),
                                      ),
                                      child: const Text(
                                        "START FOCUS",
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    )
                                else if (timer.isRunning)
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.surfaceLight,
                                      foregroundColor: AppColors.textWhite,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 40,
                                        vertical: 16,
                                      ),
                                    ),
                                    onPressed: timer.pause,
                                    child: const Text(
                                      "PAUSE",
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  )
                                else if (timer.isCompleted)
                                  ElevatedButton(
                                    onPressed: () {
                                      timer.reset();
                                      setState(() {
                                        _selectedScenario = null;
                                        _sessionSaved = false;
                                        _sessionName = null;
                                      });
                                      widget.onToggleNavigation(true);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 40,
                                        vertical: 16,
                                      ),
                                    ),
                                    child: const Text(
                                      "NEW SESSION",
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),

                                if (!timer.isRunning &&
                                    timer.remainingTime !=
                                        timer.totalDuration) ...[
                                  const SizedBox(width: 16),
                                  OutlinedButton(
                                    onPressed: timer.reset,
                                    child: const Icon(Icons.refresh),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // Floating Back Button
                  if (canGoBack)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.surfaceDark.withValues(alpha: 0.8),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: AppColors.textWhite,
                          ),
                          onPressed: () {
                            timer.reset(); // Reset on back
                            setState(() {
                              _selectedScenario = null;
                              _selectedCustomAnimation = null;
                              _sessionName = null;
                              _sessionSaved = false;
                            });
                            widget.onToggleNavigation(true);
                          },
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedScenario == null && _selectedCustomAnimation == null) {
      return _buildHomePage();
    } else {
      return _buildTimerPage();
    }
  }
}

class _DurationChip extends StatelessWidget {
  final int minutes;
  const _DurationChip({required this.minutes});

  @override
  Widget build(BuildContext context) {
    return Consumer<TimerProvider>(
      builder: (context, timer, _) {
        final isSelected = timer.totalDuration == minutes * 60;
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => timer.setDuration(minutes),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.accent.withValues(alpha: 0.2)
                    : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.accent : Colors.transparent,
                ),
              ),
              child: Text(
                formatDuration(minutes),
                style: TextStyle(
                  color: isSelected ? AppColors.accent : AppColors.textGrey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CustomDurationChip extends StatelessWidget {
  const _CustomDurationChip();

  void _showDurationPicker(BuildContext context, TimerProvider timer) {
    int selectedMinutes = timer.totalDuration ~/ 60;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          height: MediaQuery.of(context).size.height * 0.55,
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(
              color: AppColors.accent.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textGrey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Title
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Set Focus Duration',
                  style: GoogleFonts.outfit(
                    color: AppColors.textWhite,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Quick preset pills
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [15, 25, 30, 45, 60, 90, 120].map((mins) {
                    final isSelected = selectedMinutes == mins;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: GestureDetector(
                        onTap: () => setState(() => selectedMinutes = mins),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.accent
                                : AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: AppColors.accent.withValues(
                                        alpha: 0.4,
                                      ),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Text(
                            formatDuration(mins),
                            style: GoogleFonts.outfit(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textGrey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 24),

              // Wheel picker
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Selection highlight
                    Container(
                      height: 60,
                      margin: const EdgeInsets.symmetric(horizontal: 40),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.accent.withValues(alpha: 0.5),
                        ),
                      ),
                    ),

                    // Wheel
                    ListWheelScrollView.useDelegate(
                      itemExtent: 60,
                      perspective: 0.003,
                      diameterRatio: 1.5,
                      physics: const FixedExtentScrollPhysics(),
                      controller: FixedExtentScrollController(
                        initialItem: selectedMinutes - 1,
                      ),
                      onSelectedItemChanged: (index) {
                        setState(() => selectedMinutes = index + 1);
                      },
                      childDelegate: ListWheelChildBuilderDelegate(
                        childCount: 180,
                        builder: (context, index) {
                          final mins = index + 1;
                          final isCenter = mins == selectedMinutes;
                          return Center(
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 200),
                              style: GoogleFonts.outfit(
                                fontSize: isCenter ? 32 : 22,
                                fontWeight: isCenter
                                    ? FontWeight.bold
                                    : FontWeight.w400,
                                color: isCenter
                                    ? AppColors.accent
                                    : AppColors.textGrey.withValues(alpha: 0.5),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text('$mins'),
                                  const SizedBox(width: 8),
                                  Text(
                                    'min',
                                    style: GoogleFonts.outfit(
                                      fontSize: isCenter ? 16 : 14,
                                      color: isCenter
                                          ? AppColors.textGrey
                                          : AppColors.textGrey.withValues(
                                              alpha: 0.4,
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Set button
              Padding(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      timer.setDuration(selectedMinutes);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 8,
                      shadowColor: AppColors.accent.withValues(alpha: 0.5),
                    ),
                    child: Text(
                      'Start ${formatDuration(selectedMinutes)} Session',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TimerProvider>(
      builder: (context, timer, _) {
        final presets = [15, 25, 45, 60];
        final currentMin = timer.totalDuration ~/ 60;
        final isCustom = !presets.contains(currentMin);

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showDurationPicker(context, timer),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: isCustom
                    ? AppColors.accent.withValues(alpha: 0.2)
                    : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isCustom ? AppColors.accent : Colors.transparent,
                ),
              ),
              child: Text(
                isCustom ? formatDuration(currentMin) : 'Custom',
                style: TextStyle(
                  color: isCustom ? AppColors.accent : AppColors.textGrey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
