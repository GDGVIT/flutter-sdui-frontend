import 'package:flutter/material.dart';
import '../../models/widget_node.dart';
import '../../models/widget_data.dart';

// Utility functions for the design canvas. To be moved from design_canvas.dart. 

bool canAcceptChildren(String type) {
  return type == 'Row Widget' ||
         type == 'Column Widget' ||
         type == 'Stack Widget' ||
         type == 'Scaffold' ||
         type == 'SduiColumn' ||
         type == 'SduiRow' ||
         type == 'SduiScaffold' ||
         type == 'SduiContainer';
}

bool isDescendant(WidgetNode parent, WidgetNode possibleDescendant) {
  if (parent == possibleDescendant) return true;
  for (final child in parent.children) {
    if (isDescendant(child, possibleDescendant)) return true;
  }
  return false;
}

void moveWidgetNode(Function(String, String) onWidgetReparent, WidgetNode dragged, WidgetNode newParent) {
  // print('_moveWidgetNode: dragged={dragged.type} (${dragged.uid}), newParent=${newParent.type} (${newParent.uid})');
  onWidgetReparent(dragged.uid, newParent.uid);
}

Color parseColor(String colorString) {
  try {
    return Color(int.parse(colorString.replaceFirst('#', '0x')));
  } catch (e) {
    return const Color(0xFF3F3F3F);
  }
}

// Recursively compute the bounding box of all widgets
Size computeCanvasSize(WidgetNode node) {
  double maxX = node.position.dx + node.size.width;
  double maxY = node.position.dy + node.size.height;
  for (final child in node.children) {
    final childSize = computeCanvasSize(child);
    if (child.position.dx + child.size.width > maxX) {
      maxX = child.position.dx + child.size.width;
    }
    if (child.position.dy + child.size.height > maxY) {
      maxY = child.position.dy + child.size.height;
    }
    if (childSize.width > maxX) maxX = childSize.width;
    if (childSize.height > maxY) maxY = childSize.height;
  }
  return Size(maxX, maxY);
} 