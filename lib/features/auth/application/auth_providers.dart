import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_repository.dart';

final authRepositoryProvider = Provider(
  (ref) => AuthRepository(FirebaseAuth.instance, FirebaseFirestore.instance),
);
final authUserProvider = StreamProvider<User?>(
  (ref) => ref.watch(authRepositoryProvider).authStateChanges(),
);

class RegistrationNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void start() => state = true;
  void finish() => state = false;
}

final registrationInProgressProvider =
    NotifierProvider<RegistrationNotifier, bool>(RegistrationNotifier.new);

enum SessionStatus { loading, signedOut, authenticated }

final sessionStatusProvider = Provider<SessionStatus>((ref) {
  return ref.watch(authUserProvider).when(
    data: (user) => user == null
        ? SessionStatus.signedOut
        : SessionStatus.authenticated,
    loading: () => SessionStatus.loading,
    error: (_, _) => SessionStatus.signedOut,
  );
});

final authControllerProvider = Provider(AuthController.new);

class AuthController {
  AuthController(this.ref);
  final Ref ref;

  Future<void> login(String email, String password) => ref
      .read(authRepositoryProvider)
      .signIn(email: email, password: password);
  Future<void> logout() => ref.read(authRepositoryProvider).signOut();
}
