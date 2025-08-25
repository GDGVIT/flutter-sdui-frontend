import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:provider/provider.dart';
import '../viewmodels/design_canvas_viewmodel.dart';
import '../services/code_generator_service.dart';
import 'widgets/icon_bar.dart';
import 'widgets/left_sidebar.dart';
import 'widgets/design_canvas.dart';
import 'widgets/properties_panel.dart';
import 'widgets/preview_canvas.dart';

class DesignCanvasScreen extends StatelessWidget {
  const DesignCanvasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DesignCanvasViewModel(),
      child: const _DesignCanvasScreenContent(),
    );
  }
}

class _DesignCanvasScreenContent extends StatefulWidget {
  const _DesignCanvasScreenContent();

  @override
  _DesignCanvasScreenContentState createState() => _DesignCanvasScreenContentState();
}

class _DesignCanvasScreenContentState extends State<_DesignCanvasScreenContent> {
  final GlobalKey<DesignCanvasState> _canvasKey = GlobalKey<DesignCanvasState>();
  double leftWidth = 275;
  double rightWidth = 300;
  final double minPaneWidth = 140;
  bool resizingLeft = false;
  bool resizingRight = false;
  Offset? dragStart;
  double? dragStartLeftWidth;
  double? dragStartRightWidth;

  @override
  Widget build(BuildContext context) {
    return Consumer<DesignCanvasViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          body: LayoutBuilder(
            builder: (context, constraints) {
              const double iconBarWidth = 90;
              const double dividerWidth = 4;
              const double minCenterWidth = 280;

              double maxPanelWidth = math.max(minPaneWidth, constraints.maxWidth * 0.4);
              double effectiveLeftWidth = leftWidth.clamp(minPaneWidth, maxPanelWidth);
              double effectiveRightWidth = rightWidth.clamp(minPaneWidth, maxPanelWidth);

              double fixedSpace = iconBarWidth + (2 * dividerWidth) + effectiveLeftWidth + effectiveRightWidth;
              double remaining = constraints.maxWidth - fixedSpace;

              if (remaining < minCenterWidth) {
                double targetPanelsTotal = (constraints.maxWidth - iconBarWidth - (2 * dividerWidth) - minCenterWidth).clamp(0, double.infinity);
                double currentPanelsTotal = (effectiveLeftWidth + effectiveRightWidth).clamp(1, double.infinity);
                double scale = targetPanelsTotal / currentPanelsTotal;
                effectiveLeftWidth = (effectiveLeftWidth * scale).clamp(minPaneWidth, maxPanelWidth);
                effectiveRightWidth = (effectiveRightWidth * scale).clamp(minPaneWidth, maxPanelWidth);
              }

              final double minTotalWidth = iconBarWidth + (2 * dividerWidth) + (2 * minPaneWidth) + minCenterWidth;

              final Widget contentRow = Row(
                children: [
                  // Narrow Icon Bar
                  Container(
                    width: iconBarWidth,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2F2F2F),
                      border: Border(
                        right: BorderSide(color: Color(0xFFE0E0E0), width: 1),
                      ),
                    ),
                    child: IconBar(
                      selectedPane: viewModel.selectedPane,
                      onPaneSelected: viewModel.setSelectedPane,
                    ),
                  ),
                  // Resizable Left Panel
                  SizedBox(
                    width: effectiveLeftWidth,
                    child: LeftSidebar(
                      selectedPane: viewModel.selectedPane,
                      scaffoldWidget: viewModel.widgetRoot,
                      appTheme: viewModel.appTheme,
                      onThemeChanged: viewModel.updateTheme,
                      onWidgetDropped: (widgetData) {},
                      selectedWidgetId: viewModel.selectedWidgetId,
                      onWidgetSelected: viewModel.setSelectedWidget,
                      onPaletteDragStart: (data, pos) => _canvasKey.currentState?.startPaletteDrag(data, pos),
                      onPaletteDragUpdate: (pos) => _canvasKey.currentState?.updatePaletteDrag(pos),
                      onPaletteDragEnd: () => _canvasKey.currentState?.endPaletteDrag(),
                    ),
                  ),
                  // Left Divider
                  MouseRegion(
                    cursor: SystemMouseCursors.resizeLeftRight,
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onHorizontalDragStart: (details) {
                        setState(() {
                          resizingLeft = true;
                          dragStart = details.globalPosition;
                          dragStartLeftWidth = leftWidth;
                        });
                      },
                      onHorizontalDragUpdate: (details) {
                        if (resizingLeft && dragStart != null && dragStartLeftWidth != null) {
                          setState(() {
                            final double upper = math.max(minPaneWidth, constraints.maxWidth * 0.6);
                            leftWidth = (dragStartLeftWidth! + (details.globalPosition.dx - dragStart!.dx)).clamp(minPaneWidth, upper);
                          });
                        }
                      },
                      onHorizontalDragEnd: (_) {
                        setState(() {
                          resizingLeft = false;
                          dragStart = null;
                          dragStartLeftWidth = null;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 120),
                        width: dividerWidth,
                        color: resizingLeft ? Theme.of(context).colorScheme.primary.withOpacity(0.10) : Colors.transparent,
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ),
                  // Main Canvas Area
                  Expanded(
                    child: Column(
                      children: [
                        // View Toggle Header
                        Container(
                          height: 50,
                          color: const Color(0xFF2F2F2F),
                          child: LayoutBuilder(
                            builder: (context, headerConstraints) {
                              final bool compact = headerConstraints.maxWidth < 460;
                              final Widget codeButton = viewModel.showPreview
                                  ? (compact
                                      ? IconButton(
                                          onPressed: () => _showCodeDialog(context, viewModel),
                                          icon: const Icon(Icons.code, color: Color(0xFF4CAF50), size: 18),
                                          tooltip: 'View Code',
                                        )
                                      : TextButton.icon(
                                          onPressed: () => _showCodeDialog(context, viewModel),
                                          icon: const Icon(Icons.code, color: Color(0xFF4CAF50), size: 16),
                                          label: const Text(
                                            'View Code',
                                            style: TextStyle(color: Color(0xFF4CAF50)),
                                          ),
                                        ))
                                  : const SizedBox.shrink();
                              return SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    const SizedBox(width: 16),
                                    const Text(
                                      'View:',
                                      style: TextStyle(
                                        color: Color(0xFFEDF1EE),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    _buildViewToggle(context, 'Design', !viewModel.showPreview, viewModel),
                                    const SizedBox(width: 8),
                                    _buildViewToggle(context, 'Preview', viewModel.showPreview, viewModel),
                                    const SizedBox(width: 8),
                                    codeButton,
                                    const SizedBox(width: 16),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        // Canvas Content
                        Expanded(
                          child: viewModel.showPreview
                              ? PreviewCanvas(
                                  widgetRoot: viewModel.widgetRoot,
                                  appTheme: viewModel.appTheme,
                                )
                              : DesignCanvas(
                                  key: _canvasKey,
                                  widgetRoot: viewModel.widgetRoot,
                                  selectedWidgetId: viewModel.selectedWidgetId,
                                  appTheme: viewModel.appTheme,
                                  onWidgetSelected: viewModel.setSelectedWidget,
                                  onWidgetAdded: viewModel.addWidgetToParent,
                                  onWidgetMoved: viewModel.moveWidget,
                                  onWidgetResized: viewModel.resizeWidget,
                                  onWidgetReparent: viewModel.reparentWidget,
                                ),
                        ),
                      ],
                    ),
                  ),
                  // Right Divider
                  MouseRegion(
                    cursor: SystemMouseCursors.resizeLeftRight,
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onHorizontalDragStart: (details) {
                        setState(() {
                          resizingRight = true;
                          dragStart = details.globalPosition;
                          dragStartRightWidth = rightWidth;
                        });
                      },
                      onHorizontalDragUpdate: (details) {
                        if (resizingRight && dragStart != null && dragStartRightWidth != null) {
                          setState(() {
                            final double upper = math.max(minPaneWidth, constraints.maxWidth * 0.6);
                            rightWidth = (dragStartRightWidth! - (details.globalPosition.dx - dragStart!.dx)).clamp(minPaneWidth, upper);
                          });
                        }
                      },
                      onHorizontalDragEnd: (_) {
                        setState(() {
                          resizingRight = false;
                          dragStart = null;
                          dragStartRightWidth = null;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 120),
                        width: dividerWidth,
                        color: resizingRight ? Theme.of(context).colorScheme.primary.withOpacity(0.10) : Colors.transparent,
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ),
                  // Right Properties Panel
                  SizedBox(
                    width: effectiveRightWidth,
                    child: PropertiesPanel(
                      selectedWidget: viewModel.getSelectedWidget(),
                      appTheme: viewModel.appTheme,
                      onPropertyChanged: viewModel.updateWidgetProperty,
                      onWidgetRemoved: viewModel.removeWidget,
                    ),
                  ),
                ],
              );

              if (constraints.maxWidth < minTotalWidth) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: minTotalWidth),
                    child: contentRow,
                  ),
                );
              }

              return contentRow;
            },
          ),
        );
      },
    );
  }

