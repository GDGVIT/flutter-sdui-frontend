import 'package:flutter/material.dart';

class WidgetRegistryEntry {
  final String type;
  final String label;
  final IconData icon;
  final String category;
  final String childrenInfo;
  final int maxChildren;
  final bool canHaveChildren;

  const WidgetRegistryEntry({
    required this.type,
    required this.label,
    required this.icon,
    required this.category,
    required this.childrenInfo,
    required this.maxChildren,
    required this.canHaveChildren,
  });
}

const List<WidgetRegistryEntry> widgetRegistry = [
  WidgetRegistryEntry(
    type: 'SduiColumn',
    label: 'SduiColumn',
    icon: Icons.view_column,
    category: 'Layout Widgets',
    childrenInfo: 'Multiple SDUI children',
    maxChildren: -1,
    canHaveChildren: true,
  ),
  WidgetRegistryEntry(
    type: 'SduiRow',
    label: 'SduiRow',
    icon: Icons.view_stream,
    category: 'Layout Widgets',
    childrenInfo: 'Multiple SDUI children',
    maxChildren: -1,
    canHaveChildren: true,
  ),
  WidgetRegistryEntry(
    type: 'SduiContainer',
    label: 'SduiContainer',
    icon: Icons.crop_square,
    category: 'Layout Widgets',
    childrenInfo: 'Single SDUI child',
    maxChildren: 1,
    canHaveChildren: true,
  ),
  WidgetRegistryEntry(
    type: 'SduiScaffold',
    label: 'SduiScaffold',
    icon: Icons.web_asset,
    category: 'Layout Widgets',
    childrenInfo: 'Single SDUI child (body)',
    maxChildren: 1,
    canHaveChildren: true,
  ),
  WidgetRegistryEntry(
    type: 'SduiSizedBox',
    label: 'SduiSizedBox',
    icon: Icons.crop_16_9,
    category: 'Layout Widgets',
    childrenInfo: 'Single SDUI child (optional)',
    maxChildren: 1,
    canHaveChildren: true,
  ),
  WidgetRegistryEntry(
    type: 'SduiSpacer',
    label: 'SduiSpacer',
    icon: Icons.space_bar,
    category: 'Layout Widgets',
    childrenInfo: 'No children',
    maxChildren: 0,
    canHaveChildren: false,
  ),
  WidgetRegistryEntry(
    type: 'SduiText',
    label: 'SduiText',
    icon: Icons.text_fields,
    category: 'Display Widgets',
    childrenInfo: 'No children',
    maxChildren: 0,
    canHaveChildren: false,
  ),
  WidgetRegistryEntry(
    type: 'SduiImage',
    label: 'SduiImage',
    icon: Icons.image,
    category: 'Display Widgets',
    childrenInfo: 'No children',
    maxChildren: 0,
    canHaveChildren: false,
  ),
  WidgetRegistryEntry(
    type: 'SduiIcon',
    label: 'SduiIcon',
    icon: Icons.insert_emoticon,
    category: 'Display Widgets',
    childrenInfo: 'No children',
    maxChildren: 0,
    canHaveChildren: false,
  ),
]; 