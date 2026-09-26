import 'package:cloud_firestore/cloud_firestore.dart';

enum SlotStatus { open, full, closed }

class AvailableSlot {
  const AvailableSlot({required this.id, required this.startAt, required this.endAt, required this.menuName, required this.staffName, required this.capacity, required this.remainingCapacity, required this.memo, required this.status, required this.createdAt});
  final String id, menuName, staffName, memo;
  final DateTime startAt, endAt, createdAt;
  final int capacity, remainingCapacity;
  final SlotStatus status;
  bool get isPast => endAt.isBefore(DateTime.now());
  factory AvailableSlot.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    DateTime date(dynamic v) => v is Timestamp ? v.toDate() : DateTime.tryParse('$v') ?? DateTime.now();
    return AvailableSlot(id: doc.id, startAt: date(d['startAt']), endAt: date(d['endAt']), menuName: d['menuName'] ?? '', staffName: d['staffName'] ?? '', capacity: d['capacity'] ?? 1, remainingCapacity: d['remainingCapacity'] ?? d['capacity'] ?? 1, memo: d['memo'] ?? '', status: SlotStatus.values.where((e) => e.name == d['status']).firstOrNull ?? SlotStatus.open, createdAt: date(d['createdAt']));
  }
  Map<String, dynamic> toMap() => {'date': Timestamp.fromDate(DateTime(startAt.year, startAt.month, startAt.day)), 'startAt': Timestamp.fromDate(startAt), 'endAt': Timestamp.fromDate(endAt), 'menuName': menuName.trim(), 'staffName': staffName.trim(), 'capacity': capacity, 'remainingCapacity': remainingCapacity, 'memo': memo.trim(), 'status': status.name, 'updatedAt': FieldValue.serverTimestamp()};
  AvailableSlot copyWith({String? id, int? remainingCapacity, SlotStatus? status}) => AvailableSlot(id: id ?? this.id, startAt: startAt, endAt: endAt, menuName: menuName, staffName: staffName, capacity: capacity, remainingCapacity: remainingCapacity ?? this.remainingCapacity, memo: memo, status: status ?? this.status, createdAt: createdAt);
}
