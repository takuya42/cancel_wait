import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../organization/application/organization_providers.dart';
import '../data/finance_repository.dart';
import '../domain/finance_entry.dart';

final financeRepositoryProvider = Provider((ref) => FinanceRepository(ref.watch(firestoreProvider)));

Stream<List<FinanceEntry>> _watch(Ref ref, EntryType type) {
  final organization = ref.watch(organizationIdProvider);
  return organization.when(
    data: (id) => id == null ? Stream.value(const []) : ref.watch(financeRepositoryProvider).watchEntries(id, type),
    loading: () => const Stream.empty(),
    error: (error, stack) => Stream.error(error, stack),
  );
}

final salesProvider = StreamProvider<List<FinanceEntry>>((ref) => _watch(ref, EntryType.sale));
final expensesProvider = StreamProvider<List<FinanceEntry>>((ref) => _watch(ref, EntryType.expense));
