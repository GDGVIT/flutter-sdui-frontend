import 'package:flutter/material.dart';
import '../../models/device_registry.dart';
import '../../models/device_registry_entry.dart';

class DeviceSelector extends StatelessWidget {
  final String selectedDeviceName;
  final ValueChanged<String> onDeviceSelected;
  final VoidCallback onAddCustomDevice;

  const DeviceSelector({
    super.key,
    required this.selectedDeviceName,
    required this.onDeviceSelected,
    required this.onAddCustomDevice,
  });

  @override
  Widget build(BuildContext context) {
    final devices = DeviceRegistry.getAll();
    return Row(
      children: [
        DropdownButton<String>(
          value: selectedDeviceName,
          items: devices.map((d) => DropdownMenuItem(
            value: d.name,
            child: Text(d.name),
          )).toList(),
          onChanged: (value) {
            if (value != null) onDeviceSelected(value);
          },
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          icon: const Icon(Icons.add),
          label: const Text('Add Custom'),
          onPressed: onAddCustomDevice,
        ),
      ],
    );
  }
} 