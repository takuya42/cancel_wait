import 'package:cancel_wait/app.dart';
import 'package:cancel_wait/providers/auth_providers.dart';
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
}
