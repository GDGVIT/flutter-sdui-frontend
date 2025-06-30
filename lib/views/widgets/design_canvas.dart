import 'package:flutter/material.dart';
import '../../models/widget_node.dart';
import '../../models/widget_data.dart';
import '../../models/app_theme.dart';
import 'dart:collection';

class DesignCanvas extends StatefulWidget {
  final WidgetNode widgetRoot;
  final String? selectedWidgetId;
  final AppTheme appTheme;
  final Function(String) onWidgetSelected;
  final Function(String, WidgetData) onWidgetAdded;
  final Function(String, Offset) onWidgetMoved;
  final Function(String, Size) onWidgetResized;

  const DesignCanvas({
    super.key,
    required this.widgetRoot,
    required this.selectedWidgetId,
    required this.appTheme,
    required this.onWidgetSelected,
    required this.onWidgetAdded,
    required this.onWidgetMoved,
    required this.onWidgetResized,
  });

  @override
  State<DesignCanvas> createState() => _DesignCanvasState();
}

class _DesignCanvasState extends State<DesignCanvas> {
  String? _hoveredWidgetId;
  String? _resizingWidgetId;
  double _canvasScale = 1.0;
  Offset _canvasOffset = Offset.zero;

  // Advanced: Track pointer position and DragTarget keys
  Offset? _lastPointerPosition;
  final Map<String, GlobalKey> _dropTargetKeys = HashMap();
  String? _deepestDropTargetId;

  void _updatePointerPosition(PointerEvent event) {
    setState(() {
      _lastPointerPosition = event.localPosition;
      _deepestDropTargetId = _findDeepestDropTargetId(_lastPointerPosition!);
    });
  }

