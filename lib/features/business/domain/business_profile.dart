import 'package:cloud_firestore/cloud_firestore.dart';

class BusinessProfile {
  const BusinessProfile({required this.name, required this.representative, required this.industry, required this.address, required this.phone, required this.email});
  final String name, representative, industry, address, phone, email;
  factory BusinessProfile.fromDocument(DocumentSnapshot<Map<String, dynamic>> document) { final data = document.data() ?? {}; return BusinessProfile(name: data['name'] as String? ?? '', representative: data['representative'] as String? ?? '', industry: data['industry'] as String? ?? '', address: data['address'] as String? ?? '', phone: data['phone'] as String? ?? '', email: data['email'] as String? ?? ''); }
  Map<String, dynamic> toMap() => {'name': name.trim(), 'representative': representative.trim(), 'industry': industry.trim(), 'address': address.trim(), 'phone': phone.trim(), 'email': email.trim(), 'updatedAt': FieldValue.serverTimestamp()};
}
