# 経営管理ツール

小規模事業者・経営者向けの Flutter Web 管理画面です。フェーズ1では認証、レスポンシブな管理画面、各経営管理機能の画面基盤を提供します。

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

アカウント作成時に `users/{uid}`、`organizations/{organizationId}`、`organizations/{organizationId}/members/{uid}` を一括作成します。ルートの `firestore.rules` を Firebase CLI でデプロイしてから利用してください。
