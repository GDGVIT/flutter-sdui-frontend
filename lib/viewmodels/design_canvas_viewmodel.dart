import 'package:flutter/material.dart';
import '../models/widget_node.dart';
import '../models/app_theme.dart';
import '../models/widget_data.dart';
import '../services/widget_properties_service.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_sdui/flutter_sdui.dart';
import 'package:uuid/uuid.dart';

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
    _rootWidgetNode = _addWidgetToParent(_rootWidgetNode, parentUid, widgetData);
    notifyListeners();
  }

  WidgetNode _addWidgetToParent(
    WidgetNode node,
    String parentUid,
    WidgetData widgetData,
  ) {
    if (node.uid == parentUid) {
      final parentConstraints = WidgetPropertiesService.getConstraints(node.type);
      if (parentConstraints.maxChildren == 0) return node;
      final isLayoutWidget = node.type == 'Column Widget' || node.type == 'Row Widget' || node.type == 'Stack Widget' || node.type == 'SduiColumn' || node.type == 'SduiRow';
      List<WidgetNode> newChildren = List.from(node.children);
      if (!isLayoutWidget && parentConstraints.maxChildren == 1 && newChildren.isNotEmpty) {
        newChildren = [];
      } else if (newChildren.length >= parentConstraints.maxChildren && parentConstraints.maxChildren != -1) {
        return node;
      }
      var newWidget = WidgetNode(
        uid: globalUuid.v4(),
        type: widgetData.type,
        label: widgetData.label,
        icon: widgetData.icon,
        position: _getStaggeredChildPosition(node, newChildren.length),
        size: (() {
          final parentSize = node.size;
          if ((widgetData.type == 'SduiColumn' || widgetData.type == 'SduiRow' || widgetData.type == 'SduiContainer') && parentSize != null) {
            return Size(parentSize.width * 0.8, parentSize.height * 0.8);
          }
          return WidgetPropertiesService.getDefaultSize(widgetData.type);
        })(),
        children: const [],
        properties: WidgetPropertiesService.getDefaultProperties(widgetData.type),
      );
      newChildren = [...newChildren, newWidget];

      // --- Improved auto-size logic for SDUI multi-child parents ---
      if (node.type == 'SduiColumn') {
        // Grow parent if needed to fit all children
        double totalHeight = newChildren.fold(0.0, (sum, child) => sum + (child.size.height));
        double parentHeight = node.size.height;
        double parentWidth = node.size.width;
        if (totalHeight > parentHeight) {
          parentHeight = totalHeight * 2;
        }
        // Shrink children if parent is fixed and overflows
        if (totalHeight > parentHeight && parentConstraints.maxChildren != -1) {
          double newChildHeight = parentHeight / newChildren.length;
          newChildren = newChildren.map((child) => child.copyWith(size: Size(child.size.width, newChildHeight))).toList();
        }
        // Update parent size
        node = node.copyWith(size: Size(parentWidth, parentHeight));
      } else if (node.type == 'SduiRow') {
        double totalWidth = newChildren.fold(0.0, (sum, child) => sum + (child.size.width));
        double parentWidth = node.size.width;
        double parentHeight = node.size.height;
        if (totalWidth > parentWidth) {
          parentWidth = totalWidth * 2;
        }
        if (totalWidth > parentWidth && parentConstraints.maxChildren != -1) {
          double newChildWidth = parentWidth / newChildren.length;
          newChildren = newChildren.map((child) => child.copyWith(size: Size(newChildWidth, child.size.height))).toList();
        }
        node = node.copyWith(size: Size(parentWidth, parentHeight));
      }
      // --- End improved auto-size logic ---

      // --- Auto-parent-resize for multi-child parents (recursive) ---
      WidgetNode resizedNode = node.copyWith(children: newChildren);
      if (isLayoutWidget) {
        final Rect bounds = _computeChildrenBounds(newChildren);
        double minWidth = node.size.width;
        double minHeight = node.size.height;
        double neededWidth = bounds.right;
        double neededHeight = bounds.bottom;
        Size newParentSize = Size(
          neededWidth > minWidth ? neededWidth : minWidth,
          neededHeight > minHeight ? neededHeight : minHeight,
        );
        if (newParentSize != node.size) {
          final newProps = Map<String, dynamic>.from(node.properties);
          if (newProps.containsKey('width')) newProps['width'] = newParentSize.width;
          if (newProps.containsKey('height')) newProps['height'] = newParentSize.height;
          resizedNode = node.copyWith(children: newChildren, size: newParentSize, properties: newProps);
        }
      }
      return resizedNode;
    } else {
      // Recursively update ancestors if any child changes size
      final updatedChildren = node.children
          .map((child) => _addWidgetToParent(child, parentUid, widgetData))
          .toList();
      WidgetNode updatedNode = node.copyWith(children: updatedChildren);
      // --- Recursive auto-parent-resize up the tree ---
      final isLayoutWidget = node.type == 'Column Widget' || node.type == 'Row Widget' || node.type == 'Stack Widget' || node.type == 'SduiColumn' || node.type == 'SduiRow';
      if (isLayoutWidget) {
        final Rect bounds = _computeChildrenBounds(updatedChildren);
        double minWidth = node.size.width;
        double minHeight = node.size.height;
        double neededWidth = bounds.right;
        double neededHeight = bounds.bottom;
        Size newParentSize = Size(
          neededWidth > minWidth ? neededWidth : minWidth,
          neededHeight > minHeight ? neededHeight : minHeight,
        );
        if (newParentSize != node.size) {
          final newProps = Map<String, dynamic>.from(node.properties);
          if (newProps.containsKey('width')) newProps['width'] = newParentSize.width;
          if (newProps.containsKey('height')) newProps['height'] = newParentSize.height;
          updatedNode = node.copyWith(size: newParentSize, properties: newProps);
        }
      }
      return updatedNode;
    }
  }

  // Helper: stagger child positions to avoid overlap
  Offset _getStaggeredChildPosition(WidgetNode parent, int childIndex) {
    if (parent.type == 'Column Widget' || parent.type == 'SduiColumn') {
      return Offset(10, 10 + 40.0 * childIndex);
    } else if (parent.type == 'Row Widget' || parent.type == 'SduiRow') {
      return Offset(10 + 40.0 * childIndex, 10);
    } else {
      return const Offset(10, 10);
    }
  }

  void updateWidgetProperty(String widgetUid, String propertyName, dynamic value) {
    _rootWidgetNode = _updateWidgetProperty(_rootWidgetNode, widgetUid, propertyName, value);
    notifyListeners();
  }

  WidgetNode _updateWidgetProperty(
    WidgetNode node,
    String widgetUid,
    String propertyName,
    dynamic value,
  ) {
    if (node.uid == widgetUid) {
      final newProperties = Map<String, dynamic>.from(node.properties);
      newProperties[propertyName] = value;
      return node.copyWith(properties: newProperties);
    } else {
      return node.copyWith(
        children: node.children
            .map((child) => _updateWidgetProperty(child, widgetUid, propertyName, value))
            .toList(),
      );
    }
  }

  void removeWidget(String widgetUid) {
    if (widgetUid == _rootWidgetNode.uid) return;
    _rootWidgetNode = _removeWidget(_rootWidgetNode, widgetUid);
    if (_selectedWidgetId == widgetUid) {
      _selectedWidgetId = null;
    }
    notifyListeners();
  }

  WidgetNode _removeWidget(WidgetNode node, String widgetUid) {
    final newChildren = node.children
        .where((child) => child.uid != widgetUid)
        .map((child) => _removeWidget(child, widgetUid))
        .toList();
    return node.copyWith(children: newChildren);
  }

  void moveWidget(String uid, Offset newPosition) {
    _rootWidgetNode = _moveWidget(_rootWidgetNode, uid, newPosition);
    notifyListeners();
  }

  WidgetNode _moveWidget(WidgetNode node, String uid, Offset newPosition) {
    if (node.uid == uid) {
      return node.copyWith(position: newPosition);
    } else {
      return node.copyWith(
        children: node.children.map((child) => _moveWidget(child, uid, newPosition)).toList(),
      );
    }
  }

  void resizeWidget(String uid, Size newSize) {
    _rootWidgetNode = _resizeWidget(_rootWidgetNode, uid, newSize);
    notifyListeners();
  }

  WidgetNode _resizeWidget(WidgetNode node, String uid, Size newSize) {
    if (node.uid == uid) {
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
        children: node.children.map((child) => _resizeWidget(child, uid, newSize)).toList(),
      );
    }
  }

  WidgetNode? _findWidgetByUid(String? uid) {
    if (uid == null) return null;
    WidgetNode? findInWidget(WidgetNode widget) {
      if (widget.uid == uid) return widget;
      for (final child in widget.children) {
        final found = findInWidget(child);
        if (found != null) return found;
      }
      return null;
    }
    return findInWidget(_rootWidgetNode);
  }

  WidgetNode? getSelectedWidget() {
    return _findWidgetByUid(_selectedWidgetId);
  }

  // Utility methods
  bool canWidgetAcceptChildren(String widgetUid) {
    final widget = _findWidgetByUid(widgetUid);
    if (widget == null) return false;
    final constraints = WidgetPropertiesService.getConstraints(widget.type);
    return constraints.canHaveChildren;
  }

  bool shouldReplaceChild(String widgetUid) {
    final widget = _findWidgetByUid(widgetUid);
    if (widget == null) return false;
    final constraints = WidgetPropertiesService.getConstraints(widget.type);
    return constraints.maxChildren == 1 && widget.children.isNotEmpty;
  }

  void replaceChild(String widgetUid) {
    _rootWidgetNode = _replaceChild(_rootWidgetNode, widgetUid);
    notifyListeners();
  }

  WidgetNode _replaceChild(WidgetNode node, String widgetUid) {
    if (node.uid == widgetUid) {
      return node.copyWith(children: const []);
    } else {
      return node.copyWith(
        children: node.children.map((child) => _replaceChild(child, widgetUid)).toList(),
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
        return SduiColumn(
          children: children,
          mainAxisAlignment: _parseMainAxisAlignment(node.properties['mainAxisAlignment']),
          mainAxisSize: _parseMainAxisSize(node.properties['mainAxisSize']),
          crossAxisAlignment: _parseCrossAxisAlignment(node.properties['crossAxisAlignment']),
          textDirection: _parseTextDirection(node.properties['textDirection']),
          verticalDirection: _parseVerticalDirection(node.properties['verticalDirection']),
          textBaseline: _parseTextBaseline(node.properties['textBaseline']),
        );
      case 'SduiRow':
        return SduiRow(
          children: children,
          mainAxisAlignment: _parseMainAxisAlignment(node.properties['mainAxisAlignment']),
          mainAxisSize: _parseMainAxisSize(node.properties['mainAxisSize']),
          crossAxisAlignment: _parseCrossAxisAlignment(node.properties['crossAxisAlignment']),
          textDirection: _parseTextDirection(node.properties['textDirection']),
          verticalDirection: _parseVerticalDirection(node.properties['verticalDirection']),
          textBaseline: _parseTextBaseline(node.properties['textBaseline']),
        );
      case 'SduiContainer':
        return SduiContainer(
          child: children.isNotEmpty ? children.first : null,
          width: _parseDouble(node.properties['width']),
          height: _parseDouble(node.properties['height']),
          color: _parseColor(node.properties['color']),
          alignment: _parseAlignment(node.properties['alignment']),
          padding: _parseEdgeInsets(node.properties['padding']),
          margin: _parseEdgeInsets(node.properties['margin']),
          decoration: _parseBoxDecoration(node.properties),
          constraints: null, // TODO: parse constraints if needed
          transform: null, // TODO: parse transform if needed
          transformAlignment: null, // TODO: parse transformAlignment if needed
          clipBehavior: _parseClip(node.properties['clipBehavior']),
        );
      case 'SduiText':
        return SduiText(
          node.properties['text']?.toString() ?? '',
          fontSize: _parseDouble(node.properties['fontSize']),
          fontWeight: _parseFontWeight(node.properties['fontWeight']),
          color: _parseColor(node.properties['color']),
          textAlign: _parseTextAlign(node.properties['textAlign']),
          fontFamily: node.properties['fontFamily']?.toString(),
          letterSpacing: _parseDouble(node.properties['letterSpacing']),
          wordSpacing: _parseDouble(node.properties['wordSpacing']),
          height: _parseDouble(node.properties['height']),
          maxLines: _parseInt(node.properties['maxLines']),
          overflow: _parseTextOverflow(node.properties['overflow']),
          softWrap: node.properties['softWrap'] as bool?,
          decoration: _parseTextDecoration(node.properties['decoration']),
          textDirection: _parseTextDirection(node.properties['textDirection']),
        );
      case 'SduiImage':
        return SduiImage(
          node.properties['src']?.toString() ?? '',
          width: _parseDouble(node.properties['width']),
          height: _parseDouble(node.properties['height']),
          fit: _parseBoxFit(node.properties['fit']),
          alignment: _parseAlignment(node.properties['alignment']),
          repeat: _parseImageRepeat(node.properties['repeat']),
          color: _parseColor(node.properties['color']),
          colorBlendMode: _parseBlendMode(node.properties['colorBlendMode']),
          centerSlice: null, // TODO: parse if needed
          matchTextDirection: node.properties['matchTextDirection'] as bool? ?? false,
          gaplessPlayback: node.properties['gaplessPlayback'] as bool? ?? false,
          filterQuality: _parseFilterQuality(node.properties['filterQuality']),
          cacheWidth: _parseInt(node.properties['cacheWidth']),
          cacheHeight: _parseInt(node.properties['cacheHeight']),
          scale: _parseDouble(node.properties['scale']) ?? 1.0,
          semanticLabel: node.properties['semanticLabel']?.toString(),
        );
      case 'SduiIcon':
        return SduiIcon(
          icon: null, // TODO: parse icon name if needed
          size: _parseDouble(node.properties['size']),
          color: _parseColor(node.properties['color']),
          semanticLabel: node.properties['semanticLabel']?.toString(),
          textDirection: _parseTextDirection(node.properties['textDirection']),
          opacity: _parseDouble(node.properties['opacity']),
          applyTextScaling: node.properties['applyTextScaling'] as bool?,
          shadows: null, // TODO: parse shadows if needed
        );
      case 'SduiSpacer':
        return SduiSpacer(flex: _parseInt(node.properties['flex']) ?? 1);
      case 'SduiSizedBox':
        return SduiSizedBox(
          width: _parseDouble(node.properties['width']),
          height: _parseDouble(node.properties['height']),
          child: children.isNotEmpty ? children.first : null,
        );
      case 'SduiScaffold':
        return SduiScaffold(
          backgroundColor: _parseColor(node.properties['backgroundColor']),
          resizeToAvoidBottomInset: node.properties['resizeToAvoidBottomInset'] as bool?,
          primary: node.properties['primary'] as bool? ?? true,
          floatingActionButtonLocation: null, // TODO: parse if needed
          extendBody: node.properties['extendBody'] as bool? ?? false,
          extendBodyBehindAppBar: node.properties['extendBodyBehindAppBar'] as bool? ?? false,
          drawerScrimColor: _parseColor(node.properties['drawerScrimColor']),
          drawerEdgeDragWidth: _parseDouble(node.properties['drawerEdgeDragWidth']),
          drawerEnableOpenDragGesture: node.properties['drawerEnableOpenDragGesture'] as bool? ?? true,
          endDrawerEnableOpenDragGesture: node.properties['endDrawerEnableOpenDragGesture'] as bool? ?? true,
          body: children.isNotEmpty ? children.first : null,
        );
      default:
        return SduiContainer();
    }
  }

  // --- Property parsing helpers ---
  MainAxisAlignment? _parseMainAxisAlignment(dynamic value) {
    switch (value) {
      case 'start': return MainAxisAlignment.start;
      case 'end': return MainAxisAlignment.end;
      case 'center': return MainAxisAlignment.center;
      case 'spaceBetween': return MainAxisAlignment.spaceBetween;
      case 'spaceAround': return MainAxisAlignment.spaceAround;
      case 'spaceEvenly': return MainAxisAlignment.spaceEvenly;
      default: return null;
    }
  }
  MainAxisSize? _parseMainAxisSize(dynamic value) {
    switch (value) {
      case 'min': return MainAxisSize.min;
      case 'max': return MainAxisSize.max;
      default: return null;
    }
  }
  CrossAxisAlignment? _parseCrossAxisAlignment(dynamic value) {
    switch (value) {
      case 'start': return CrossAxisAlignment.start;
      case 'end': return CrossAxisAlignment.end;
      case 'center': return CrossAxisAlignment.center;
      case 'stretch': return CrossAxisAlignment.stretch;
      case 'baseline': return CrossAxisAlignment.baseline;
      default: return null;
    }
  }
  TextDirection? _parseTextDirection(dynamic value) {
    switch (value) {
      case 'ltr': return TextDirection.ltr;
      case 'rtl': return TextDirection.rtl;
      default: return null;
    }
  }
  VerticalDirection? _parseVerticalDirection(dynamic value) {
    switch (value) {
      case 'down': return VerticalDirection.down;
      case 'up': return VerticalDirection.up;
      default: return null;
    }
  }
  TextBaseline? _parseTextBaseline(dynamic value) {
    switch (value) {
      case 'alphabetic': return TextBaseline.alphabetic;
      case 'ideographic': return TextBaseline.ideographic;
      default: return null;
    }
  }
  double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString());
  }
  int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString());
  }
  Color? _parseColor(dynamic value) {
    if (value == null || value == '') return null;
    try {
      if (value is Color) return value;
      if (value is String && value.startsWith('#')) {
        return Color(int.parse(value.replaceFirst('#', '0x')));
      }
    } catch (_) {}
    return null;
  }
  Alignment? _parseAlignment(dynamic value) {
    switch (value) {
      case 'topLeft': return Alignment.topLeft;
      case 'topCenter': return Alignment.topCenter;
      case 'topRight': return Alignment.topRight;
      case 'centerLeft': return Alignment.centerLeft;
      case 'center': return Alignment.center;
      case 'centerRight': return Alignment.centerRight;
      case 'bottomLeft': return Alignment.bottomLeft;
      case 'bottomCenter': return Alignment.bottomCenter;
      case 'bottomRight': return Alignment.bottomRight;
      default: return null;
    }
  }
  EdgeInsets? _parseEdgeInsets(dynamic value) {
    if (value == null) return null;
    if (value is double) return EdgeInsets.all(value);
    if (value is int) return EdgeInsets.all(value.toDouble());
    return null;
  }
  BoxDecoration? _parseBoxDecoration(Map<String, dynamic> props) {
    final color = _parseColor(props['color']);
    final borderRadius = _parseDouble(props['borderRadius']);
    final borderWidth = _parseDouble(props['borderWidth']);
    final borderColor = _parseColor(props['borderColor']);
    if (color == null && borderRadius == null && borderWidth == null) return null;
    return BoxDecoration(
      color: color,
      borderRadius: borderRadius != null ? BorderRadius.circular(borderRadius) : null,
      border: borderWidth != null && borderWidth > 0
          ? Border.all(color: borderColor ?? const Color(0xFF666666), width: borderWidth)
          : null,
    );
  }
  Clip? _parseClip(dynamic value) {
    switch (value) {
      case 'none': return Clip.none;
      case 'hardEdge': return Clip.hardEdge;
      case 'antiAlias': return Clip.antiAlias;
      case 'antiAliasWithSaveLayer': return Clip.antiAliasWithSaveLayer;
      default: return null;
    }
  }
  FontWeight? _parseFontWeight(dynamic value) {
    switch (value) {
      case 'bold': return FontWeight.bold;
      case 'normal': return FontWeight.normal;
      case 'w100': return FontWeight.w100;
      case 'w200': return FontWeight.w200;
      case 'w300': return FontWeight.w300;
      case 'w400': return FontWeight.w400;
      case 'w500': return FontWeight.w500;
      case 'w600': return FontWeight.w600;
      case 'w700': return FontWeight.w700;
      case 'w800': return FontWeight.w800;
      case 'w900': return FontWeight.w900;
      default: return null;
    }
  }
  TextAlign? _parseTextAlign(dynamic value) {
    switch (value) {
      case 'left': return TextAlign.left;
      case 'right': return TextAlign.right;
      case 'center': return TextAlign.center;
      case 'justify': return TextAlign.justify;
      default: return null;
    }
  }
  TextOverflow? _parseTextOverflow(dynamic value) {
    switch (value) {
      case 'clip': return TextOverflow.clip;
      case 'fade': return TextOverflow.fade;
      case 'ellipsis': return TextOverflow.ellipsis;
      case 'visible': return TextOverflow.visible;
      default: return null;
    }
  }
  TextDecoration? _parseTextDecoration(dynamic value) {
    switch (value) {
      case 'underline': return TextDecoration.underline;
      case 'overline': return TextDecoration.overline;
      case 'lineThrough': return TextDecoration.lineThrough;
      default: return TextDecoration.none;
    }
  }
  BoxFit? _parseBoxFit(dynamic value) {
    switch (value) {
      case 'fill': return BoxFit.fill;
      case 'contain': return BoxFit.contain;
      case 'cover': return BoxFit.cover;
      case 'fitWidth': return BoxFit.fitWidth;
      case 'fitHeight': return BoxFit.fitHeight;
      case 'none': return BoxFit.none;
      case 'scaleDown': return BoxFit.scaleDown;
      default: return null;
    }
  }
  ImageRepeat? _parseImageRepeat(dynamic value) {
    switch (value) {
      case 'repeat': return ImageRepeat.repeat;
      case 'repeatX': return ImageRepeat.repeatX;
      case 'repeatY': return ImageRepeat.repeatY;
      case 'noRepeat': return ImageRepeat.noRepeat;
      default: return null;
    }
  }
  BlendMode? _parseBlendMode(dynamic value) {
    if (value == null) return null;
    try {
      return BlendMode.values.firstWhere((e) => e.name == value);
    } catch (_) {}
    return null;
  }
  FilterQuality? _parseFilterQuality(dynamic value) {
    switch (value) {
      case 'none': return FilterQuality.none;
      case 'low': return FilterQuality.low;
      case 'medium': return FilterQuality.medium;
      case 'high': return FilterQuality.high;
      default: return null;
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

  void reparentWidget(String nodeId, String newParentId) {
    // Prevent moving the root node or moving a node into itself
    if (nodeId == _rootWidgetNode.uid || nodeId == newParentId) return;
    // Prevent moving a node into its descendant
    if (_isDescendant(nodeId, newParentId)) return;
    WidgetNode? nodeToMove;
    final newRoot = _removeAndExtractWidget(_rootWidgetNode, nodeId, (removed) {
      nodeToMove = removed;
    });
    if (nodeToMove != null && newRoot != null) {
      _rootWidgetNode = _addExistingWidgetToParent(newRoot, newParentId, nodeToMove!);
      notifyListeners();
    }
  }

  WidgetNode? _removeAndExtractWidget(WidgetNode node, String nodeId, void Function(WidgetNode) onRemoved) {
    if (node.uid == nodeId) {
      onRemoved(node);
      return null;
    }
    final newChildren = <WidgetNode>[];
    for (final child in node.children) {
      final result = _removeAndExtractWidget(child, nodeId, onRemoved);
      if (result != null) newChildren.add(result);
    }
    return node.copyWith(children: newChildren);
  }

  bool _isDescendant(String ancestorId, String possibleDescendantId) {
    WidgetNode? ancestor = _findWidgetByUid(ancestorId);
    if (ancestor == null) return false;
    bool search(WidgetNode node) {
      if (node.uid == possibleDescendantId) return true;
      for (final child in node.children) {
        if (search(child)) return true;
      }
      return false;
    }
    return search(ancestor);
  }

  WidgetNode _addExistingWidgetToParent(WidgetNode node, String parentId, WidgetNode childToAdd) {
    if (node.uid == parentId) {
      final parentConstraints = WidgetPropertiesService.getConstraints(node.type);
      List<WidgetNode> newChildren = List.from(node.children);
      if (parentConstraints.maxChildren == 1) {
        newChildren = [childToAdd];
      } else {
        newChildren = [...newChildren, childToAdd];
      }
      return node.copyWith(children: newChildren);
    } else {
      return node.copyWith(
        children: node.children.map((child) => _addExistingWidgetToParent(child, parentId, childToAdd)).toList(),
      );
    }
  }

  // Compute the bounding box of all children (positions and sizes)
  Rect _computeChildrenBounds(List<WidgetNode> children) {
    if (children.isEmpty) return Rect.zero;
    double minX = double.infinity, minY = double.infinity, maxX = 0, maxY = 0;
    for (final child in children) {
      minX = child.position.dx < minX ? child.position.dx : minX;
      minY = child.position.dy < minY ? child.position.dy : minY;
      final childMaxX = child.position.dx + child.size.width;
      final childMaxY = child.position.dy + child.size.height;
      maxX = childMaxX > maxX ? childMaxX : maxX;
      maxY = childMaxY > maxY ? childMaxY : maxY;
    }
    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }

  // SDUI JSON import: parse with SduiParser.parseJSON, then convert to WidgetNode
  void importFromSduiJson(Map<String, dynamic> json) {
    try {
      final sduiWidget = SduiParser.parseJSON(json);
      if (sduiWidget == null) {
        print('SDUI JSON could not be parsed into a widget');
        throw Exception('SDUI JSON could not be parsed into a widget');
      }
      final widgetNode = _widgetNodeFromSduiWidget(sduiWidget);
      _rootWidgetNode = widgetNode;
      notifyListeners();
    } catch (e, stack) {
      print('Error in importFromSduiJson: $e');
      print(stack);
      rethrow;
    }
  }

  // Robust, null-safe SDUI-to-WidgetNode conversion
  WidgetNode _widgetNodeFromSduiWidget(dynamic sduiWidget) {
    try {
      if (sduiWidget == null) {
        print('Tried to convert a null SDUI widget');
        throw Exception('Tried to convert a null SDUI widget');
      }
      String type = sduiWidget.runtimeType.toString();
      String label = type;
      IconData icon = WidgetNode.getIconFromType(type);
      Offset position = const Offset(10, 10);
      Size size = const Size(200, 100);

      // Extract children recursively, null-safe
      List<WidgetNode> children = [];
      if (sduiWidget is SduiColumn || sduiWidget is SduiRow) {
        if (sduiWidget.children != null) {
          children = (sduiWidget.children as List)
              .where((child) => child != null)
              .map((child) => _widgetNodeFromSduiWidget(child))
              .toList();
        }
      } else if (sduiWidget is SduiContainer && sduiWidget.child != null) {
        children = [_widgetNodeFromSduiWidget(sduiWidget.child!)];
      } else if (sduiWidget is SduiScaffold && sduiWidget.body != null) {
        children = [_widgetNodeFromSduiWidget(sduiWidget.body!)];
      } else if (sduiWidget is SduiSizedBox && sduiWidget.child != null) {
        children = [_widgetNodeFromSduiWidget(sduiWidget.child!)];
      }

      // Extract properties (expand as needed)
      Map<String, dynamic> properties = {};

      // Universal properties
      if (sduiWidget is SduiContainer) {
        if (sduiWidget.width != null) properties['width'] = sduiWidget.width;
        if (sduiWidget.height != null) properties['height'] = sduiWidget.height;
        if (sduiWidget.alignment != null) properties['alignment'] = sduiWidget.alignment.toString();
        if (sduiWidget.color != null) {
          properties['color'] = '#${sduiWidget.color!.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
        }
        if (sduiWidget.padding != null) properties['padding'] = sduiWidget.padding;
        if (sduiWidget.margin != null) properties['margin'] = sduiWidget.margin;
        if (sduiWidget.decoration != null) {
          final BoxDecoration decoration = sduiWidget.decoration!;
          if (decoration.borderRadius != null && decoration.borderRadius is BorderRadius) {
            final BorderRadius br = decoration.borderRadius as BorderRadius;
            if (br.topLeft == br.topRight && br.topLeft == br.bottomLeft && br.topLeft == br.bottomRight) {
              properties['borderRadius'] = br.topLeft.x;
            }
          }
          if (decoration.border != null && decoration.border is Border) {
            final Border border = decoration.border as Border;
            if (border.top.width == border.right.width && border.top.width == border.bottom.width && border.top.width == border.left.width) {
              properties['borderWidth'] = border.top.width;
            }
            if (border.top.color == border.right.color && border.top.color == border.bottom.color && border.top.color == border.left.color) {
              properties['borderColor'] = '#${border.top.color.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
            }
          }
          if (decoration.color != null) {
            properties['color'] = '#${decoration.color!.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
          }
        }
        if (sduiWidget.clipBehavior != null) properties['clipBehavior'] = sduiWidget.clipBehavior.toString();
      } else if (sduiWidget is SduiRow || sduiWidget is SduiColumn) {
        // Only add layout properties for rows/columns
        if (sduiWidget.mainAxisAlignment != null) properties['mainAxisAlignment'] = sduiWidget.mainAxisAlignment.toString().split('.').last;
        if (sduiWidget.mainAxisSize != null) properties['mainAxisSize'] = sduiWidget.mainAxisSize.toString().split('.').last;
        if (sduiWidget.crossAxisAlignment != null) properties['crossAxisAlignment'] = sduiWidget.crossAxisAlignment.toString().split('.').last;
        if (sduiWidget.textDirection != null) properties['textDirection'] = sduiWidget.textDirection.toString().split('.').last;
        if (sduiWidget.verticalDirection != null) properties['verticalDirection'] = sduiWidget.verticalDirection.toString().split('.').last;
        if (sduiWidget.textBaseline != null) properties['textBaseline'] = sduiWidget.textBaseline.toString().split('.').last;
        print('Extracted SduiRow/SduiColumn properties: $properties');
      }

      // SduiScaffold
      if (sduiWidget is SduiScaffold) {
        if (sduiWidget.backgroundColor != null) {
          properties['backgroundColor'] = '#${sduiWidget.backgroundColor!.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
        }
        if (sduiWidget.primary != null) properties['primary'] = sduiWidget.primary;
        if (sduiWidget.extendBody != null) properties['extendBody'] = sduiWidget.extendBody;
        if (sduiWidget.extendBodyBehindAppBar != null) properties['extendBodyBehindAppBar'] = sduiWidget.extendBodyBehindAppBar;
        if (sduiWidget.drawerEnableOpenDragGesture != null) properties['drawerEnableOpenDragGesture'] = sduiWidget.drawerEnableOpenDragGesture;
        if (sduiWidget.endDrawerEnableOpenDragGesture != null) properties['endDrawerEnableOpenDragGesture'] = sduiWidget.endDrawerEnableOpenDragGesture;
      }

      // SduiText
      if (sduiWidget is SduiText) {
        properties['text'] = sduiWidget.text;
        properties['textAlign'] = sduiWidget.textAlign?.toString();
        properties['fontFamily'] = sduiWidget.fontFamily;
        if (sduiWidget.color != null) {
          properties['color'] = '#${sduiWidget.color!.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
        }
      }

      // SduiImage
      if (sduiWidget is SduiImage) {
        if (sduiWidget.src != null) properties['src'] = sduiWidget.src;
        if (sduiWidget.width != null) properties['width'] = sduiWidget.width;
        if (sduiWidget.height != null) properties['height'] = sduiWidget.height;
        if (sduiWidget.fit != null) properties['fit'] = sduiWidget.fit.toString();
        if (sduiWidget.alignment != null) properties['alignment'] = sduiWidget.alignment.toString();
        if (sduiWidget.repeat != null) properties['repeat'] = sduiWidget.repeat.toString();
        if (sduiWidget.color != null) {
          properties['color'] = '#${sduiWidget.color!.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
        }
        if (sduiWidget.filterQuality != null) properties['filterQuality'] = sduiWidget.filterQuality.toString();
        if (sduiWidget.scale != null) properties['scale'] = sduiWidget.scale;
      }

      // SduiIcon
      if (sduiWidget is SduiIcon) {
        if (sduiWidget.icon != null) properties['icon'] = sduiWidget.icon.toString();
        if (sduiWidget.size != null) properties['size'] = sduiWidget.size;
        if (sduiWidget.color != null) {
          properties['color'] = '#${sduiWidget.color!.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
        }
      }

      return WidgetNode(
        uid: globalUuid.v4(),
        type: type,
        label: label,
        icon: icon,
        position: position,
        size: size,
        children: children,
        properties: properties,
      );
    } catch (e, stack) {
      print('Error in _widgetNodeFromSduiWidget: $e');
      print(stack);
      rethrow;
    }
  }

  // --- SDUI Import/Export ---

  /// Import SDUI JSON string, parse, and build WidgetNode tree with new unique ids.
  void importFromSduiJsonString(String jsonString) {
    final Map<String, dynamic> json = jsonDecode(jsonString);
    final sduiWidget = SduiParser.parseJSON(json);
    if (sduiWidget is! SduiScaffold) {
      throw Exception('Root SDUI widget must be SduiScaffold');
    }
    WidgetNode buildNode(dynamic sduiWidget) {
      String type = sduiWidget.runtimeType.toString();
      String label = type;
      IconData icon = WidgetNode.getIconFromType(type);
      Offset position = const Offset(10, 10);
      Size size = const Size(200, 100);
      List<WidgetNode> children = [];
      if (sduiWidget is SduiColumn || sduiWidget is SduiRow) {
        if (sduiWidget.children != null) {
          children = (sduiWidget.children as List)
              .where((child) => child != null)
              .map((child) => buildNode(child))
              .toList();
        }
      } else if (sduiWidget is SduiContainer && sduiWidget.child != null) {
        children = [buildNode(sduiWidget.child!)];
      } else if (sduiWidget is SduiScaffold && sduiWidget.body != null) {
        children = [buildNode(sduiWidget.body!)];
      } else if (sduiWidget is SduiSizedBox && sduiWidget.child != null) {
        children = [buildNode(sduiWidget.child!)];
      }
      Map<String, dynamic> properties = {};
      if (sduiWidget is SduiContainer) {
        if (sduiWidget.width != null) properties['width'] = sduiWidget.width;
        if (sduiWidget.height != null) properties['height'] = sduiWidget.height;
        if (sduiWidget.alignment != null) properties['alignment'] = sduiWidget.alignment.toString();
        if (sduiWidget.color != null) {
          properties['color'] = '#${sduiWidget.color!.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
        }
        if (sduiWidget.padding != null) properties['padding'] = sduiWidget.padding;
        if (sduiWidget.margin != null) properties['margin'] = sduiWidget.margin;
        if (sduiWidget.decoration != null) {
          final BoxDecoration decoration = sduiWidget.decoration!;
          if (decoration.borderRadius != null && decoration.borderRadius is BorderRadius) {
            final BorderRadius br = decoration.borderRadius as BorderRadius;
            if (br.topLeft == br.topRight && br.topLeft == br.bottomLeft && br.topLeft == br.bottomRight) {
              properties['borderRadius'] = br.topLeft.x;
            }
          }
          if (decoration.border != null && decoration.border is Border) {
            final Border border = decoration.border as Border;
            if (border.top.width == border.right.width && border.top.width == border.bottom.width && border.top.width == border.left.width) {
              properties['borderWidth'] = border.top.width;
            }
            if (border.top.color == border.right.color && border.top.color == border.bottom.color && border.top.color == border.left.color) {
              properties['borderColor'] = '#${border.top.color.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
            }
          }
          if (decoration.color != null) {
            properties['color'] = '#${decoration.color!.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
          }
        }
        if (sduiWidget.clipBehavior != null) properties['clipBehavior'] = sduiWidget.clipBehavior.toString();
      } else if (sduiWidget is SduiRow || sduiWidget is SduiColumn) {
        if (sduiWidget.mainAxisAlignment != null) properties['mainAxisAlignment'] = sduiWidget.mainAxisAlignment.toString().split('.').last;
        if (sduiWidget.mainAxisSize != null) properties['mainAxisSize'] = sduiWidget.mainAxisSize.toString().split('.').last;
        if (sduiWidget.crossAxisAlignment != null) properties['crossAxisAlignment'] = sduiWidget.crossAxisAlignment.toString().split('.').last;
        if (sduiWidget.textDirection != null) properties['textDirection'] = sduiWidget.textDirection.toString().split('.').last;
        if (sduiWidget.verticalDirection != null) properties['verticalDirection'] = sduiWidget.verticalDirection.toString().split('.').last;
        if (sduiWidget.textBaseline != null) properties['textBaseline'] = sduiWidget.textBaseline.toString().split('.').last;
      } else if (sduiWidget is SduiScaffold) {
        if (sduiWidget.backgroundColor != null) {
          properties['backgroundColor'] = '#${sduiWidget.backgroundColor!.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
        }
        if (sduiWidget.primary != null) properties['primary'] = sduiWidget.primary;
        if (sduiWidget.extendBody != null) properties['extendBody'] = sduiWidget.extendBody;
        if (sduiWidget.extendBodyBehindAppBar != null) properties['extendBodyBehindAppBar'] = sduiWidget.extendBodyBehindAppBar;
        if (sduiWidget.drawerEnableOpenDragGesture != null) properties['drawerEnableOpenDragGesture'] = sduiWidget.drawerEnableOpenDragGesture;
        if (sduiWidget.endDrawerEnableOpenDragGesture != null) properties['endDrawerEnableOpenDragGesture'] = sduiWidget.endDrawerEnableOpenDragGesture;
      } else if (sduiWidget is SduiText) {
        properties['text'] = sduiWidget.text;
        properties['textAlign'] = sduiWidget.textAlign?.toString();
        properties['fontFamily'] = sduiWidget.fontFamily;
        if (sduiWidget.color != null) {
          properties['color'] = '#${sduiWidget.color!.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
        }
      } else if (sduiWidget is SduiImage) {
        if (sduiWidget.src != null) properties['src'] = sduiWidget.src;
        if (sduiWidget.width != null) properties['width'] = sduiWidget.width;
        if (sduiWidget.height != null) properties['height'] = sduiWidget.height;
        if (sduiWidget.fit != null) properties['fit'] = sduiWidget.fit.toString();
        if (sduiWidget.alignment != null) properties['alignment'] = sduiWidget.alignment.toString();
        if (sduiWidget.repeat != null) properties['repeat'] = sduiWidget.repeat.toString();
        if (sduiWidget.color != null) {
          properties['color'] = '#${sduiWidget.color!.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
        }
        if (sduiWidget.filterQuality != null) properties['filterQuality'] = sduiWidget.filterQuality.toString();
        if (sduiWidget.scale != null) properties['scale'] = sduiWidget.scale;
      } else if (sduiWidget is SduiIcon) {
        if (sduiWidget.icon != null) properties['icon'] = sduiWidget.icon.toString();
        if (sduiWidget.size != null) properties['size'] = sduiWidget.size;
        if (sduiWidget.color != null) {
          properties['color'] = '#${sduiWidget.color!.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
        }
      }
      return WidgetNode(
        uid: globalUuid.v4(),
        type: type,
        label: label,
        icon: icon,
        position: position,
        size: size,
        children: children,
        properties: properties,
      );
    }
    _rootWidgetNode = buildNode(sduiWidget);
    notifyListeners();
  }

  /// Export WidgetNode tree to SDUI JSON string.
  String exportToSduiJsonString() {
    final sduiWidget = widgetNodeToSduiWidget(_rootWidgetNode);
    final json = SduiParser.toJson(sduiWidget);
    return jsonEncode(json);
  }
} 