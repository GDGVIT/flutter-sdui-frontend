class DeviceRegistryEntry {
  final String name;
  final double? width;
  final double? height;
  final bool isResponsive;

  const DeviceRegistryEntry({
    required this.name,
    this.width,
    this.height,
    this.isResponsive = false,
  });
} 