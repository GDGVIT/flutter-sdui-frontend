import 'package:flutter/material.dart';
import '../../models/widget_node.dart';
import '../../models/widget_data.dart';
import '../../models/app_theme.dart';
import 'dart:collection';
import 'widget_node_dnd.dart';
import 'node_container.dart';
import 'palette_drag_feedback.dart';
import 'canvas_utils.dart';
import '../../services/widget_properties_service.dart';

class DesignCanvas extends StatefulWidget {
  final WidgetNode widgetRoot;
  final String? selectedWidgetId;
  final AppTheme appTheme;
  final Function(String) onWidgetSelected;
  final Function(String, WidgetData) onWidgetAdded;
  final Function(String, Offset) onWidgetMoved;
  final Function(String, Size) onWidgetResized;
  final Function(String, String) onWidgetReparent;

  const DesignCanvas({
    super.key,
    required this.widgetRoot,
    required this.selectedWidgetId,
    required this.appTheme,
    required this.onWidgetSelected,
    required this.onWidgetAdded,
    required this.onWidgetMoved,
    required this.onWidgetResized,
    required this.onWidgetReparent,
  });

  @override
  State<DesignCanvas> createState() => DesignCanvasState();
}

class DesignCanvasState extends State<DesignCanvas> {
  String? _hoveredWidgetId;
  String? _resizingWidgetId;
  double _canvasScale = 1.0;
  Offset _canvasOffset = Offset.zero;

  // Advanced: Track pointer position and DragTarget keys
  Offset? _lastPointerPosition;
  final Map<String, GlobalKey> _dropTargetKeys = HashMap();
  String? _deepestDropTargetId;

  // Custom drag state for palette-to-canvas
  bool _isDraggingFromPalette = false;
  WidgetData? _draggedWidgetData;
  Offset? _dragPointerPositionGlobal;
  Offset? _dragPointerPositionLocal;
  String? _paletteDropTargetId;

  // Scroll controllers for scrollbars
  final ScrollController _verticalScrollController = ScrollController();
  final ScrollController _horizontalScrollController = ScrollController();

  // --- Resize tracking ---
  Offset? _resizeStartPointer;
  Size? _resizeStartSize;
  Offset? _resizeStartPosition;
  int? _resizeDx;
  int? _resizeDy;

  // Helper: get the RenderBox for the canvas
  RenderBox? get _canvasBox => context.findRenderObject() as RenderBox?;

  @override
  void dispose() {
    _verticalScrollController.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }

