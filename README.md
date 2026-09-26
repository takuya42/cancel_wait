# cancel_wait

CancelWait の店舗向け Flutter Web 管理画面です。

## Firebase Web 設定

`lib/firebase_options.dart` は環境ごとの差分を `--dart-define` から読み込みます。Firebase Console の Web アプリ設定を次のキーで渡してください。

```sh
flutter run -d chrome \
  --dart-define=FIREBASE_WEB_API_KEY=... \
  --dart-define=FIREBASE_WEB_APP_ID=... \
  --dart-define=FIREBASE_MESSAGING_SENDER_ID=... \
  --dart-define=FIREBASE_PROJECT_ID=... \
  --dart-define=FIREBASE_AUTH_DOMAIN=... \
  --dart-define=FIREBASE_STORAGE_BUCKET=...
```

Firestore には `shops/{shopId}` と `users/{uid}` が作成されます。`users/{uid}.shopId` が、ログインユーザーがアクセス可能な店舗を決定します。ルートの `firestore.rules` を Firebase CLI でデプロイしてから利用してください。

テストログインは Firebase Authentication と Firestore を一切使用せず、メモリ上のデモ状態と既存ダミーデータを使用します。リリースビルドでは自動で非表示になります。開発ビルドでも無効にする場合は `lib/config/app_config.dart` の `enableDemoLogin` を変更してください。

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
