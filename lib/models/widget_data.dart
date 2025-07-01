import 'package:flutter/material.dart';
import 'widget_registry.dart';

class WidgetData {
  final String type;
  final String label;
  final IconData icon;
  final Offset position;

  const WidgetData({
    required this.type,
    required this.label,
    required this.icon,
    required this.position,
  });

  WidgetData copyWith({
    String? type,
    String? label,
    IconData? icon,
    Offset? position,
  }) {
    return WidgetData(
      type: type ?? this.type,
      label: label ?? this.label,
      icon: icon ?? this.icon,
      position: position ?? this.position,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'label': label,
      'position': {'dx': position.dx, 'dy': position.dy},
    };
  }

  factory WidgetData.fromJson(Map<String, dynamic> json) {
    return WidgetData(
      type: json['type'],
      label: WidgetRegistry.getLabel(json['type']),
      icon: WidgetRegistry.getIcon(json['type']),
      position: Offset(json['position']['dx'], json['position']['dy']),
    );
  }
} 