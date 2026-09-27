import 'package:business_management_tool/app.dart';
import 'package:business_management_tool/features/auth/application/auth_providers.dart';
import 'package:business_management_tool/features/auth/application/test_login_config.dart';
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
    expect(find.text('テストログイン'), findsOneWidget);
  });

  testWidgets('test login opens the dashboard without a Firebase user',
      (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        authUserProvider.overrideWith((ref) => Stream.value(null)),
        testLoginConfigProvider.overrideWithValue(
          const TestLoginConfig(
            isDebugMode: true,
            enabledByEnvironment: true,
          ),
        ),
      ],
      child: const BusinessManagementApp(),
    ));
    await tester.pump();
    expect(find.text('テストログイン'), findsOneWidget);
    expect(find.text('または'), findsOneWidget);

    await tester.tap(find.byKey(const Key('test-login-button')));
    await tester.pumpAndSettle();

    expect(find.text('ダッシュボード'), findsWidgets);
    expect(find.text('売上'), findsWidgets);
    expect(find.text('経費'), findsWidgets);
    expect(find.text('レポート'), findsWidgets);
    expect(find.text('事業者情報'), findsWidgets);
    expect(find.text('料金プラン'), findsWidgets);
    expect(find.text('設定'), findsWidgets);
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
