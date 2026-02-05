import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/ai_animation_config.dart';
import '../services/gemini_service.dart';

class AnimationCreatorProvider extends ChangeNotifier {
  static const String _animationsKey = 'ai_animations_v2';

  final GeminiService _geminiService = GeminiService();
  final Uuid _uuid = const Uuid();

  List<AIAnimationConfig> _animations = [];
  AIAnimationConfig? _previewConfig;
  bool _isGenerating = false;
  String? _error;
  bool _isApiKeySet = false;

  // Wizard State
  int _currentStep = 0;
  final Map<int, String> _wizardAnswers = {};

  // Getters
  List<AIAnimationConfig> get animations => _animations;
  AIAnimationConfig? get previewConfig => _previewConfig;
  bool get isGenerating => _isGenerating;
  String? get error => _error;
  bool get hasPreview => _previewConfig != null;
  bool get isApiKeySet => _isApiKeySet;
  int get currentStep => _currentStep;

  AnimationCreatorProvider() {
    _loadAnimations();
  }

  void setStep(int step) {
    _currentStep = step;
    notifyListeners();
  }

  void setAnswer(int step, String answer) {
    _wizardAnswers[step] = answer;
    notifyListeners();
  }

  String getAnswer(int step) => _wizardAnswers[step] ?? '';

  void nextStep() {
    if (_currentStep < 3) {
      _currentStep++;
      notifyListeners();
    }
  }

  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  void resetWizard() {
    _currentStep = 0;
    _wizardAnswers.clear();
    _previewConfig = null;
    _error = null;
    notifyListeners();
  }

  /// Generate animation from Wizard inputs
  Future<void> generateAnimation() async {
    _isGenerating = true;
    _error = null;
    notifyListeners();

    try {
      final action = _wizardAnswers[0] ?? 'Walking';
      final env = _wizardAnswers[1] ?? 'Path';
      final progress = _wizardAnswers[2] ?? 'Nothing';
      final style = _wizardAnswers[3] ?? 'Default';

      final params = await _geminiService.generateFromWizard(
        action: action,
        environment: env,
        progress: progress,
        style: style,
      );

      debugPrint('AI params: $params');

      String prompt = "$action on $env";

      _previewConfig = AIAnimationConfig.fromAIResponse(
        id: _uuid.v4(),
        name: _generateName(prompt),
        userPrompt: prompt,
        aiResponse: params,
      );
      _error = null;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _previewConfig = null;
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
  }

  /// Refine the current preview based on new instructions
  Future<void> refinePreview(String instructions) async {
    if (_previewConfig == null) return;

    _isGenerating = true;
    _error = null;
    notifyListeners();

    try {
      final currentJson = _previewConfig!.toJson();

      final newParams = await _geminiService.refineAnimation(
        currentJson: currentJson,
        instructions: instructions,
      );

      // Create new config while preserving ID/Name
      _previewConfig = AIAnimationConfig.fromAIResponse(
        id: _previewConfig!.id,
        name: _previewConfig!.name,
        userPrompt: _previewConfig!.userPrompt,
        aiResponse: newParams,
      );
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
  }

  // -API Key Setup

  Future<void> _loadAnimations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_animationsKey);
      if (jsonStr != null) {
        final List<dynamic> jsonList = jsonDecode(jsonStr);
        _animations = jsonList
            .map((json) => AIAnimationConfig.fromJson(json))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading animations: $e');
    }
  }

  Future<void> _saveAnimations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = jsonEncode(_animations.map((a) => a.toJson()).toList());
      await prefs.setString(_animationsKey, jsonStr);
    } catch (e) {
      debugPrint('Error saving animations: $e');
    }
  }

  Future<bool> hasApiKey() => _geminiService.hasApiKey();

  Future<void> checkApiKey() async {
    final has = await _geminiService.hasApiKey();
    if (has != _isApiKeySet) {
      _isApiKeySet = has;
      notifyListeners();
    }
  }

  Future<void> saveApiKey(String apiKey) => _geminiService.saveApiKey(apiKey);
  Future<String?> getApiKey() => _geminiService.getApiKey();
  Future<void> clearApiKey() => _geminiService.clearApiKey();

  String _generateName(String prompt) {
    final words = prompt.split(' ').take(3).join(' ');
    return words.length > 25 ? '${words.substring(0, 22)}...' : words;
  }

  Future<AIAnimationConfig?> saveCurrentAnimation(String name) async {
    if (_previewConfig == null) return null;

    final animation = AIAnimationConfig(
      id: _previewConfig!.id,
      name: name.isEmpty ? _previewConfig!.name : name,
      userPrompt: _previewConfig!.userPrompt,
      backgroundColor: _previewConfig!.backgroundColor,
      elements: _previewConfig!.elements,
      createdAt: DateTime.now(),
    );

    _animations.insert(0, animation);
    await _saveAnimations();

    _previewConfig = null;
    resetWizard(); // Reset after save

    return animation;
  }

  Future<void> deleteAnimation(String id) async {
    _animations.removeWhere((a) => a.id == id);
    await _saveAnimations();
    notifyListeners();
  }

  void clearPreview() {
    resetWizard();
  }

  void discardPreview() {
    _previewConfig = null;
    notifyListeners();
  }
}
