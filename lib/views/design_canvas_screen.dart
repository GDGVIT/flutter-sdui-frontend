import 'package:flutter/material.dart';
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

class _DesignCanvasScreenContent extends StatelessWidget {
  const _DesignCanvasScreenContent();

  @override
  Widget build(BuildContext context) {
    return Consumer<DesignCanvasViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          body: Row(
            children: [
              // Narrow Icon Bar
              Container(
                width: 90,
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
              // Wider Left Panel
              Container(
                width: 275,
                color: const Color(0xFF2F2F2F),
                child: LeftSidebar(
                  selectedPane: viewModel.selectedPane,
                  scaffoldWidget: viewModel.scaffoldWidget,
                  appTheme: viewModel.appTheme,
                  onThemeChanged: viewModel.updateTheme,
                  onWidgetDropped: (widgetData) {
                    // This callback is used by BuildPane's Draggable
                    // Drop logic is handled in DesignCanvas, but keep for compatibility
                  },
                  selectedWidgetId: viewModel.selectedWidgetId,
                  onWidgetSelected: viewModel.setSelectedWidget,
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
                          const Spacer(),
                          if (viewModel.showPreview)
                            TextButton.icon(
                              onPressed: () => _showCodeDialog(context, viewModel),
                              icon: const Icon(Icons.code, color: Color(0xFF4CAF50), size: 16),
                              label: const Text(
                                'View Code',
                                style: TextStyle(color: Color(0xFF4CAF50)),
                              ),
                            ),
                          const SizedBox(width: 16),
                        ],
                      ),
                    ),
                    // Canvas Content
                    Expanded(
                      child: viewModel.showPreview
                          ? PreviewCanvas(
                              scaffoldWidget: viewModel.scaffoldWidget,
                              appTheme: viewModel.appTheme,
                            )
                          : DesignCanvas(
                              scaffoldWidget: viewModel.scaffoldWidget,
                              selectedWidgetId: viewModel.selectedWidgetId,
                              appTheme: viewModel.appTheme,
                              onWidgetSelected: viewModel.setSelectedWidget,
                              onWidgetAdded: viewModel.addWidgetToParent,
                              onWidgetMoved: viewModel.moveWidget,
                              onWidgetResized: viewModel.resizeWidget,
                            ),
                    ),
                  ],
                ),
              ),
              // Right Properties Panel
              Container(
                width: 300,
                color: const Color(0xFF2F2F2F),
                child: PropertiesPanel(
                  selectedWidget: viewModel.getSelectedWidget(),
                  appTheme: viewModel.appTheme,
                  onPropertyChanged: viewModel.updateWidgetProperty,
                  onWidgetRemoved: viewModel.removeWidget,
                ),
              ),
            ],
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
    final code = CodeGeneratorService.generateCode(viewModel.scaffoldWidget, viewModel.appTheme);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2F2F2F),
        title: const Text(
          'Generated Flutter Code',
          style: TextStyle(color: Color(0xFFEDF1EE)),
        ),
        content: Container(
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