import 'package:flutter/material.dart';
import '../../transactions/domain/finance_entry.dart';
import '../../transactions/presentation/finance_list_screen.dart';

class ExpensesScreen extends StatelessWidget {
  const ExpensesScreen({super.key});
  @override
  Widget build(BuildContext context) => const FinanceListScreen(type: EntryType.expense);
}
