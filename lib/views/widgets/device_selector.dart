import 'package:flutter/material.dart';
import '../../models/device_registry.dart';

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
    return LayoutBuilder(
      builder: (context, constraints) {
        final double available = constraints.maxWidth;
        final double computedMax = available > 360 ? 320 : (available - 100).clamp(120, available);
        final double computedMin = computedMax.clamp(120, computedMax);
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: computedMax,
                minWidth: computedMin,
              ),
              child: DropdownButtonFormField<String>(
                value: selectedDeviceName,
                isExpanded: true,
                items: devices
                    .map((d) => DropdownMenuItem(
                          value: d.name,
                          child: Text(d.name, overflow: TextOverflow.ellipsis),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) onDeviceSelected(value);
                },
                decoration: const InputDecoration(
                  isDense: true,
                  border: OutlineInputBorder(),
                  labelText: 'Device',
                ),
              ),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add Custom'),
              onPressed: onAddCustomDevice,
            ),
          ],
        );
      },
    );
  }
} 