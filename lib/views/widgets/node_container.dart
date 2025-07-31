import 'package:flutter/material.dart';
import '../../models/widget_node.dart';
import 'canvas_utils.dart';

// This file will contain the NodeContainer and ResizeHandle widgets/functions.
// The logic will be moved from design_canvas.dart. 

Widget buildNodeContainer({
  required WidgetNode node,
  required Widget childContent,
  required Size visualSize,
  required bool isSelected,
  required bool isHovered,
  required bool isScaffold,
  required void Function() onTap,
  required List<Widget> resizeHandles,
}) {
  Widget container = GestureDetector(
    onTap: onTap,
    child: Container(
      width: visualSize.width,
      height: visualSize.height,
      decoration: BoxDecoration(
        color: isScaffold
            ? parseColor(node.properties['backgroundColor']?.toString() ?? '#FF2F2F2F')
            : node.type == 'Container Widget'
                ? parseColor(node.properties['color']?.toString() ?? '#FF3F3F3F')
                : const Color(0xFF3F3F3F),
        border: Border.all(
          color: isScaffold
              ? const Color(0xFF4CAF50)
              : isSelected || isHovered
                  ? const Color(0xFF4CAF50)
                  : parseColor(node.properties['borderColor']?.toString() ?? '#FFE0E0E0'),
          width: isScaffold ? 2 : (node.properties['borderWidth'] as double? ?? 1),
        ),
        borderRadius: BorderRadius.circular(
          node.type == 'Container Widget'
              ? (node.properties['borderRadius'] as double? ?? 8.0)
              : isScaffold ? 8 : 4,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 28,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF4CAF50).withOpacity(0.15) : const Color(0xFF232323),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              border: Border(
                bottom: BorderSide(color: isSelected ? const Color(0xFF4CAF50) : const Color(0xFF444444), width: 1),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Icon(node.icon, size: 16, color: isSelected ? const Color(0xFF4CAF50) : const Color(0xFFEDF1EE)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    node.label,
                    style: TextStyle(
                      color: isSelected ? const Color(0xFF4CAF50) : const Color(0xFFEDF1EE),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: childContent),
        ],
      ),
    ),
  );

  // Add resize handles if selected
  if (isSelected && resizeHandles.isNotEmpty) {
    container = Stack(
      children: [
        container,
        ...resizeHandles,
      ],
    );
  }
  return container;
}

Widget buildResizeHandle({
  required WidgetNode node,
  required Size visualSize,
  required int dx,
  required int dy,
  required void Function(DragStartDetails) onPanStart,
  required void Function(DragUpdateDetails) onPanUpdate,
  required void Function(DragEndDetails) onPanEnd,
}) {
  return Positioned(
    left: dx == -1 ? -8 : null,
    right: dx == 1 ? -8 : null,
    top: dy == -1 ? -8 : null,
    bottom: dy == 1 ? -8 : null,
    child: GestureDetector(
      behavior: HitTestBehavior.translucent,
      onPanStart: onPanStart,
      onPanUpdate: onPanUpdate,
      onPanEnd: onPanEnd,
      child: Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.green, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
  );
} 