import 'package:cloud_firestore/cloud_firestore.dart';

enum WaitingStatus { waiting, notified, reserved, cancelled }

class WaitingCustomer {
  const WaitingCustomer({required this.id, required this.name, required this.preferredDate, required this.preferredStartTime, required this.preferredEndTime, required this.menuName, required this.phone, required this.lineLinked, required this.memo, required this.status, this.notifiedAt, required this.createdAt});
  final String id, name, preferredStartTime, preferredEndTime, menuName, phone, memo;
  final DateTime preferredDate, createdAt;
  final bool lineLinked;
  final WaitingStatus status;
  final DateTime? notifiedAt;

  factory WaitingCustomer.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    DateTime date(dynamic value) => value is Timestamp ? value.toDate() : DateTime.tryParse('$value') ?? DateTime.now();
    return WaitingCustomer(id: doc.id, name: d['name'] ?? '', preferredDate: date(d['preferredDate']), preferredStartTime: d['preferredStartTime'] ?? '', preferredEndTime: d['preferredEndTime'] ?? '', menuName: d['menuName'] ?? '', phone: d['phone'] ?? '', lineLinked: d['lineLinked'] ?? false, memo: d['memo'] ?? '', status: WaitingStatus.values.where((e) => e.name == d['status']).firstOrNull ?? WaitingStatus.waiting, notifiedAt: d['notifiedAt'] == null ? null : date(d['notifiedAt']), createdAt: date(d['createdAt']));
  }

  Map<String, dynamic> toMap() => {'name': name.trim(), 'preferredDate': Timestamp.fromDate(DateTime(preferredDate.year, preferredDate.month, preferredDate.day)), 'preferredStartTime': preferredStartTime, 'preferredEndTime': preferredEndTime, 'menuName': menuName.trim(), 'phone': phone.trim(), 'lineLinked': lineLinked, 'memo': memo.trim(), 'status': status.name, 'notifiedAt': notifiedAt == null ? null : Timestamp.fromDate(notifiedAt!), 'updatedAt': FieldValue.serverTimestamp()};
  WaitingCustomer copyWith({String? id, WaitingStatus? status, DateTime? notifiedAt}) => WaitingCustomer(id: id ?? this.id, name: name, preferredDate: preferredDate, preferredStartTime: preferredStartTime, preferredEndTime: preferredEndTime, menuName: menuName, phone: phone, lineLinked: lineLinked, memo: memo, status: status ?? this.status, notifiedAt: notifiedAt ?? this.notifiedAt, createdAt: createdAt);
}
