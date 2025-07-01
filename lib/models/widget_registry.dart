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

class WidgetRegistry {
  static final List<WidgetRegistryEntry> entries = [
    WidgetRegistryEntry(
      type: 'SduiColumn',
      label: 'SduiColumn',
      icon: Icons.view_column,
      category: 'Layout Widgets',
      childrenInfo: 'Multiple SDUI children',
      maxChildren: -1,
      canHaveChildren: true,
      propertyDefinitions: [
        PropertyDefinition<String>('mainAxisAlignment', 'Main Axis Alignment', PropertyType.dropdown, options: [
          'start', 'end', 'center', 'spaceBetween', 'spaceAround', 'spaceEvenly']),
        PropertyDefinition<String>('crossAxisAlignment', 'Cross Axis Alignment', PropertyType.dropdown, options: [
          'start', 'end', 'center', 'stretch', 'baseline']),
        PropertyDefinition<String>('mainAxisSize', 'Main Axis Size', PropertyType.dropdown, options: ['min', 'max']),
        PropertyDefinition<String>('textDirection', 'Text Direction', PropertyType.dropdown, options: ['ltr', 'rtl']),
        PropertyDefinition<String>('verticalDirection', 'Vertical Direction', PropertyType.dropdown, options: ['down', 'up']),
        PropertyDefinition<String>('textBaseline', 'Text Baseline', PropertyType.dropdown, options: ['alphabetic', 'ideographic']),
      ],
      defaultProperties: {
        'mainAxisAlignment': 'start',
        'mainAxisSize': 'max',
        'crossAxisAlignment': 'center',
        'textDirection': null,
        'verticalDirection': 'down',
        'textBaseline': null,
        'width': 200.0,
        'height': 300.0,
      },
      defaultSize: const Size(200, 300),
    ),
    WidgetRegistryEntry(
      type: 'SduiRow',
      label: 'SduiRow',
      icon: Icons.view_stream,
      category: 'Layout Widgets',
      childrenInfo: 'Multiple SDUI children',
      maxChildren: -1,
      canHaveChildren: true,
      propertyDefinitions: [
        PropertyDefinition<String>('mainAxisAlignment', 'Main Axis Alignment', PropertyType.dropdown, options: [
          'start', 'end', 'center', 'spaceBetween', 'spaceAround', 'spaceEvenly']),
        PropertyDefinition<String>('crossAxisAlignment', 'Cross Axis Alignment', PropertyType.dropdown, options: [
          'start', 'end', 'center', 'stretch', 'baseline']),
        PropertyDefinition<String>('mainAxisSize', 'Main Axis Size', PropertyType.dropdown, options: ['min', 'max']),
        PropertyDefinition<String>('textDirection', 'Text Direction', PropertyType.dropdown, options: ['ltr', 'rtl']),
        PropertyDefinition<String>('verticalDirection', 'Vertical Direction', PropertyType.dropdown, options: ['down', 'up']),
        PropertyDefinition<String>('textBaseline', 'Text Baseline', PropertyType.dropdown, options: ['alphabetic', 'ideographic']),
      ],
      defaultProperties: {
        'mainAxisAlignment': 'start',
        'mainAxisSize': 'max',
        'crossAxisAlignment': 'center',
        'textDirection': null,
        'verticalDirection': 'down',
        'textBaseline': null,
        'width': 200.0,
        'height': 300.0,
      },
      defaultSize: const Size(200, 300),
    ),
    WidgetRegistryEntry(
      type: 'SduiContainer',
      label: 'SduiContainer',
      icon: Icons.crop_square,
      category: 'Layout Widgets',
      childrenInfo: 'Single SDUI child',
      maxChildren: 1,
      canHaveChildren: true,
      propertyDefinitions: [
        PropertyDefinition<String>('mainAxisAlignment', 'Main Axis Alignment', PropertyType.dropdown, options: [
          'start', 'end', 'center', 'spaceBetween', 'spaceAround', 'spaceEvenly']),
        PropertyDefinition<String>('crossAxisAlignment', 'Cross Axis Alignment', PropertyType.dropdown, options: [
          'start', 'end', 'center', 'stretch', 'baseline']),
        PropertyDefinition<String>('mainAxisSize', 'Main Axis Size', PropertyType.dropdown, options: ['min', 'max']),
        PropertyDefinition<String>('textDirection', 'Text Direction', PropertyType.dropdown, options: ['ltr', 'rtl']),
        PropertyDefinition<String>('verticalDirection', 'Vertical Direction', PropertyType.dropdown, options: ['down', 'up']),
        PropertyDefinition<String>('textBaseline', 'Text Baseline', PropertyType.dropdown, options: ['alphabetic', 'ideographic']),
      ],
      defaultProperties: {
        'mainAxisAlignment': 'start',
        'mainAxisSize': 'max',
        'crossAxisAlignment': 'center',
        'textDirection': null,
        'verticalDirection': 'down',
        'textBaseline': null,
        'width': 200.0,
        'height': 300.0,
      },
      defaultSize: const Size(200, 300),
    ),
    WidgetRegistryEntry(
      type: 'SduiScaffold',
      label: 'SduiScaffold',
      icon: Icons.web_asset,
      category: 'Layout Widgets',
      childrenInfo: 'Single SDUI child (body)',
      maxChildren: 1,
      canHaveChildren: true,
      propertyDefinitions: [
        PropertyDefinition<String>('backgroundColor', 'Background Color', PropertyType.color),
        PropertyDefinition<bool>('resizeToAvoidBottomInset', 'Resize To Avoid Bottom Inset', PropertyType.boolean),
        PropertyDefinition<bool>('primary', 'Primary', PropertyType.boolean),
        PropertyDefinition<String>('floatingActionButtonLocation', 'Floating Action Button Location', PropertyType.text),
        PropertyDefinition<bool>('extendBody', 'Extend Body', PropertyType.boolean),
        PropertyDefinition<bool>('extendBodyBehindAppBar', 'Extend Body Behind AppBar', PropertyType.boolean),
        PropertyDefinition<String>('drawerScrimColor', 'Drawer Scrim Color', PropertyType.color),
        PropertyDefinition<double>('drawerEdgeDragWidth', 'Drawer Edge Drag Width', PropertyType.number),
        PropertyDefinition<bool>('drawerEnableOpenDragGesture', 'Drawer Enable Open Drag Gesture', PropertyType.boolean),
        PropertyDefinition<bool>('endDrawerEnableOpenDragGesture', 'End Drawer Enable Open Drag Gesture', PropertyType.boolean),
      ],
      defaultProperties: {
        'backgroundColor': null,
        'resizeToAvoidBottomInset': null,
        'primary': true,
        'floatingActionButtonLocation': null,
        'extendBody': false,
        'extendBodyBehindAppBar': false,
        'drawerScrimColor': null,
        'drawerEdgeDragWidth': null,
        'drawerEnableOpenDragGesture': true,
        'endDrawerEnableOpenDragGesture': true,
      },
      defaultSize: const Size(200, 300),
    ),
    WidgetRegistryEntry(
      type: 'SduiSizedBox',
      label: 'SduiSizedBox',
      icon: Icons.crop_16_9,
      category: 'Layout Widgets',
      childrenInfo: 'Single SDUI child (optional)',
      maxChildren: 1,
      canHaveChildren: true,
      propertyDefinitions: [
        PropertyDefinition<double>('width', 'Width', PropertyType.number),
        PropertyDefinition<double>('height', 'Height', PropertyType.number),
      ],
      defaultProperties: {
        'width': null,
        'height': null,
      },
      defaultSize: const Size(200, 300),
    ),
    WidgetRegistryEntry(
      type: 'SduiSpacer',
      label: 'SduiSpacer',
      icon: Icons.space_bar,
      category: 'Layout Widgets',
      childrenInfo: 'No children',
      maxChildren: 0,
      canHaveChildren: false,
      propertyDefinitions: [
        PropertyDefinition<int>('flex', 'Flex', PropertyType.number),
      ],
      defaultProperties: {
        'flex': 1,
      },
      defaultSize: const Size(0, 0),
    ),
    WidgetRegistryEntry(
      type: 'SduiText',
      label: 'SduiText',
      icon: Icons.text_fields,
      category: 'Display Widgets',
      childrenInfo: 'No children',
      maxChildren: 0,
      canHaveChildren: false,
      propertyDefinitions: [
        PropertyDefinition<String>('text', 'Text', PropertyType.text),
        PropertyDefinition<double>('fontSize', 'Font Size', PropertyType.number),
        PropertyDefinition<String>('fontWeight', 'Font Weight', PropertyType.dropdown, options: [
          'normal', 'bold', 'w100', 'w200', 'w300', 'w400', 'w500', 'w600', 'w700', 'w800', 'w900']),
        PropertyDefinition<String>('color', 'Color', PropertyType.color),
        PropertyDefinition<String>('textAlign', 'Text Align', PropertyType.dropdown, options: [
          'left', 'right', 'center', 'justify']),
        PropertyDefinition<String>('fontFamily', 'Font Family', PropertyType.dropdown, options: [
          'Roboto', 'Arial', 'Helvetica', 'Times New Roman', 'Courier New']),
        PropertyDefinition<double>('letterSpacing', 'Letter Spacing', PropertyType.number),
        PropertyDefinition<double>('wordSpacing', 'Word Spacing', PropertyType.number),
        PropertyDefinition<double>('height', 'Line Height', PropertyType.number),
        PropertyDefinition<int>('maxLines', 'Max Lines', PropertyType.number),
        PropertyDefinition<String>('overflow', 'Overflow', PropertyType.dropdown, options: [
          'clip', 'fade', 'ellipsis', 'visible']),
        PropertyDefinition<bool>('softWrap', 'Soft Wrap', PropertyType.boolean),
        PropertyDefinition<String>('decoration', 'Decoration', PropertyType.dropdown, options: [
          'none', 'underline', 'overline', 'lineThrough']),
        PropertyDefinition<String>('textDirection', 'Text Direction', PropertyType.dropdown, options: ['ltr', 'rtl']),
      ],
      defaultProperties: {
        'text': '',
        'fontSize': null,
        'fontWeight': 'normal',
        'color': null,
        'textAlign': null,
        'fontFamily': null,
        'letterSpacing': null,
        'wordSpacing': null,
        'height': null,
        'maxLines': null,
        'overflow': null,
        'softWrap': null,
        'decoration': 'none',
        'textDirection': null,
      },
      defaultSize: const Size(100, 60),
    ),
    WidgetRegistryEntry(
      type: 'SduiImage',
      label: 'SduiImage',
      icon: Icons.image,
      category: 'Display Widgets',
      childrenInfo: 'No children',
      maxChildren: 0,
      canHaveChildren: false,
      propertyDefinitions: [
        PropertyDefinition<String>('src', 'Image Source', PropertyType.text),
        PropertyDefinition<double>('width', 'Width', PropertyType.number),
        PropertyDefinition<double>('height', 'Height', PropertyType.number),
        PropertyDefinition<String>('fit', 'Box Fit', PropertyType.dropdown, options: [
          'fill', 'contain', 'cover', 'fitWidth', 'fitHeight', 'none', 'scaleDown']),
        PropertyDefinition<String>('alignment', 'Alignment', PropertyType.dropdown, options: [
          'topLeft', 'topCenter', 'topRight', 'centerLeft', 'center', 'centerRight',
          'bottomLeft', 'bottomCenter', 'bottomRight']),
        PropertyDefinition<String>('repeat', 'Repeat', PropertyType.dropdown, options: [
          'noRepeat', 'repeat', 'repeatX', 'repeatY']),
        PropertyDefinition<String>('color', 'Color', PropertyType.color),
        PropertyDefinition<String>('colorBlendMode', 'Color Blend Mode', PropertyType.dropdown, options: [
          'clear', 'src', 'dst', 'srcOver', 'dstOver', 'srcIn', 'dstIn', 'srcOut', 'dstOut', 'srcATop', 'dstATop', 'xor', 'plus', 'modulate', 'screen', 'overlay', 'darken', 'lighten', 'colorDodge', 'colorBurn', 'hardLight', 'softLight', 'difference', 'exclusion', 'multiply', 'hue', 'saturation', 'color', 'luminosity']),
        PropertyDefinition<String>('centerSlice', 'Center Slice', PropertyType.text),
        PropertyDefinition<bool>('matchTextDirection', 'Match Text Direction', PropertyType.boolean),
        PropertyDefinition<bool>('gaplessPlayback', 'Gapless Playback', PropertyType.boolean),
        PropertyDefinition<String>('filterQuality', 'Filter Quality', PropertyType.dropdown, options: ['none', 'low', 'medium', 'high']),
        PropertyDefinition<int>('cacheWidth', 'Cache Width', PropertyType.number),
        PropertyDefinition<int>('cacheHeight', 'Cache Height', PropertyType.number),
        PropertyDefinition<double>('scale', 'Scale', PropertyType.number),
        PropertyDefinition<String>('semanticLabel', 'Semantic Label', PropertyType.text),
      ],
      defaultProperties: {
        'src': '',
        'width': null,
        'height': null,
        'fit': null,
        'alignment': 'center',
        'repeat': 'noRepeat',
        'color': null,
        'colorBlendMode': null,
        'centerSlice': null,
        'matchTextDirection': false,
        'gaplessPlayback': false,
        'filterQuality': 'low',
        'cacheWidth': null,
        'cacheHeight': null,
        'scale': 1.0,
        'semanticLabel': null,
      },
      defaultSize: const Size(100, 60),
    ),
    WidgetRegistryEntry(
      type: 'SduiIcon',
      label: 'SduiIcon',
      icon: Icons.insert_emoticon,
      category: 'Display Widgets',
      childrenInfo: 'No children',
      maxChildren: 0,
      canHaveChildren: false,
      propertyDefinitions: [
        PropertyDefinition<String>('icon', 'Icon Name', PropertyType.text),
        PropertyDefinition<double>('size', 'Icon Size', PropertyType.number),
        PropertyDefinition<String>('color', 'Icon Color', PropertyType.color),
        PropertyDefinition<String>('semanticLabel', 'Semantic Label', PropertyType.text),
        PropertyDefinition<String>('textDirection', 'Text Direction', PropertyType.dropdown, options: ['ltr', 'rtl']),
        PropertyDefinition<double>('opacity', 'Opacity', PropertyType.number),
        PropertyDefinition<bool>('applyTextScaling', 'Apply Text Scaling', PropertyType.boolean),
        PropertyDefinition<String>('shadows', 'Shadows', PropertyType.text),
      ],
      defaultProperties: {
        'icon': null,
        'size': null,
        'color': null,
        'semanticLabel': null,
        'textDirection': null,
        'opacity': null,
        'applyTextScaling': null,
        'shadows': null,
      },
      defaultSize: const Size(100, 60),
    ),
  ];

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