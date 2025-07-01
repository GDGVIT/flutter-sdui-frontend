// Remove all code except the WidgetRegistry class and import/export the new files.
// widget_registry_entry.dart: contains WidgetRegistryEntry class
// widget_registry_data.dart: contains the List<WidgetRegistryEntry> entries
// widget_registry.dart: imports/exports both and provides static lookup methods

import 'package:flutter/material.dart';
import '../services/widget_properties_service.dart';
import 'widget_registry_entry.dart';
import 'widget_registry_data.dart';

class WidgetRegistry {
  static final List<WidgetRegistryEntry> entries = widgetRegistryEntries;

  static WidgetRegistryEntry? getByType(String type) {
    try {
      return entries.firstWhere((e) => e.type == type);
    } catch (_) {
      return null;
    }
  }

  static IconData getIcon(String type) {
    return getByType(type)?.icon ?? Icons.widgets;
  }

  static String getLabel(String type) {
    return getByType(type)?.label ?? type;
  }

  static List<PropertyDefinition> getPropertyDefinitions(String type) {
    return getByType(type)?.propertyDefinitions ?? [];
  }

  static Map<String, dynamic> getDefaultProperties(String type) {
    return getByType(type)?.defaultProperties ?? {};
  }

  static Size getDefaultSize(String type) {
    return getByType(type)?.defaultSize ?? const Size(100, 60);
  }

  static int getMaxChildren(String type) {
    return getByType(type)?.maxChildren ?? 0;
  }

  static bool canHaveChildren(String type) {
    return getByType(type)?.canHaveChildren ?? false;
  }

  static String getChildrenInfo(String type) {
    return getByType(type)?.childrenInfo ?? 'No children';
  }
} 