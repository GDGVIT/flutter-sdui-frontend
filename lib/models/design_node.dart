import 'package:flutter/material.dart';
import 'widget_node.dart';

class DesignNode extends ChangeNotifier {
  final WidgetNode widgetNode;
  final List<DesignNode> children;
  DesignNode? parent;

  // Design-time state
  bool isSelected;
  bool isHovered;
  bool isBeingDragged;
  Size? visualSize;
  Offset? visualPosition;

  DesignNode({
    required this.widgetNode,
    List<DesignNode>? children,
    this.parent,
    this.isSelected = false,
    this.isHovered = false,
    this.isBeingDragged = false,
    this.visualSize,
    this.visualPosition,
  }) : children = children ?? <DesignNode>[];

  // Build a DesignNode tree from a WidgetNode tree
  static DesignNode fromWidgetNode(WidgetNode node, {DesignNode? parent}) {
    final designNode = DesignNode(
      widgetNode: node,
      parent: parent,
      visualSize: node.size,
      visualPosition: node.position,
      children: node.children.map((child) => DesignNode.fromWidgetNode(child, parent: null)).toList(),
    );
    // Set parent for children
    for (final child in designNode.children) {
      child.parent = designNode;
    }
    return designNode;
  }

  // Helper: find a node by widgetNode id
  DesignNode? findById(String id) {
    if (widgetNode.uid == id) return this;
    for (final child in children) {
      final found = child.findById(id);
      if (found != null) return found;
    }
    return null;
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is DesignNode && hashCode == other.hashCode;

  @override
  int get hashCode => identityHashCode(this);
} 