import 'package:flutter/material.dart';
import '../../models/widget_node.dart';
import '../../models/app_theme.dart';
import '../../services/widget_properties_service.dart';

class PropertiesPanel extends StatelessWidget {
  final WidgetNode? selectedWidget;
  final AppTheme appTheme;
  final Function(String, String, dynamic) onPropertyChanged;
  final Function(String) onWidgetRemoved;

  const PropertiesPanel({
    super.key,
    this.selectedWidget,
    required this.appTheme,
    required this.onPropertyChanged,
    required this.onWidgetRemoved,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, constraints) => ConstrainedBox(
          constraints: BoxConstraints(maxWidth: constraints.maxWidth),
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Properties',
                style: TextStyle(
                  color: Color(0xFFEDF1EE),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              if (selectedWidget != null && selectedWidget!.type != 'Scaffold')
                IconButton(
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: const Color(0xFF2F2F2F),
                        title: const Text('Remove Widget?', style: TextStyle(color: Color(0xFFEDF1EE))),
                        content: const Text('Are you sure you want to remove this widget? This action cannot be undone.', style: TextStyle(color: Color(0xFFEDF1EE))),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancel', style: TextStyle(color: Color(0xFFFF5252))),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Remove', style: TextStyle(color: Color(0xFF4CAF50))),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      onWidgetRemoved(selectedWidget!.uid);
                    }
                  },
                  icon: const Icon(
                    Icons.delete,
                    color: Color(0xFFFF5252),
                    size: 20,
                  ),
                  tooltip: 'Remove Widget',
                ),
            ],
          ),
          const SizedBox(height: 20),
          if (selectedWidget != null) ...[
            Text(
              'Selected: ${selectedWidget!.label}',
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFFEDF1EE),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Type: ${selectedWidget!.type}',
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Color(0xFFEDF1EE), fontSize: 12),
            ),
            const SizedBox(height: 8),
            Text(
              'Children: ${selectedWidget!.children.length}',
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Color(0xFFEDF1EE), fontSize: 12),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('UUID:', style: TextStyle(color: Color(0xFFEDF1EE), fontSize: 12)),
                const SizedBox(width: 8),
                Expanded(
                  child: SelectableText(
                    selectedWidget!.uid,
                    style: const TextStyle(color: Color(0xFFEDF1EE), fontSize: 12, fontFamily: 'monospace'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: Color(0xFF666666)),
            const SizedBox(height: 16),
            Expanded(
              child: _buildPropertiesEditor(context),
            ),
          ] else
            const Text(
              'Select a widget to edit its properties',
              style: TextStyle(color: Color(0xFFEDF1EE)),
            ),
        ],
          ),
        ),
      ),
    );
  }

  Widget _buildPropertiesEditor(BuildContext context) {
    final properties = WidgetPropertiesService.getPropertyDefinitions(selectedWidget!.type);
    return ListView.builder(
      itemCount: properties.length,
      itemBuilder: (context, index) {
        final property = properties[index];
        final currentValue = selectedWidget!.properties[property.key];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                property.label,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFFEDF1EE),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              _buildPropertyInput(context, property, currentValue),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPropertyInput(BuildContext context, PropertyDefinition property, dynamic currentValue) {
    switch (property.type) {
      case PropertyType.text:
        final controller = TextEditingController(text: currentValue?.toString() ?? '');
        controller.selection = TextSelection.fromPosition(
          TextPosition(offset: controller.text.length),
        );
        return TextField(
          style: const TextStyle(color: Color(0xFFEDF1EE)),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF3F3F3F),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: Color(0xFF666666)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: Color(0xFF666666)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: Color(0xFF4CAF50)),
            ),
          ),
          controller: controller,
          onChanged: (value) {
            onPropertyChanged(selectedWidget!.uid, property.key, value);
          },
        );
      case PropertyType.number:
        return TextField(
          style: const TextStyle(color: Color(0xFFEDF1EE)),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF3F3F3F),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: Color(0xFF666666)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: Color(0xFF666666)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: Color(0xFF4CAF50)),
            ),
          ),
          keyboardType: TextInputType.number,
          controller: TextEditingController(text: currentValue?.toString() ?? '0'),
          onChanged: (value) {
            final numValue = double.tryParse(value) ?? 0.0;
            onPropertyChanged(selectedWidget!.uid, property.key, numValue);
          },
        );
      case PropertyType.boolean:
        return Row(
          children: [
            Switch(
              value: currentValue ?? false,
              onChanged: (value) {
                onPropertyChanged(selectedWidget!.uid, property.key, value);
              },
              activeColor: const Color(0xFF4CAF50),
            ),
            const SizedBox(width: 8),
            Text(
              currentValue == true ? 'True' : 'False',
              style: const TextStyle(color: Color(0xFFEDF1EE)),
            ),
          ],
        );
      case PropertyType.color:
        return GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => _SimpleColorPickerDialog(
                initialColor: _parseColor(currentValue?.toString() ?? '#FF3F3F3F'),
                onColorChanged: (color) {
                  final hexColor = '#${color.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
                  onPropertyChanged(selectedWidget!.uid, property.key, hexColor);
                },
              ),
            );
          },
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: _parseColor(currentValue?.toString() ?? '#FF3F3F3F'),
              border: Border.all(color: const Color(0xFF666666)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                const SizedBox(width: 12),
                Text(
                  currentValue?.toString() ?? '#FF3F3F3F',
                  style: TextStyle(
                    color: _parseColor(currentValue?.toString() ?? '#FF3F3F3F').computeLuminance() > 0.5 
                        ? Colors.black 
                        : Colors.white,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.color_lens,
                  color: Color(0xFFEDF1EE),
                  size: 16,
                ),
                const SizedBox(width: 12),
              ],
            ),
          ),
        );
      case PropertyType.dropdown:
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF3F3F3F),
            border: Border.all(color: const Color(0xFF666666)),
            borderRadius: BorderRadius.circular(4),
          ),
          child: DropdownButton<String>(
            value: currentValue?.toString(),
            isExpanded: true,
            underline: Container(),
            dropdownColor: const Color(0xFF3F3F3F),
            style: const TextStyle(color: Color(0xFFEDF1EE)),
            items: property.options?.map((option) {
              return DropdownMenuItem<String>(
                value: option,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(option),
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                onPropertyChanged(selectedWidget!.uid, property.key, value);
              }
            },
          ),
        );
    }
  }

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0x')));
    } catch (e) {
      return const Color(0xFF3F3F3F);
    }
  }
}

