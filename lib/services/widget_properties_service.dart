import 'package:flutter/material.dart';

class WidgetPropertiesService {
  // --- Modular property registry for all widget types ---
  static final Map<String, List<PropertyDefinition>> propertyRegistry = {
    // Legacy types
    'Container Widget': [
      PropertyDefinition<double>('width', 'Width', PropertyType.number),
      PropertyDefinition<double>('height', 'Height', PropertyType.number),
      PropertyDefinition<double>('widthPercent', 'Width (%)', PropertyType.number),
      PropertyDefinition<double>('heightPercent', 'Height (%)', PropertyType.number),
      PropertyDefinition<String>('color', 'Color', PropertyType.color),
      PropertyDefinition<double>('padding', 'Padding', PropertyType.number),
      PropertyDefinition<double>('margin', 'Margin', PropertyType.number),
      PropertyDefinition<String>('alignment', 'Alignment', PropertyType.dropdown, options: [
        'topLeft', 'topCenter', 'topRight', 'centerLeft', 'center', 'centerRight',
        'bottomLeft', 'bottomCenter', 'bottomRight']),
      PropertyDefinition<double>('borderRadius', 'Border Radius', PropertyType.number),
      PropertyDefinition<double>('borderWidth', 'Border Width', PropertyType.number),
      PropertyDefinition<String>('borderColor', 'Border Color', PropertyType.color),
      PropertyDefinition<double>('minWidth', 'Min Width', PropertyType.number),
      PropertyDefinition<double>('maxWidth', 'Max Width', PropertyType.number),
      PropertyDefinition<double>('minHeight', 'Min Height', PropertyType.number),
      PropertyDefinition<double>('maxHeight', 'Max Height', PropertyType.number),
    ],
    'Row Widget': [
      PropertyDefinition<String>('mainAxisAlignment', 'Main Axis Alignment', PropertyType.dropdown, options: [
        'start', 'end', 'center', 'spaceBetween', 'spaceAround', 'spaceEvenly']),
      PropertyDefinition<String>('crossAxisAlignment', 'Cross Axis Alignment', PropertyType.dropdown, options: [
        'start', 'end', 'center', 'stretch', 'baseline']),
      PropertyDefinition<String>('mainAxisSize', 'Main Axis Size', PropertyType.dropdown, options: ['min', 'max']),
      PropertyDefinition<double>('padding', 'Padding', PropertyType.number),
      PropertyDefinition<double>('margin', 'Margin', PropertyType.number),
      PropertyDefinition<double>('widthPercent', 'Width (%)', PropertyType.number),
      PropertyDefinition<double>('heightPercent', 'Height (%)', PropertyType.number),
    ],
    'Column Widget': [
      PropertyDefinition<String>('mainAxisAlignment', 'Main Axis Alignment', PropertyType.dropdown, options: [
        'start', 'end', 'center', 'spaceBetween', 'spaceAround', 'spaceEvenly']),
      PropertyDefinition<String>('crossAxisAlignment', 'Cross Axis Alignment', PropertyType.dropdown, options: [
        'start', 'end', 'center', 'stretch', 'baseline']),
      PropertyDefinition<String>('mainAxisSize', 'Main Axis Size', PropertyType.dropdown, options: ['min', 'max']),
      PropertyDefinition<double>('padding', 'Padding', PropertyType.number),
      PropertyDefinition<double>('margin', 'Margin', PropertyType.number),
      PropertyDefinition<double>('widthPercent', 'Width (%)', PropertyType.number),
      PropertyDefinition<double>('heightPercent', 'Height (%)', PropertyType.number),
    ],
    'Text Widget': [
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
      PropertyDefinition<double>('lineHeight', 'Line Height', PropertyType.number),
      PropertyDefinition<int>('maxLines', 'Max Lines', PropertyType.number),
      PropertyDefinition<String>('overflow', 'Overflow', PropertyType.dropdown, options: [
        'clip', 'fade', 'ellipsis', 'visible']),
      PropertyDefinition<double>('padding', 'Padding', PropertyType.number),
      PropertyDefinition<double>('margin', 'Margin', PropertyType.number),
      PropertyDefinition<double>('widthPercent', 'Width (%)', PropertyType.number),
      PropertyDefinition<double>('heightPercent', 'Height (%)', PropertyType.number),
    ],
    'Scaffold': [
      PropertyDefinition<String>('backgroundColor', 'Background Color', PropertyType.color),
      PropertyDefinition<String>('appBarTitle', 'App Bar Title', PropertyType.text),
      PropertyDefinition<String>('appBarColor', 'App Bar Color', PropertyType.color),
      PropertyDefinition<double>('widthPercent', 'Width (%)', PropertyType.number),
      PropertyDefinition<double>('heightPercent', 'Height (%)', PropertyType.number),
    ],
    // --- SDUI types ---
    'SduiColumn': [
      PropertyDefinition<String>('mainAxisAlignment', 'Main Axis Alignment', PropertyType.dropdown, options: [
        'start', 'end', 'center', 'spaceBetween', 'spaceAround', 'spaceEvenly']),
      PropertyDefinition<String>('crossAxisAlignment', 'Cross Axis Alignment', PropertyType.dropdown, options: [
        'start', 'end', 'center', 'stretch', 'baseline']),
      PropertyDefinition<String>('mainAxisSize', 'Main Axis Size', PropertyType.dropdown, options: ['min', 'max']),
      PropertyDefinition<String>('textDirection', 'Text Direction', PropertyType.dropdown, options: ['ltr', 'rtl']),
      PropertyDefinition<String>('verticalDirection', 'Vertical Direction', PropertyType.dropdown, options: ['down', 'up']),
      PropertyDefinition<String>('textBaseline', 'Text Baseline', PropertyType.dropdown, options: ['alphabetic', 'ideographic']),
    ],
    'SduiRow': [
      PropertyDefinition<String>('mainAxisAlignment', 'Main Axis Alignment', PropertyType.dropdown, options: [
        'start', 'end', 'center', 'spaceBetween', 'spaceAround', 'spaceEvenly']),
      PropertyDefinition<String>('crossAxisAlignment', 'Cross Axis Alignment', PropertyType.dropdown, options: [
        'start', 'end', 'center', 'stretch', 'baseline']),
      PropertyDefinition<String>('mainAxisSize', 'Main Axis Size', PropertyType.dropdown, options: ['min', 'max']),
      PropertyDefinition<String>('textDirection', 'Text Direction', PropertyType.dropdown, options: ['ltr', 'rtl']),
      PropertyDefinition<String>('verticalDirection', 'Vertical Direction', PropertyType.dropdown, options: ['down', 'up']),
      PropertyDefinition<String>('textBaseline', 'Text Baseline', PropertyType.dropdown, options: ['alphabetic', 'ideographic']),
    ],
    'SduiContainer': [
      PropertyDefinition<double>('width', 'Width', PropertyType.number),
      PropertyDefinition<double>('height', 'Height', PropertyType.number),
      PropertyDefinition<String>('color', 'Color', PropertyType.color),
      PropertyDefinition<String>('alignment', 'Alignment', PropertyType.dropdown, options: [
        'topLeft', 'topCenter', 'topRight', 'centerLeft', 'center', 'centerRight',
        'bottomLeft', 'bottomCenter', 'bottomRight']),
      PropertyDefinition<double>('padding', 'Padding', PropertyType.number),
      PropertyDefinition<double>('margin', 'Margin', PropertyType.number),
      PropertyDefinition<double>('borderRadius', 'Border Radius', PropertyType.number),
      PropertyDefinition<double>('borderWidth', 'Border Width', PropertyType.number),
      PropertyDefinition<String>('borderColor', 'Border Color', PropertyType.color),
      PropertyDefinition<String>('constraints', 'Constraints', PropertyType.text),
      PropertyDefinition<String>('transform', 'Transform', PropertyType.text),
      PropertyDefinition<String>('transformAlignment', 'Transform Alignment', PropertyType.text),
      PropertyDefinition<String>('clipBehavior', 'Clip Behavior', PropertyType.dropdown, options: ['none', 'hardEdge', 'antiAlias', 'antiAliasWithSaveLayer']),
    ],
    'SduiText': [
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
    'SduiImage': [
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
    'SduiIcon': [
      PropertyDefinition<String>('icon', 'Icon Name', PropertyType.text),
      PropertyDefinition<double>('size', 'Icon Size', PropertyType.number),
      PropertyDefinition<String>('color', 'Icon Color', PropertyType.color),
      PropertyDefinition<String>('semanticLabel', 'Semantic Label', PropertyType.text),
      PropertyDefinition<String>('textDirection', 'Text Direction', PropertyType.dropdown, options: ['ltr', 'rtl']),
      PropertyDefinition<double>('opacity', 'Opacity', PropertyType.number),
      PropertyDefinition<bool>('applyTextScaling', 'Apply Text Scaling', PropertyType.boolean),
      PropertyDefinition<String>('shadows', 'Shadows', PropertyType.text),
    ],
    'SduiSpacer': [
      PropertyDefinition<int>('flex', 'Flex', PropertyType.number),
    ],
    'SduiSizedBox': [
      PropertyDefinition<double>('width', 'Width', PropertyType.number),
      PropertyDefinition<double>('height', 'Height', PropertyType.number),
    ],
    'SduiScaffold': [
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
  };

  static Map<String, dynamic> getDefaultProperties(String widgetType) {
    switch (widgetType) {
      case 'Container Widget':
        return {
          'width': 150.0,
          'height': 150.0,
          'widthPercent': null,
          'heightPercent': null,
          'color': '#FF3F3F3F',
          'padding': 8.0,
          'margin': 0.0,
          'alignment': 'center',
          'borderRadius': 8.0,
          'borderWidth': 0.0,
          'borderColor': '#FF666666',
          'minWidth': 0.0,
          'maxWidth': double.infinity,
          'minHeight': 0.0,
          'maxHeight': double.infinity,
        };
      case 'Row Widget':
        return {
          'mainAxisAlignment': 'start',
          'crossAxisAlignment': 'center',
          'mainAxisSize': 'max',
          'padding': 0.0,
          'margin': 0.0,
          'widthPercent': null,
          'heightPercent': null,
        };
      case 'Column Widget':
        return {
          'mainAxisAlignment': 'start',
          'crossAxisAlignment': 'center',
          'mainAxisSize': 'max',
          'padding': 0.0,
          'margin': 0.0,
          'widthPercent': null,
          'heightPercent': null,
        };
      case 'Stack Widget':
        return {
          'padding': 0.0,
          'margin': 0.0,
          'widthPercent': null,
          'heightPercent': null,
        };
      case 'Text Widget':
        return {
          'text': 'Text',
          'fontSize': 16.0,
          'fontWeight': 'normal',
          'color': '#FFEDF1EE',
          'textAlign': 'left',
          'fontFamily': 'Roboto',
          'letterSpacing': 0.0,
          'lineHeight': 1.0,
          'maxLines': null,
          'overflow': 'clip',
          'padding': 0.0,
          'margin': 0.0,
          'widthPercent': null,
          'heightPercent': null,
        };
      case 'TextField Widget':
        return {
          'hintText': 'Enter text...',
          'labelText': 'Label',
          'obscureText': false,
          'enabled': true,
          'maxLines': 1,
          'filled': false,
          'fillColor': '#FF2F2F2F',
          'padding': 8.0,
          'margin': 0.0,
          'widthPercent': null,
          'heightPercent': null,
        };
      case 'Scaffold':
        return {
          'backgroundColor': '#FF2F2F2F',
          'appBarTitle': 'App Bar',
          'appBarColor': '#FF232323',
          'widthPercent': null,
          'heightPercent': null,
        };
      case 'SduiColumn':
        return {
          'mainAxisAlignment': 'start',
          'mainAxisSize': 'max',
          'crossAxisAlignment': 'center',
          'textDirection': null,
          'verticalDirection': 'down',
          'textBaseline': null,
          'width': 200.0,
          'height': 300.0,
        };
      case 'SduiRow':
        return {
          'mainAxisAlignment': 'start',
          'mainAxisSize': 'max',
          'crossAxisAlignment': 'center',
          'textDirection': null,
          'verticalDirection': 'down',
          'textBaseline': null,
          'width': 300.0,
          'height': 100.0,
        };
      case 'SduiContainer':
        return {
          'width': null,
          'height': null,
          'color': null,
          'alignment': null,
          'padding': null,
          'margin': null,
          'borderRadius': null,
          'borderWidth': null,
          'borderColor': null,
          'constraints': null,
          'transform': null,
          'transformAlignment': null,
          'clipBehavior': 'none',
        };
      case 'SduiText':
        return {
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
        };
      case 'SduiImage':
        return {
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
        };
      case 'SduiIcon':
        return {
          'icon': null,
          'size': null,
          'color': null,
          'semanticLabel': null,
          'textDirection': null,
          'opacity': null,
          'applyTextScaling': null,
          'shadows': null,
        };
      case 'SduiSpacer':
        return {
          'flex': 1,
        };
      case 'SduiSizedBox':
        return {
          'width': null,
          'height': null,
        };
      case 'SduiScaffold':
        return {
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
        };
      default:
        return {};
    }
  }

  static List<PropertyDefinition<T>> getPropertyDefinitions<T>(String widgetType) {
    final defs = propertyRegistry[widgetType];
    if (defs != null) {
      return defs.cast<PropertyDefinition<T>>();
    }
    return [];
  }

  static WidgetConstraints getConstraints(String widgetType) {
    switch (widgetType) {
      case 'Scaffold':
        return const WidgetConstraints(maxChildren: 1, canHaveChildren: true);
      case 'Column Widget':
      case 'Row Widget':
      case 'Stack Widget':
      case 'SduiColumn':
      case 'SduiRow':
      case 'SduiStack':
        return const WidgetConstraints(maxChildren: -1, canHaveChildren: true); // Unlimited
      case 'Container Widget':
      case 'SduiContainer':
        return const WidgetConstraints(maxChildren: 1, canHaveChildren: true);
      case 'SduiScaffold':
        return const WidgetConstraints(maxChildren: 1, canHaveChildren: true);
      case 'Text Widget':
      case 'TextField Widget':
      case 'Image Widget':
      case 'SduiText':
      case 'SduiImage':
      case 'SduiIcon':
      case 'SduiSpacer':
        return const WidgetConstraints(maxChildren: 0, canHaveChildren: false); // No children
      default:
        return const WidgetConstraints(maxChildren: 0, canHaveChildren: false);
    }
  }

  static Size getDefaultSize(String widgetType) {
    switch (widgetType) {
      case 'Column Widget':
        return const Size(200, 300);
      case 'Row Widget':
        return const Size(300, 100);
      case 'Container Widget':
        return const Size(150, 150);
      case 'Stack Widget':
        return const Size(200, 200);
      case 'Text Widget':
        return const Size(120, 40);
      case 'TextField Widget':
        return const Size(200, 50);
      case 'Image Widget':
        return const Size(120, 120);
      default:
        return const Size(100, 60);
    }
  }

  static String getChildrenInfo(String widgetType) {
    switch (widgetType) {
      case 'SduiColumn':
        return 'Multiple SDUI children';
      case 'SduiRow':
        return 'Multiple SDUI children';
      case 'SduiContainer':
        return 'Single SDUI child';
      case 'SduiScaffold':
        return 'Single SDUI child (body)';
      case 'SduiSizedBox':
        return 'Single SDUI child (optional)';
      case 'SduiSpacer':
        return 'No children';
      case 'SduiText':
        return 'No children';
      case 'SduiImage':
        return 'No children';
      case 'SduiIcon':
        return 'No children';
      default:
        return 'No children';
    }
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