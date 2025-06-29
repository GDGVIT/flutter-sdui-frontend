import 'package:flutter/material.dart';
import '../models/widget_node.dart';
import '../models/app_theme.dart';
import '../models/widget_data.dart';
import '../services/widget_properties_service.dart';

class DesignCanvasViewModel extends ChangeNotifier {
  String _selectedPane = 'build';
  WidgetNode _scaffoldWidget;
  String? _selectedWidgetId;
  bool _showPreview = false;
  AppTheme _appTheme = AppTheme.defaultTheme;
  double _canvasScale = 1.0;
  Offset _canvasOffset = Offset.zero;
  // Persist visual sizes for design mode
  final Map<String, Size> _visualSizes = {};

  DesignCanvasViewModel() : _scaffoldWidget = _createDefaultScaffold();

  // Getters
  String get selectedPane => _selectedPane;
  WidgetNode get scaffoldWidget => _scaffoldWidget;
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

  // Actions
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
    _scaffoldWidget = _addWidgetToParent(_scaffoldWidget, parentId, widgetData);
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
    _scaffoldWidget = _updateWidgetProperty(_scaffoldWidget, widgetId, propertyName, value);
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
    if (widgetId == _scaffoldWidget.id) return;
    _scaffoldWidget = _removeWidget(_scaffoldWidget, widgetId);
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
    _scaffoldWidget = _moveWidget(_scaffoldWidget, id, newPosition);
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
    _scaffoldWidget = _resizeWidget(_scaffoldWidget, id, newSize);
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
    return findInWidget(_scaffoldWidget);
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
    _scaffoldWidget = _replaceChild(_scaffoldWidget, widgetId);
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
      'scaffoldWidget': _scaffoldWidget.toJson(),
      'appTheme': _appTheme.toJson(),
      'selectedWidgetId': _selectedWidgetId,
    };
  }

  void importProject(Map<String, dynamic> data) {
    try {
      _scaffoldWidget = WidgetNode.fromJson(data['scaffoldWidget']);
      _appTheme = AppTheme.fromJson(data['appTheme']);
      _selectedWidgetId = data['selectedWidgetId'];
      notifyListeners();
    } catch (e) {
      // Handle import error
      debugPrint('Error importing project: $e');
    }
  }

  // Visual size methods for design mode
  Size? getVisualSize(String widgetId) => _visualSizes[widgetId];
  void setVisualSize(String widgetId, Size size) {
    _visualSizes[widgetId] = size;
    notifyListeners();
  }
  void clearVisualSizes() {
    _visualSizes.clear();
    notifyListeners();
  }
} 