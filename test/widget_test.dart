import 'package:cancel_wait/app.dart';
import 'package:cancel_wait/providers/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('login screen is shown initially', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [authUserProvider.overrideWith((ref) => Stream.value(null))],
      child: const CancelWaitApp(),
    ));
    await tester.pump();
    expect(find.text('CancelWait'), findsOneWidget);
    expect(find.text('ログイン'), findsOneWidget);
    expect(find.text('メールアドレス'), findsOneWidget);
  });

  testWidgets('registration link opens the registration form', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authUserProvider.overrideWith((ref) => Stream.value(null)),
        ],
        child: const CancelWaitApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('店舗アカウントを作成'));
    await tester.pumpAndSettle();

    expect(find.text('店舗情報を登録'), findsOneWidget);
    expect(find.text('担当者名'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.text('店舗管理画面にログイン'), findsOneWidget);
  });
}
