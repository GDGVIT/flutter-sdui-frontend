import 'package:flutter/material.dart';
import '../../models/widget_node.dart';
import '../../models/widget_data.dart';
import 'canvas_utils.dart';

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
  Function(String, String, int)? onWidgetReparentAtIndex,
  required void Function(void Function()) setState,
  required Widget Function(WidgetNode, int, {bool insideStack}) buildWidgetNodeWithDnD,
  required Widget Function({required WidgetNode node, required Widget childContent, required Size visualSize, required bool isSelected, required bool isHovered, required bool isScaffold, required void Function() onTap, required List<Widget> resizeHandles}) buildNodeContainer,
  required ScrollController Function(String nodeId) getNodeScrollController,
  required Widget Function(WidgetNode node, Size visualSize, int dx, int dy) getResizeHandle,
  required Widget Function(WidgetNode, Size) dragFeedback,
  required void Function(String parentId, WidgetData data) onQuickAdd,
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
    final rowController = getNodeScrollController(node.uid);
    childContent = SizedBox(
      width: node.size.width,
      height: node.size.height,
      child: Scrollbar(
        controller: rowController,
        thumbVisibility: true,
        notificationPredicate: (notif) => notif.metrics.axis == Axis.horizontal,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          controller: rowController,
          physics: const AlwaysScrollableScrollPhysics(),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < node.children.length; i++) ...[
                _InsertionSlot(
                  axis: Axis.horizontal,
                  onAccept: (dragged) {
                    if (onWidgetReparentAtIndex != null) {
                      onWidgetReparentAtIndex(dragged.uid, node.uid, i);
                    }
                  },
                ),
                buildWidgetNodeWithDnD(node.children[i], depth + 1, insideStack: false),
              ],
              _InsertionSlot(
                axis: Axis.horizontal,
                onAccept: (dragged) {
                  if (onWidgetReparentAtIndex != null) {
                    onWidgetReparentAtIndex(dragged.uid, node.uid, node.children.length);
                  }
                },
              ),
              _EndDropGhost(
                axis: Axis.horizontal,
                isActive: (isDraggingFromPalette && paletteDropTargetId == node.uid) || (!isDraggingFromPalette && deepestDropTargetId == node.uid),
                parentId: node.uid,
                onQuickAdd: onQuickAdd,
              ),
              const SizedBox(width: 400),
            ],
          ),
        ),
      ),
    );
  } else if (node.type == 'Column Widget' || node.type == 'SduiColumn') {
    final columnController = getNodeScrollController(node.uid);
    childContent = SizedBox(
      width: node.size.width,
      height: node.size.height,
      child: Stack(
        children: [
          Scrollbar(
            thumbVisibility: true,
            controller: columnController,
            child: SingleChildScrollView(
              controller: columnController,
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (int i = 0; i < node.children.length; i++) ...[
                    _InsertionSlot(
                      axis: Axis.vertical,
                      onAccept: (dragged) {
                        if (onWidgetReparentAtIndex != null) {
                          onWidgetReparentAtIndex(dragged.uid, node.uid, i);
                        }
                      },
                    ),
                    buildWidgetNodeWithDnD(node.children[i], depth + 1, insideStack: false),
                  ],
                  _InsertionSlot(
                    axis: Axis.vertical,
                    onAccept: (dragged) {
                      if (onWidgetReparentAtIndex != null) {
                        onWidgetReparentAtIndex(dragged.uid, node.uid, node.children.length);
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  _EndDropGhost(
                    axis: Axis.vertical,
                    isActive: (isDraggingFromPalette && paletteDropTargetId == node.uid) || (!isDraggingFromPalette && deepestDropTargetId == node.uid),
                    parentId: node.uid,
                    onQuickAdd: onQuickAdd,
                  ),
                  const SizedBox(height: 400), // extra scroll padding to allow future items
                ],
              ),
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
    final showAppBar = node.properties['showAppBar'] as bool? ?? true;
    final appBarTitle = node.properties['appBarTitle']?.toString() ?? '';
    final appBarColor = parseColor(node.properties['appBarBackgroundColor']?.toString() ?? '#FF232323');
    
    List<Widget> columnChildren = [];
    
    // Only add AppBar if showAppBar is true
    if (showAppBar) {
      columnChildren.add(
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
      );
    }
    
    // Add body content
    columnChildren.add(
      Expanded(
        child: Scrollbar(
          thumbVisibility: true,
          controller: getNodeScrollController('${node.uid}:v'),
          child: SingleChildScrollView(
            controller: getNodeScrollController('${node.uid}:v'),
            scrollDirection: Axis.vertical,
            child: Scrollbar(
              thumbVisibility: true,
              controller: getNodeScrollController('${node.uid}:h'),
              notificationPredicate: (notif) => notif.metrics.axis == Axis.horizontal,
              child: SingleChildScrollView(
                controller: getNodeScrollController('${node.uid}:h'),
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: node.size.width,
                  height: node.size.height,
                  child: node.children.isNotEmpty
                      ? Stack(children: node.children.map((child) => buildWidgetNodeWithDnD(child, depth + 1, insideStack: true)).toList())
                      : const SizedBox.shrink(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    
    childContent = Column(children: columnChildren);
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
      onWillAccept: (data) => true,
      onAccept: (data) {
        // Accept from palette handled upstream via palette flow; keep visual highlight only.
      },
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
      return LongPressDraggable<WidgetNode>(
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

class _EndDropGhost extends StatelessWidget {
  final Axis axis;
  final bool isActive;
  final String parentId;
  final void Function(String parentId, WidgetData data) onQuickAdd;
  const _EndDropGhost({required this.axis, required this.isActive, required this.parentId, required this.onQuickAdd});

  @override
  Widget build(BuildContext context) {
    final size = axis == Axis.vertical ? const Size(double.infinity, 48) : const Size(48, double.infinity);
    return GestureDetector(
      onTap: () async {
        final selection = await showMenu<_QuickAddItem>(
          context: context,
          position: const RelativeRect.fromLTRB(200, 200, 0, 0),
          items: const [
            PopupMenuItem<_QuickAddItem>(value: _QuickAddItem.row, child: Text('Add Row')),
            PopupMenuItem<_QuickAddItem>(value: _QuickAddItem.column, child: Text('Add Column')),
            PopupMenuItem<_QuickAddItem>(value: _QuickAddItem.text, child: Text('Add Text')),
          ],
        );
        if (selection != null) {
          switch (selection) {
            case _QuickAddItem.row:
              onQuickAdd(parentId, const WidgetData(type: 'SduiRow', label: 'Row', icon: Icons.view_stream, position: Offset.zero));
              break;
            case _QuickAddItem.column:
              onQuickAdd(parentId, const WidgetData(type: 'SduiColumn', label: 'Column', icon: Icons.view_column, position: Offset.zero));
              break;
            case _QuickAddItem.text:
              onQuickAdd(parentId, const WidgetData(type: 'SduiText', label: 'Text', icon: Icons.text_fields, position: Offset.zero));
              break;
          }
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        width: size.width,
        height: size.height,
        margin: axis == Axis.vertical ? const EdgeInsets.symmetric(vertical: 6) : const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: isActive ? Colors.green.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isActive ? Colors.green : Colors.transparent, width: 2),
        ),
        child: Center(
          child: Text(
            isActive ? 'Drop here to append (or click to quick add)' : 'Click to quick add',
            style: TextStyle(color: isActive ? Colors.green : const Color(0xFF888888)),
          ),
        ),
      ),
    );
  }
}

enum _QuickAddItem { row, column, text }

class _InsertionSlot extends StatelessWidget {
  final Axis axis;
  final void Function(WidgetNode dragged) onAccept;
  const _InsertionSlot({required this.axis, required this.onAccept});

  @override
  Widget build(BuildContext context) {
    final size = axis == Axis.vertical ? const Size(double.infinity, 8) : const Size(8, double.infinity);
    return DragTarget<WidgetNode>(
      onWillAccept: (data) => data != null,
      onAccept: (data) => onAccept(data),
      builder: (context, candidate, rejected) {
        final active = candidate.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
          width: size.width,
          height: size.height,
          margin: axis == Axis.vertical ? const EdgeInsets.symmetric(vertical: 4) : const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: active ? Colors.green.withOpacity(0.16) : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: active ? Colors.green : Colors.transparent, width: 2),
          ),
        );
      },
    );
  }
}