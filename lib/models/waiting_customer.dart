class WaitingCustomer {
  const WaitingCustomer({
    required this.name,
    required this.preferredDate,
    required this.preferredTime,
    required this.menu,
    required this.isLineConnected,
    required this.registeredAt,
  });

  final String name;
  final String preferredDate;
  final String preferredTime;
  final String menu;
  final bool isLineConnected;
  final String registeredAt;
}
