import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/available_slot.dart';
import '../../models/waiting_customer.dart';
import '../../providers/auth_providers.dart';
import '../../providers/dashboard_providers.dart';
import '../../widgets/async_content.dart';
import '../../widgets/page_header.dart';
import '../../widgets/status_badge.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  String _formatDateTime(DateTime date) =>
      '${date.month}/${date.day} ${date.hour.toString().padLeft(2, '0')}:'
      '${date.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slots = ref.watch(slotsProvider);
    final customers = ref.watch(waitingCustomersProvider);

    return SingleChildScrollView(
      padding: EdgeInsets.all(MediaQuery.sizeOf(context).width < 600 ? 16 : 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PageHeader(
                title: 'LINE通知',
                subtitle: '条件に合うお客様へ空き枠をお知らせします（現在はモック送信）。',
              ),
              const SizedBox(height: 22),
              Text(
                '通知候補',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              AsyncContent(
                value: slots,
                builder: (slotItems) => AsyncContent(
                  value: customers,
                  builder: (customerItems) {
                    final openSlots = slotItems
                        .where(
                          (slot) =>
                              !slot.isPast && slot.status == SlotStatus.open,
                        )
                        .toList();
                    if (openSlots.isEmpty) {
                      return const Card(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Center(child: Text('通知できる空き枠はありません。')),
                        ),
                      );
                    }
                    return Column(
                      children: openSlots.map((slot) {
                        final matches = ref
                            .read(matchingServiceProvider)
                            .candidates(slot, customerItems);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Card(
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(18),
                              title: Text(
                                '${_formatDateTime(slot.startAt)}〜'
                                '${_formatDateTime(slot.endAt).split(' ').last}  '
                                '${slot.menuName}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                '担当 ${slot.staffName} ・ 通知候補 ${matches.length}名',
                              ),
                              trailing: FilledButton.icon(
                                onPressed: matches.isEmpty
                                    ? null
                                    : () => _notify(
                                        context,
                                        ref,
                                        slot,
                                        matches,
                                      ),
                                icon: const Icon(Icons.send_outlined),
                                label: const Text('LINEで通知'),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
              const SizedBox(height: 28),
              Text(
                '通知履歴',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              AsyncContent(
                value: ref.watch(notificationsProvider),
                builder: (items) => items.isEmpty
                    ? const Card(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Center(child: Text('通知履歴はまだありません。')),
                        ),
                      )
                    : Column(
                        children: items
                            .map(
                              (notification) => Card(
                                child: ListTile(
                                  leading: const CircleAvatar(
                                    child: Icon(Icons.check),
                                  ),
                                  title: Text(notification.customerName),
                                  subtitle: Text(
                                    '${_formatDateTime(notification.createdAt)} ・ '
                                    '${notification.message}',
                                  ),
                                  trailing: const StatusBadge(
                                    'モック送信',
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _notify(
    BuildContext context,
    WidgetRef ref,
    AvailableSlot slot,
    List<WaitingCustomer> matches,
  ) async {
    final selected = <String>{...matches.map((customer) => customer.id)};
    final message = TextEditingController(
      text: '${slot.menuName}に空きが出ました。先着順でご予約いただけます。',
    );
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('通知対象を選択'),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...matches.map(
                    (customer) => CheckboxListTile(
                      value: selected.contains(customer.id),
                      onChanged: (checked) {
                        setDialogState(() {
                          if (checked == true) {
                            selected.add(customer.id);
                          } else {
                            selected.remove(customer.id);
                          }
                        });
                      },
                      title: Text(customer.name),
                      subtitle: Text(
                        customer.lineLinked ? 'LINE連携済み' : 'LINE未連携（モック）',
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: message,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: '通知メッセージ'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('キャンセル'),
            ),
            FilledButton(
              onPressed: selected.isEmpty
                  ? null
                  : () => Navigator.pop(dialogContext, true),
              child: Text('${selected.length}名にモック送信'),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true) {
      final shopId = ref.read(shopIdProvider).value;
      if (shopId != null) {
        await ref.read(dashboardRepositoryProvider).sendMockNotifications(
              shopId,
              slot,
              matches
                  .where((customer) => selected.contains(customer.id))
                  .toList(),
              message.text,
            );
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('モック通知を送信しました（LINE通信は行っていません）')),
        );
      }
    }
    message.dispose();
  }
}
