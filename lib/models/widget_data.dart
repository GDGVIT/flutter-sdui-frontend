import 'package:flutter/material.dart';

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
      label: json['label'],
      icon: WidgetData.getIconFromType(json['type']),
      position: Offset(json['position']['dx'], json['position']['dy']),
    );
  }

  static IconData getIconFromType(String type) {
    switch (type) {
      case 'Column Widget':
        return Icons.view_column;
      case 'Row Widget':
        return Icons.view_stream;
      case 'Container Widget':
        return Icons.crop_square;
      case 'Stack Widget':
        return Icons.view_in_ar;
      case 'Text Widget':
        return Icons.text_fields;
      case 'TextField Widget':
        return Icons.input;
      case 'Image Widget':
        return Icons.image;
      default:
        return Icons.widgets;
    }
  }
} 