import 'package:flutter/material.dart';
import '../../models/widget_node.dart';

// Stub for WidgetConstraints
class WidgetConstraints {
  final bool canHaveChildren;
  final int maxChildren;
  const WidgetConstraints({required this.canHaveChildren, required this.maxChildren});
  static WidgetConstraints getConstraints(String type) {
    // Support both legacy and SDUI types
    switch (type) {
      case 'Column Widget':
      case 'Row Widget':
      case 'Stack Widget':
      case 'SduiColumn':
      case 'SduiRow':
      case 'SduiStack':
        return WidgetConstraints(canHaveChildren: true, maxChildren: -1);
      case 'Container Widget':
      case 'SduiContainer':
      case 'SduiScaffold':
        return WidgetConstraints(canHaveChildren: true, maxChildren: 1);
      default:
        return WidgetConstraints(canHaveChildren: false, maxChildren: 0);
    }
  }
}

class WidgetTreePane extends StatelessWidget {
  final WidgetNode scaffoldWidget;
  final String? selectedWidgetId;
  final void Function(String) onWidgetSelected;

  const WidgetTreePane({
    super.key,
    required this.scaffoldWidget,
    required this.selectedWidgetId,
    required this.onWidgetSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Widget Tree',
            style: TextStyle(
              color: Color(0xFFEDF1EE),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: [_buildTreeNode(scaffoldWidget, 0)],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTreeNode(WidgetNode node, int depth) {
    final isSelected = node.uid == selectedWidgetId;
    final constraints = WidgetConstraints.getConstraints(node.type);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => onWidgetSelected(node.uid),
          child: Container(
            color: isSelected ? const Color(0xFF4CAF50).withOpacity(0.18) : Colors.transparent,
            child: Padding(
              padding: EdgeInsets.only(left: depth * 16.0),
              child: Row(
                children: [
                  if (node.children.isNotEmpty)
                    const Icon(
                      Icons.keyboard_arrow_down,
                      color: Color(0xFFEDF1EE),
                      size: 16,
                    )
                  else if (constraints.canHaveChildren)
                    const Icon(
                      Icons.keyboard_arrow_right,
                      color: Color(0xFF666666),
                      size: 16,
                    )
                  else
                    const SizedBox(width: 16),
                  Icon(node.icon, color: const Color(0xFFEDF1EE), size: 16),
                  const SizedBox(width: 8),
                  Text(
                    node.label,
                    style: TextStyle(
                      color: isSelected ? const Color(0xFF4CAF50) : const Color(0xFFEDF1EE),
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (constraints.maxChildren == 1)
                    const Text(
                      '(1 child max)',
                      style: TextStyle(
                        color: Color(0xFF666666),
                        fontSize: 12,
                      ),
                    )
                  else if (constraints.maxChildren == -1)
                    const Text(
                      '(multiple children)',
                      style: TextStyle(
                        color: Color(0xFF666666),
                        fontSize: 12,
                      ),
                    )
                  else
                    const Text(
                      '(no children)',
                      style: TextStyle(
                        color: Color(0xFF666666),
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        ...node.children.map((child) => _buildTreeNode(child, depth + 1)),
      ],
    );
  }
} 