import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

enum RegistrationStage {
  firebaseAuth('Firebase Auth アカウント作成'),
  userProfile('users/{uid} 作成準備'),
  organization('organizations/{organizationId} 作成準備'),
  member('members/{uid} 作成準備'),
  firestoreCommit('Firestore 一括書き込み'),
  authRollback('Firebase Auth アカウントのロールバック');

  const RegistrationStage(this.label);
  final String label;
}

/// Keeps the original Firebase error and identifies the registration step.
class RegistrationException implements Exception {
  const RegistrationException({
    required this.stage,
    required this.cause,
    required this.stackTrace,
  });

  final RegistrationStage stage;
  final Object cause;
  final StackTrace stackTrace;

  @override
  String toString() => 'RegistrationException(${stage.label}): $cause';
}

class AuthRepository {
  AuthRepository(this._auth, this._firestore);

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) => _auth.signInWithEmailAndPassword(
    email: email.trim(),
    password: password,
  );

  Future<UserCredential> createUser({
    required String email,
    required String password,
    required String organizationName,
    required String ownerName,
  }) async {
    UserCredential credential;
    try {
      _logRegistrationStep(RegistrationStage.firebaseAuth, '開始');
      credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      _logRegistrationStep(RegistrationStage.firebaseAuth, '完了');
    } catch (error, stackTrace) {
      _logRegistrationError(RegistrationStage.firebaseAuth, error, stackTrace);
      throw RegistrationException(
        stage: RegistrationStage.firebaseAuth,
        cause: error,
        stackTrace: stackTrace,
      );
    }

    final user = credential.user;
    if (user == null) {
      final error = StateError('Firebase Auth returned no user.');
      final stackTrace = StackTrace.current;
      _logRegistrationError(RegistrationStage.firebaseAuth, error, stackTrace);
      throw RegistrationException(
        stage: RegistrationStage.firebaseAuth,
        cause: error,
        stackTrace: stackTrace,
      );
    }

    var stage = RegistrationStage.userProfile;
    try {
      // These three documents must be committed atomically. The security rules
      // use getAfter() to validate the other documents in this same batch.
      final organization = _firestore.collection('organizations').doc();
      final batch = _firestore.batch();

      _logRegistrationStep(stage, '追加: users/${user.uid}');
      batch.set(_firestore.collection('users').doc(user.uid), {
        'uid': user.uid,
        'email': email.trim(),
        'displayName': ownerName.trim(),
        'organizationId': organization.id,
        'createdAt': FieldValue.serverTimestamp(),
      });

      stage = RegistrationStage.organization;
      _logRegistrationStep(stage, '追加: organizations/${organization.id}');
      batch.set(organization, {
        'name': organizationName.trim(),
        'ownerUid': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      stage = RegistrationStage.member;
      _logRegistrationStep(
        stage,
        '追加: organizations/${organization.id}/members/${user.uid}',
      );
      batch.set(organization.collection('members').doc(user.uid), {
        'uid': user.uid,
        'email': email.trim(),
        'displayName': ownerName.trim(),
        'role': 'owner',
        'createdAt': FieldValue.serverTimestamp(),
      });

      stage = RegistrationStage.firestoreCommit;
      _logRegistrationStep(
        stage,
        '開始: users/${user.uid} → organizations/${organization.id} '
            '→ members/${user.uid}',
      );
      await batch.commit();
      _logRegistrationStep(stage, '完了');
      return credential;
    } catch (error, stackTrace) {
      _logRegistrationError(stage, error, stackTrace);
      final registrationError = RegistrationException(
        stage: stage,
        cause: error,
        stackTrace: stackTrace,
      );

      try {
        _logRegistrationStep(RegistrationStage.authRollback, '開始');
        await user.delete();
        _logRegistrationStep(RegistrationStage.authRollback, '完了');
      } catch (rollbackError, rollbackStackTrace) {
        _logRegistrationError(
          RegistrationStage.authRollback,
          rollbackError,
          rollbackStackTrace,
        );
      }
      throw registrationError;
    }
  }

  Future<void> sendPasswordResetEmail(String email) =>
      _auth.sendPasswordResetEmail(email: email.trim());
  Future<void> signOut() => _auth.signOut();
}

void _logRegistrationStep(RegistrationStage stage, String detail) {
  debugPrint('[Registration][${stage.label}] $detail');
}

void _logRegistrationError(
  RegistrationStage stage,
  Object error,
  StackTrace stackTrace,
) {
  debugPrint('[Registration][${stage.label}] ERROR: $error');
  if (error is FirebaseAuthException) {
    debugPrint(
      '[Registration][FirebaseAuthException] code=${error.code}, '
      'message=${error.message}',
    );
  } else if (error is FirebaseException) {
    debugPrint(
      '[Registration][FirebaseException] plugin=${error.plugin}, '
      'code=${error.code}, message=${error.message}',
    );
  }
  debugPrintStack(
    label: '[Registration][${stage.label}] stackTrace',
    stackTrace: stackTrace,
  );
}

String authErrorMessage(Object error, {bool debug = kDebugMode}) {
  final registrationError = error is RegistrationException ? error : null;
  final cause = registrationError?.cause ?? error;

  if (debug) {
    final stage = registrationError == null
        ? ''
        : '${registrationError.stage.label}: ';
    if (cause is FirebaseAuthException) {
      return '$stage FirebaseAuthException '
          '(code: ${cause.code}, message: ${cause.message ?? 'なし'})';
    }
    if (cause is FirebaseException) {
      return '$stage FirebaseException '
          '(plugin: ${cause.plugin}, code: ${cause.code}, '
          'message: ${cause.message ?? 'なし'})';
    }
    return '$stage$cause';
  }

  if (cause is! FirebaseAuthException) {
    return '処理に失敗しました。もう一度お試しください。';
  }
  return switch (cause.code) {
    'invalid-email' => 'メールアドレスの形式が正しくありません。',
    'invalid-credential' || 'user-not-found' || 'wrong-password' =>
      'メールアドレスまたはパスワードが正しくありません。',
    'email-already-in-use' => 'このメールアドレスは既に使用されています。',
    'weak-password' => 'パスワードは6文字以上で設定してください。',
    'too-many-requests' => '試行回数が多すぎます。しばらくしてからお試しください。',
    'network-request-failed' => '通信に失敗しました。ネットワーク接続をご確認ください。',
    _ => '認証処理に失敗しました。もう一度お試しください。',
  };
}
