import 'package:flutter/material.dart';

class WidgetPropertiesService {
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
      default:
        return {};
    }
  }

  static List<PropertyDefinition<T>> getPropertyDefinitions<T>(String widgetType) {
    switch (widgetType) {
      case 'Container Widget':
        return [
          PropertyDefinition<double>('width', 'Width', PropertyType.number),
          PropertyDefinition<double>('height', 'Height', PropertyType.number),
          PropertyDefinition<double>('widthPercent', 'Width (%)', PropertyType.number),
          PropertyDefinition<double>('heightPercent', 'Height (%)', PropertyType.number),
          PropertyDefinition<String>('color', 'Color', PropertyType.color),
          PropertyDefinition<double>('padding', 'Padding', PropertyType.number),
          PropertyDefinition<double>('margin', 'Margin', PropertyType.number),
          PropertyDefinition<String>('alignment', 'Alignment', PropertyType.dropdown, 
            options: ['topLeft', 'topCenter', 'topRight', 'centerLeft', 'center', 'centerRight', 'bottomLeft', 'bottomCenter', 'bottomRight']),
          PropertyDefinition<double>('borderRadius', 'Border Radius', PropertyType.number),
          PropertyDefinition<double>('borderWidth', 'Border Width', PropertyType.number),
          PropertyDefinition<String>('borderColor', 'Border Color', PropertyType.color),
          PropertyDefinition<double>('minWidth', 'Min Width', PropertyType.number),
          PropertyDefinition<double>('maxWidth', 'Max Width', PropertyType.number),
          PropertyDefinition<double>('minHeight', 'Min Height', PropertyType.number),
          PropertyDefinition<double>('maxHeight', 'Max Height', PropertyType.number),
        ] as List<PropertyDefinition<T>>;
      case 'Row Widget':
        return [
          PropertyDefinition<String>('mainAxisAlignment', 'Main Axis Alignment', PropertyType.dropdown,
            options: ['start', 'end', 'center', 'spaceBetween', 'spaceAround', 'spaceEvenly']),
          PropertyDefinition<String>('crossAxisAlignment', 'Cross Axis Alignment', PropertyType.dropdown,
            options: ['start', 'end', 'center', 'stretch', 'baseline']),
          PropertyDefinition<String>('mainAxisSize', 'Main Axis Size', PropertyType.dropdown,
            options: ['min', 'max']),
          PropertyDefinition<double>('padding', 'Padding', PropertyType.number),
          PropertyDefinition<double>('margin', 'Margin', PropertyType.number),
          PropertyDefinition<double>('widthPercent', 'Width (%)', PropertyType.number),
          PropertyDefinition<double>('heightPercent', 'Height (%)', PropertyType.number),
        ] as List<PropertyDefinition<T>>;
      case 'Column Widget':
        return [
          PropertyDefinition<String>('mainAxisAlignment', 'Main Axis Alignment', PropertyType.dropdown,
            options: ['start', 'end', 'center', 'spaceBetween', 'spaceAround', 'spaceEvenly']),
          PropertyDefinition<String>('crossAxisAlignment', 'Cross Axis Alignment', PropertyType.dropdown,
            options: ['start', 'end', 'center', 'stretch', 'baseline']),
          PropertyDefinition<String>('mainAxisSize', 'Main Axis Size', PropertyType.dropdown,
            options: ['min', 'max']),
          PropertyDefinition<double>('padding', 'Padding', PropertyType.number),
          PropertyDefinition<double>('margin', 'Margin', PropertyType.number),
          PropertyDefinition<double>('widthPercent', 'Width (%)', PropertyType.number),
          PropertyDefinition<double>('heightPercent', 'Height (%)', PropertyType.number),
        ] as List<PropertyDefinition<T>>;
      case 'Stack Widget':
        return [
          PropertyDefinition<double>('padding', 'Padding', PropertyType.number),
          PropertyDefinition<double>('margin', 'Margin', PropertyType.number),
          PropertyDefinition<double>('widthPercent', 'Width (%)', PropertyType.number),
          PropertyDefinition<double>('heightPercent', 'Height (%)', PropertyType.number),
        ] as List<PropertyDefinition<T>>;
      case 'Text Widget':
        return [
          PropertyDefinition<String>('text', 'Text', PropertyType.text),
          PropertyDefinition<double>('fontSize', 'Font Size', PropertyType.number),
          PropertyDefinition<String>('fontWeight', 'Font Weight', PropertyType.dropdown,
            options: ['normal', 'bold', 'w100', 'w200', 'w300', 'w400', 'w500', 'w600', 'w700', 'w800', 'w900']),
          PropertyDefinition<String>('color', 'Color', PropertyType.color),
          PropertyDefinition<String>('textAlign', 'Text Align', PropertyType.dropdown,
            options: ['left', 'right', 'center', 'justify']),
          PropertyDefinition<String>('fontFamily', 'Font Family', PropertyType.dropdown,
            options: ['Roboto', 'Arial', 'Helvetica', 'Times New Roman', 'Courier New']),
          PropertyDefinition<double>('letterSpacing', 'Letter Spacing', PropertyType.number),
          PropertyDefinition<double>('lineHeight', 'Line Height', PropertyType.number),
          PropertyDefinition<int>('maxLines', 'Max Lines', PropertyType.number),
          PropertyDefinition<String>('overflow', 'Overflow', PropertyType.dropdown,
            options: ['clip', 'fade', 'ellipsis', 'visible']),
          PropertyDefinition<double>('padding', 'Padding', PropertyType.number),
          PropertyDefinition<double>('margin', 'Margin', PropertyType.number),
          PropertyDefinition<double>('widthPercent', 'Width (%)', PropertyType.number),
          PropertyDefinition<double>('heightPercent', 'Height (%)', PropertyType.number),
        ] as List<PropertyDefinition<T>>;
      case 'TextField Widget':
        return [
          PropertyDefinition<String>('hintText', 'Hint Text', PropertyType.text),
          PropertyDefinition<String>('labelText', 'Label Text', PropertyType.text),
          PropertyDefinition<bool>('obscureText', 'Obscure Text', PropertyType.boolean),
          PropertyDefinition<bool>('enabled', 'Enabled', PropertyType.boolean),
          PropertyDefinition<int>('maxLines', 'Max Lines', PropertyType.number),
          PropertyDefinition<bool>('filled', 'Filled', PropertyType.boolean),
          PropertyDefinition<String>('fillColor', 'Fill Color', PropertyType.color),
          PropertyDefinition<double>('padding', 'Padding', PropertyType.number),
          PropertyDefinition<double>('margin', 'Margin', PropertyType.number),
          PropertyDefinition<double>('widthPercent', 'Width (%)', PropertyType.number),
          PropertyDefinition<double>('heightPercent', 'Height (%)', PropertyType.number),
        ] as List<PropertyDefinition<T>>;
      case 'Scaffold':
        return [
          PropertyDefinition<String>('backgroundColor', 'Background Color', PropertyType.color),
          PropertyDefinition<String>('appBarTitle', 'App Bar Title', PropertyType.text),
          PropertyDefinition<String>('appBarColor', 'App Bar Color', PropertyType.color),
          PropertyDefinition<double>('widthPercent', 'Width (%)', PropertyType.number),
          PropertyDefinition<double>('heightPercent', 'Height (%)', PropertyType.number),
        ] as List<PropertyDefinition<T>>;
      default:
        return [];
    }
  }

  static WidgetConstraints getConstraints(String widgetType) {
    switch (widgetType) {
      case 'Scaffold':
        return const WidgetConstraints(maxChildren: 1, canHaveChildren: true);
      case 'Column Widget':
      case 'Row Widget':
      case 'Stack Widget':
        return const WidgetConstraints(maxChildren: -1, canHaveChildren: true); // Unlimited
      case 'Container Widget':
        return const WidgetConstraints(maxChildren: 1, canHaveChildren: true);
      case 'Text Widget':
      case 'TextField Widget':
      case 'Image Widget':
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