import 'package:flutter/material.dart';
import '../models/widget_node.dart';
import '../models/app_theme.dart';
import '../models/widget_data.dart';
import '../services/widget_properties_service.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_sdui/flutter_sdui.dart';
import 'package:uuid/uuid.dart';
import 'widget_tree_service.dart';
import 'sdui_conversion_service.dart';
import 'import_export_service.dart';

final Uuid globalUuid = Uuid();

class DesignCanvasViewModel extends ChangeNotifier {
  WidgetNode _rootWidgetNode;
  String _selectedPane = 'build';
  String? _selectedWidgetId;
  bool _showPreview = false;
  AppTheme _appTheme = AppTheme.defaultTheme;
  double _canvasScale = 1.0;
  Offset _canvasOffset = Offset.zero;

  DesignCanvasViewModel()
      : _rootWidgetNode = _createDefaultScaffold();

  // Getters
  String get selectedPane => _selectedPane;
  WidgetNode get widgetRoot => _rootWidgetNode;
  String? get selectedWidgetId => _selectedWidgetId;
  bool get showPreview => _showPreview;
  AppTheme get appTheme => _appTheme;
  double get canvasScale => _canvasScale;
  Offset get canvasOffset => _canvasOffset;

  static WidgetNode _createDefaultScaffold() {
    return WidgetNode(
      uid: 'scaffold_root',
      type: 'SduiScaffold',
      label: 'SduiScaffold',
      icon: Icons.web_asset,
      position: const Offset(0, 0),
      size: const Size(900, 600),
      children: const [],
      properties: WidgetPropertiesService.getDefaultProperties('SduiScaffold'),
    );
  }

  void setSelectedPane(String pane) {
    _selectedPane = pane;
    notifyListeners();
  }

  void setSelectedWidget(String? widgetUid) {
    _selectedWidgetId = widgetUid;
    notifyListeners();
  }

  void togglePreview() {
    _showPreview = !_showPreview;
    notifyListeners();
  }

  void setShowPreview(bool show) {
    _showPreview = show;
    notifyListeners();
  }

  void updateTheme(AppTheme theme) {
    _appTheme = theme;
    notifyListeners();
  }

  void setCanvasScale(double scale) {
    _canvasScale = scale.clamp(0.5, 3.0);
    notifyListeners();
  }

  void setCanvasOffset(Offset offset) {
    _canvasOffset = offset;
    notifyListeners();
  }

  void resetCanvasView() {
    _canvasScale = 1.0;
    _canvasOffset = Offset.zero;
    notifyListeners();
  }

  void addWidgetToParent(String parentUid, WidgetData widgetData) {
    _rootWidgetNode = WidgetTreeService.addWidgetToParent(_rootWidgetNode, parentUid, widgetData);
    notifyListeners();
  }

  void updateWidgetProperty(String widgetUid, String propertyName, dynamic value) {
    _rootWidgetNode = WidgetTreeService.updateWidgetProperty(_rootWidgetNode, widgetUid, propertyName, value);
    notifyListeners();
  }

  void removeWidget(String widgetUid) {
    if (widgetUid == _rootWidgetNode.uid) return;
    _rootWidgetNode = WidgetTreeService.removeWidget(_rootWidgetNode, widgetUid);
    if (_selectedWidgetId == widgetUid) {
      _selectedWidgetId = null;
    }
    notifyListeners();
  }

  void moveWidget(String uid, Offset newPosition) {
    _rootWidgetNode = WidgetTreeService.moveWidget(_rootWidgetNode, uid, newPosition);
    notifyListeners();
  }

  void resizeWidget(String uid, Size newSize) {
    _rootWidgetNode = WidgetTreeService.resizeWidget(_rootWidgetNode, uid, newSize);
    notifyListeners();
  }

  WidgetNode? getSelectedWidget() {
    return WidgetTreeService.findWidgetByUid(_rootWidgetNode, _selectedWidgetId);
  }

  // SDUI conversion
  SduiWidget widgetNodeToSduiWidget(WidgetNode node) {
    return SduiConversionService.widgetNodeToSduiWidget(node);
  }

  // Import/Export
  Map<String, dynamic> exportProject() {
    return ImportExportService.exportProject(_rootWidgetNode, _appTheme, _selectedWidgetId);
  }

  void importProject(Map<String, dynamic> data) {
    ImportExportService.importProject(
      data,
      setRoot: (root) => _rootWidgetNode = root,
      setTheme: (theme) => _appTheme = theme,
      setSelectedWidgetId: (id) => _selectedWidgetId = id,
    );
    notifyListeners();
  }

  Future<void> exportToFile(String filePath) async {
    final sduiWidget = widgetNodeToSduiWidget(_rootWidgetNode);
    await ImportExportService.exportToFile(filePath, sduiWidget);
  }

  String exportToJsonString(SduiWidget sduiWidget) {
    return ImportExportService.exportToJsonString(sduiWidget);
  }

  void reparentWidget(String nodeId, String newParentId) {
    // Prevent moving the root node or moving a node into itself
    if (nodeId == _rootWidgetNode.uid || nodeId == newParentId) return;
    // Prevent moving a node into its descendant
    final nodeToMove = WidgetTreeService.findWidgetByUid(_rootWidgetNode, nodeId);
    if (nodeToMove == null) return;
    final newParent = WidgetTreeService.findWidgetByUid(_rootWidgetNode, newParentId);
    if (newParent == null) return;
    // Prevent moving a node into its descendant
    bool isDescendant(WidgetNode ancestor, WidgetNode possibleDescendant) {
      if (ancestor.uid == possibleDescendant.uid) return true;
      for (final child in ancestor.children) {
        if (isDescendant(child, possibleDescendant)) return true;
      }
      return false;
    }
    if (isDescendant(nodeToMove, newParent)) return;
    // Remove node from old parent
    WidgetNode removeNode(WidgetNode root, String uid) {
      final newChildren = root.children
          .where((child) => child.uid != uid)
          .map((child) => removeNode(child, uid))
          .toList();
      return root.copyWith(children: newChildren);
    }
    final rootWithoutNode = removeNode(_rootWidgetNode, nodeId);
    // Add node to new parent
    _rootWidgetNode = WidgetTreeService.addWidgetToParent(rootWithoutNode, newParentId, WidgetData(
      type: nodeToMove.type,
      label: nodeToMove.label,
      icon: nodeToMove.icon,
      position: const Offset(10, 10),
    ));
    notifyListeners();
  }

  void importFromSduiJson(Map<String, dynamic> json) {
    final sduiWidget = SduiParser.parseJSON(json);
    if (sduiWidget == null) return;
    final widgetNode = SduiConversionService.widgetNodeFromSduiWidget(sduiWidget);
    _rootWidgetNode = widgetNode;
    notifyListeners();
  }

  // Add more high-level coordination as needed...
} 