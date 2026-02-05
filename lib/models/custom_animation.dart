/// Represents a custom AI-generated animation
library;

class CustomAnimation {
  final String id;
  final String name;
  final String description;
  final String userPrompt;
  final AnimationConfig config;
  final DateTime createdAt;

  CustomAnimation({
    required this.id,
    required this.name,
    required this.description,
    required this.userPrompt,
    required this.config,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'userPrompt': userPrompt,
    'config': config.toJson(),
    'createdAt': createdAt.toIso8601String(),
  };

  factory CustomAnimation.fromJson(Map<String, dynamic> json) =>
      CustomAnimation(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        userPrompt: json['userPrompt'],
        config: AnimationConfig.fromJson(json['config']),
        createdAt: DateTime.parse(json['createdAt']),
      );
}

/// Configuration for the entire animation scene
class AnimationConfig {
  final String backgroundColor;
  final int durationMs;
  final List<AnimationElement> elements;

  AnimationConfig({
    required this.backgroundColor,
    required this.durationMs,
    required this.elements,
  });

  Map<String, dynamic> toJson() => {
    'backgroundColor': backgroundColor,
    'durationMs': durationMs,
    'elements': elements.map((e) => e.toJson()).toList(),
  };

  factory AnimationConfig.fromJson(Map<String, dynamic> json) =>
      AnimationConfig(
        backgroundColor: json['backgroundColor'] ?? '#1A1A2E',
        durationMs: json['durationMs'] ?? 3000,
        elements:
            (json['elements'] as List?)
                ?.map((e) => AnimationElement.fromJson(e))
                .toList() ??
            [],
      );
}

/// Types of elements that can be drawn
enum ElementType {
  stickman,
  circle,
  rectangle,
  line,
  tree,
  sun,
  moon,
  star,
  cloud,
  mountain,
  wave,
  text,
}

/// A single element in the animation
class AnimationElement {
  final String id;
  final ElementType type;
  final String color;
  final double strokeWidth;
  final double initialX;
  final double initialY;
  final double scale;
  final double rotation;
  final Map<String, dynamic> properties;
  final List<AnimationMovement> movements;

  AnimationElement({
    required this.id,
    required this.type,
    required this.color,
    this.strokeWidth = 3.0,
    required this.initialX,
    required this.initialY,
    this.scale = 1.0,
    this.rotation = 0.0,
    this.properties = const {},
    this.movements = const [],
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'color': color,
    'strokeWidth': strokeWidth,
    'initialX': initialX,
    'initialY': initialY,
    'scale': scale,
    'rotation': rotation,
    'properties': properties,
    'movements': movements.map((m) => m.toJson()).toList(),
  };

  factory AnimationElement.fromJson(Map<String, dynamic> json) =>
      AnimationElement(
        id: json['id'] ?? 'element_0',
        type: ElementType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => ElementType.circle,
        ),
        color: json['color'] ?? '#FFFFFF',
        strokeWidth: (json['strokeWidth'] ?? 3.0).toDouble(),
        initialX: (json['initialX'] ?? 0.5).toDouble(),
        initialY: (json['initialY'] ?? 0.5).toDouble(),
        scale: (json['scale'] ?? 1.0).toDouble(),
        rotation: (json['rotation'] ?? 0.0).toDouble(),
        properties: json['properties'] ?? {},
        movements:
            (json['movements'] as List?)
                ?.map((m) => AnimationMovement.fromJson(m))
                .toList() ??
            [],
      );
}

/// Movement types for animations
enum MovementType { linear, bounce, wave, rotate, scale, fade, walk, jump, run }

/// Defines a movement/animation for an element
class AnimationMovement {
  final MovementType type;
  final double startTime; // 0.0 to 1.0
  final double endTime; // 0.0 to 1.0
  final double startValue;
  final double endValue;
  final String axis; // 'x', 'y', 'both', 'rotation', 'scale', 'opacity'
  final bool loop;

  AnimationMovement({
    required this.type,
    required this.startTime,
    required this.endTime,
    required this.startValue,
    required this.endValue,
    this.axis = 'both',
    this.loop = true,
  });

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'startTime': startTime,
    'endTime': endTime,
    'startValue': startValue,
    'endValue': endValue,
    'axis': axis,
    'loop': loop,
  };

  factory AnimationMovement.fromJson(Map<String, dynamic> json) =>
      AnimationMovement(
        type: MovementType.values.firstWhere(
          (t) => t.name == json['type'],
          orElse: () => MovementType.linear,
        ),
        startTime: (json['startTime'] ?? 0.0).toDouble(),
        endTime: (json['endTime'] ?? 1.0).toDouble(),
        startValue: (json['startValue'] ?? 0.0).toDouble(),
        endValue: (json['endValue'] ?? 1.0).toDouble(),
        axis: json['axis'] ?? 'both',
        loop: json['loop'] ?? true,
      );
}
