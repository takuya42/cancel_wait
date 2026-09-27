import 'package:flutter/material.dart';

import '../../../core/utils/formatters.dart';
import '../domain/finance_entry.dart';

class FinanceEntryInput {
  const FinanceEntryInput(this.date, this.amount, this.category, this.memo);
  final DateTime date;
  final int amount;
  final String category;
  final String memo;
}

Future<FinanceEntryInput?> showFinanceEntryDialog(
  BuildContext context, {
  required EntryType type,
  FinanceEntry? entry,
}) => showDialog<FinanceEntryInput>(
  context: context,
  builder: (_) => _FinanceEntryDialog(type: type, entry: entry),
);

class _FinanceEntryDialog extends StatefulWidget {
  const _FinanceEntryDialog({required this.type, this.entry});
  final EntryType type;
  final FinanceEntry? entry;

  @override
  State<_FinanceEntryDialog> createState() => _FinanceEntryDialogState();
}

class _FinanceEntryDialogState extends State<_FinanceEntryDialog> {
  final _key = GlobalKey<FormState>();
  late DateTime _date;
  late final TextEditingController _amount;
  late final TextEditingController _category;
  late final TextEditingController _memo;

  @override
  void initState() {
    super.initState();
    _date = widget.entry?.date ?? DateTime.now();
    _amount = TextEditingController(text: widget.entry?.amount.toString() ?? '');
    _category = TextEditingController(text: widget.entry?.category ?? '');
    _memo = TextEditingController(text: widget.entry?.memo ?? '');
  }

  @override
  void dispose() {
    _amount.dispose();
    _category.dispose();
    _memo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final label = widget.type == EntryType.sale ? '売上' : '経費';
    return AlertDialog(
      title: Text('${widget.entry == null ? '新しい' : ''}$label${widget.entry == null ? 'を登録' : 'を編集'}'),
      content: SizedBox(
        width: 460,
        child: Form(
          key: _key,
          child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () async {
                  final selected = await pickBusinessDate(context, _date);
                  if (selected != null) setState(() => _date = selected);
                },
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: '日付', prefixIcon: Icon(Icons.calendar_today_outlined)),
                  child: Text(formatDate(_date)),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amount,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: '金額', prefixText: '¥ '),
                validator: (value) {
                  final amount = int.tryParse((value ?? '').replaceAll(',', ''));
                  return amount == null || amount <= 0 ? '1円以上の金額を入力してください。' : null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _category,
                decoration: const InputDecoration(labelText: 'カテゴリ', hintText: '例：商品売上'),
                validator: (value) => value == null || value.trim().isEmpty ? 'カテゴリを入力してください。' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(controller: _memo, maxLines: 3, decoration: const InputDecoration(labelText: 'メモ（任意）', alignLabelWithHint: true)),
            ]),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('キャンセル')),
        FilledButton(
          onPressed: () {
            if (!_key.currentState!.validate()) return;
            Navigator.pop(context, FinanceEntryInput(_date, int.parse(_amount.text.replaceAll(',', '')), _category.text, _memo.text));
          },
          child: Text(widget.entry == null ? '登録する' : '更新する'),
        ),
      ],
    );
  }
}
