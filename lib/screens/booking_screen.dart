import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/available_slot.dart';
import '../repositories/dashboard_repository.dart';

class BookingScreen extends StatelessWidget {
  const BookingScreen({required this.shopId, super.key});

  final String shopId;

  @override
  Widget build(BuildContext context) {
    final db = FirebaseFirestore.instance;

    return Scaffold(
      appBar: AppBar(title: const Text('CancelWait 予約')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: db
            .collection('shops')
            .doc(shopId)
            .collection('availableSlots')
            .where('status', isEqualTo: 'open')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('空き枠を読み込めませんでした: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final slots = snapshot.data!.docs
              .map(AvailableSlot.fromDocument)
              .where((slot) => !slot.isPast && slot.remainingCapacity > 0)
              .toList()
            ..sort((a, b) => a.startAt.compareTo(b.startAt));

          return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            future: db.collection('shops').doc(shopId).get(),
            builder: (context, shopSnapshot) {
              final name = shopSnapshot.data?.data()?['name'] ?? '店舗';
              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text(
                    '$name の空き枠',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text('ご希望の時間を選び、先着順で予約を確定してください。'),
                  const SizedBox(height: 24),
                  if (slots.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: Center(child: Text('現在予約できる空き枠はありません。')),
                      ),
                    ),
                  ...slots.map(
                    (slot) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(18),
                          title: Text(
                            '${slot.startAt.year}/${slot.startAt.month}/${slot.startAt.day} '
                            '${_formatTime(slot.startAt)}〜${_formatTime(slot.endAt)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${slot.menuName} ・ 担当 ${slot.staffName} ・ '
                            '残り${slot.remainingCapacity}名',
                          ),
                          trailing: FilledButton(
                            onPressed: () => _reserve(context, slot),
                            child: const Text('予約する'),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  static String _formatTime(DateTime date) =>
      '${date.hour.toString().padLeft(2, '0')}:'
      '${date.minute.toString().padLeft(2, '0')}';

  Future<void> _reserve(BuildContext context, AvailableSlot slot) async {
    final formKey = GlobalKey<FormState>();
    final name = TextEditingController();
    final phone = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('予約者情報'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: name,
                decoration: const InputDecoration(labelText: 'お名前'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? '入力してください'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: phone,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: '電話番号'),
                validator: (value) => value == null || value.trim().length < 8
                    ? '正しい電話番号を入力してください'
                    : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(dialogContext, true);
              }
            },
            child: const Text('予約を確定'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await FirestoreDashboardRepository(
          FirebaseFirestore.instance,
        ).reserve(shopId, slot, name: name.text, phone: phone.text);
        if (context.mounted) {
          await showDialog<void>(
            context: context,
            builder: (dialogContext) => AlertDialog(
              title: const Text('予約が確定しました'),
              content: const Text('ご予約ありがとうございます。'),
              actions: [
                FilledButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('閉じる'),
                ),
              ],
            ),
          );
        }
      } catch (error) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('$error')));
        }
      }
    }
    name.dispose();
    phone.dispose();
  }
}
