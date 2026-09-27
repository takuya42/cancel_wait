import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../organization/application/organization_providers.dart';
import '../data/finance_repository.dart';
import '../domain/finance_entry.dart';

final financeRepositoryProvider = Provider(
  (ref) => FinanceRepository(ref.watch(firestoreProvider)),
);

Stream<List<FinanceEntry>> _watch(Ref ref, EntryType type) async* {
  final repository = ref.watch(financeRepositoryProvider);

  // Await the dependency instead of branching on its AsyncValue. This lets
  // Riverpod cancel/restart this subscription when the organization changes,
  // without creating a synchronous replacement stream during widget build.
  final organizationId = await ref.watch(organizationIdProvider.future);
  if (organizationId == null) {
    yield const [];
    return;
  }

  yield* repository.watchEntries(organizationId, type);
}

final salesProvider = StreamProvider<List<FinanceEntry>>(
  (ref) => _watch(ref, EntryType.sale),
);
final expensesProvider = StreamProvider<List<FinanceEntry>>(
  (ref) => _watch(ref, EntryType.expense),
);
