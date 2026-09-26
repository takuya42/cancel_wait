import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationRecord {
  const NotificationRecord({required this.id, required this.slotId, required this.customerId, required this.customerName, required this.message, required this.deliveryMode, required this.status, required this.createdAt});
  final String id, slotId, customerId, customerName, message, deliveryMode, status;
  final DateTime createdAt;
  factory NotificationRecord.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) { final d=doc.data()??{}; return NotificationRecord(id: doc.id, slotId:d['slotId']??'', customerId:d['customerId']??'', customerName:d['customerName']??'', message:d['message']??'', deliveryMode:d['deliveryMode']??'mock', status:d['status']??'sent', createdAt:(d['createdAt'] as Timestamp?)?.toDate()??DateTime.now()); }
}
