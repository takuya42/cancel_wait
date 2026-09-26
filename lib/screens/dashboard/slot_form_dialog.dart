import 'package:flutter/material.dart';

import '../../models/available_slot.dart';

class SlotFormDialog extends StatefulWidget {
  const SlotFormDialog({this.initial, super.key});

  final AvailableSlot? initial;

  @override
  State<SlotFormDialog> createState() => _SlotFormDialogState();
}

class _SlotFormDialogState extends State<SlotFormDialog> {
  final formKey = GlobalKey<FormState>();
  late DateTime date;
  late TimeOfDay start;
  late TimeOfDay end;
  late TextEditingController menu;
  late TextEditingController staff;
  late TextEditingController capacity;
  late TextEditingController memo;

  @override
  void initState() {
    super.initState();
    final slot = widget.initial;
    date = slot?.startAt ?? DateTime.now().add(const Duration(days: 1));
    start = TimeOfDay.fromDateTime(slot?.startAt ?? DateTime(2020, 1, 1, 10));
    end = TimeOfDay.fromDateTime(slot?.endAt ?? DateTime(2020, 1, 1, 11));
    menu = TextEditingController(text: slot?.menuName);
    staff = TextEditingController(text: slot?.staffName);
    capacity = TextEditingController(text: '${slot?.capacity ?? 1}');
    memo = TextEditingController(text: slot?.memo);
  }

  @override
  void dispose() {
    for (final controller in [menu, staff, capacity, memo]) {
      controller.dispose();
    }
    super.dispose();
  }

  String _formatTime(TimeOfDay time) =>
      '${time.hour.toString().padLeft(2, '0')}:'
      '${time.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initial == null ? '空き枠を登録' : '空き枠を編集'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('日付'),
                  subtitle: Text('${date.year}/${date.month}/${date.day}'),
                  trailing: const Icon(Icons.calendar_month),
                  onTap: _selectDate,
                ),
                Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('開始'),
                        subtitle: Text(_formatTime(start)),
                        onTap: () => _selectTime(isStart: true),
                      ),
                    ),
                    Expanded(
                      child: ListTile(
                        title: const Text('終了'),
                        subtitle: Text(_formatTime(end)),
                        onTap: () => _selectTime(isStart: false),
                      ),
                    ),
                  ],
                ),
                TextFormField(
                  controller: menu,
                  decoration: const InputDecoration(labelText: 'メニュー名'),
                  validator: _required,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: staff,
                  decoration: const InputDecoration(labelText: '担当者名'),
                  validator: _required,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: capacity,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: '募集人数'),
                  validator: (value) => (int.tryParse(value ?? '') ?? 0) < 1
                      ? '1以上を入力してください'
                      : null,
                ),
                const SizedBox(height: 12),
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
      initialDate: date,
    );
    if (selected != null) setState(() => date = selected);
  }

  Future<void> _selectTime({required bool isStart}) async {
    final selected = await showTimePicker(
      context: context,
      initialTime: isStart ? start : end,
    );
    if (selected != null) {
      setState(() {
        if (isStart) {
          start = selected;
        } else {
          end = selected;
        }
      });
    }
  }

  void _save() {
    if (!formKey.currentState!.validate()) return;
    final startAt = DateTime(
      date.year,
      date.month,
      date.day,
      start.hour,
      start.minute,
    );
    final endAt = DateTime(
      date.year,
      date.month,
      date.day,
      end.hour,
      end.minute,
    );
    if (!endAt.isAfter(startAt)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('終了時間は開始時間より後にしてください')),
      );
      return;
    }

    final oldSlot = widget.initial;
    final newCapacity = int.parse(capacity.text);
    Navigator.pop(
      context,
      AvailableSlot(
        id: oldSlot?.id ?? '',
        startAt: startAt,
        endAt: endAt,
        menuName: menu.text,
        staffName: staff.text,
        capacity: newCapacity,
        remainingCapacity: oldSlot == null
            ? newCapacity
            : (oldSlot.remainingCapacity + (newCapacity - oldSlot.capacity))
                  .clamp(0, newCapacity)
                  .toInt(),
        memo: memo.text,
        status: oldSlot?.status ?? SlotStatus.open,
        createdAt: oldSlot?.createdAt ?? DateTime.now(),
      ),
    );
  }

  String? _required(String? value) => value == null || value.trim().isEmpty
      ? '入力してください'
      : null;
}
