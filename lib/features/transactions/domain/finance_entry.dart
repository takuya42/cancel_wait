import 'package:cloud_firestore/cloud_firestore.dart';

enum EntryType { sale, expense }

class FinanceEntry {
  const FinanceEntry({
    required this.id,
    required this.date,
    required this.amount,
    required this.category,
    required this.memo,
    required this.createdAt,
  });

  final String id;
  final DateTime date;
  final int amount;
  final String category;
  final String memo;
  final DateTime? createdAt;

  factory FinanceEntry.fromDocument(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data() ?? const <String, dynamic>{};
    return FinanceEntry(
      id: document.id,
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      amount: (data['amount'] as num?)?.round() ?? 0,
      category: data['category'] as String? ?? '未分類',
      memo: data['memo'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