  void _updatePointerPosition(PointerEvent event) {
    if (_isDraggingFromPalette) {
      updatePaletteDrag(event.position);
    } else {
      setState(() {
        _lastPointerPosition = event.localPosition;
        _deepestDropTargetId = _findDeepestDropTargetId(_lastPointerPosition!);
      });
    }
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

  void startPaletteDrag(WidgetData data, Offset globalPosition) {
    setState(() {
      _isDraggingFromPalette = true;
      _draggedWidgetData = data;
      _dragPointerPositionGlobal = globalPosition;
      _updatePaletteDragPosition(globalPosition);
    });
  }

  void updatePaletteDrag(Offset globalPosition) {
    if (_isDraggingFromPalette) {
      setState(() {
        _dragPointerPositionGlobal = globalPosition;
        _updatePaletteDragPosition(globalPosition);
      });
    }
  }

  void endPaletteDrag() async {
    if (_isDraggingFromPalette && _paletteDropTargetId != null && _draggedWidgetData != null) {
      // Check if drop target is a single-child parent with a child
      final parentNode = _findNodeById(widget.widgetRoot, _paletteDropTargetId!);
      if (parentNode != null) {
        final constraints = WidgetPropertiesService.getConstraints(parentNode.type);
        if (constraints.maxChildren == 1 && parentNode.children.isNotEmpty) {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: const Color(0xFF2F2F2F),
              title: const Text('Replace Child?', style: TextStyle(color: Color(0xFFEDF1EE))),
              content: const Text('This parent can only have one child. Adding a new widget will replace the existing child and you may lose data. Continue?', style: TextStyle(color: Color(0xFFEDF1EE))),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel', style: TextStyle(color: Color(0xFFFF5252))),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Replace', style: TextStyle(color: Color(0xFF4CAF50))),
                ),
              ],
            ),
          );
          if (confirmed != true) {
            setState(() {
              _isDraggingFromPalette = false;
              _draggedWidgetData = null;
              _dragPointerPositionGlobal = null;
              _dragPointerPositionLocal = null;
              _paletteDropTargetId = null;
            });
            return;
          }
        }
      }
      widget.onWidgetAdded(_paletteDropTargetId!, _draggedWidgetData!);
    }
    setState(() {
      _isDraggingFromPalette = false;
      _draggedWidgetData = null;
      _dragPointerPositionGlobal = null;
      _dragPointerPositionLocal = null;
      _paletteDropTargetId = null;
    });
  }

  WidgetNode? _findNodeById(WidgetNode node, String id) {
    if (node.uid == id) return node;
    for (final child in node.children) {
      final found = _findNodeById(child, id);
      if (found != null) return found;
    }
    return null;
  }

  void _updatePaletteDragPosition(Offset globalPosition) {
    final box = _canvasBox;
    if (box != null) {
      final local = box.globalToLocal(globalPosition);
      _dragPointerPositionLocal = local;
      _paletteDropTargetId = _findDeepestDropTargetId(local);
    }
  }

  Widget _canvasDragFeedback(WidgetNode node, Size visualSize) {
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(node.icon, color: Colors.blueAccent, size: 32),
              const SizedBox(height: 4),
              Text(node.label, style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  // --- Resize handle callbacks generator ---
  Map<String, dynamic> getResizeCallbacks(WidgetNode node, Size visualSize, int dx, int dy) {
    return {
      'onPanStart': (DragStartDetails details) {
        setState(() {
          _resizingWidgetId = node.uid;
          _resizeStartPointer = details.globalPosition;
          _resizeStartSize = visualSize;
          _resizeStartPosition = node.position;
          _resizeDx = dx;
          _resizeDy = dy;
        });
      },
      'onPanUpdate': (DragUpdateDetails details) {
        if (_resizingWidgetId == node.uid && _resizeStartPointer != null && _resizeStartSize != null && _resizeStartPosition != null && _resizeDx != null && _resizeDy != null) {
          double scale = _canvasScale;
          Offset pointer = details.globalPosition;
          Offset delta = (pointer - _resizeStartPointer!) * (1 / scale);
          double newWidth = _resizeStartSize!.width + delta.dx * _resizeDx!;
          double newHeight = _resizeStartSize!.height + delta.dy * _resizeDy!;
          double minWidth = 32;
          double minHeight = 32;
          newWidth = newWidth.clamp(minWidth, 2000);
          newHeight = newHeight.clamp(minHeight, 2000);
          Offset newPosition = _resizeStartPosition!;
          if (_resizeDx == -1) newPosition = newPosition.translate(delta.dx, 0);
          if (_resizeDy == -1) newPosition = newPosition.translate(0, delta.dy);
          widget.onWidgetResized(
            node.uid,
            Size(newWidth, newHeight),
          );
          // Optionally, update position for top/left handles
          if (_resizeDx == -1 || _resizeDy == -1) {
            widget.onWidgetSelected(node.uid); // keep selected
            widget.onWidgetMoved(
              node.uid,
              newPosition,
            );
          }
        }
      },
      'onPanEnd': (DragEndDetails _) {
        setState(() {
          _resizingWidgetId = null;
          _resizeStartPointer = null;
          _resizeStartSize = null;
          _resizeStartPosition = null;
          _resizeDx = null;
          _resizeDy = null;
        });
      },
    };
  }

  Widget widgetNodeDndWrapper(WidgetNode node, int depth, {bool insideStack = false}) {
    return buildWidgetNodeWithDnD(
      node: node,
      depth: depth,
      insideStack: insideStack,
      selectedWidgetId: widget.selectedWidgetId,
      hoveredWidgetId: _hoveredWidgetId,
      dropTargetKeys: _dropTargetKeys,
      isDraggingFromPalette: _isDraggingFromPalette,
      paletteDropTargetId: _paletteDropTargetId,
      deepestDropTargetId: _deepestDropTargetId,
      onWidgetSelected: widget.onWidgetSelected,
      onWidgetReparent: widget.onWidgetReparent,
      setState: setState,
      buildWidgetNodeWithDnD: widgetNodeDndWrapper,
      buildNodeContainer: buildNodeContainer,
      getResizeHandle: (node, visualSize, dx, dy) {
        final cbs = getResizeCallbacks(node, visualSize, dx, dy);
        return buildResizeHandle(
          node: node,
          visualSize: visualSize,
          dx: dx,
          dy: dy,
          onPanStart: cbs['onPanStart'],
          onPanUpdate: cbs['onPanUpdate'],
          onPanEnd: cbs['onPanEnd'],
        );
      },
      dragFeedback: (node, visualSize) => _isDraggingFromPalette && _draggedWidgetData != null
        ? buildPaletteDragFeedback(_draggedWidgetData!)
        : _canvasDragFeedback(node, visualSize),
    );
  }

  @override
  Widget build(BuildContext context) {
    // --- Auto-enlarge: compute bounding box of all widgets ---
    Size canvasSize = computeCanvasSize(widget.widgetRoot);
    const Size minCanvasSize = Size(1200, 900);
    final double canvasWidth = canvasSize.width < minCanvasSize.width ? minCanvasSize.width : canvasSize.width;
    final double canvasHeight = canvasSize.height < minCanvasSize.height ? minCanvasSize.height : canvasSize.height;

    return Column(
      children: [
        Expanded(
          child: Container(
            color: const Color(0xFF212121),
            child: Scrollbar(
              controller: _verticalScrollController,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _verticalScrollController,
                scrollDirection: Axis.vertical,
                child: Scrollbar(
                  controller: _horizontalScrollController,
                  thumbVisibility: true,
                  notificationPredicate: (notif) => notif.metrics.axis == Axis.horizontal,
                  child: SingleChildScrollView(
                    controller: _horizontalScrollController,
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: canvasWidth,
                      height: canvasHeight,
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
                                  const SizedBox(width: 8),
                                  IconButton(
                                    onPressed: () {
                                      // Fit all content to view
                                      final canvasSize = computeCanvasSize(widget.widgetRoot);
                                      final viewportSize = MediaQuery.of(context).size;
                                      final scaleX = (viewportSize.width * 0.8) / canvasSize.width;
                                      final scaleY = (viewportSize.height * 0.8) / canvasSize.height;
                                      final fitScale = [scaleX, scaleY, 1.0].where((v) => v.isFinite && v > 0).reduce((a, b) => a < b ? a : b);
                                      setState(() {
                                        _canvasScale = fitScale.clamp(0.1, 3.0);
                                        _canvasOffset = Offset.zero;
                                      });
                                    },
                                    icon: const Icon(Icons.fit_screen, color: Color(0xFFEDF1EE), size: 20),
                                    tooltip: 'Fit to View',
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Main canvas (with pan/zoom)
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
                                      widgetNodeDndWrapper(widget.widgetRoot, 0, insideStack: false),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Custom drag feedback overlay
                          if (_isDraggingFromPalette && _draggedWidgetData != null && _dragPointerPositionLocal != null)
                            Positioned(
                              left: _dragPointerPositionLocal!.dx - 40,
                              top: _dragPointerPositionLocal!.dy - 40,
                              child: IgnorePointer(
                                child: Opacity(
                                  opacity: 0.85,
                                  child: buildPaletteDragFeedback(_draggedWidgetData!),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        // Reference: Regular Flutter Column
        // Container(
        //   color: Colors.grey[200],
        //   padding: const EdgeInsets.all(16),
        //   child: Column(
        //     crossAxisAlignment: CrossAxisAlignment.start,
        //     children: [
        //       const Text('Reference: Regular Flutter Column', style: TextStyle(fontWeight: FontWeight.bold)),
        //       const SizedBox(height: 8),
        //       Column(
        //         crossAxisAlignment: CrossAxisAlignment.start,
        //         children: [
        //           Container(width: 80, height: 40, color: Colors.red, margin: const EdgeInsets.only(bottom: 8)),
        //           Container(width: 120, height: 40, color: Colors.green, margin: const EdgeInsets.only(bottom: 8)),
        //           Container(width: 60, height: 40, color: Colors.blue),
        //         ],
        //       ),
        //     ],
        //   ),
        // ),
      ],
    );
  }
} 