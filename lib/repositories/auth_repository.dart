import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  AuthRepository(this._auth);
  final FirebaseAuth _auth;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<UserCredential> signIn({required String email, required String password}) =>
      _auth.signInWithEmailAndPassword(email: email.trim(), password: password);

  Future<UserCredential> createUser({required String email, required String password}) =>
      _auth.createUserWithEmailAndPassword(email: email.trim(), password: password);

  Future<void> sendPasswordResetEmail(String email) =>
      _auth.sendPasswordResetEmail(email: email.trim());

  Future<void> signOut() => _auth.signOut();
}

String authErrorMessage(Object error) {
  if (error is! FirebaseAuthException) return '処理に失敗しました。もう一度お試しください。';
  return switch (error.code) {
    'invalid-email' => 'メールアドレスの形式が正しくありません。',
    'invalid-credential' || 'user-not-found' || 'wrong-password' => 'メールアドレスまたはパスワードが正しくありません。',
    'email-already-in-use' => 'このメールアドレスは既に使用されています。',
    'weak-password' => 'パスワードは6文字以上で設定してください。',
    'too-many-requests' => '試行回数が多すぎます。しばらくしてからお試しください。',
    'network-request-failed' => '通信に失敗しました。ネットワーク接続をご確認ください。',
    _ => '認証処理に失敗しました。もう一度お試しください。',
  };
}
