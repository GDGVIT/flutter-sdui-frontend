import 'package:flutter/material.dart';
import '../../models/widget_node.dart';
import '../../models/widget_data.dart';
import 'canvas_utils.dart';
import 'node_container.dart';

// This widget/function encapsulates the drag-and-drop logic for widget nodes.
// It should be called from DesignCanvasState.

// Example usage:
// WidgetNodeDnD(
//   node: node,
//   depth: depth,
//   insideStack: insideStack,
//   ...other params...
// )

// For now, this is a placeholder. The full logic will be moved from design_canvas.dart. 

Widget buildWidgetNodeWithDnD({
  required WidgetNode node,
  required int depth,
  required bool insideStack,
  required String? selectedWidgetId,
  required String? hoveredWidgetId,
  required Map<String, GlobalKey> dropTargetKeys,
  required bool isDraggingFromPalette,
  required String? paletteDropTargetId,
  required String? deepestDropTargetId,
  required Function(String) onWidgetSelected,
  required Function(String, String) onWidgetReparent,
  required void Function(void Function()) setState,
  required Widget Function(WidgetNode, int, {bool insideStack}) buildWidgetNodeWithDnD,
  required Widget Function({required WidgetNode node, required Widget childContent, required Size visualSize, required bool isSelected, required bool isHovered, required bool isScaffold, required void Function() onTap, required List<Widget> resizeHandles}) buildNodeContainer,
  required Widget Function(WidgetNode node, Size visualSize, int dx, int dy) getResizeHandle,
  required Widget Function(WidgetNode, Size) dragFeedback,
}) {
  final isSelected = selectedWidgetId == node.uid;
  final isHovered = hoveredWidgetId == node.uid;
  final isScaffold = node.type == 'Scaffold' || node.type == 'SduiScaffold';
  final visualSize = node.size;
  final visualPosition = node.position;
  final canAccept = canAcceptChildren(node.type);

  // Advanced: Assign a GlobalKey for each drop target
  GlobalKey dropKey = dropTargetKeys[node.uid] ??= GlobalKey();

  Widget childContent;
  if (node.type == 'Row Widget' || node.type == 'SduiRow') {
    childContent = Container(
      width: node.size.width,
      height: node.size.height,
      child: Row(
        children: node.children.map((child) => buildWidgetNodeWithDnD(child, depth + 1, insideStack: false)).toList(),
      ),
    );
  } else if (node.type == 'Column Widget' || node.type == 'SduiColumn') {
    childContent = Container(
      width: node.size.width,
      height: node.size.height,
      child: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: node.children.map((child) => buildWidgetNodeWithDnD(child, depth + 1, insideStack: false)).toList(),
            ),
          ),
          // Show scroll indicator when there are many children
          if (node.children.length > 2)
            Positioned(
              right: 4,
              top: 4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
        ],
      ),
    );
  } else if (node.type == 'Stack Widget' || node.type == 'SduiStack') {
    childContent = Stack(
      children: node.children.map((child) => buildWidgetNodeWithDnD(child, depth + 1, insideStack: true)).toList(),
    );
  } else if (node.type == 'SduiContainer') {
    childContent = node.children.isNotEmpty
      ? buildWidgetNodeWithDnD(node.children.first, depth + 1, insideStack: false)
      : const SizedBox.shrink();
  } else if (node.type == 'Scaffold' || node.type == 'SduiScaffold') {
    final appBarTitle = node.properties['appBarTitle']?.toString() ?? '';
    final appBarColor = parseColor(node.properties['appBarColor']?.toString() ?? '#FF232323');
    childContent = Column(
      children: [
        GestureDetector(
          onTap: () => onWidgetSelected(node.uid),
          child: MouseRegion(
            onEnter: (_) => setState(() => hoveredWidgetId = node.uid),
            onExit: (_) => setState(() => hoveredWidgetId = null),
            child: Material(
              elevation: 2,
              color: appBarColor,
              child: Container(
                height: 56,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: (selectedWidgetId == node.uid || hoveredWidgetId == node.uid)
                          ? const Color(0xFF4CAF50)
                          : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
                child: Text(
                  appBarTitle.isNotEmpty ? appBarTitle : 'App Bar',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: node.children.isNotEmpty
              ? Stack(children: node.children.map((child) => buildWidgetNodeWithDnD(child, depth + 1, insideStack: true)).toList())
              : const SizedBox.shrink(),
        ),
      ],
    );
  } else {
    childContent = Center(
      child: Text(
        node.label,
        style: const TextStyle(color: Color(0xFFEDF1EE)),
      ),
    );
  }

  // Resize handles (for selected nodes)
  List<Widget> resizeHandles = [];
  if (isSelected) {
    resizeHandles = [
      getResizeHandle(node, visualSize, -1, -1),
      getResizeHandle(node, visualSize, 1, -1),
      getResizeHandle(node, visualSize, -1, 1),
      getResizeHandle(node, visualSize, 1, 1),
    ];
  }

  Widget nodeContainer = buildNodeContainer(
    node: node,
    childContent: childContent,
    visualSize: visualSize,
    isSelected: isSelected,
    isHovered: isHovered,
    isScaffold: isScaffold,
    onTap: () => onWidgetSelected(node.uid),
    resizeHandles: resizeHandles,
  );

  if (canAccept) {
    final baseNodeContainer = nodeContainer;
    nodeContainer = DragTarget<WidgetData>(
      key: dropKey,
      onWillAccept: (data) => false,
      onAccept: (data) {},
      builder: (context, candidateData, rejectedData) {
        return Stack(
          children: [
            baseNodeContainer,
            if ((isDraggingFromPalette && paletteDropTargetId == node.uid) || (!isDraggingFromPalette && deepestDropTargetId == node.uid && candidateData.isNotEmpty))
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.13),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green, width: 2),
                  ),
                  child: const Center(
                    child: Text(
                      'Drop to add here',
                      style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget dragTarget = DragTarget<WidgetNode>(
    onWillAccept: (dragged) {
      final result = (dragged != null && dragged.uid != node.uid && !isDescendant(dragged, node) && canAccept);
      return result;
    },
    onAccept: (dragged) {
      setState(() {
        moveWidgetNode(onWidgetReparent, dragged, node);
      });
    },
    builder: (context, candidateData, rejectedData) {
      return Draggable<WidgetNode>(
        data: node,
        feedback: dragFeedback(node, visualSize),
        childWhenDragging: Opacity(
          opacity: 0.3,
          child: nodeContainer,
        ),
        child: nodeContainer,
      );
    },
  );

  if (insideStack) {
    return Positioned(
      left: visualPosition.dx,
      top: visualPosition.dy,
      child: dragTarget,
    );
  } else {
    return dragTarget;
  }
} 