  String? _findDeepestDropTargetId(Offset pointer) {
    String? result;
    double smallestArea = double.infinity;
    _dropTargetKeys.forEach((id, key) {
      final ctx = key.currentContext;
      if (ctx != null) {
        final box = ctx.findRenderObject() as RenderBox?;
        if (box != null && box.hasSize) {
          final pos = box.localToGlobal(Offset.zero, ancestor: context.findRenderObject());
          final rect = pos & box.size;
          if (rect.contains(pointer)) {
            final area = box.size.width * box.size.height;
            if (area < smallestArea) {
              smallestArea = area;
              result = id;
            }
          }
        }
      }
    });
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            color: const Color(0xFF212121),
            child: Stack(
              children: [
                // Canvas controls
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2F2F2F),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF666666)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _canvasScale = (_canvasScale * 1.2).clamp(0.5, 3.0);
                            });
                          },
                          icon: const Icon(Icons.zoom_in, color: Color(0xFFEDF1EE), size: 20),
                          tooltip: 'Zoom In',
                        ),
                        Text(
                          '${(_canvasScale * 100).round()}%',
                          style: const TextStyle(color: Color(0xFFEDF1EE), fontSize: 12),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _canvasScale = (_canvasScale / 1.2).clamp(0.5, 3.0);
                            });
                          },
                          icon: const Icon(Icons.zoom_out, color: Color(0xFFEDF1EE), size: 20),
                          tooltip: 'Zoom Out',
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _canvasScale = 1.0;
                              _canvasOffset = Offset.zero;
                            });
                          },
                          icon: const Icon(Icons.center_focus_strong, color: Color(0xFFEDF1EE), size: 20),
                          tooltip: 'Reset View',
                        ),
                      ],
                    ),
                  ),
                ),
                // Main canvas
                Listener(
                  onPointerHover: _updatePointerPosition,
                  onPointerMove: _updatePointerPosition,
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      if (_resizingWidgetId == null) {
                        setState(() {
                          _canvasOffset += details.delta;
                        });
                      }
                    },
                    child: Transform.scale(
                      scale: _canvasScale,
                      child: Transform.translate(
                        offset: _canvasOffset,
                        child: Stack(
                          children: [
                            _buildWidgetNodeWithDnD(widget.widgetRoot, 0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Reference: Regular Flutter Column
        Container(
          color: Colors.grey[200],
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Reference: Regular Flutter Column', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 80, height: 40, color: Colors.red, margin: const EdgeInsets.only(bottom: 8)),
                  Container(width: 120, height: 40, color: Colors.green, margin: const EdgeInsets.only(bottom: 8)),
                  Container(width: 60, height: 40, color: Colors.blue),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWidgetNodeWithDnD(WidgetNode node, int depth) {
    final isSelected = widget.selectedWidgetId == node.id;
    final isHovered = _hoveredWidgetId == node.id;
    final isScaffold = node.type == 'Scaffold';
    final visualSize = node.size;
    final visualPosition = node.position;
    final canAcceptChildren = _canAcceptChildren(node.type);

    // Advanced: Assign a GlobalKey for each drop target
    GlobalKey dropKey = _dropTargetKeys[node.id] ??= GlobalKey();

    Widget childContent;
    if (node.type == 'Row Widget') {
      childContent = Row(
        children: node.children.map((child) => _buildWidgetNodeWithDnD(child, depth + 1)).toList(),
      );
    } else if (node.type == 'Column Widget') {
      childContent = Column(
        children: node.children.map((child) => _buildWidgetNodeWithDnD(child, depth + 1)).toList(),
      );
    } else if (node.type == 'Scaffold') {
      final appBarTitle = node.properties['appBarTitle']?.toString() ?? '';
      final appBarColor = _parseColor(node.properties['appBarColor']?.toString() ?? '#FF232323');
      childContent = Column(
        children: [
          GestureDetector(
            onTap: () => widget.onWidgetSelected(node.id),
            child: MouseRegion(
              onEnter: (_) => setState(() => _hoveredWidgetId = node.id),
              onExit: (_) => setState(() => _hoveredWidgetId = null),
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
                        color: (widget.selectedWidgetId == node.id || _hoveredWidgetId == node.id)
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
                ? Stack(children: node.children.map((child) => _buildWidgetNodeWithDnD(child, depth + 1)).toList())
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

    Widget nodeContainer = _buildNodeContainer(node, childContent, visualSize, isSelected, isHovered, isScaffold);
    if (canAcceptChildren) {
      final baseNodeContainer = nodeContainer;
      nodeContainer = DragTarget<WidgetData>(
        key: dropKey,
        onWillAccept: (data) => true,
        onAccept: (data) {
          widget.onWidgetAdded(node.id, data);
        },
        builder: (context, candidateData, rejectedData) {
          return Stack(
            children: [
              baseNodeContainer,
              if (_deepestDropTargetId == node.id && candidateData.isNotEmpty)
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

    return Positioned(
      left: visualPosition.dx,
      top: visualPosition.dy,
      child: DragTarget<WidgetNode>(
        onWillAccept: (dragged) {
          if (dragged == null || dragged.id == node.id || _isDescendant(dragged, node)) return false;
          return canAcceptChildren;
        },
        onAccept: (dragged) {
          setState(() {
            _moveWidgetNode(dragged, node);
          });
        },
        builder: (context, candidateData, rejectedData) {
          return Draggable<WidgetNode>(
            data: node,
            feedback: Opacity(
              opacity: 0.7,
              child: _dragFeedback(node, visualSize),
            ),
            childWhenDragging: Opacity(
              opacity: 0.3,
              child: nodeContainer,
            ),
            child: nodeContainer,
          );
        },
      ),
    );
  }

  Widget _buildNodeContainer(WidgetNode node, Widget childContent, Size visualSize, bool isSelected, bool isHovered, bool isScaffold) {
    return GestureDetector(
      onTap: () => widget.onWidgetSelected(node.id),
      child: Container(
        width: visualSize.width,
        height: visualSize.height,
        decoration: BoxDecoration(
          color: isScaffold
              ? _parseColor(node.properties['backgroundColor']?.toString() ?? '#FF2F2F2F')
              : node.type == 'Container Widget'
                  ? _parseColor(node.properties['color']?.toString() ?? '#FF3F3F3F')
                  : const Color(0xFF3F3F3F),
          border: Border.all(
            color: isScaffold
                ? const Color(0xFF4CAF50)
                : isSelected || isHovered
                    ? const Color(0xFF4CAF50)
                    : _parseColor(node.properties['borderColor']?.toString() ?? '#FFE0E0E0'),
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
  }

  Widget _dragFeedback(WidgetNode node, Size visualSize) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: visualSize.width,
        height: visualSize.height,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.7),
          border: Border.all(color: Colors.blueAccent, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Icon(node.icon, color: Colors.blueAccent, size: 32),
        ),
      ),
    );
  }

  bool _canAcceptChildren(String type) {
    return type == 'Row Widget' || type == 'Column Widget' || type == 'Stack Widget' || type == 'Scaffold';
  }

  bool _isDescendant(WidgetNode parent, WidgetNode possibleDescendant) {
    if (parent == possibleDescendant) return true;
    for (final child in parent.children) {
      if (_isDescendant(child, possibleDescendant)) return true;
    }
    return false;
  }

  void _moveWidgetNode(WidgetNode dragged, WidgetNode newParent) {
    // This is a placeholder for the move logic. You should update the view model to actually move the node in the tree.
    // For now, this just triggers a UI update.
    setState(() {});
  }

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0x')));
    } catch (e) {
      return const Color(0xFF3F3F3F);
    }
  }
} 