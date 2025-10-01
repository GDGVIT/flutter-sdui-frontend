import 'package:flutter/material.dart';
import 'package:flutter_sdui_frontend/services/widget_properties_service.dart';

import 'widget_registry_entry.dart';

final List<WidgetRegistryEntry> widgetRegistryEntries = [
  // ... all WidgetRegistryEntry definitions for SDUI widgets ...
  const WidgetRegistryEntry(
    type: 'SduiColumn',
    label: 'SduiColumn',
    icon: Icons.view_column,
    category: 'Layout Widgets',
    childrenInfo: 'Multiple SDUI children',
    maxChildren: -1,
    canHaveChildren: true,
    propertyDefinitions: [
      PropertyDefinition<String>(
          'mainAxisAlignment', 'Main Axis Alignment', PropertyType.dropdown,
          options: [
            'start',
            'end',
            'center',
            'spaceBetween',
            'spaceAround',
            'spaceEvenly'
          ]),
      PropertyDefinition<String>(
          'crossAxisAlignment', 'Cross Axis Alignment', PropertyType.dropdown,
          options: ['start', 'end', 'center', 'stretch', 'baseline']),
      PropertyDefinition<String>(
          'mainAxisSize', 'Main Axis Size', PropertyType.dropdown,
          options: ['min', 'max']),
      PropertyDefinition<String>(
          'textDirection', 'Text Direction', PropertyType.dropdown,
          options: ['ltr', 'rtl']),
      PropertyDefinition<String>(
          'verticalDirection', 'Vertical Direction', PropertyType.dropdown,
          options: ['down', 'up']),
      PropertyDefinition<String>(
          'textBaseline', 'Text Baseline', PropertyType.dropdown,
          options: ['alphabetic', 'ideographic']),
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

  const WidgetRegistryEntry(
    type: 'SduiRow',
    label: 'SduiRow',
    icon: Icons.view_stream,
    category: 'Layout Widgets',
    childrenInfo: 'Multiple SDUI children',
    maxChildren: -1,
    canHaveChildren: true,
    propertyDefinitions: [
      PropertyDefinition<String>(
          'mainAxisAlignment', 'Main Axis Alignment', PropertyType.dropdown,
          options: [
            'start',
            'end',
            'center',
            'spaceBetween',
            'spaceAround',
            'spaceEvenly'
          ]),
      PropertyDefinition<String>(
          'crossAxisAlignment', 'Cross Axis Alignment', PropertyType.dropdown,
          options: ['start', 'end', 'center', 'stretch', 'baseline']),
      PropertyDefinition<String>(
          'mainAxisSize', 'Main Axis Size', PropertyType.dropdown,
          options: ['min', 'max']),
      PropertyDefinition<String>(
          'textDirection', 'Text Direction', PropertyType.dropdown,
          options: ['ltr', 'rtl']),
      PropertyDefinition<String>(
          'verticalDirection', 'Vertical Direction', PropertyType.dropdown,
          options: ['down', 'up']),
      PropertyDefinition<String>(
          'textBaseline', 'Text Baseline', PropertyType.dropdown,
          options: ['alphabetic', 'ideographic']),
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

 const  WidgetRegistryEntry(
    type: 'SduiContainer',
    label: 'SduiContainer',
    icon: Icons.crop_square,
    category: 'Layout Widgets',
    childrenInfo: 'Single SDUI child',
    maxChildren: 1,
    canHaveChildren: true,
    propertyDefinitions: [
      PropertyDefinition<double>('width', 'Width', PropertyType.number),
      PropertyDefinition<double>('height', 'Height', PropertyType.number),
      PropertyDefinition<String>('color', 'Color', PropertyType.color),
      PropertyDefinition<double>('padding', 'Padding', PropertyType.number),
      PropertyDefinition<double>('margin', 'Margin', PropertyType.number),
      PropertyDefinition<String>('alignment', 'Alignment', PropertyType.dropdown,
          options: [
            'topLeft',
            'topCenter',
            'topRight',
            'centerLeft',
            'center',
            'centerRight',
            'bottomLeft',
            'bottomCenter',
            'bottomRight'
          ]),
      PropertyDefinition<double>(
          'borderRadius', 'Border Radius', PropertyType.number),
      PropertyDefinition<String>(
          'borderColor', 'Border Color', PropertyType.color),
      PropertyDefinition<double>(
          'borderWidth', 'Border Width', PropertyType.number),
      PropertyDefinition<String>(
          'shadowColor', 'Shadow Color', PropertyType.color),
      PropertyDefinition<double>(
          'shadowOffsetX', 'Shadow Offset X', PropertyType.number),
      PropertyDefinition<double>(
          'shadowOffsetY', 'Shadow Offset Y', PropertyType.number),
      PropertyDefinition<double>(
          'shadowBlurRadius', 'Shadow Blur Radius', PropertyType.number),
      PropertyDefinition<double>(
          'shadowSpreadRadius', 'Shadow Spread Radius', PropertyType.number),
    ],
    defaultProperties: {
      'width': 200.0,
      'height': 100.0,
      'color': 0xFFFFFFFF,
      'padding': 0.0,
      'margin': 0.0,
      'alignment': 'center',
      'borderRadius': 0.0,
      'borderColor': 0xFF232526,
      'borderWidth': 0.0,
      'shadowColor': 0x00000000,
      'shadowOffsetX': 0.0,
      'shadowOffsetY': 0.0,
      'shadowBlurRadius': 0.0,
      'shadowSpreadRadius': 0.0,
    },
    defaultSize: const Size(200, 100),
  ),

  const WidgetRegistryEntry(
    type: 'SduiScaffold',
    label: 'SduiScaffold',
    icon: Icons.web_asset,
    category: 'Layout Widgets',
    childrenInfo: 'Single SDUI child (body)',
    maxChildren: 1,
    canHaveChildren: true,
    propertyDefinitions: [
      PropertyDefinition<bool>('showAppBar', 'Show AppBar', PropertyType.boolean),
      PropertyDefinition<String>('appBarTitle', 'AppBar Title', PropertyType.text),
      PropertyDefinition<String>(
          'appBarBackgroundColor', 'AppBar Background Color', PropertyType.color),
      PropertyDefinition<String>(
          'backgroundColor', 'Background Color', PropertyType.color),
      PropertyDefinition<bool>('resizeToAvoidBottomInset',
          'Resize To Avoid Bottom Inset', PropertyType.boolean),
      PropertyDefinition<bool>('primary', 'Primary', PropertyType.boolean),
      PropertyDefinition<String>('floatingActionButtonLocation',
          'Floating Action Button Location', PropertyType.text),
      PropertyDefinition<bool>(
          'extendBody', 'Extend Body', PropertyType.boolean),
      PropertyDefinition<bool>('extendBodyBehindAppBar',
          'Extend Body Behind AppBar', PropertyType.boolean),
      PropertyDefinition<String>(
          'drawerScrimColor', 'Drawer Scrim Color', PropertyType.color),
      PropertyDefinition<double>(
          'drawerEdgeDragWidth', 'Drawer Edge Drag Width', PropertyType.number),
      PropertyDefinition<bool>('drawerEnableOpenDragGesture',
          'Drawer Enable Open Drag Gesture', PropertyType.boolean),
      PropertyDefinition<bool>('endDrawerEnableOpenDragGesture',
          'End Drawer Enable Open Drag Gesture', PropertyType.boolean),
    ],
    defaultProperties: {
      'showAppBar': true,
      'appBarTitle': 'AppBar',
      'appBarBackgroundColor': null,
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

  const WidgetRegistryEntry(
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
      'width': 100.0,
      'height': 40.0,
    },
    defaultSize: const Size(100, 40),
  ),

  const WidgetRegistryEntry(
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

 const  WidgetRegistryEntry(
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
      PropertyDefinition<String>(
          'fontWeight', 'Font Weight', PropertyType.dropdown,
          options: [
            'normal',
            'bold',
            'w100',
            'w200',
            'w300',
            'w400',
            'w500',
            'w600',
            'w700',
            'w800',
            'w900'
          ]),
      PropertyDefinition<String>('color', 'Color', PropertyType.color),
      PropertyDefinition<String>(
          'textAlign', 'Text Align', PropertyType.dropdown,
          options: ['left', 'right', 'center', 'justify']),
      PropertyDefinition<String>(
          'fontFamily', 'Font Family', PropertyType.dropdown,
          options: [
            'Roboto',
            'Arial',
            'Helvetica',
            'Times New Roman',
            'Courier New',
            'Montserrat',
            'Lato',
            'Poppins'
          ]),
      PropertyDefinition<double>(
          'letterSpacing', 'Letter Spacing', PropertyType.number),
      PropertyDefinition<double>(
          'wordSpacing', 'Word Spacing', PropertyType.number),
      PropertyDefinition<double>('height', 'Line Height', PropertyType.number),
      PropertyDefinition<int>('maxLines', 'Max Lines', PropertyType.number),
      PropertyDefinition<String>('overflow', 'Overflow', PropertyType.dropdown,
          options: ['clip', 'fade', 'ellipsis', 'visible']),
      PropertyDefinition<bool>('softWrap', 'Soft Wrap', PropertyType.boolean),
      PropertyDefinition<String>(
          'decoration', 'Decoration', PropertyType.dropdown,
          options: ['none', 'underline', 'overline', 'lineThrough']),
      PropertyDefinition<String>(
          'textDirection', 'Text Direction', PropertyType.dropdown,
          options: ['ltr', 'rtl']),
    ],
    defaultProperties: {
      'text': 'Text',
      'fontSize': 16.0,
      'fontWeight': 'normal',
      'color': 0xFF232526,
      'textAlign': 'left',
      'fontFamily': 'Roboto',
      'letterSpacing': 0.0,
      'wordSpacing': 0.0,
      'height': 1.2,
      'maxLines': 1,
      'overflow': 'clip',
      'softWrap': true,
      'decoration': 'none',
      'textDirection': 'ltr',
    },
    defaultSize: const Size(100, 60),
  ),

  const WidgetRegistryEntry(
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
      PropertyDefinition<String>('fit', 'Box Fit', PropertyType.dropdown,
          options: [
            'fill',
            'contain',
            'cover',
            'fitWidth',
            'fitHeight',
            'none',
            'scaleDown'
          ]),
      PropertyDefinition<double>(
          'borderRadius', 'Border Radius', PropertyType.number),
      PropertyDefinition<String>(
          'alignment', 'Alignment', PropertyType.dropdown,
          options: [
            'topLeft',
            'topCenter',
            'topRight',
            'centerLeft',
            'center',
            'centerRight',
            'bottomLeft',
            'bottomCenter',
            'bottomRight'
          ]),
      PropertyDefinition<String>('repeat', 'Repeat', PropertyType.dropdown,
          options: ['noRepeat', 'repeat', 'repeatX', 'repeatY']),
      PropertyDefinition<String>('color', 'Color', PropertyType.color),
      PropertyDefinition<String>(
          'colorBlendMode', 'Color Blend Mode', PropertyType.dropdown,
          options: [
            'clear',
            'src',
            'dst',
            'srcOver',
            'dstOver',
            'srcIn',
            'dstIn',
            'srcOut',
            'dstOut',
            'srcATop',
            'dstATop',
            'xor',
            'plus',
            'modulate',
            'screen',
            'overlay',
            'darken',
            'lighten',
            'colorDodge',
            'colorBurn',
            'hardLight',
            'softLight',
            'difference',
            'exclusion',
            'multiply',
            'hue',
            'saturation',
            'color',
            'luminosity'
          ]),
      PropertyDefinition<String>(
          'centerSlice', 'Center Slice', PropertyType.text),
      PropertyDefinition<bool>(
          'matchTextDirection', 'Match Text Direction', PropertyType.boolean),
      PropertyDefinition<bool>(
          'gaplessPlayback', 'Gapless Playback', PropertyType.boolean),
      PropertyDefinition<String>(
          'filterQuality', 'Filter Quality', PropertyType.dropdown,
          options: ['none', 'low', 'medium', 'high']),
      PropertyDefinition<int>('cacheWidth', 'Cache Width', PropertyType.number),
      PropertyDefinition<int>(
          'cacheHeight', 'Cache Height', PropertyType.number),
      PropertyDefinition<double>('scale', 'Scale', PropertyType.number),
      PropertyDefinition<String>(
          'semanticLabel', 'Semantic Label', PropertyType.text),
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

  const WidgetRegistryEntry(
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
      PropertyDefinition<String>(
          'semanticLabel', 'Semantic Label', PropertyType.text),
      PropertyDefinition<String>(
          'textDirection', 'Text Direction', PropertyType.dropdown,
          options: ['ltr', 'rtl']),
      PropertyDefinition<double>('opacity', 'Opacity', PropertyType.number),
      PropertyDefinition<bool>(
          'applyTextScaling', 'Apply Text Scaling', PropertyType.boolean),
      PropertyDefinition<String>('shadows', 'Shadows', PropertyType.text),
    ],
    defaultProperties: {
      'icon': 'star',
      'size': 32.0,
      'color': 0xFF232526,
      'semanticLabel': null,
      'textDirection': 'ltr',
      'opacity': 1.0,
      'applyTextScaling': false,
      'shadows': null,
    },
    defaultSize: const Size(40, 40),
  ),
];
