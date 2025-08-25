import 'package:flutter/material.dart';
import '../../models/widget_data.dart';
import '../../services/widget_properties_service.dart';

// Set to true to show experimental/legacy widgets in the palette
const bool _showExperimentalWidgets = false;

class BuildPane extends StatefulWidget {
  final Function(WidgetData) onWidgetDropped;
  final void Function(WidgetData, Offset)? onPaletteDragStart;
  final void Function(Offset)? onPaletteDragUpdate;
  final VoidCallback? onPaletteDragEnd;

  const BuildPane({
    super.key,
    required this.onWidgetDropped,
    this.onPaletteDragStart,
    this.onPaletteDragUpdate,
    this.onPaletteDragEnd,
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
    // Filter widget palette based on experimental toggle
    final filteredWidgetPalette = _showExperimentalWidgets
        ? _allWidgetPalette
        : _allWidgetPalette.where((entry) => entry.type != 'SduiScaffold' && entry.type != 'Column Widget').toList();

    final categories = <String>{for (var w in filteredWidgetPalette) w.category};
    final Map<String, List<WidgetPaletteEntry>> grouped = {
      for (var cat in categories)
        cat: filteredWidgetPalette.where((w) => w.category == cat).toList(),
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
    final widgetData = WidgetData(
      type: entry.type,
      label: entry.label,
      icon: entry.icon,
      position: const Offset(0, 0),
    );
    return Listener(
      onPointerDown: (event) {
        widget.onPaletteDragStart?.call(widgetData, event.position);
      },
      onPointerMove: (event) {
        widget.onPaletteDragUpdate?.call(event.position);
      },
      onPointerUp: (event) {
        widget.onPaletteDragEnd?.call();
      },
      onPointerCancel: (event) {
        widget.onPaletteDragEnd?.call();
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double tileWidth = constraints.maxWidth;
          final double iconSize = (tileWidth * 0.18).clamp(22, 36);
          final double labelFont = (tileWidth * 0.08).clamp(11, 14);
          final double infoFont = (tileWidth * 0.07).clamp(9, 12);
          final double verticalGap = (tileWidth * 0.02).clamp(2, 8);
          return Container(
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(entry.icon, color: const Color(0xFF212121), size: iconSize),
                  SizedBox(height: verticalGap),
                  Text(
                    entry.label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: const Color(0xFF212121),
                      fontSize: labelFont.toDouble(),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: (verticalGap * 0.6).clamp(2, 6)),
                  Text(
                    entry.childrenInfo,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFF666666),
                      fontSize: infoFont.toDouble(),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
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
          LayoutBuilder(
            builder: (context, constraints) {
              // Aim for cards around 160-200px wide and adapt to sidebar width
              const double desiredTileWidth = 180;
              return GridView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: desiredTileWidth,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 0.9,
                ),
                children: widgets.map((w) => w ?? _buildEmptyCard()).toList(),
              );
            },
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

List<WidgetPaletteEntry> _allWidgetPalette = [
  // --- SDUI Widgets Only ---
  WidgetPaletteEntry(
    label: 'SduiColumn',
    type: 'SduiColumn',
    icon: Icons.view_column,
    category: 'Layout Widgets',
    childrenInfo: WidgetPropertiesService.getChildrenInfo('SduiColumn'),
    properties: WidgetPropertiesService.getPropertyDefinitions('SduiColumn'),
    maxChildren: WidgetPropertiesService.getConstraints('SduiColumn').maxChildren,
    canHaveChildren: WidgetPropertiesService.getConstraints('SduiColumn').canHaveChildren,
  ),
  WidgetPaletteEntry(
    label: 'SduiRow',
    type: 'SduiRow',
    icon: Icons.view_stream,
    category: 'Layout Widgets',
    childrenInfo: WidgetPropertiesService.getChildrenInfo('SduiRow'),
    properties: WidgetPropertiesService.getPropertyDefinitions('SduiRow'),
    maxChildren: WidgetPropertiesService.getConstraints('SduiRow').maxChildren,
    canHaveChildren: WidgetPropertiesService.getConstraints('SduiRow').canHaveChildren,
  ),
  WidgetPaletteEntry(
    label: 'SduiContainer',
    type: 'SduiContainer',
    icon: Icons.crop_square,
    category: 'Layout Widgets',
    childrenInfo: WidgetPropertiesService.getChildrenInfo('SduiContainer'),
    properties: WidgetPropertiesService.getPropertyDefinitions('SduiContainer'),
    maxChildren: WidgetPropertiesService.getConstraints('SduiContainer').maxChildren,
    canHaveChildren: WidgetPropertiesService.getConstraints('SduiContainer').canHaveChildren,
  ),
  WidgetPaletteEntry(
    label: 'SduiScaffold',
    type: 'SduiScaffold',
    icon: Icons.web_asset,
    category: 'Layout Widgets',
    childrenInfo: WidgetPropertiesService.getChildrenInfo('SduiScaffold'),
    properties: WidgetPropertiesService.getPropertyDefinitions('SduiScaffold'),
    maxChildren: WidgetPropertiesService.getConstraints('SduiScaffold').maxChildren,
    canHaveChildren: WidgetPropertiesService.getConstraints('SduiScaffold').canHaveChildren,
  ),
  WidgetPaletteEntry(
    label: 'SduiSizedBox',
    type: 'SduiSizedBox',
    icon: Icons.crop_16_9,
    category: 'Layout Widgets',
    childrenInfo: WidgetPropertiesService.getChildrenInfo('SduiSizedBox'),
    properties: WidgetPropertiesService.getPropertyDefinitions('SduiSizedBox'),
    maxChildren: WidgetPropertiesService.getConstraints('SduiSizedBox').maxChildren,
    canHaveChildren: WidgetPropertiesService.getConstraints('SduiSizedBox').canHaveChildren,
  ),
  WidgetPaletteEntry(
    label: 'SduiSpacer',
    type: 'SduiSpacer',
    icon: Icons.space_bar,
    category: 'Layout Widgets',
    childrenInfo: WidgetPropertiesService.getChildrenInfo('SduiSpacer'),
    properties: WidgetPropertiesService.getPropertyDefinitions('SduiSpacer'),
    maxChildren: WidgetPropertiesService.getConstraints('SduiSpacer').maxChildren,
    canHaveChildren: WidgetPropertiesService.getConstraints('SduiSpacer').canHaveChildren,
  ),
  WidgetPaletteEntry(
    label: 'SduiText',
    type: 'SduiText',
    icon: Icons.text_fields,
    category: 'Display Widgets',
    childrenInfo: WidgetPropertiesService.getChildrenInfo('SduiText'),
    properties: WidgetPropertiesService.getPropertyDefinitions('SduiText'),
    maxChildren: WidgetPropertiesService.getConstraints('SduiText').maxChildren,
    canHaveChildren: WidgetPropertiesService.getConstraints('SduiText').canHaveChildren,
  ),
  WidgetPaletteEntry(
    label: 'SduiImage',
    type: 'SduiImage',
    icon: Icons.image,
    category: 'Display Widgets',
    childrenInfo: WidgetPropertiesService.getChildrenInfo('SduiImage'),
    properties: WidgetPropertiesService.getPropertyDefinitions('SduiImage'),
    maxChildren: WidgetPropertiesService.getConstraints('SduiImage').maxChildren,
    canHaveChildren: WidgetPropertiesService.getConstraints('SduiImage').canHaveChildren,
  ),
  WidgetPaletteEntry(
    label: 'SduiIcon',
    type: 'SduiIcon',
    icon: Icons.insert_emoticon,
    category: 'Display Widgets',
    childrenInfo: WidgetPropertiesService.getChildrenInfo('SduiIcon'),
    properties: WidgetPropertiesService.getPropertyDefinitions('SduiIcon'),
    maxChildren: WidgetPropertiesService.getConstraints('SduiIcon').maxChildren,
    canHaveChildren: WidgetPropertiesService.getConstraints('SduiIcon').canHaveChildren,
  ),
  // SduiScaffold and legacy Column Widget are experimental/legacy
  WidgetPaletteEntry(
    label: 'SduiScaffold',
    type: 'SduiScaffold',
    icon: Icons.web_asset,
    category: 'Layout Widgets',
    childrenInfo: WidgetPropertiesService.getChildrenInfo('SduiScaffold'),
    properties: WidgetPropertiesService.getPropertyDefinitions('SduiScaffold'),
    maxChildren: WidgetPropertiesService.getConstraints('SduiScaffold').maxChildren,
    canHaveChildren: WidgetPropertiesService.getConstraints('SduiScaffold').canHaveChildren,
  ),
  WidgetPaletteEntry(
    label: 'Column',
    type: 'Column Widget',
    icon: Icons.view_column,
    category: 'Layout Widgets',
    childrenInfo: WidgetPropertiesService.getChildrenInfo('Column Widget'),
    properties: WidgetPropertiesService.getPropertyDefinitions('Column Widget'),
    maxChildren: WidgetPropertiesService.getConstraints('Column Widget').maxChildren,
    canHaveChildren: WidgetPropertiesService.getConstraints('Column Widget').canHaveChildren,
  ),
]; 