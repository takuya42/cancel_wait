import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_providers.dart';

final firestoreProvider = Provider<FirebaseFirestore>(
  (ref) => FirebaseFirestore.instance,
);

/// The organization id always comes from the signed-in user's protected profile.
final organizationIdProvider = StreamProvider<String?>((ref) async* {
  if (ref.watch(testModeProvider)) {
    yield null;
    return;
  }

  final firestore = ref.watch(firestoreProvider);

  // Waiting on the provider's future keeps the auth -> organization transition
  // inside Riverpod's asynchronous dependency lifecycle. In particular, this
  // avoids synchronously replacing a stream while a consumer is building.
  final user = await ref.watch(authUserProvider.future);
  if (user == null) {
    yield null;
    return;
  }

  yield* firestore
      .collection('users')
      .doc(user.uid)
      .snapshots()
      .map((snapshot) => snapshot.data()?['organizationId'] as String?);
});
