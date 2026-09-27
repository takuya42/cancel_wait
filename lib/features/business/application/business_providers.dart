import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../organization/application/organization_providers.dart';
import '../data/business_repository.dart';
import '../domain/business_profile.dart';
final businessRepositoryProvider = Provider((ref) => BusinessRepository(ref.watch(firestoreProvider)));
final businessProfileProvider = StreamProvider<BusinessProfile?>((ref) { final organization = ref.watch(organizationIdProvider); return organization.when(data: (id) => id == null ? Stream.value(null) : ref.watch(businessRepositoryProvider).watch(id), loading: () => const Stream.empty(), error: (e,s) => Stream.error(e,s)); });
