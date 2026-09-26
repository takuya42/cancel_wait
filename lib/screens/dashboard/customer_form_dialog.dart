import 'package:flutter/material.dart';

import '../../models/waiting_customer.dart';

class CustomerFormDialog extends StatefulWidget {
  const CustomerFormDialog({this.initial, super.key});

  final WaitingCustomer? initial;

  @override
  State<CustomerFormDialog> createState() => _CustomerFormDialogState();
}

class _CustomerFormDialogState extends State<CustomerFormDialog> {
  final formKey = GlobalKey<FormState>();
  late DateTime preferredDate;
  late TextEditingController name;
  late TextEditingController start;
  late TextEditingController end;
  late TextEditingController menu;
  late TextEditingController phone;
  late TextEditingController memo;
  late bool lineLinked;

  @override
  void initState() {
    super.initState();
    final customer = widget.initial;
    preferredDate =
        customer?.preferredDate ?? DateTime.now().add(const Duration(days: 1));
    name = TextEditingController(text: customer?.name);
    start = TextEditingController(
      text: customer?.preferredStartTime ?? '10:00',
    );
    end = TextEditingController(
      text: customer?.preferredEndTime ?? '18:00',
    );
    menu = TextEditingController(text: customer?.menuName);
    phone = TextEditingController(text: customer?.phone);
    memo = TextEditingController(text: customer?.memo);
    lineLinked = customer?.lineLinked ?? false;
  }

  @override
  void dispose() {
    for (final controller in [name, start, end, menu, phone, memo]) {
      controller.dispose();
    }
    super.dispose();
  }

  String? _required(String? value) => value == null || value.trim().isEmpty
      ? '入力してください'
      : null;

  String? _validTime(String? value) =>
      RegExp(r'^([01]\d|2[0-3]):[0-5]\d$').hasMatch(value ?? '')
      ? null
      : '例: 09:30';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initial == null ? '顧客を登録' : '顧客を編集'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: name,
                  decoration: const InputDecoration(labelText: '顧客名'),
                  validator: _required,
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('希望日'),
                  subtitle: Text(
                    '${preferredDate.year}/${preferredDate.month}/${preferredDate.day}',
                  ),
                  onTap: _selectDate,
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: start,
                        decoration: const InputDecoration(
                          labelText: '希望開始 (HH:mm)',
                        ),
                        validator: _validTime,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: end,
                        decoration: const InputDecoration(
                          labelText: '希望終了 (HH:mm)',
                        ),
                        validator: _validTime,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: menu,
                  decoration: const InputDecoration(labelText: '希望メニュー'),
                  validator: _required,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: phone,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: '電話番号（任意）'),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('LINE連携済み'),
                  value: lineLinked,
                  onChanged: (value) => setState(() => lineLinked = value),
                ),
                TextFormField(
                  controller: memo,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'メモ（任意）'),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('キャンセル'),
        ),
        FilledButton(onPressed: _save, child: const Text('保存')),
      ],
    );
  }

  Future<void> _selectDate() async {
    final selected = await showDatePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
      initialDate: preferredDate,
    );
    if (selected != null) {
      setState(() => preferredDate = selected);
    }
  }

  void _save() {
    if (!formKey.currentState!.validate()) return;
    final initial = widget.initial;
    Navigator.pop(
      context,
      WaitingCustomer(
        id: initial?.id ?? '',
        name: name.text,
        preferredDate: preferredDate,
        preferredStartTime: start.text,
        preferredEndTime: end.text,
        menuName: menu.text,
        phone: phone.text,
        lineLinked: lineLinked,
        memo: memo.text,
        status: initial?.status ?? WaitingStatus.waiting,
        notifiedAt: initial?.notifiedAt,
        createdAt: initial?.createdAt ?? DateTime.now(),
      ),
    );
  }
}