class _SimpleColorPickerDialog extends StatefulWidget {
  final Color initialColor;
  final Function(Color) onColorChanged;
  const _SimpleColorPickerDialog({super.key, required this.initialColor, required this.onColorChanged});

  @override
  State<_SimpleColorPickerDialog> createState() => _SimpleColorPickerDialogState();
}

class _SimpleColorPickerDialogState extends State<_SimpleColorPickerDialog> {
  late Color _color;
  final List<Color> _presetColors = [
    Colors.red, Colors.pink, Colors.purple, Colors.deepPurple,
    Colors.indigo, Colors.blue, Colors.lightBlue, Colors.cyan,
    Colors.teal, Colors.green, Colors.lightGreen, Colors.lime,
    Colors.yellow, Colors.amber, Colors.orange, Colors.deepOrange,
    Colors.brown, Colors.grey, Colors.blueGrey, Colors.black,
    Colors.white, Colors.transparent,
  ];

  @override
  void initState() {
    super.initState();
    _color = widget.initialColor;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Color'),
      content: SizedBox(
        width: 300,
        height: 200,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                color: _color,
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '#${_color.value.toRadixString(16).padLeft(8, '0').toUpperCase()}',
                  style: TextStyle(
                    color: _color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _presetColors.length,
                itemBuilder: (context, index) {
                  final color = _presetColors[index];
                  return GestureDetector(
                    onTap: () => setState(() => _color = color),
                    child: Container(
                      decoration: BoxDecoration(
                        color: color,
                        border: Border.all(
                          color: _color == color ? Colors.blue : Colors.grey,
                          width: _color == color ? 3 : 1,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onColorChanged(_color);
            Navigator.of(context).pop();
          },
          child: const Text('Select'),
        ),
      ],
    );
  }
} 

