import 'package:flutter/material.dart';
import '../../models/app_theme.dart';
import 'color_picker_dialog.dart';

class ThemePane extends StatelessWidget {
  final AppTheme appTheme;
  final Function(AppTheme) onThemeChanged;

  const ThemePane({
    super.key,
    required this.appTheme,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Theme',
            style: TextStyle(
              color: Color(0xFFEDF1EE),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: [
                _buildColorProperty(context, 'Primary Color', appTheme.primaryColor, (color) {
                  onThemeChanged(appTheme.copyWith(primaryColor: color));
                }),
                const SizedBox(height: 16),
                _buildColorProperty(context, 'Secondary Color', appTheme.secondaryColor, (color) {
                  onThemeChanged(appTheme.copyWith(secondaryColor: color));
                }),
                const SizedBox(height: 16),
                _buildColorProperty(context, 'Background Color', appTheme.backgroundColor, (color) {
                  onThemeChanged(appTheme.copyWith(backgroundColor: color));
                }),
                const SizedBox(height: 16),
                _buildColorProperty(context, 'Surface Color', appTheme.surfaceColor, (color) {
                  onThemeChanged(appTheme.copyWith(surfaceColor: color));
                }),
                const SizedBox(height: 16),
                _buildColorProperty(context, 'Text Color', appTheme.textColor, (color) {
                  onThemeChanged(appTheme.copyWith(textColor: color));
                }),
                const SizedBox(height: 16),
                _buildColorProperty(context, 'Accent Color', appTheme.accentColor, (color) {
                  onThemeChanged(appTheme.copyWith(accentColor: color));
                }),
                const SizedBox(height: 16),
                _buildNumberProperty('Border Radius', appTheme.borderRadius, (value) {
                  onThemeChanged(appTheme.copyWith(borderRadius: value));
                }),
                const SizedBox(height: 16),
                _buildNumberProperty('Default Padding', appTheme.defaultPadding, (value) {
                  onThemeChanged(appTheme.copyWith(defaultPadding: value));
                }),
                const SizedBox(height: 16),
                _buildDropdownProperty('Font Family', appTheme.fontFamily, 
                  ['Roboto', 'Arial', 'Helvetica', 'Times New Roman', 'Courier New'], (value) {
                  onThemeChanged(appTheme.copyWith(fontFamily: value));
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorProperty(BuildContext context, String label, Color color, Function(Color) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFEDF1EE),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => ColorPickerDialog(
                initialColor: color,
                onColorChanged: onChanged,
              ),
            );
          },
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: color,
              border: Border.all(color: const Color(0xFF666666)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                const SizedBox(width: 12),
                Text(
                  '#${color.value.toRadixString(16).padLeft(8, '0').toUpperCase()}',
                  style: TextStyle(
                    color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
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
        ),
      ],
    );
  }

  Widget _buildNumberProperty(String label, double value, Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFEDF1EE),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
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
          controller: TextEditingController(text: value.toString()),
          onChanged: (val) {
            final numValue = double.tryParse(val) ?? value;
            onChanged(numValue);
          },
        ),
      ],
    );
  }

  Widget _buildDropdownProperty(String label, String value, List<String> options, Function(String) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFEDF1EE),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF3F3F3F),
            border: Border.all(color: const Color(0xFF666666)),
            borderRadius: BorderRadius.circular(4),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: Container(),
            dropdownColor: const Color(0xFF3F3F3F),
            style: const TextStyle(color: Color(0xFFEDF1EE)),
            items: options.map((option) {
              return DropdownMenuItem<String>(
                value: option,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(option),
                ),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) {
                onChanged(val);
              }
            },
          ),
        ),
      ],
    );
  }
} 