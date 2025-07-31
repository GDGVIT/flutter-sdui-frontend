import 'package:flutter/material.dart';
import '../services/widget_properties_service.dart';

class WidgetRegistryEntry {
  final String type;
  final String label;
  final IconData icon;
  final String category;
  final String childrenInfo;
  final int maxChildren;
  final bool canHaveChildren;
  final List<PropertyDefinition> propertyDefinitions;
  final Map<String, dynamic> defaultProperties;
  final Size defaultSize;

  const WidgetRegistryEntry({
    required this.type,
    required this.label,
    required this.icon,
    required this.category,
    required this.childrenInfo,
    required this.maxChildren,
    required this.canHaveChildren,
    required this.propertyDefinitions,
    required this.defaultProperties,
    required this.defaultSize,
  });
} 