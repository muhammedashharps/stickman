import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GeminiService {
  static const String _apiKeyPref = 'gemini_api_key';
  static const String _modelPref = 'gemini_model';
  static const String defaultModel = 'gemini-3-flash-preview';

  static final GeminiService _instance = GeminiService._internal();
  factory GeminiService() => _instance;
  GeminiService._internal();

  GenerativeModel? _model;
  String? _apiKey;
  String _modelName = defaultModel; // Default

  static const List<String> availableModels = [
    'gemini-3-pro-preview',
    'gemini-3-flash-preview',
    'gemini-flash-latest',
    'gemini-flash-lite-latest',
  ];

  /// Check if API key is configured
  Future<bool> hasApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    _apiKey = prefs.getString(_apiKeyPref);
    _modelName = prefs.getString(_modelPref) ?? defaultModel;
    return _apiKey != null && _apiKey!.isNotEmpty;
  }

  /// Save API key
  Future<void> saveApiKey(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiKeyPref, apiKey);
    _apiKey = apiKey;
    _model = null; // Reset model
  }

  /// Set AI Model
  Future<void> setModel(String modelName) async {
    if (!availableModels.contains(modelName)) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_modelPref, modelName);
    _modelName = modelName;
    _model = null; // Reset model to use new name
  }

  /// Get current model name
  Future<String> getModelName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_modelPref) ?? defaultModel;
  }

  /// Get API key
  Future<String?> getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_apiKeyPref);
  }

  /// Clear API key
  Future<void> clearApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_apiKeyPref);
    _apiKey = null;
    _model = null;
  }

  /// Initialize the model
  Future<GenerativeModel?> _getModel() async {
    if (_model != null) return _model;

    final prefs = await SharedPreferences.getInstance();
    _apiKey ??= prefs.getString(_apiKeyPref);
    _modelName = prefs.getString(_modelPref) ?? defaultModel;

    if (_apiKey == null || _apiKey!.isEmpty) return null;

    _model = GenerativeModel(model: _modelName, apiKey: _apiKey!);
    return _model;
  }

  /// Generate animation params from Wizard inputs
  Future<Map<String, dynamic>> generateFromWizard({
    required String action,
    required String environment,
    required String progress,
    required String style,
  }) async {
    final model = await _getModel();
    if (model == null) {
      throw Exception('API key not configured');
    }

    final prompt = _buildWizardPrompt(action, environment, progress, style);

    try {
      final response = await model.generateContent([Content.text(prompt)]);

      String? text;
      try {
        text = response.text;
      } catch (e) {
        if (response.candidates.isNotEmpty) {
          final candidate = response.candidates.first;
          if (candidate.content.parts.isNotEmpty) {
            final part = candidate.content.parts.first;
            if (part is TextPart) {
              text = part.text;
            }
          }
        }
      }

      if (text == null || text.isEmpty) {
        throw Exception('Empty response from AI');
      }

      debugPrint('Gemini response: $text');

      final jsonStr = _extractJson(text);
      if (jsonStr == null) {
        throw Exception('Could not find animation config');
      }

      return jsonDecode(jsonStr) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Gemini error: $e');
      throw _classifyError(e);
    }
  }

  /// Classify errors and return user-friendly messages
  Exception _classifyError(dynamic error) {
    final errorStr = error.toString().toLowerCase();

    // Rate limit errors
    if (errorStr.contains('429') ||
        errorStr.contains('rate limit') ||
        errorStr.contains('quota') ||
        errorStr.contains('too many requests')) {
      return Exception(
        'API rate limit reached. Please wait a moment and try again.',
      );
    }

    // Model overload errors
    if (errorStr.contains('503') ||
        errorStr.contains('overload') ||
        errorStr.contains('unavailable') ||
        errorStr.contains('capacity')) {
      return Exception(
        'AI model is currently busy. Please try again in a few seconds.',
      );
    }

    // Connectivity errors
    if (errorStr.contains('socketexception') ||
        errorStr.contains('network') ||
        errorStr.contains('connection') ||
        errorStr.contains('timeout') ||
        errorStr.contains('unreachable')) {
      return Exception(
        'No internet connection. Please check your network and try again.',
      );
    }

    // API key errors
    if (errorStr.contains('401') ||
        errorStr.contains('invalid') && errorStr.contains('key') ||
        errorStr.contains('unauthorized')) {
      return Exception('Invalid API key. Please check your key in Settings.');
    }

    // Safety/content filter errors
    if (errorStr.contains('safety') ||
        errorStr.contains('blocked') ||
        errorStr.contains('harmful')) {
      return Exception(
        'Content was blocked by safety filters. Try a different description.',
      );
    }

    // Generic error with original message
    if (error is Exception) {
      final msg = error.toString().replaceFirst('Exception: ', '');
      return Exception(msg);
    }

    return Exception('Something went wrong. Please try again.');
  }

  String _buildWizardPrompt(
    String action,
    String environment,
    String progress,
    String style,
  ) {
    return '''
You are a Vector Graphics Generator. Create a JSON description of a scene using geometric primitives (circles, lines, rects).

USER REQUEST:
Action: "$action"
Environment: "$environment"
Progress/Interaction: "$progress"
Style: "$style"

INSTRUCTIONS:
1. Deconstruct the scene into simple shapes (lines for stickfigures, circles for heads/suns, rects for buildings/ground).
2. Coordinates are normalized (0.0 to 1.0). Top-left is (0,0). Bottom-right is (1,1).
3. Ground level is usually around Y=0.8.
4. ANIMATION: Use the "animations" array to make things move.
   - "type": "sine" (for waving/breathing)
   - "type": "linear" (for moving across screen)
   - "type": "progress" (CRITICAL: Use this for long-term changes aligned with the timer, e.g., shrinking candle, growing plant, building wall. Maps 0.0->1.0 session progress)
   - "property": Which value to animate (e.g., "y1", "cx", "rotation", "h")
   - "magnitude": Amount to change. Use NEGATIVE for shrinking (e.g., -0.3).

JSON STRUCTURE (Return ONLY this):
{
  "backgroundColor": "#1E1E1E",
  "elements": [
    {
      "id": "item_1",
      "type": "circle", // or "line", "rect"
      "color": "#FFFFFF",
      "strokeWidth": 2.0,
      "filled": false,
      "properties": {
        "cx": 0.5, "cy": 0.5, "r": 0.1 // for circle
        // "x1", "y1", "x2", "y2" for line
        // "x", "y", "w", "h" for rect
      },
      "animations": [
        {
          "property": "cx", // property to modify
          "type": "sine",   // "sine" or "linear"
          "speed": 1.0,     // speed multiplier
          "magnitude": 0.1  // amount to change
        }
      ]
    }
  ]
}

EXAMPLE: "Stickman walking"
- Head (circle at 0.5, 0.7)
- Body (line from 0.5, 0.75 to 0.5, 0.85)
- Legs (lines with "sine" animation on x2/y2 to swing)
- Arms (lines)

Create a COMPLEX and DETAILED scene matching the user request. Use 10-20 elements if needed.
''';
  }

  String? _extractJson(String text) {
    final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(text);
    if (jsonMatch != null) {
      return jsonMatch.group(0);
    }
    return null;
  }

  /// Refine an existing animation based on user feedback
  Future<Map<String, dynamic>> refineAnimation({
    required Map<String, dynamic> currentJson,
    required String instructions,
  }) async {
    final model = await _getModel();
    if (model == null) {
      throw Exception('API key not configured');
    }

    final prompt = _buildRefinementPrompt(currentJson, instructions);

    try {
      final response = await model.generateContent([Content.text(prompt)]);
      final text = response.text;

      if (text == null || text.isEmpty) {
        throw Exception('Empty response from AI');
      }

      debugPrint('Refinement response: $text');

      final jsonStr = _extractJson(text);
      if (jsonStr == null) {
        throw Exception('Could not find valid JSON');
      }

      return jsonDecode(jsonStr) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Refinement Gemini error: $e');
      throw _classifyError(e);
    }
  }

  String _buildRefinementPrompt(
    Map<String, dynamic> currentJson,
    String instructions,
  ) {
    return '''
You are a Vector Graphics Generator. Modify the existing JSON scene based on the user's instructions.

CURRENT JSON:
${jsonEncode(currentJson)}

USER INSTRUCTIONS:
"$instructions"

TASKS:
1. Parse the Current JSON.
2. Apply the requested changes (e.g., change colors, add elements, modify animations).
3. Keep the rest of the scene intact unless asked to change it.
4. If adding new elements, use the standard geometric primitives (circle, line, rect) with normalized coordinates (0.0-1.0).

RETURN FORMAT:
Return ONLY the updated JSON structure.
''';
  }
}
