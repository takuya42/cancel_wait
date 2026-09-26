import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/shop.dart';
import '../repositories/auth_repository.dart';
import '../repositories/shop_repository.dart';

final authRepositoryProvider = Provider((ref) => AuthRepository(FirebaseAuth.instance));
final shopRepositoryProvider = Provider((ref) => ShopRepository(FirebaseFirestore.instance));
final authUserProvider = StreamProvider<User?>((ref) => ref.watch(authRepositoryProvider).authStateChanges());

class DemoModeNotifier extends Notifier<bool> {
  @override bool build() => false;
  void enter() => state = true;
  void leave() => state = false;
}

final isDemoModeProvider = NotifierProvider<DemoModeNotifier, bool>(DemoModeNotifier.new);

class RegistrationNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void start() => state = true;
  void finish() => state = false;
}

/// Keeps the router on the registration form while the newly authenticated
/// user's Firestore records are being created.
final registrationInProgressProvider =
    NotifierProvider<RegistrationNotifier, bool>(RegistrationNotifier.new);

enum SessionStatus { loading, signedOut, firebase, demo }

final sessionStatusProvider = Provider<SessionStatus>((ref) {
  if (ref.watch(isDemoModeProvider)) return SessionStatus.demo;
  return ref.watch(authUserProvider).when(
    data: (user) => user == null ? SessionStatus.signedOut : SessionStatus.firebase,
    loading: () => SessionStatus.loading,
    error: (_, _) => SessionStatus.signedOut,
  );
});

final shopIdProvider = StreamProvider<String?>((ref) {
  if (ref.watch(isDemoModeProvider)) return Stream.value('demo-shop');
  final user = ref.watch(authUserProvider).value;
  if (user == null) return Stream.value(null);
  return ref.watch(shopRepositoryProvider).watchShopId(user.uid);
});

final shopProvider = StreamProvider<Shop?>((ref) {
  if (ref.watch(isDemoModeProvider)) {
    return Stream.value(const Shop(id: 'demo-shop', name: 'デモ店舗', ownerUid: 'demo-user', ownerName: 'デモ担当者', email: 'demo@example.com', lineConnected: false));
  }
  final shopId = ref.watch(shopIdProvider).value;
  if (shopId == null) return Stream.value(null);
  return ref.watch(shopRepositoryProvider).watchShop(shopId);
});

final authControllerProvider = Provider(AuthController.new);

class AuthController {
  AuthController(this.ref);
  final Ref ref;

  Future<void> login(String email, String password) async {
    ref.read(isDemoModeProvider.notifier).leave();
    await ref.read(authRepositoryProvider).signIn(email: email, password: password);
  }

  void demoLogin() => ref.read(isDemoModeProvider.notifier).enter();

  Future<void> logout() async {
    if (ref.read(isDemoModeProvider)) {
      ref.read(isDemoModeProvider.notifier).leave();
    } else {
      await ref.read(authRepositoryProvider).signOut();
    }
  }
}
