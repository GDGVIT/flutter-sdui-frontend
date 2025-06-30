import 'package:flutter/material.dart';
import '../../models/widget_data.dart';
import 'package:flutter_sdui/flutter_sdui.dart';
import '../../services/widget_properties_service.dart';

class BuildPane extends StatefulWidget {
  final Function(WidgetData) onWidgetDropped;

  const BuildPane({
    super.key,
    required this.onWidgetDropped,
  });

  @override
  State<BuildPane> createState() => _BuildPaneState();
}

class _BuildPaneState extends State<BuildPane> {
  bool layoutWidgetsExpanded = true;
  bool displayWidgetsExpanded = true;
  bool inputWidgetsExpanded = true;
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = <String>{for (var w in widgetPalette) w.category};
    final Map<String, List<WidgetPaletteEntry>> grouped = {
      for (var cat in categories)
        cat: widgetPalette.where((w) => w.category == cat).toList(),
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: const Text(
            'Build',
            style: TextStyle(
              color: Color(0xFFEDF1EE),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        // Search Bar
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFE0E0E0),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.search, color: Color(0xFF060A07), size: 16),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search components',
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    style: const TextStyle(color: Color(0xFF060A07), fontSize: 14),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value.trim().toLowerCase();
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        // Widget Categories
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              for (final cat in categories)
                _buildWidgetSection(
                  cat,
                  _getExpandedState(cat),
                  () => _toggleExpanded(cat),
                  grouped[cat]!
                      .map((entry) => _filterWidgetPaletteEntry(entry) ? _buildWidgetCard(entry) : null)
                      .toList(),
                ),
            ],
          ),
        ),
      ],
    );
  }

  bool _getExpandedState(String category) {
    switch (category) {
      case 'Layout Widgets':
        return layoutWidgetsExpanded;
      case 'Display Widgets':
        return displayWidgetsExpanded;
      case 'Input Widgets':
        return inputWidgetsExpanded;
      default:
        return true;
    }
  }

  void _toggleExpanded(String category) {
    setState(() {
      switch (category) {
        case 'Layout Widgets':
          layoutWidgetsExpanded = !layoutWidgetsExpanded;
          break;
        case 'Display Widgets':
          displayWidgetsExpanded = !displayWidgetsExpanded;
          break;
        case 'Input Widgets':
          inputWidgetsExpanded = !inputWidgetsExpanded;
          break;
      }
    });
  }

  bool _filterWidgetPaletteEntry(WidgetPaletteEntry entry) {
    if (searchQuery.isEmpty) return true;
    return entry.label.toLowerCase().contains(searchQuery) ||
        entry.type.toLowerCase().contains(searchQuery);
  }

  Widget _buildWidgetCard(WidgetPaletteEntry entry) {
    return Draggable<WidgetData>(
      data: WidgetData(
        type: entry.type,
        label: entry.label,
        icon: entry.icon,
        position: const Offset(0, 0),
      ),
      feedback: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: const Color(0xFFE0E0E0).withOpacity(0.9),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF4CAF50), width: 2),
        ),
        child: Icon(entry.icon, color: const Color(0xFF212121), size: 32),
      ),
      childWhenDragging: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF3F3F3F),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
        ),
        child: const Center(
          child: Text(
            'Dragging...',
            style: TextStyle(color: Color(0xFFEDF1EE), fontSize: 12),
          ),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFE0E0E0),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(entry.icon, color: const Color(0xFF212121), size: 28),
              const SizedBox(height: 4),
              Text(
                entry.label,
                style: const TextStyle(
                  color: Color(0xFF212121),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                entry.childrenInfo,
                style: const TextStyle(
                  color: Color(0xFF666666),
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWidgetSection(String title, bool isExpanded, VoidCallback onToggle, List<Widget?> widgets) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onToggle,
          child: Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFFEDF1EE),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Icon(
                isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
                color: const Color(0xFFEDF1EE),
                size: 20,
              ),
            ],
          ),
        ),
        if (isExpanded) ...[
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.8,
            children: widgets.map((widget) => widget ?? _buildEmptyCard()).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildEmptyCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF3F3F3F),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

