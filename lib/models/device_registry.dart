import 'device_registry_entry.dart';
import 'device_registry_data.dart';

class DeviceRegistry {
  static final List<DeviceRegistryEntry> _customDevices = [];

  static List<DeviceRegistryEntry> getAll() {
    return [...deviceRegistryEntries, ..._customDevices];
  }

  static DeviceRegistryEntry? getByName(String name) {
    try {
      return getAll().firstWhere((e) => e.name == name);
    } catch (_) {
      return null;
    }
  }

  static void addCustom(DeviceRegistryEntry entry) {
    _customDevices.add(entry);
  }
} 