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

## 開発用テストログイン

デバッグ／プロファイルビルドで `TEST_LOGIN_EMAIL` と
`TEST_LOGIN_PASSWORD` の両方を指定すると、ログイン画面に「テストログイン」
ボタンが表示されます。認証情報はソースコードには保存せず、次のように起動時に
渡してください。

```sh
flutter run -d chrome \
  --dart-define=TEST_LOGIN_EMAIL=test@example.com \
  --dart-define=TEST_LOGIN_PASSWORD='your-test-password' \
  --dart-define=FIREBASE_WEB_API_KEY=... \
  --dart-define=FIREBASE_WEB_APP_ID=... \
  --dart-define=FIREBASE_MESSAGING_SENDER_ID=... \
  --dart-define=FIREBASE_PROJECT_ID=... \
  --dart-define=FIREBASE_AUTH_DOMAIN=... \
  --dart-define=FIREBASE_STORAGE_BUCKET=...
```

テストユーザーを初めて用意するときは、上記のメールアドレスとパスワードを使い、
通常の「事業者アカウントを作成」画面から一度アカウントを作成してください。
これにより Authentication のユーザーと同時に `users/{uid}`、
`organizations/{organizationId}`、`organizations/{organizationId}/members/{uid}`
が作成されます。Firebase Console の Authentication だけでユーザーを追加すると、
必要な組織データが作られないため使用しないでください。

両方の値が設定されていない場合、ボタンは表示されません。また、誤って値を指定しても
リリースビルド（`--release`）では常に非表示になります。`--dart-define` の値はビルド成果物に
含まれ得るため、本番用の認証情報を渡さず、テスト専用アカウントだけを使用してください。
