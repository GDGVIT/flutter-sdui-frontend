import 'package:flutter/material.dart';
import '../models/widget_node.dart';
import '../models/app_theme.dart';
import '../models/widget_data.dart';
import '../services/widget_properties_service.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_sdui/flutter_sdui.dart';

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
      id: 'scaffold_root',
      type: 'Scaffold',
      label: 'Scaffold',
      icon: WidgetNode.getIconFromType('Scaffold'),
      position: const Offset(0, 0),
      size: const Size(900, 600),
      children: const [],
      properties: WidgetPropertiesService.getDefaultProperties('Scaffold'),
    );
  }

  void setSelectedPane(String pane) {
    _selectedPane = pane;
    notifyListeners();
  }

  void setSelectedWidget(String? widgetId) {
    _selectedWidgetId = widgetId;
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

  void addWidgetToParent(String parentId, WidgetData widgetData) {
    _rootWidgetNode = _addWidgetToParent(_rootWidgetNode, parentId, widgetData);
    notifyListeners();
  }

  WidgetNode _addWidgetToParent(
    WidgetNode node,
    String parentId,
    WidgetData widgetData,
  ) {
    if (node.id == parentId) {
      final parentConstraints = WidgetPropertiesService.getConstraints(node.type);
      if (parentConstraints.maxChildren == 0) return node;
      final isLayoutWidget = node.type == 'Column Widget' || node.type == 'Row Widget' || node.type == 'Stack Widget';
      List<WidgetNode> newChildren = List.from(node.children);
      if (!isLayoutWidget && parentConstraints.maxChildren == 1 && newChildren.isNotEmpty) {
        newChildren = [];
      } else if (newChildren.length >= parentConstraints.maxChildren && parentConstraints.maxChildren != -1) {
        return node;
      }
      final newWidget = WidgetNode(
        id: 'widget_${DateTime.now().millisecondsSinceEpoch}',
        type: widgetData.type,
        label: widgetData.label,
        icon: widgetData.icon,
        position: const Offset(10, 10),
        size: WidgetPropertiesService.getDefaultSize(widgetData.type),
        children: const [],
        properties: WidgetPropertiesService.getDefaultProperties(widgetData.type),
      );
      newChildren = [...newChildren, newWidget];
      return node.copyWith(children: newChildren);
    } else {
      return node.copyWith(
        children: node.children
            .map((child) => _addWidgetToParent(child, parentId, widgetData))
            .toList(),
      );
    }
  }

  void updateWidgetProperty(String widgetId, String propertyName, dynamic value) {
    _rootWidgetNode = _updateWidgetProperty(_rootWidgetNode, widgetId, propertyName, value);
    notifyListeners();
  }

  WidgetNode _updateWidgetProperty(
    WidgetNode node,
    String widgetId,
    String propertyName,
    dynamic value,
  ) {
    if (node.id == widgetId) {
      final newProperties = Map<String, dynamic>.from(node.properties);
      newProperties[propertyName] = value;
      return node.copyWith(properties: newProperties);
    } else {
      return node.copyWith(
        children: node.children
            .map((child) => _updateWidgetProperty(child, widgetId, propertyName, value))
            .toList(),
      );
    }
  }

  void removeWidget(String widgetId) {
    if (widgetId == _rootWidgetNode.id) return;
    _rootWidgetNode = _removeWidget(_rootWidgetNode, widgetId);
    if (_selectedWidgetId == widgetId) {
      _selectedWidgetId = null;
    }
    notifyListeners();
  }

  WidgetNode _removeWidget(WidgetNode node, String widgetId) {
    final newChildren = node.children
        .where((child) => child.id != widgetId)
        .map((child) => _removeWidget(child, widgetId))
        .toList();
    return node.copyWith(children: newChildren);
  }

  void moveWidget(String id, Offset newPosition) {
    _rootWidgetNode = _moveWidget(_rootWidgetNode, id, newPosition);
    notifyListeners();
  }

  WidgetNode _moveWidget(WidgetNode node, String id, Offset newPosition) {
    if (node.id == id) {
      return node.copyWith(position: newPosition);
    } else {
      return node.copyWith(
        children: node.children.map((child) => _moveWidget(child, id, newPosition)).toList(),
      );
    }
  }

  void resizeWidget(String id, Size newSize) {
    _rootWidgetNode = _resizeWidget(_rootWidgetNode, id, newSize);
    notifyListeners();
  }

  WidgetNode _resizeWidget(WidgetNode node, String id, Size newSize) {
    if (node.id == id) {
      final newProperties = Map<String, dynamic>.from(node.properties);
      if (newProperties.containsKey('width')) {
        newProperties['width'] = newSize.width;
      }
      if (newProperties.containsKey('height')) {
        newProperties['height'] = newSize.height;
      }
      return node.copyWith(size: newSize, properties: newProperties);
    } else {
      return node.copyWith(
        children: node.children.map((child) => _resizeWidget(child, id, newSize)).toList(),
      );
    }
  }

  WidgetNode? _findWidgetById(String? id) {
    if (id == null) return null;
    WidgetNode? findInWidget(WidgetNode widget) {
      if (widget.id == id) return widget;
      for (final child in widget.children) {
        final found = findInWidget(child);
        if (found != null) return found;
      }
      return null;
    }
    return findInWidget(_rootWidgetNode);
  }

  WidgetNode? getSelectedWidget() {
    return _findWidgetById(_selectedWidgetId);
  }

  // Utility methods
  bool canWidgetAcceptChildren(String widgetId) {
    final widget = _findWidgetById(widgetId);
    if (widget == null) return false;
    final constraints = WidgetPropertiesService.getConstraints(widget.type);
    return constraints.canHaveChildren;
  }

  bool shouldReplaceChild(String widgetId) {
    final widget = _findWidgetById(widgetId);
    if (widget == null) return false;
    final constraints = WidgetPropertiesService.getConstraints(widget.type);
    return constraints.maxChildren == 1 && widget.children.isNotEmpty;
  }

  void replaceChild(String widgetId) {
    _rootWidgetNode = _replaceChild(_rootWidgetNode, widgetId);
    notifyListeners();
  }

  WidgetNode _replaceChild(WidgetNode node, String widgetId) {
    if (node.id == widgetId) {
      return node.copyWith(children: const []);
    } else {
      return node.copyWith(
        children: node.children.map((child) => _replaceChild(child, widgetId)).toList(),
      );
    }
  }

  // Export/Import methods
  Map<String, dynamic> exportProject() {
    return {
      'scaffoldWidget': _rootWidgetNode.toJson(),
      'appTheme': _appTheme.toJson(),
      'selectedWidgetId': _selectedWidgetId,
    };
  }

  void importProject(Map<String, dynamic> data) {
    try {
      _rootWidgetNode = WidgetNode.fromJson(data['scaffoldWidget']);
      _appTheme = AppTheme.fromJson(data['appTheme']);
      _selectedWidgetId = data['selectedWidgetId'];
      notifyListeners();
    } catch (e) {
      // Handle import error
      debugPrint('Error importing project: $e');
    }
  }

  /// Recursively convert a WidgetNode tree to an SDUI widget tree.
  SduiWidget widgetNodeToSduiWidget(WidgetNode node) {
    final children = node.children.map(widgetNodeToSduiWidget).toList();
    switch (node.type) {
      case 'SduiColumn':
        return SduiColumn(children: children);
      case 'SduiRow':
        return SduiRow(children: children);
      case 'SduiContainer':
        return SduiContainer(); // Add property mapping as needed
      case 'SduiText':
        return SduiText(node.properties['text']?.toString() ?? '');
      case 'SduiImage':
        return SduiImage(node.properties['src']?.toString() ?? '');
      case 'SduiIcon':
        return SduiIcon();
      case 'SduiSpacer':
        return SduiSpacer();
      case 'SduiSizedBox':
        return SduiSizedBox();
      case 'SduiScaffold':
        return SduiScaffold();
      default:
        return SduiContainer();
    }
  }

  /// Export the current SDUI widget tree to a JSON file at [filePath].
  Future<void> exportToFile(String filePath) async {
    final sduiWidget = widgetNodeToSduiWidget(widgetRoot);
    final sduiJson = SduiParser.toJson(sduiWidget);
    final jsonString = jsonEncode(sduiJson);
    final file = File(filePath);
    await file.writeAsString(jsonString);
  }

  /// Utility to export an SduiWidget to a JSON string.
  String exportToJsonString(SduiWidget sduiWidget) {
    final sduiJson = SduiParser.toJson(sduiWidget);
    return jsonEncode(sduiJson);
  }
} 