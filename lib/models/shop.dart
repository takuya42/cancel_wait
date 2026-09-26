import 'package:cloud_firestore/cloud_firestore.dart';

class Shop {
  const Shop({required this.id, required this.name, required this.ownerUid, required this.ownerName, required this.email, required this.lineConnected});

  final String id;
  final String name;
  final String ownerUid;
  final String ownerName;
  final String email;
  final bool lineConnected;

  factory Shop.fromDocument(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;
    return Shop(
      id: document.id,
      name: data['name'] as String? ?? '',
      ownerUid: data['ownerUid'] as String? ?? '',
      ownerName: data['ownerName'] as String? ?? '',
      email: data['email'] as String? ?? '',
      lineConnected: data['lineConnected'] as bool? ?? false,
    );
  }
}
