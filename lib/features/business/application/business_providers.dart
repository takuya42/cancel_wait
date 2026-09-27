import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../organization/application/organization_providers.dart';
import '../data/business_repository.dart';
import '../domain/business_profile.dart';

final businessRepositoryProvider = Provider(
  (ref) => BusinessRepository(ref.watch(firestoreProvider)),
);
final businessProfileProvider = StreamProvider<BusinessProfile?>((ref) async* {
  final repository = ref.watch(businessRepositoryProvider);
  final organizationId = await ref.watch(organizationIdProvider.future);
  if (organizationId == null) {
    yield null;
    return;
  }

  yield* repository.watch(organizationId);
});
