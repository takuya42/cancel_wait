import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/finance_entry.dart';

class FinanceRepository {
  FinanceRepository(this._firestore);
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _collection(String organizationId, EntryType type) =>
      _firestore.collection('organizations').doc(organizationId).collection(type == EntryType.sale ? 'sales' : 'expenses');

  Stream<List<FinanceEntry>> watchEntries(String organizationId, EntryType type) =>
      _collection(organizationId, type)
          .orderBy('date', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs.map(FinanceEntry.fromDocument).toList());

  Future<void> save({required String organizationId, required EntryType type, FinanceEntry? existing, required DateTime date, required int amount, required String category, required String memo}) async {
    final document = existing == null ? _collection(organizationId, type).doc() : _collection(organizationId, type).doc(existing.id);
    await document.set({
      'date': Timestamp.fromDate(date),
      'amount': amount,
      'category': category.trim(),
      'memo': memo.trim(),
      if (existing == null) 'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> delete(String organizationId, EntryType type, String id) =>
      _collection(organizationId, type).doc(id).delete();
}