  Widget _buildLeftSidebar(DesignCanvasViewModel viewModel) {
    // This method is now obsolete, as we use LeftSidebar directly above.
    return const SizedBox();
  }

  Widget _buildPropertiesPanel(DesignCanvasViewModel viewModel) {
    // This method is now obsolete, as we use PropertiesPanel directly above.
    return const SizedBox();
  }

  Widget _buildViewToggle(BuildContext context, String label, bool isSelected, DesignCanvasViewModel viewModel) {
    return GestureDetector(
      onTap: () {
        viewModel.setShowPreview(label == 'Preview');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4CAF50) : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelected ? const Color(0xFF4CAF50) : const Color(0xFF666666),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFFEDF1EE),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _showCodeDialog(BuildContext context, DesignCanvasViewModel viewModel) {
    final code = CodeGeneratorService.generateCode(viewModel.widgetRoot, viewModel.appTheme);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2F2F2F),
        title: const Text(
          'Generated Flutter Code',
          style: TextStyle(color: Color(0xFFEDF1EE)),
        ),
        content: SizedBox(
          width: 600,
          height: 400,
          child: SingleChildScrollView(
            child: SelectableText(
              code,
              style: const TextStyle(
                color: Color(0xFFEDF1EE),
                fontFamily: 'monospace',
                fontSize: 12,
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Close',
              style: TextStyle(color: Color(0xFF4CAF50)),
            ),
          ),
        ],
      ),
    );
  }
} 