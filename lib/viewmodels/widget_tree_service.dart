import '../models/widget_node.dart';
import '../models/widget_data.dart';
import '../services/widget_properties_service.dart';
import 'package:flutter/material.dart';

class WidgetTreeService {
  static WidgetNode addWidgetToParent(WidgetNode root, String parentUid, WidgetData widgetData) {
    // ... logic from DesignCanvasViewModel._addWidgetToParent ...
    if (root.uid == parentUid) {
      final parentConstraints = WidgetPropertiesService.getConstraints(root.type);
      if (parentConstraints.maxChildren == 0) return root;
      final isLayoutWidget = root.type == 'Column Widget' || root.type == 'Row Widget' || root.type == 'Stack Widget' || root.type == 'SduiColumn' || root.type == 'SduiRow';
      List<WidgetNode> newChildren = List.from(root.children);
      if (!isLayoutWidget && parentConstraints.maxChildren == 1 && newChildren.isNotEmpty) {
        newChildren = [];
      } else if (newChildren.length >= parentConstraints.maxChildren && parentConstraints.maxChildren != -1) {
        return root;
      }
      var newWidget = WidgetNode(
        uid: UniqueKey().toString(),
        type: widgetData.type,
        label: widgetData.label,
        icon: widgetData.icon,
        position: _getStaggeredChildPosition(root, newChildren.length),
        size: (() {
          final parentSize = root.size;
          if ((widgetData.type == 'SduiColumn' || widgetData.type == 'SduiRow' || widgetData.type == 'SduiContainer') && parentSize != null) {
            return Size(parentSize.width * 0.8, parentSize.height * 0.8);
          }
          return WidgetPropertiesService.getDefaultSize(widgetData.type);
        })(),
        children: const [],
        properties: WidgetPropertiesService.getDefaultProperties(widgetData.type),
      );
      newChildren = [...newChildren, newWidget];
      // ... auto-size logic ...
      if (root.type == 'SduiColumn') {
        double totalHeight = newChildren.fold(0.0, (sum, child) => sum + (child.size.height));
        double parentHeight = root.size.height;
        double parentWidth = root.size.width;
        if (totalHeight > parentHeight) {
          parentHeight = totalHeight * 2;
        }
        if (totalHeight > parentHeight && parentConstraints.maxChildren != -1) {
          double newChildHeight = parentHeight / newChildren.length;
          newChildren = newChildren.map((child) => child.copyWith(size: Size(child.size.width, newChildHeight))).toList();
        }
        root = root.copyWith(size: Size(parentWidth, parentHeight));
      } else if (root.type == 'SduiRow') {
        double totalWidth = newChildren.fold(0.0, (sum, child) => sum + (child.size.width));
        double parentWidth = root.size.width;
        double parentHeight = root.size.height;
        if (totalWidth > parentWidth) {
          parentWidth = totalWidth * 2;
        }
        if (totalWidth > parentWidth && parentConstraints.maxChildren != -1) {
          double newChildWidth = parentWidth / newChildren.length;
          newChildren = newChildren.map((child) => child.copyWith(size: Size(newChildWidth, child.size.height))).toList();
        }
        root = root.copyWith(size: Size(parentWidth, parentHeight));
      }
      WidgetNode resizedNode = root.copyWith(children: newChildren);
      if (isLayoutWidget) {
        final Rect bounds = _computeChildrenBounds(newChildren);
        double minWidth = root.size.width;
        double minHeight = root.size.height;
        double neededWidth = bounds.right;
        double neededHeight = bounds.bottom;
        Size newParentSize = Size(
          neededWidth > minWidth ? neededWidth : minWidth,
          neededHeight > minHeight ? neededHeight : minHeight,
        );
        if (newParentSize != root.size) {
          final newProps = Map<String, dynamic>.from(root.properties);
          if (newProps.containsKey('width')) newProps['width'] = newParentSize.width;
          if (newProps.containsKey('height')) newProps['height'] = newParentSize.height;
          resizedNode = root.copyWith(children: newChildren, size: newParentSize, properties: newProps);
        }
      }
      return resizedNode;
    } else {
      final updatedChildren = root.children
          .map((child) => addWidgetToParent(child, parentUid, widgetData))
          .toList();
      WidgetNode updatedNode = root.copyWith(children: updatedChildren);
      final isLayoutWidget = root.type == 'Column Widget' || root.type == 'Row Widget' || root.type == 'Stack Widget' || root.type == 'SduiColumn' || root.type == 'SduiRow';
      if (isLayoutWidget) {
        final Rect bounds = _computeChildrenBounds(updatedChildren);
        double minWidth = root.size.width;
        double minHeight = root.size.height;
        double neededWidth = bounds.right;
        double neededHeight = bounds.bottom;
        Size newParentSize = Size(
          neededWidth > minWidth ? neededWidth : minWidth,
          neededHeight > minHeight ? neededHeight : minHeight,
        );
        if (newParentSize != root.size) {
          final newProps = Map<String, dynamic>.from(root.properties);
          if (newProps.containsKey('width')) newProps['width'] = newParentSize.width;
          if (newProps.containsKey('height')) newProps['height'] = newParentSize.height;
          updatedNode = root.copyWith(size: newParentSize, properties: newProps);
        }
      }
      return updatedNode;
    }
  }

