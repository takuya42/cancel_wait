import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/waiting_customer.dart';
import '../../providers/auth_providers.dart';
import '../../providers/dashboard_providers.dart';
import '../../widgets/async_content.dart';
import '../../widgets/page_header.dart';
import '../../widgets/status_badge.dart';
import 'customer_form_dialog.dart';

class WaitingListScreen extends ConsumerStatefulWidget {
  const WaitingListScreen({super.key});

  @override
  ConsumerState<WaitingListScreen> createState() => _WaitingListScreenState();
}

class _WaitingListScreenState extends ConsumerState<WaitingListScreen> {
  String query = '';
  WaitingStatus? filter;
  DateTime? date;

  String _formatDate(DateTime value) =>
      '${value.year}/${value.month.toString().padLeft(2, '0')}/'
      '${value.day.toString().padLeft(2, '0')}';

  Future<void> _save([WaitingCustomer? customer]) async {
    final value = await showDialog<WaitingCustomer>(
      context: context,
      builder: (context) => CustomerFormDialog(initial: customer),
    );
    final shopId = ref.read(shopIdProvider).value;
    if (value != null && shopId != null) {
      await ref.read(dashboardRepositoryProvider).saveCustomer(shopId, value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(MediaQuery.sizeOf(context).width < 600 ? 16 : 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PageHeader(
                title: 'キャンセル待ち',
                subtitle: 'お客様の希望条件と対応状況を管理します。',
                action: FilledButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.person_add_alt),
                  label: const Text('顧客を登録'),
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: 280,
                    child: TextField(
                      onChanged: (value) => setState(() => query = value),
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: '名前で検索',
                      ),
                    ),
                  ),
                  DropdownButton<WaitingStatus?>(
                    value: filter,
                    hint: const Text('すべてのステータス'),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('すべて'),
                      ),
                      ...WaitingStatus.values.map(
                        (status) => DropdownMenuItem(
                          value: status,
                          child: Text(_statusLabel(status)),
                        ),
                      ),
                    ],
                    onChanged: (value) => setState(() => filter = value),
                  ),
                  OutlinedButton.icon(
                    onPressed: _selectDate,
                    onLongPress: () => setState(() => date = null),
                    icon: const Icon(Icons.filter_alt_outlined),
                    label: Text(date == null ? '日付' : '${_formatDate(date!)}（解除）'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              AsyncContent(
                value: ref.watch(waitingCustomersProvider),
                builder: (allCustomers) {
                  final customers = allCustomers.where((customer) {
                    return customer.name.contains(query) &&
                        (filter == null || customer.status == filter) &&
                        (date == null ||
                            _formatDate(customer.preferredDate) ==
                                _formatDate(date!));
                  }).toList();
                  if (customers.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(48),
                        child: Text('条件に一致する顧客はいません。'),
                      ),
                    );
                  }
                  return Column(
                    children: customers
                        .map(
                          (customer) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Card(
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                leading: CircleAvatar(
                                  child: Text(customer.name.characters.first),
                                ),
                                title: Wrap(
                                  spacing: 8,
                                  children: [
                                    Text(
                                      customer.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    StatusBadge(
                                      _statusLabel(customer.status),
                                      color: _statusColor(customer.status),
                                    ),
                                    StatusBadge(
                                      customer.lineLinked
                                          ? 'LINE連携済み'
                                          : 'LINE未連携',
                                      color: customer.lineLinked
                                          ? Colors.green
                                          : Colors.grey,
                                    ),
                                  ],
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    '${_formatDate(customer.preferredDate)} '
                                    '${customer.preferredStartTime}〜'
                                    '${customer.preferredEndTime} ・ '
                                    '${customer.menuName}'
                                    '${customer.phone.isEmpty ? '' : ' ・ ${customer.phone}'}',
                                  ),
                                ),
                                trailing: _CustomerMenu(
                                  onEdit: () => _save(customer),
                                  onDelete: () => _delete(customer),
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final selected = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      initialDate: date ?? DateTime.now(),
    );
    if (selected != null) setState(() => date = selected);
  }

  Future<void> _delete(WaitingCustomer customer) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('顧客を削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('削除'),
          ),
        ],
      ),
    );
    final shopId = ref.read(shopIdProvider).value;
    if (confirmed == true && shopId != null) {
      await ref
          .read(dashboardRepositoryProvider)
          .deleteCustomer(shopId, customer.id);
    }
  }

  static String _statusLabel(WaitingStatus status) => switch (status) {
    WaitingStatus.waiting => '待機中',
    WaitingStatus.notified => '通知済み',
    WaitingStatus.reserved => '予約済み',
    WaitingStatus.cancelled => 'キャンセル',
  };

  static Color _statusColor(WaitingStatus status) => switch (status) {
    WaitingStatus.waiting => Colors.blue,
    WaitingStatus.notified => Colors.orange,
    WaitingStatus.reserved => Colors.green,
    WaitingStatus.cancelled => Colors.grey,
  };
}

class _CustomerMenu extends StatelessWidget {
  const _CustomerMenu({required this.onEdit, required this.onDelete});

  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'edit') onEdit();
        if (value == 'delete') onDelete();
      },
      itemBuilder: (context) => const [
        PopupMenuItem(value: 'edit', child: Text('編集')),
        PopupMenuItem(value: 'delete', child: Text('削除')),
      ],
    );
  }
}
