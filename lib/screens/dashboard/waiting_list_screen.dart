import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/waiting_customer.dart';
import '../../providers/dashboard_providers.dart';
import '../../widgets/page_header.dart';

class WaitingListScreen extends ConsumerWidget {
  const WaitingListScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customers = ref.watch(waitingCustomersProvider);
    return SingleChildScrollView(padding: const EdgeInsets.all(32), child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1180), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      PageHeader(title: 'キャンセル待ち', subtitle: '${customers.length}人が登録されています', action: FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.add), label: const Text('キャンセル待ちを追加'))),
      const SizedBox(height: 28),
      LayoutBuilder(builder: (context, constraints) => constraints.maxWidth >= 800 ? _CustomerTable(customers: customers) : Column(children: customers.map((customer) => Padding(padding: const EdgeInsets.only(bottom: 12), child: _CustomerCard(customer: customer))).toList())),
    ]))));
  }
}

class _CustomerTable extends StatelessWidget {
  const _CustomerTable({required this.customers}); final List<WaitingCustomer> customers;
  @override Widget build(BuildContext context) => Card(child: ClipRRect(borderRadius: BorderRadius.circular(16), child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: DataTable(
    headingRowColor: WidgetStatePropertyAll(Colors.blueGrey.shade50),
    columns: const ['顧客名', '希望日', '希望時間', 'メニュー', 'LINE連携状態', '登録日時'].map((label) => DataColumn(label: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)))).toList(),
    rows: customers.map((c) => DataRow(cells: [DataCell(Text(c.name, style: const TextStyle(fontWeight: FontWeight.w600))), DataCell(Text(c.preferredDate)), DataCell(Text(c.preferredTime)), DataCell(Text(c.menu)), DataCell(_LineBadge(connected: c.isLineConnected)), DataCell(Text(c.registeredAt))])).toList(),
  ))));
}

class _CustomerCard extends StatelessWidget {
  const _CustomerCard({required this.customer}); final WaitingCustomer customer;
  @override Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [CircleAvatar(child: Text(customer.name.characters.first)), const SizedBox(width: 12), Expanded(child: Text(customer.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600))), _LineBadge(connected: customer.isLineConnected)]),
    const Divider(height: 28),
    _Info(label: '希望日時', value: '${customer.preferredDate}  ${customer.preferredTime}'), const SizedBox(height: 10),
    _Info(label: 'メニュー', value: customer.menu), const SizedBox(height: 10), _Info(label: '登録日時', value: customer.registeredAt),
  ])));
}

class _Info extends StatelessWidget { const _Info({required this.label, required this.value}); final String label; final String value; @override Widget build(BuildContext context) => Row(children: [SizedBox(width: 76, child: Text(label, style: TextStyle(color: Colors.blueGrey.shade600))), Expanded(child: Text(value))]); }
class _LineBadge extends StatelessWidget { const _LineBadge({required this.connected}); final bool connected; @override Widget build(BuildContext context) { final color = connected ? const Color(0xFF059669) : Colors.blueGrey; return Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: color.withValues(alpha: .1), borderRadius: BorderRadius.circular(20)), child: Text(connected ? 'LINE連携済み' : '未連携', style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600))); } }
