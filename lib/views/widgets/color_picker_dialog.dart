import 'package:flutter/material.dart';

class ColorPickerDialog extends StatelessWidget {
  final Color initialColor;
  final Function(Color) onColorChanged;
  const ColorPickerDialog({super.key, required this.initialColor, required this.onColorChanged});
  @override
  Widget build(BuildContext context) {
    // Minimal stub for now
    return AlertDialog(
      title: const Text('Pick a color'),
      content: const Text('Color picker not implemented.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
    );
  }
} 