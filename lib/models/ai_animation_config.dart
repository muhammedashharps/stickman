/// Top-level configuration for a dynamic AI animation
class AIAnimationConfig {
  final String id;
  final String name;
  final String userPrompt;
  final String backgroundColor; // Hex code
  final List<DynamicElement> elements;
  final DateTime createdAt;

  AIAnimationConfig({
    required this.id,
    required this.name,
    required this.userPrompt,
    required this.backgroundColor,
    required this.elements,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'userPrompt': userPrompt,
    'backgroundColor': backgroundColor,
    'elements': elements.map((e) => e.toJson()).toList(),
    'createdAt': createdAt.toIso8601String(),
  };

  factory AIAnimationConfig.fromJson(Map<String, dynamic> json) {
    return AIAnimationConfig(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Custom Animation',
      userPrompt: json['userPrompt'] ?? '',
      backgroundColor: json['backgroundColor'] ?? '#1A1A2E',
      elements: (json['elements'] as List? ?? [])
          .map((e) => DynamicElement.fromJson(e))
          .toList(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  factory AIAnimationConfig.fromAIResponse({
    required String id,
    required String name,
    required String userPrompt,
    required Map<String, dynamic> aiResponse,
  }) {
    return AIAnimationConfig(
      id: id,
      name: name,
      userPrompt: userPrompt,
      backgroundColor: aiResponse['backgroundColor'] ?? '#1A1A2E',
      elements: (aiResponse['elements'] as List? ?? [])
          .map((e) => DynamicElement.fromJson(e))
          .toList(),
      createdAt: DateTime.now(),
    );
  }
}

/// Abstract base class for any drawable element
abstract class DynamicElement {
  final String id;
  final String type;
  final String color;
  final double strokeWidth;
  final bool filled;
  final List<ElementAnimation> animations;

  DynamicElement({
    required this.id,
    required this.type,
    required this.color,
    required this.strokeWidth,
    required this.filled,
    required this.animations,
  });

  Map<String, dynamic> toJson();

  static DynamicElement fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String? ?? 'circle';
    switch (type) {
      case 'circle':
        return CircleElement.fromJson(json);
      case 'line':
        return LineElement.fromJson(json);
      case 'rect':
        return RectElement.fromJson(json);
      default:
        return CircleElement.fromJson(json); // Fallback
    }
  }
}

class CircleElement extends DynamicElement {
  final double cx;
  final double cy;
  final double r;

  CircleElement({
    required super.id,
    required super.type,
    required super.color,
    required super.strokeWidth,
    required super.filled,
    required super.animations,
    required this.cx,
    required this.cy,
    required this.r,
  });

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': 'circle',
    'color': color,
    'strokeWidth': strokeWidth,
    'filled': filled,
    'animations': animations.map((a) => a.toJson()).toList(),
    'properties': {'cx': cx, 'cy': cy, 'r': r},
  };

  factory CircleElement.fromJson(Map<String, dynamic> json) {
    final props = json['properties'] as Map<String, dynamic>? ?? {};
    final anims = (json['animations'] as List? ?? [])
        .map((a) => ElementAnimation.fromJson(a))
        .toList();

    return CircleElement(
      id: json['id'] ?? 'circle',
      type: 'circle',
      color: json['color'] ?? '#FFFFFF',
      strokeWidth: (json['strokeWidth'] as num?)?.toDouble() ?? 2.0,
      filled: json['filled'] ?? false,
      animations: anims,
      cx: (props['cx'] as num?)?.toDouble() ?? 0.5,
      cy: (props['cy'] as num?)?.toDouble() ?? 0.5,
      r: (props['r'] as num?)?.toDouble() ?? 0.1,
    );
  }
}

class LineElement extends DynamicElement {
  final double x1;
  final double y1;
  final double x2;
  final double y2;

  LineElement({
    required super.id,
    required super.type,
    required super.color,
    required super.strokeWidth,
    required super.filled,
    required super.animations,
    required this.x1,
    required this.y1,
    required this.x2,
    required this.y2,
  });

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': 'line',
    'color': color,
    'strokeWidth': strokeWidth,
    'filled': filled,
    'animations': animations.map((a) => a.toJson()).toList(),
    'properties': {'x1': x1, 'y1': y1, 'x2': x2, 'y2': y2},
  };

  factory LineElement.fromJson(Map<String, dynamic> json) {
    final props = json['properties'] as Map<String, dynamic>? ?? {};
    final anims = (json['animations'] as List? ?? [])
        .map((a) => ElementAnimation.fromJson(a))
        .toList();

    return LineElement(
      id: json['id'] ?? 'line',
      type: 'line',
      color: json['color'] ?? '#FFFFFF',
      strokeWidth: (json['strokeWidth'] as num?)?.toDouble() ?? 2.0,
      filled: json['filled'] ?? false,
      animations: anims,
      x1: (props['x1'] as num?)?.toDouble() ?? 0.0,
      y1: (props['y1'] as num?)?.toDouble() ?? 0.0,
      x2: (props['x2'] as num?)?.toDouble() ?? 0.0,
      y2: (props['y2'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class RectElement extends DynamicElement {
  final double x;
  final double y;
  final double w;
  final double h;

  RectElement({
    required super.id,
    required super.type,
    required super.color,
    required super.strokeWidth,
    required super.filled,
    required super.animations,
    required this.x,
    required this.y,
    required this.w,
    required this.h,
  });

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': 'rect',
    'color': color,
    'strokeWidth': strokeWidth,
    'filled': filled,
    'animations': animations.map((a) => a.toJson()).toList(),
    'properties': {'x': x, 'y': y, 'w': w, 'h': h},
  };

  factory RectElement.fromJson(Map<String, dynamic> json) {
    final props = json['properties'] as Map<String, dynamic>? ?? {};
    final anims = (json['animations'] as List? ?? [])
        .map((a) => ElementAnimation.fromJson(a))
        .toList();

    return RectElement(
      id: json['id'] ?? 'rect',
      type: 'rect',
      color: json['color'] ?? '#FFFFFF',
      strokeWidth: (json['strokeWidth'] as num?)?.toDouble() ?? 2.0,
      filled: json['filled'] ?? false,
      animations: anims,
      x: (props['x'] as num?)?.toDouble() ?? 0.0,
      y: (props['y'] as num?)?.toDouble() ?? 0.0,
      w: (props['w'] as num?)?.toDouble() ?? 0.1,
      h: (props['h'] as num?)?.toDouble() ?? 0.1,
    );
  }
}

/// Defines how a property changes
class ElementAnimation {
  final String property; // e.g. 'cx', 'y1', 'rotation'
  final String type; // 'sine', 'linear', 'pulse'
  final double speed; // Frequency/Speed multiplier
  final double magnitude; // Amplitude/Range
  final bool loop;

  ElementAnimation({
    required this.property,
    required this.type,
    required this.speed,
    required this.magnitude,
    required this.loop,
  });

  Map<String, dynamic> toJson() => {
    'property': property,
    'type': type,
    'speed': speed,
    'magnitude': magnitude,
    'loop': loop,
  };

  factory ElementAnimation.fromJson(Map<String, dynamic> json) {
    return ElementAnimation(
      property: json['property'] ?? '',
      type: json['type'] ?? 'sine',
      speed: (json['speed'] as num?)?.toDouble() ?? 1.0,
      magnitude: (json['magnitude'] as num?)?.toDouble() ?? 0.1,
      loop: json['loop'] ?? true,
    );
  }
}
