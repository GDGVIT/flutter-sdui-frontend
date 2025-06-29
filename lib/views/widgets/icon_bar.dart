import 'package:flutter/material.dart';

class IconBar extends StatelessWidget {
  final String selectedPane;
  final Function(String) onPaneSelected;

  const IconBar({
    super.key,
    required this.selectedPane,
    required this.onPaneSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildIconButton(Icons.build, 'build', 'Build'),
          const SizedBox(height: 12),
          _buildIconButton(Icons.account_tree, 'widget-tree', 'Widget Tree'),
          const SizedBox(height: 12),
          _buildIconButton(Icons.palette, 'theme', 'Theme'),
          const SizedBox(height: 12),
          _buildIconButton(Icons.file_download, 'import', 'Import'),
          const SizedBox(height: 12),
          _buildIconButton(Icons.file_upload, 'export', 'Export'),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, String pane, String label) {
    final isSelected = selectedPane == pane;
    return GestureDetector(
      onTap: () => onPaneSelected(pane),
      child: Container(
        width: 74,
        height: 55,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE0E0E0) : Colors.transparent,
          borderRadius: BorderRadius.circular(0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF212121) : const Color(0xFFEDF1EE),
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF212121) : const Color(0xFFEDF1EE),
                fontSize: 10,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
} 