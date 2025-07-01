import 'package:flutter/material.dart';
import 'dart:convert';

class ImportPane extends StatefulWidget {
  final void Function(String) onImportJson;
  final bool Function()? isProjectNonEmpty;
  const ImportPane({super.key, required this.onImportJson, this.isProjectNonEmpty});

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
            onPressed: () async {
              try {
                if (widget.isProjectNonEmpty != null && widget.isProjectNonEmpty!()) {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: const Color(0xFF2F2F2F),
                      title: const Text('Import Project?', style: TextStyle(color: Color(0xFFEDF1EE))),
                      content: const Text('Importing will overwrite your current project and you may lose unsaved changes. Continue?', style: TextStyle(color: Color(0xFFEDF1EE))),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancel', style: TextStyle(color: Color(0xFFFF5252))),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Import', style: TextStyle(color: Color(0xFF4CAF50))),
                        ),
                      ],
                    ),
                  );
                  if (confirmed != true) return;
                }
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