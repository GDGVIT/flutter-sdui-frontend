import 'package:flutter/material.dart';

class WidgetNode {
  final String uid;
  final String type;
  final String label;
  final IconData icon;
  final Offset position;
  final Size size;
  final List<WidgetNode> children;
  final Map<String, dynamic> properties;

  const WidgetNode({
    required this.uid,
    required this.type,
    required this.label,
    required this.icon,
    required this.position,
    required this.size,
    required this.children,
    required this.properties,
  });

  WidgetNode copyWith({
    String? uid,
    String? type,
    String? label,
    IconData? icon,
    Offset? position,
    Size? size,
    List<WidgetNode>? children,
    Map<String, dynamic>? properties,
  }) {
    return WidgetNode(
      uid: uid ?? this.uid,
      type: type ?? this.type,
      label: label ?? this.label,
      icon: icon ?? this.icon,
      position: position ?? this.position,
      size: size ?? this.size,
      children: children ?? this.children,
      properties: properties ?? this.properties,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'type': type,
      'label': label,
      'position': {'dx': position.dx, 'dy': position.dy},
      'size': {'width': size.width, 'height': size.height},
      'children': children.map((child) => child.toJson()).toList(),
      'properties': properties,
    };
  }

  factory WidgetNode.fromJson(Map<String, dynamic> json) {
    return WidgetNode(
      uid: json['uid'] ?? json['id'],
      type: json['type'],
      label: json['label'],
      icon: WidgetNode.getIconFromType(json['type']),
      position: Offset(json['position']['dx'], json['position']['dy']),
      size: Size(json['size']['width'], json['size']['height']),
      children: (json['children'] as List).map((child) => WidgetNode.fromJson(child)).toList(),
      properties: Map<String, dynamic>.from(json['properties']),
    );
  }

  static IconData getIconFromType(String type) {
    switch (type) {
      case 'Scaffold':
        return Icons.web_asset;
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