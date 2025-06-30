import 'package:flutter/material.dart';
import '../models/widget_node.dart';
import '../models/app_theme.dart';
import 'package:flutter_sdui/flutter_sdui.dart';

class PreviewWidgetService {
  /// Returns a preview widget for the given WidgetNode and theme.
  static Widget buildPreviewWidget(WidgetNode node, AppTheme appTheme) {
    final sduiWidget = _toSduiWidget(node);
    if (sduiWidget != null) {
      return sduiWidget.toFlutterWidget();
    }
    return const Center(child: Text('Unsupported widget type in preview'));
  }

  /// Converts a WidgetNode to an SDUI widget instance using the SDUI package.
  static SduiWidget? _toSduiWidget(WidgetNode node) {
    try {
      switch (node.type) {
        case 'SduiImage':
          return SduiImage("");
        case 'SduiText':
          return SduiText('Hello, World!');
        case 'SduiColumn':
          return SduiColumn(children: []);
        case 'SduiRow':
          return SduiRow(children: []);
        case 'SduiContainer':
          return SduiContainer();
        case 'SduiScaffold':
          return SduiScaffold();
        case 'SduiSizedBox':
          return SduiSizedBox();
        case 'SduiSpacer':
          return SduiSpacer();
        case 'SduiIcon':
          return SduiIcon();
        // Add more SDUI widget types as needed
        default:
          return null;
      }
    } catch (e) {
      debugPrint('SDUI conversion error: $e');
      return null;
    }
  }
} 