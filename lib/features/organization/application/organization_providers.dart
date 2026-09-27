import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_providers.dart';

final firestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);

/// The organization id always comes from the signed-in user's protected profile.
final organizationIdProvider = StreamProvider<String?>((ref) {
  if (ref.watch(testModeProvider)) return Stream.value(null);
  final user = ref.watch(authUserProvider).value;
  if (user == null) return Stream.value(null);
  return ref
      .watch(firestoreProvider)
      .collection('users')
      .doc(user.uid)
      .snapshots()
      .map((snapshot) => snapshot.data()?['organizationId'] as String?);
});