class WidgetPaletteEntry {
  final String label;
  final String type;
  final IconData icon;
  final String category;
  final String childrenInfo;
  final List<PropertyDefinition> properties;
  final int maxChildren;
  final bool canHaveChildren;

  const WidgetPaletteEntry({
    required this.label,
    required this.type,
    required this.icon,
    required this.category,
    required this.childrenInfo,
    required this.properties,
    required this.maxChildren,
    required this.canHaveChildren,
  });
}

List<WidgetPaletteEntry> widgetPalette = [
  WidgetPaletteEntry(
    label: 'Column',
    type: 'Column Widget',
    icon: Icons.view_column,
    category: 'Layout Widgets',
    childrenInfo: 'Multiple children',
    properties: WidgetPropertiesService.getPropertyDefinitions('Column Widget'),
    maxChildren: WidgetPropertiesService.getConstraints('Column Widget').maxChildren,
    canHaveChildren: WidgetPropertiesService.getConstraints('Column Widget').canHaveChildren,
  ),
  WidgetPaletteEntry(
    label: 'Row',
    type: 'Row Widget',
    icon: Icons.view_stream,
    category: 'Layout Widgets',
    childrenInfo: 'Multiple children',
    properties: WidgetPropertiesService.getPropertyDefinitions('Row Widget'),
    maxChildren: WidgetPropertiesService.getConstraints('Row Widget').maxChildren,
    canHaveChildren: WidgetPropertiesService.getConstraints('Row Widget').canHaveChildren,
  ),
  WidgetPaletteEntry(
    label: 'Container',
    type: 'Container Widget',
    icon: Icons.crop_square,
    category: 'Layout Widgets',
    childrenInfo: 'Single child',
    properties: WidgetPropertiesService.getPropertyDefinitions('Container Widget'),
    maxChildren: WidgetPropertiesService.getConstraints('Container Widget').maxChildren,
    canHaveChildren: WidgetPropertiesService.getConstraints('Container Widget').canHaveChildren,
  ),
  WidgetPaletteEntry(
    label: 'Stack',
    type: 'Stack Widget',
    icon: Icons.view_in_ar,
    category: 'Layout Widgets',
    childrenInfo: 'Multiple children',
    properties: WidgetPropertiesService.getPropertyDefinitions('Stack Widget'),
    maxChildren: WidgetPropertiesService.getConstraints('Stack Widget').maxChildren,
    canHaveChildren: WidgetPropertiesService.getConstraints('Stack Widget').canHaveChildren,
  ),
  WidgetPaletteEntry(
    label: 'Text',
    type: 'Text Widget',
    icon: Icons.text_fields,
    category: 'Display Widgets',
    childrenInfo: 'No children',
    properties: WidgetPropertiesService.getPropertyDefinitions('Text Widget'),
    maxChildren: WidgetPropertiesService.getConstraints('Text Widget').maxChildren,
    canHaveChildren: WidgetPropertiesService.getConstraints('Text Widget').canHaveChildren,
  ),
  WidgetPaletteEntry(
    label: 'Image',
    type: 'Image Widget',
    icon: Icons.image,
    category: 'Display Widgets',
    childrenInfo: 'No children',
    properties: WidgetPropertiesService.getPropertyDefinitions('Image Widget'),
    maxChildren: WidgetPropertiesService.getConstraints('Image Widget').maxChildren,
    canHaveChildren: WidgetPropertiesService.getConstraints('Image Widget').canHaveChildren,
  ),
  WidgetPaletteEntry(
    label: 'TextField',
    type: 'TextField Widget',
    icon: Icons.input,
    category: 'Input Widgets',
    childrenInfo: 'No children',
    properties: WidgetPropertiesService.getPropertyDefinitions('TextField Widget'),
    maxChildren: WidgetPropertiesService.getConstraints('TextField Widget').maxChildren,
    canHaveChildren: WidgetPropertiesService.getConstraints('TextField Widget').canHaveChildren,
  ),
]; 