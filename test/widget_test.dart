import 'package:business_management_tool/app.dart';
import 'package:business_management_tool/features/auth/application/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('login screen is shown initially', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [authUserProvider.overrideWith((ref) => Stream.value(null))],
      child: const BusinessManagementApp(),
    ));
    await tester.pump();
    expect(find.text('経営管理ツール'), findsOneWidget);
    expect(find.text('ログイン'), findsOneWidget);
  });
  testWidgets('registration link opens the business registration form', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [authUserProvider.overrideWith((ref) => Stream.value(null))],
      child: const BusinessManagementApp(),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.text('事業者アカウントを作成'));
    await tester.pumpAndSettle();
    expect(find.text('事業者情報を登録'), findsOneWidget);
    expect(find.text('事業者名'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.text('事業の今を、ひと目で把握'), findsOneWidget);
  });
}
