import 'package:cancel_wait/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('login screen is shown initially', (tester) async {
    await tester.pumpWidget(const CancelWaitApp());
    expect(find.text('CancelWait'), findsOneWidget);
    expect(find.text('ログイン'), findsOneWidget);
    expect(find.text('メールアドレス'), findsOneWidget);
  });
}
