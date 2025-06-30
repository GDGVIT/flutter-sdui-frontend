import 'package:flutter/material.dart';
import '../../models/widget_node.dart';
import '../../models/app_theme.dart';

class PreviewCanvas extends StatelessWidget {
  final WidgetNode widgetRoot;
  final AppTheme appTheme;

  const PreviewCanvas({
    super.key,
    required this.widgetRoot,
    required this.appTheme,
  });

  @override
  Widget build(BuildContext context) {
    // Phone-like frame
    return Center(
        child: Container(
        width: 360,
        height: 640,
          decoration: BoxDecoration(
            color: Colors.black,
          borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
              child: Material(
                color: appTheme.backgroundColor,
            child: _buildWidgetNode(widgetRoot),
          ),
        ),
      ),
    );
  }

  Widget _buildWidgetNode(WidgetNode node) {
    // Minimal preview: just show type and children recursively
    if (node.type == 'Row Widget') {
      return Row(
        children: node.children.map(_buildWidgetNode).toList(),
      );
    } else if (node.type == 'Column Widget') {
      return Column(
        children: node.children.map(_buildWidgetNode).toList(),
      );
    } else if (node.type == 'Scaffold') {
      return Column(
        children: [
          Container(
            height: 56,
            color: appTheme.surfaceColor,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              node.properties['appBarTitle']?.toString() ?? 'App Bar',
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: node.children.isNotEmpty
                ? Stack(children: node.children.map(_buildWidgetNode).toList())
                : const SizedBox.shrink(),
          ),
        ],
          );
        } else {
      return Center(
        child: Text(
          node.label,
          style: const TextStyle(color: Color(0xFFEDF1EE)),
        ),
      );
    }
  }
} 