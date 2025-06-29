import 'package:flutter/material.dart';
import '../../models/widget_data.dart';

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
              // Layout Widgets Section
              _buildWidgetSection(
                'Layout Widgets',
                layoutWidgetsExpanded,
                () => setState(() => layoutWidgetsExpanded = !layoutWidgetsExpanded),
                [
                  _buildWidgetCard(Icons.view_column, 'Column', 'Column Widget', 'Multiple children'),
                  _buildWidgetCard(Icons.view_stream, 'Row', 'Row Widget', 'Multiple children'),
                  _buildWidgetCard(Icons.crop_square, 'Container', 'Container Widget', 'Single child'),
                  _buildWidgetCard(Icons.view_in_ar, 'Stack', 'Stack Widget', 'Multiple children'),
                ].where((w) => _filterWidgetCard(w)).toList(),
              ),
              const SizedBox(height: 16),
              // Display Widgets Section
              _buildWidgetSection(
                'Display Widgets',
                displayWidgetsExpanded,
                () => setState(() => displayWidgetsExpanded = !displayWidgetsExpanded),
                [
                  _buildWidgetCard(Icons.text_fields, 'Text', 'Text Widget', 'No children'),
                  _buildWidgetCard(Icons.image, 'Image', 'Image Widget', 'No children'),
                ].where((w) => _filterWidgetCard(w)).toList(),
              ),
              const SizedBox(height: 16),
              // Input Widgets Section
              _buildWidgetSection(
                'Input Widgets',
                inputWidgetsExpanded,
                () => setState(() => inputWidgetsExpanded = !inputWidgetsExpanded),
                [
                  _buildWidgetCard(Icons.input, 'TextField', 'TextField Widget', 'No children'),
                  null, // Empty slot
                ].where((w) => _filterWidgetCard(w)).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  bool _filterWidgetCard(Widget? widget) {
    if (widget == null || searchQuery.isEmpty) return widget != null;
    if (widget is Draggable<WidgetData>) {
      final data = widget.data as WidgetData;
      final label = data.label.toLowerCase();
      final type = data.type.toLowerCase();
      return label.contains(searchQuery) || type.contains(searchQuery);
    }
    return true;
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

  Widget _buildWidgetCard(IconData icon, String label, String widgetType, String childrenInfo) {
    return Draggable<WidgetData>(
      data: WidgetData(
        type: widgetType,
        label: label,
        icon: icon,
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
        child: Icon(icon, color: const Color(0xFF212121), size: 32),
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
              Icon(icon, color: const Color(0xFF212121), size: 28),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF212121),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                childrenInfo,
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

  Widget _buildEmptyCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF3F3F3F),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
} 