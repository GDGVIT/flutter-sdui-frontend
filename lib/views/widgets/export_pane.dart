import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../../viewmodels/design_canvas_viewmodel.dart';
import 'package:file_picker/file_picker.dart';

class ExportPane extends StatelessWidget {
  const ExportPane({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<DesignCanvasViewModel>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Export',
            style: TextStyle(
              color: Color(0xFFEDF1EE),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              final path = 'export.json';
              await viewModel.exportToFile(path);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Exported to export.json')),
              );
            },
            child: const Text('Export to default file'),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () async {
              String? outputPath = await FilePicker.platform.saveFile(
                dialogTitle: 'Export SDUI JSON',
                fileName: 'export.json',
              );
              if (outputPath != null) {
                await viewModel.exportToFile(outputPath);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Exported to $outputPath')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Export cancelled.')),
                );
              }
            },
            child: const Text('Export with file picker'),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () async {
              final sduiWidget = viewModel.widgetNodeToSduiWidget(viewModel.widgetRoot);
              final sduiJson = viewModel.exportToJsonString(sduiWidget);
              await Clipboard.setData(ClipboardData(text: sduiJson));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('JSON copied to clipboard')),
              );
            },
            child: const Text('Copy JSON to clipboard'),
          ),
        ],
      ),
    );
  }
} 