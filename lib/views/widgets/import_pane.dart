import 'package:flutter/material.dart';
import 'dart:convert';

class ImportPane extends StatefulWidget {
  final void Function(String) onImportJson;
  const ImportPane({super.key, required this.onImportJson});

  @override
  State<ImportPane> createState() => _ImportPaneState();
}

class _ImportPaneState extends State<ImportPane> {
  final TextEditingController _controller = TextEditingController();
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Import',
            style: TextStyle(
              color: Color(0xFFEDF1EE),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _controller,
            maxLines: 10,
            decoration: InputDecoration(
              labelText: 'Paste JSON here',
              errorText: _error,
              labelStyle: const TextStyle(color: Color(0xFFEDF1EE)),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFEDF1EE)),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF4CAF50)),
              ),
            ),
            style: const TextStyle(color: Color(0xFFEDF1EE)),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              try {
                // final json = jsonDecode(_controller.text);
                // if (json is Map<String, dynamic>) {
                //   widget.onImportJson(json);
                //   setState(() => _error = null);
                //   ScaffoldMessenger.of(context).showSnackBar(
                //     const SnackBar(content: Text('Imported successfully!')),
                //   );
                // } else {
                //   setState(() => _error = 'JSON must be an object');
                // }
                widget.onImportJson(_controller.text);
              } catch (e) {
                setState(() => _error = 'Invalid JSON');
              }
            },
            child: const Text('Import'),
          ),
        ],
      ),
    );
  }
} 