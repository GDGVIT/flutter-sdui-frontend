import 'package:flutter/material.dart';
import '../../models/widget_node.dart';
import '../../models/app_theme.dart';
import '../../models/widget_data.dart';
import 'build_pane.dart';
import 'widget_tree_pane.dart';
import 'import_pane.dart';
import 'export_pane.dart';
import 'theme_pane.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:flutter_sdui_frontend/viewmodels/design_canvas_viewmodel.dart';

class LeftSidebar extends StatelessWidget {
  final String selectedPane;
  final WidgetNode scaffoldWidget;
  final AppTheme appTheme;
  final Function(AppTheme) onThemeChanged;
  final Function(WidgetData) onWidgetDropped;
  final String? selectedWidgetId;
  final Function(String) onWidgetSelected;
  final void Function(WidgetData, Offset)? onPaletteDragStart;
  final void Function(Offset)? onPaletteDragUpdate;
  final VoidCallback? onPaletteDragEnd;

  const LeftSidebar({
    super.key,
    required this.selectedPane,
    required this.scaffoldWidget,
    required this.appTheme,
    required this.onThemeChanged,
    required this.onWidgetDropped,
    this.selectedWidgetId,
    required this.onWidgetSelected,
    this.onPaletteDragStart,
    this.onPaletteDragUpdate,
    this.onPaletteDragEnd,
  });

  // Set to true to show the theme panel in the sidebar
  static const bool _showThemePanel = true;

  @override
  Widget build(BuildContext context) {
    if (selectedPane == 'build') {
      return BuildPane(
        onWidgetDropped: onWidgetDropped,
        onPaletteDragStart: onPaletteDragStart,
        onPaletteDragUpdate: onPaletteDragUpdate,
        onPaletteDragEnd: onPaletteDragEnd,
      );
    } else if (selectedPane == 'widget-tree') {
      return WidgetTreePane(
        scaffoldWidget: scaffoldWidget,
        selectedWidgetId: selectedWidgetId,
        onWidgetSelected: onWidgetSelected,
      );
    } else if (selectedPane == 'theme') {
      if (_showThemePanel) {
        return ThemePane(
          appTheme: appTheme,
          onThemeChanged: onThemeChanged,
        );
      } else {
        return const Center(
          child: Text(
            'Theme panel is disabled.',
            style: TextStyle(color: Color(0xFFEDF1EE)),
          ),
        );
      }
    } else if (selectedPane == 'import') {
      return ImportPane(
        onImportJson: (jsonString) {
          try {
            final json = jsonDecode(jsonString);
            if (json is Map<String, dynamic>) {
              Provider.of<DesignCanvasViewModel>(context, listen: false).importFromSduiJson(json);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('JSON must be an object')),
              );
            }
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Invalid JSON: $e')),
            );
          }
        },
      );
    } else if (selectedPane == 'export') {
      return const ExportPane();
    } else {
      return const Center(
        child: Text(
          'Select a pane',
          style: TextStyle(color: Color(0xFFEDF1EE)),
        ),
      );
    }
  }
} 