  static Offset _getStaggeredChildPosition(WidgetNode parent, int childIndex) {
    if (parent.type == 'Column Widget' || parent.type == 'SduiColumn') {
      return Offset(10, 10 + 40.0 * childIndex);
    } else if (parent.type == 'Row Widget' || parent.type == 'SduiRow') {
      return Offset(10 + 40.0 * childIndex, 10);
    } else {
      return const Offset(10, 10);
    }
  }

  static WidgetNode updateWidgetProperty(WidgetNode root, String widgetUid, String propertyName, dynamic value) {
    if (root.uid == widgetUid) {
      final newProperties = Map<String, dynamic>.from(root.properties);
      newProperties[propertyName] = value;
      return root.copyWith(properties: newProperties);
    } else {
      return root.copyWith(
        children: root.children
            .map((child) => updateWidgetProperty(child, widgetUid, propertyName, value))
            .toList(),
      );
    }
  }

  static WidgetNode removeWidget(WidgetNode root, String widgetUid) {
    final newChildren = root.children
        .where((child) => child.uid != widgetUid)
        .map((child) => removeWidget(child, widgetUid))
        .toList();
    return root.copyWith(children: newChildren);
  }

  static WidgetNode moveWidget(WidgetNode root, String uid, Offset newPosition) {
    if (root.uid == uid) {
      return root.copyWith(position: newPosition);
    } else {
      return root.copyWith(
        children: root.children.map((child) => moveWidget(child, uid, newPosition)).toList(),
      );
    }
  }

  static WidgetNode resizeWidget(WidgetNode root, String uid, Size newSize) {
    if (root.uid == uid) {
      final newProperties = Map<String, dynamic>.from(root.properties);
      if (newProperties.containsKey('width')) {
        newProperties['width'] = newSize.width;
      }
      if (newProperties.containsKey('height')) {
        newProperties['height'] = newSize.height;
      }
      return root.copyWith(size: newSize, properties: newProperties);
    } else {
      return root.copyWith(
        children: root.children.map((child) => resizeWidget(child, uid, newSize)).toList(),
      );
    }
  }

  static WidgetNode? findWidgetByUid(WidgetNode root, String? uid) {
    if (uid == null) return null;
    if (root.uid == uid) return root;
    for (final child in root.children) {
      final found = findWidgetByUid(child, uid);
      if (found != null) return found;
    }
    return null;
  }

  static Rect _computeChildrenBounds(List<WidgetNode> children) {
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

  // Add more tree operations as needed...
} 