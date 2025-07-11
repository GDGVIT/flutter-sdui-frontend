import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:flutter_sdui/src/service/sdui_grpc_client.dart';
import 'package:flutter_sdui/src/parser/sdui_proto_parser.dart';
import 'package:flutter_sdui/src/generated/sdui.pb.dart';
import '../../viewmodels/design_canvas_viewmodel.dart';
import '../../viewmodels/sdui_conversion_service.dart';

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
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () async {
              // Prompt for screen ID, host, and port
              String screenId = 'home';
              String host = 'localhost';
              String portStr = '50051';
              final screenIdController = TextEditingController(text: screenId);
              final hostController = TextEditingController(text: host);
              final portController = TextEditingController(text: portStr);
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: const Color(0xFF2F2F2F),
                  title: const Text('Import from gRPC', style: TextStyle(color: Color(0xFFEDF1EE))),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: screenIdController,
                        style: const TextStyle(color: Color(0xFFEDF1EE)),
                        decoration: const InputDecoration(
                          labelText: 'Screen ID',
                          labelStyle: TextStyle(color: Color(0xFFEDF1EE)),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFEDF1EE)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF4CAF50)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: hostController,
                        style: const TextStyle(color: Color(0xFFEDF1EE)),
                        decoration: const InputDecoration(
                          labelText: 'gRPC Host',
                          labelStyle: TextStyle(color: Color(0xFFEDF1EE)),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFEDF1EE)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF4CAF50)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: portController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Color(0xFFEDF1EE)),
                        decoration: const InputDecoration(
                          labelText: 'gRPC Port',
                          labelStyle: TextStyle(color: Color(0xFFEDF1EE)),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFEDF1EE)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF4CAF50)),
                          ),
                        ),
                      ),
                    ],
                  ),
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
              screenId = screenIdController.text.trim();
              host = hostController.text.trim();
              portStr = portController.text.trim();
              if (screenId.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Screen ID cannot be empty')),
                );
                return;
              }
              if (host.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('gRPC host cannot be empty')),
                );
                return;
              }
              int port = int.tryParse(portStr) ?? 50051;
              final client = SduiGrpcClient(host: host, port: port);
              try {
                final SduiWidgetData data = await client.getWidget(screenId);
                final sduiWidget = SduiParser.parseProto(data);
                if (sduiWidget != null) {
                  final widgetNode = SduiConversionService.widgetNodeFromSduiWidget(sduiWidget);
                  Provider.of<DesignCanvasViewModel>(context, listen: false)
                    ..setSelectedPane('build')
                    ..importFromSduiJson({}) // placeholder, will set below
                  ;
                  // Directly set the root widget node
                  Provider.of<DesignCanvasViewModel>(context, listen: false).setRootWidgetNode(widgetNode);
                  Provider.of<DesignCanvasViewModel>(context, listen: false).notifyListeners();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to parse SDUI proto')),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('gRPC import failed: $e')),
                );
              } finally {
                await client.dispose();
              }
            },
            child: const Text('Import from gRPC'),
          ),
        ],
      ),
    );
  }
} 