import 'package:flutter/material.dart';
import '../../models/widget_node.dart';

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
  // Start with the current node's bounds
  double minX = node.position.dx;
  double minY = node.position.dy;
  double maxX = node.position.dx + node.size.width;
  double maxY = node.position.dy + node.size.height;

  for (final child in node.children) {
    // Recursively compute child bounds
    computeCanvasSize(child);
    
    // Update bounds to include child
    final childMinX = child.position.dx;
    final childMinY = child.position.dy;
    final childMaxX = child.position.dx + child.size.width;
    final childMaxY = child.position.dy + child.size.height;
    
    minX = minX < childMinX ? minX : childMinX;
    minY = minY < childMinY ? minY : childMinY;
    maxX = maxX > childMaxX ? maxX : childMaxX;
    maxY = maxY > childMaxY ? maxY : childMaxY;
  }
  
  // Add padding to ensure all content is visible and scrollable
  const double padding = 200;
  final double width = (maxX - minX + padding).clamp(1200, double.infinity);
  final double height = (maxY - minY + padding).clamp(900, double.infinity);
  
  return Size(width, height);
} 