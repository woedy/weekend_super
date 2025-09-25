class DispatcherProfile {
  const DispatcherProfile({
    required this.name,
    required this.email,
    required this.phone,
    required this.serviceAreas,
    required this.completedDeliveries,
    required this.onTimeRate,
  });

  final String name;
  final String email;
  final String phone;
  final List<String> serviceAreas;
  final int completedDeliveries;
  final double onTimeRate;
}
