import 'package:flutter/material.dart';
import '../../models/widget_node.dart';
import '../../models/app_theme.dart';
import '../../models/widget_data.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/design_canvas_viewmodel.dart';

class DesignCanvas extends StatefulWidget {
  final WidgetNode scaffoldWidget;
  final String? selectedWidgetId;
  final AppTheme appTheme;
  final Function(String) onWidgetSelected;
  final Function(String, WidgetData) onWidgetAdded;
  final Function(String, Offset) onWidgetMoved;
  final Function(String, Size) onWidgetResized;

  const DesignCanvas({
    super.key,
    required this.scaffoldWidget,
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
  Offset? _resizeStartPosition;
  Size? _resizeStartSize;
  double _canvasScale = 1.0;
  Offset _canvasOffset = Offset.zero;
  String? _dragTargetId;

  @override
  Widget build(BuildContext context) {
    return Container(
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
          GestureDetector(
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
                child: DragTarget<WidgetData>(
                  onWillAcceptWithDetails: (details) {
                    return _findDeepestWidgetAt(details.offset) != null;
                  },
                  onAcceptWithDetails: (details) {
                    final targetWidget = _findDeepestWidgetAt(details.offset);
                    if (targetWidget != null) {
                      widget.onWidgetAdded(targetWidget.id, details.data);
                    }
                  },
                  builder: (context, candidateData, rejectedData) {
                    return Stack(
                      children: [
                        _buildWidgetNode(widget.scaffoldWidget, 0),
                        if (candidateData.isNotEmpty && _dragTargetId != null)
                          _buildDropIndicator(),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropIndicator() {
    final targetWidget = _findWidgetById(_dragTargetId!);
    if (targetWidget == null) return const SizedBox();
    return Positioned(
      left: targetWidget.position.dx,
      top: targetWidget.position.dy,
      child: Container(
        width: targetWidget.size.width,
        height: targetWidget.size.height,
        decoration: BoxDecoration(
          color: const Color(0xFF4CAF50).withOpacity(0.3),
          border: Border.all(color: const Color(0xFF4CAF50), width: 3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_circle,
                color: Color(0xFF4CAF50),
                size: 32,
              ),
              SizedBox(height: 8),
              Text(
                'Drop Here',
                style: TextStyle(
                  color: Color(0xFF4CAF50),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  WidgetNode? _findDeepestWidgetAt(Offset globalPosition) {
    final localPosition = (globalPosition - _canvasOffset) / _canvasScale;
    WidgetNode? deepestWidget;
    void searchInWidget(WidgetNode widget) {
      final widgetRect = Rect.fromLTWH(
        widget.position.dx,
        widget.position.dy,
        widget.size.width,
        widget.size.height,
      );
      if (widgetRect.contains(localPosition)) {
        // For this stub, allow all widgets to be drop targets
        deepestWidget = widget;
        for (final child in widget.children) {
          searchInWidget(child);
        }
      }
    }
    searchInWidget(widget.scaffoldWidget);
    setState(() {
      _dragTargetId = deepestWidget?.id;
    });
    return deepestWidget;
  }

  WidgetNode? _findWidgetById(String id) {
    WidgetNode? findInWidget(WidgetNode widget) {
      if (widget.id == id) return widget;
      for (final child in widget.children) {
        final found = findInWidget(child);
        if (found != null) return found;
      }
      return null;
    }
    return findInWidget(widget.scaffoldWidget);
  }

  Widget _buildWidgetNode(WidgetNode node, int depth) {
    final isSelected = widget.selectedWidgetId == node.id;
    final isHovered = _hoveredWidgetId == node.id;
    final isScaffold = node.type == 'Scaffold';

    // For layout widgets, render children in the correct layout
    Widget childContent;
    if (node.type == 'Row Widget') {
      childContent = Row(
        mainAxisAlignment: _parseMainAxisAlignment(node.properties['mainAxisAlignment']?.toString() ?? 'start'),
        crossAxisAlignment: _parseCrossAxisAlignment(node.properties['crossAxisAlignment']?.toString() ?? 'center'),
        children: node.children.map((child) => _buildWidgetNode(child, depth + 1)).toList(),
      );
    } else if (node.type == 'Column Widget') {
      childContent = Column(
        mainAxisAlignment: _parseMainAxisAlignment(node.properties['mainAxisAlignment']?.toString() ?? 'start'),
        crossAxisAlignment: _parseCrossAxisAlignment(node.properties['crossAxisAlignment']?.toString() ?? 'center'),
        children: node.children.map((child) => _buildWidgetNode(child, depth + 1)).toList(),
      );
    } else if (node.type == 'Container Widget') {
      childContent = node.children.isNotEmpty
          ? Stack(children: node.children.map((child) => _buildWidgetNode(child, depth + 1)).toList())
          : const SizedBox.shrink();
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
                ? Stack(children: node.children.map((child) => _buildWidgetNode(child, depth + 1)).toList())
                : const SizedBox.shrink(),
          ),
        ],
      );
    } else {
      // For leaf widgets, just show a label or a simple representation
      childContent = Center(
        child: Text(
          node.label,
          style: const TextStyle(color: Color(0xFFEDF1EE)),
        ),
      );
    }

    // Use visual size if present (for selected widget), else model size
    final viewModel = Provider.of<DesignCanvasViewModel>(context, listen: false);
    final visualSize = viewModel.getVisualSize(node.id) ?? node.size;

    return Positioned(
      left: node.position.dx,
      top: node.position.dy,
      child: DragTarget<WidgetData>(
        onWillAccept: (data) => true,
        onAccept: (data) {
          widget.onWidgetAdded(node.id, data);
        },
        builder: (context, candidateData, rejectedData) {
          final isDragHovering = candidateData.isNotEmpty;
          return Stack(
            children: [
              GestureDetector(
                onTap: () => widget.onWidgetSelected(node.id),
                onPanUpdate: (details) {
                  if (!isScaffold && _resizingWidgetId != node.id) {
                    widget.onWidgetMoved(
                      node.id,
                      Offset(
                        node.position.dx + details.delta.dx / _canvasScale,
                        node.position.dy + details.delta.dy / _canvasScale,
                      ),
                    );
                  }
                },
                child: MouseRegion(
                  onEnter: (_) => setState(() => _hoveredWidgetId = node.id),
                  onExit: (_) => setState(() => _hoveredWidgetId = null),
                  child: Container(
                    width: visualSize.width,
                    height: visualSize.height,
                    decoration: BoxDecoration(
                      color: isDragHovering
                          ? const Color(0xFF4CAF50).withOpacity(0.10)
                          : isScaffold 
                              ? _parseColor(node.properties['backgroundColor']?.toString() ?? '#FF2F2F2F')
                              : node.type == 'Container Widget'
                                  ? _parseColor(node.properties['color']?.toString() ?? '#FF3F3F3F')
                                  : const Color(0xFF3F3F3F),
                      border: Border.all(
                        color: isDragHovering
                            ? const Color(0xFF4CAF50)
                            : isScaffold 
                                ? const Color(0xFF4CAF50)
                                : isSelected || isHovered
                                    ? const Color(0xFF4CAF50) 
                                    : _parseColor(node.properties['borderColor']?.toString() ?? '#FFE0E0E0'),
                        width: isScaffold ? 2 : (node.properties['borderWidth'] as double? ?? 1),
                      ),
                      borderRadius: BorderRadius.circular(
                        node.type == 'Container Widget' 
                            ? (node.properties['borderRadius'] as double? ?? 8.0)
                            : isScaffold ? 8 : 4
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
                ),
              ),
              // Resize handles (corners) for selected widget
              if (isSelected)
                ..._buildResizeHandles(node, visualSize),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildResizeHandles(WidgetNode node, Size visualSize) {
    const handleSize = 14.0;
    final handles = <Widget>[];
    final corners = [
      Alignment.topLeft,
      Alignment.topRight,
      Alignment.bottomLeft,
      Alignment.bottomRight,
    ];
    for (final alignment in corners) {
      handles.add(
        Positioned(
          left: alignment.x < 0 ? 0 : null,
          right: alignment.x > 0 ? 0 : null,
          top: alignment.y < 0 ? 0 : null,
          bottom: alignment.y > 0 ? 0 : null,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onPanStart: (details) {
              setState(() {
                _resizingWidgetId = node.id;
                _resizeStartPosition = details.globalPosition;
                _resizeStartSize = visualSize;
              });
            },
            onPanUpdate: (details) {
              if (_resizingWidgetId == node.id && _resizeStartPosition != null && _resizeStartSize != null) {
                final delta = details.globalPosition - _resizeStartPosition!;
                double newWidth = _resizeStartSize!.width;
                double newHeight = _resizeStartSize!.height;
                if (alignment.x < 0) {
                  newWidth -= delta.dx;
                } else if (alignment.x > 0) {
                  newWidth += delta.dx;
                }
                if (alignment.y < 0) {
                  newHeight -= delta.dy;
                } else if (alignment.y > 0) {
                  newHeight += delta.dy;
                }
                newWidth = newWidth.clamp(40.0, 2000.0);
                newHeight = newHeight.clamp(28.0, 2000.0);
                final viewModel = Provider.of<DesignCanvasViewModel>(context, listen: false);
                viewModel.setVisualSize(node.id, Size(newWidth, newHeight));
              }
            },
            onPanEnd: (_) {
              setState(() {
                _resizingWidgetId = null;
                _resizeStartPosition = null;
                _resizeStartSize = null;
              });
            },
            child: Container(
              width: handleSize,
              height: handleSize,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFF4CAF50), width: 2),
                borderRadius: BorderRadius.circular(7),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    return handles;
  }

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0x')));
    } catch (e) {
      return const Color(0xFF3F3F3F);
    }
  }

  MainAxisAlignment _parseMainAxisAlignment(String alignment) {
    switch (alignment) {
      case 'start': return MainAxisAlignment.start;
      case 'end': return MainAxisAlignment.end;
      case 'center': return MainAxisAlignment.center;
      case 'spaceBetween': return MainAxisAlignment.spaceBetween;
      case 'spaceAround': return MainAxisAlignment.spaceAround;
      case 'spaceEvenly': return MainAxisAlignment.spaceEvenly;
      default: return MainAxisAlignment.start;
    }
  }

  CrossAxisAlignment _parseCrossAxisAlignment(String alignment) {
    switch (alignment) {
      case 'start': return CrossAxisAlignment.start;
      case 'end': return CrossAxisAlignment.end;
      case 'center': return CrossAxisAlignment.center;
      case 'stretch': return CrossAxisAlignment.stretch;
      case 'baseline': return CrossAxisAlignment.baseline;
      default: return CrossAxisAlignment.center;
    }
  }
} 