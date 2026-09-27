import 'package:business_management_tool/features/auth/data/auth_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('authErrorMessage', () {
    test('debug message exposes Firebase Auth code and message', () {
      final error = FirebaseAuthException(
        code: 'operation-not-allowed',
        message: 'Email/password sign-in is disabled.',
      );

      expect(
        authErrorMessage(error, debug: true),
        contains('code: operation-not-allowed'),
      );
      expect(authErrorMessage(error, debug: true), contains('is disabled'));
    });

    test('debug message exposes Firestore stage, plugin, code, and message', () {
      final error = RegistrationException(
        stage: RegistrationStage.firestoreCommit,
        cause: FirebaseException(
          plugin: 'cloud_firestore',
          code: 'permission-denied',
          message: 'Missing or insufficient permissions.',
        ),
        stackTrace: StackTrace.empty,
      );

      final message = authErrorMessage(error, debug: true);
      expect(message, contains('Firestore 一括書き込み'));
      expect(message, contains('plugin: cloud_firestore'));
      expect(message, contains('code: permission-denied'));
      expect(message, contains('Missing or insufficient permissions'));
    });

    test('release message does not expose Firestore details', () {
      final error = FirebaseException(
        plugin: 'cloud_firestore',
        code: 'permission-denied',
        message: 'sensitive detail',
      );

      expect(
        authErrorMessage(error, debug: false),
        '処理に失敗しました。もう一度お試しください。',
      );
    });
  });
}
