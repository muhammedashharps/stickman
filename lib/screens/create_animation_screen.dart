// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/animation_creator_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/ai_animation_widget.dart';
import '../widgets/generating_screen.dart';

class CreateAnimationScreen extends StatefulWidget {
  const CreateAnimationScreen({super.key});

  @override
  State<CreateAnimationScreen> createState() => _CreateAnimationScreenState();
}

class _CreateAnimationScreenState extends State<CreateAnimationScreen> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final PageController _pageController = PageController();

  double _previewProgress = 0.5;
  bool _isRefining = false;

  final List<Map<String, String>> _questions = [
    {
      'title': 'The Action',
      'subtitle': 'What is the stickman doing?',
      'hint': 'e.g., Walking, Running, Climbing, Pushing',
      'icon': '🏃',
    },
    {
      'title': 'The Scene',
      'subtitle': 'Where is this happening?',
      'hint': 'e.g., On a hill, Ladder, Empty road, Bridge',
      'icon': '🏞️',
    },
    {
      'title': 'The Progress',
      'subtitle': 'What changes with time?',
      'hint': 'e.g., Nothing (just walking), Plant grows, Sun rises',
      'icon': '⏳',
    },
    {
      'title': 'The Style',
      'subtitle': 'Any specific colors or vibes?',
      'hint': 'e.g., Neon blue, Calm, Red and angry',
      'icon': '🎨',
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnimationCreatorProvider>().checkApiKey();
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    _nameController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep(AnimationCreatorProvider provider) {
    if (_inputController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please answer the question')));
      return;
    }

    provider.setAnswer(provider.currentStep, _inputController.text.trim());

    if (provider.currentStep < 3) {
      final nextAnswer = provider.getAnswer(provider.currentStep + 1);
      _inputController.text = nextAnswer;

      provider.nextStep();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _generateAnimation(provider);
    }
  }

  void _prevStep(AnimationCreatorProvider provider) {
    if (provider.currentStep > 0) {
      final prevAnswer = provider.getAnswer(provider.currentStep - 1);
      _inputController.text = prevAnswer;

      provider.previousStep();
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Animation Saved')));
        provider.resetWizard();
      }
    }
  }

  Future<void> _generateAnimation(AnimationCreatorProvider provider) async {
    setState(() => _isRefining = false);
    FocusScope.of(context).unfocus();
    await provider.generateAnimation();

    if (provider.error != null && mounted) {
      showErrorDialog(
        context,
        message: provider.error!,
        onRetry: () => _generateAnimation(provider),
      );
    }
  }

  void _saveAnimation(AnimationCreatorProvider provider) async {
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: Text(
          'Name Animation',
          style: GoogleFonts.outfit(color: Colors.white),
        ),
        content: TextField(
          controller: _nameController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(hintText: 'My Animation'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, _nameController.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (name != null && name.isNotEmpty) {
      await provider.saveCurrentAnimation(name);
      if (mounted) {
        provider.resetWizard();
        _nameController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Animation saved successfully')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AnimationCreatorProvider>(
      builder: (context, provider, _) {
        // Show loading screen during generation
        if (provider.isGenerating) {
          return GeneratingScreen(isRefining: _isRefining);
        }

        // Show preview if generated
        if (provider.hasPreview) {
          return _buildPreviewScreen(provider);
        }

        return Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: AppColors.backgroundBlack,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            leading: provider.currentStep > 0
                ? IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => _prevStep(provider),
                  )
                : null,
            title: Text(
              'Step ${provider.currentStep + 1} of 4',
              style: GoogleFonts.outfit(color: Colors.white70, fontSize: 16),
            ),
            centerTitle: true,
          ),
          body: !provider.isApiKeySet
              ? _buildApiKeyInput()
              : _buildWizardStep(provider),
        );
      },
    );
  }

  Widget _buildWizardStep(AnimationCreatorProvider provider) {
    final question = _questions[provider.currentStep];

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(question['icon']!, style: const TextStyle(fontSize: 48)),
                const SizedBox(height: 24),
                Text(
                  question['title']!,
                  style: GoogleFonts.outfit(
                    color: AppColors.accent,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  question['subtitle']!,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _inputController,
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 20),
                  maxLines: null,
                  minLines: 1,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    hintText: question['hint'],
                    hintStyle: GoogleFonts.outfit(color: Colors.white30),
                    filled: true,
                    fillColor: AppColors.surfaceLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(20),
                  ),
                  autofocus: true,
                ),
              ],
            ),
          ),
        ),

        Container(
          padding: const EdgeInsets.all(24),
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _nextStep(provider),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: provider.isGenerating
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(
                    provider.currentStep == 3 ? 'Generate ✨' : 'Next',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewScreen(AnimationCreatorProvider provider) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            provider.discardPreview();
          },
        ),
        title: Text('Preview', style: GoogleFonts.outfit(color: Colors.white)),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.accent, width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: AIAnimationWidget(
                      config: provider.previewConfig!,
                      progress: _previewProgress,
                      isRunning: true,
                      isCompleted: false,
                    ),
                  ),
                ),
              ),

              // Refinement Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _showRefinementSheet(context, provider),
                    icon: const Icon(Icons.auto_fix_high),
                    label: const Text('Edit with AI'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.surfaceLight,
                      foregroundColor: AppColors.accent,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: AppColors.accent),
                    ),
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  children: [
                    // Progress Slider
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Session Progress: ${(_previewProgress * 100).toInt()}%',
                                style: GoogleFonts.outfit(
                                  color: Colors.white70,
                                ),
                              ),
                              Text(
                                'Time Passing',
                                style: GoogleFonts.outfit(
                                  color: AppColors.accent,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Slider(
                          value: _previewProgress,
                          activeColor: AppColors.accent,
                          inactiveColor: Colors.white10,
                          onChanged: (val) =>
                              setState(() => _previewProgress = val),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _saveAnimation(provider),
                        icon: const Icon(Icons.save),
                        label: const Text('Save Animation'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (provider.isGenerating)
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: AppColors.accent),
                    const SizedBox(height: 16),
                    Text(
                      'Refining...',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildApiKeyInput() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.vpn_key, size: 48, color: AppColors.accent),
            const SizedBox(height: 24),
            Text(
              'Add Gemini API Key',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _inputController,
              decoration: const InputDecoration(
                hintText: 'Paste API Key here',
                filled: true,
                fillColor: AppColors.surfaceLight,
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                if (_inputController.text.isNotEmpty) {
                  await context.read<AnimationCreatorProvider>().saveApiKey(
                    _inputController.text.trim(),
                  );
                  if (mounted) {
                    context.read<AnimationCreatorProvider>().checkApiKey();
                    _inputController.clear();
                  }
                }
              },
              child: const Text('Save Key'),
            ),
          ],
        ),
      ),
    );
  }

  void _showRefinementSheet(
    BuildContext context,
    AnimationCreatorProvider provider,
  ) {
    final controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
          top: 20,
          left: 20,
          right: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Refine Animation',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'What would you like to change?',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              maxLines: null,
              decoration: InputDecoration(
                hintText: 'e.g., Make lines thicker, Add a hat...',
                filled: true,
                fillColor: AppColors.surfaceLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (controller.text.isNotEmpty) {
                    Navigator.pop(sheetContext);
                    setState(() => _isRefining = true);
                    await provider.refinePreview(controller.text.trim());

                    if (provider.error != null && context.mounted) {
                      showErrorDialog(
                        context,
                        message: provider.error!,
                        onRetry: () => _showRefinementSheet(context, provider),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Update'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showErrorDialog(
    BuildContext context, {
    required String message,
    required VoidCallback onRetry,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: Text(
          'Error',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          message.replaceAll('Exception: ', ''),
          style: GoogleFonts.outfit(color: Colors.white70, fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onRetry();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}
