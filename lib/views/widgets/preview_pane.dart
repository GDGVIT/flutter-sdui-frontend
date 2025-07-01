import 'package:flutter/material.dart';
import '../../models/device_registry.dart';
import '../../models/device_registry_entry.dart';
import 'device_selector.dart';

class PreviewPane extends StatefulWidget {
  final Widget sduiRoot;
  const PreviewPane({super.key, required this.sduiRoot});

  @override
  State<PreviewPane> createState() => _PreviewPaneState();
}

class _PreviewPaneState extends State<PreviewPane> {
  String selectedDevice = DeviceRegistry.getAll().first.name;
  double zoom = 1.0;
  double responsiveWidth = 400;
  double responsiveHeight = 700;

  void _onDeviceSelected(String name) {
    setState(() {
      selectedDevice = name;
      final device = DeviceRegistry.getByName(name);
      if (device != null && device.isResponsive) {
        // keep current responsiveWidth/Height
      } else if (device != null) {
        responsiveWidth = device.width ?? 400;
        responsiveHeight = device.height ?? 700;
      }
    });
  }

  void _onAddCustomDevice() async {
    final result = await showDialog<DeviceRegistryEntry>(
      context: context,
      builder: (context) => _AddCustomDeviceDialog(),
    );
    if (result != null) {
      DeviceRegistry.addCustom(result);
      setState(() {
        selectedDevice = result.name;
        responsiveWidth = result.width ?? 400;
        responsiveHeight = result.height ?? 700;
      });
    }
  }

  void _onResize(double dx, double dy) {
    setState(() {
      responsiveWidth = (responsiveWidth + dx).clamp(100, 2000);
      responsiveHeight = (responsiveHeight + dy).clamp(100, 2000);
    });
  }

  @override
  Widget build(BuildContext context) {
    final device = DeviceRegistry.getByName(selectedDevice);
    final isResponsive = device?.isResponsive ?? false;
    final width = isResponsive ? responsiveWidth : (device?.width ?? 400);
    final height = isResponsive ? responsiveHeight : (device?.height ?? 700);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DeviceSelector(
          selectedDeviceName: selectedDevice,
          onDeviceSelected: _onDeviceSelected,
          onAddCustomDevice: _onAddCustomDevice,
        ),
        const SizedBox(height: 12),
        if (isResponsive)
          Row(
            children: [
              const Text('Zoom:'),
              Slider(
                value: zoom,
                min: 0.2,
                max: 2.0,
                divisions: 18,
                label: '${(zoom * 100).round()}%',
                onChanged: (v) => setState(() => zoom = v),
              ),
              Text('${(zoom * 100).round()}%'),
            ],
          ),
        Center(
          child: Stack(
            children: [
              Container(
                width: width * zoom,
                height: height * zoom,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 2),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.black,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: width * zoom,
                    height: height * zoom,
                    child: widget.sduiRoot,
                  ),
                ),
              ),
              if (isResponsive)
                ..._buildResizeHandles(),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildResizeHandles() {
    // Four edge handles (left, right, top, bottom)
    return [
      // Right edge
      Positioned(
        right: -8,
        top: 0,
        bottom: 0,
        child: _ResizeHandle(
          onDrag: (dx, dy) => _onResize(dx, 0),
          cursor: SystemMouseCursors.resizeLeftRight,
        ),
      ),
      // Bottom edge
      Positioned(
        left: 0,
        right: 0,
        bottom: -8,
        child: _ResizeHandle(
          onDrag: (dx, dy) => _onResize(0, dy),
          cursor: SystemMouseCursors.resizeUpDown,
        ),
      ),
      // Left edge
      Positioned(
        left: -8,
        top: 0,
        bottom: 0,
        child: _ResizeHandle(
          onDrag: (dx, dy) => _onResize(-dx, 0),
          cursor: SystemMouseCursors.resizeLeftRight,
        ),
      ),
      // Top edge
      Positioned(
        left: 0,
        right: 0,
        top: -8,
        child: _ResizeHandle(
          onDrag: (dx, dy) => _onResize(0, -dy),
          cursor: SystemMouseCursors.resizeUpDown,
        ),
      ),
    ];
  }
}

class _ResizeHandle extends StatelessWidget {
  final void Function(double dx, double dy) onDrag;
  final MouseCursor cursor;
  const _ResizeHandle({required this.onDrag, required this.cursor});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: cursor,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onPanUpdate: (details) => onDrag(details.delta.dx, details.delta.dy),
        child: Container(
          width: 16,
          height: 16,
          color: Colors.transparent,
        ),
      ),
    );
  }
}

class _AddCustomDeviceDialog extends StatefulWidget {
  @override
  State<_AddCustomDeviceDialog> createState() => _AddCustomDeviceDialogState();
}

class _AddCustomDeviceDialogState extends State<_AddCustomDeviceDialog> {
  final _nameController = TextEditingController();
  final _widthController = TextEditingController();
  final _heightController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Custom Device'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Device Name'),
          ),
          TextField(
            controller: _widthController,
            decoration: const InputDecoration(labelText: 'Width'),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: _heightController,
            decoration: const InputDecoration(labelText: 'Height'),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final name = _nameController.text.trim();
            final width = double.tryParse(_widthController.text.trim());
            final height = double.tryParse(_heightController.text.trim());
            if (name.isNotEmpty && width != null && height != null) {
              Navigator.of(context).pop(DeviceRegistryEntry(
                name: name,
                width: width,
                height: height,
              ));
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
} 