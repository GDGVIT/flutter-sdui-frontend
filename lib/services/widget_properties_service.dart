import 'package:flutter/material.dart';
import '../models/widget_registry.dart';

class WidgetPropertiesService {
  // Only provide helpers that delegate to WidgetRegistry
  static List<PropertyDefinition<T>> getPropertyDefinitions<T>(String widgetType) {
    return WidgetRegistry.getPropertyDefinitions(widgetType).cast<PropertyDefinition<T>>();
  }
  static Map<String, dynamic> getDefaultProperties(String widgetType) {
    return WidgetRegistry.getDefaultProperties(widgetType);
  }
  static WidgetConstraints getConstraints(String widgetType) {
    return WidgetConstraints(
      maxChildren: WidgetRegistry.getMaxChildren(widgetType),
      canHaveChildren: WidgetRegistry.canHaveChildren(widgetType),
    );
  }
  static Size getDefaultSize(String widgetType) {
    return WidgetRegistry.getDefaultSize(widgetType);
  }
  static String getChildrenInfo(String widgetType) {
    return WidgetRegistry.getChildrenInfo(widgetType);
  }
}

class PropertyDefinition<T> {
  final String key;
  final String label;
  final PropertyType type;
  final List<T>? options;

  const PropertyDefinition(this.key, this.label, this.type, {this.options});
}

enum PropertyType {
  text,
  number,
  boolean,
  color,
  dropdown,
}

class WidgetConstraints {
  final int maxChildren; // -1 for unlimited, 0 for no children, positive number for limit
  final bool canHaveChildren;

  const WidgetConstraints({
    required this.maxChildren,
    required this.canHaveChildren,
  });
} 