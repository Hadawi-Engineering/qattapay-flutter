# QattaPay Flutter example

Minimal storefront showing `QattaPayButton`.

```bash
cd example
flutter pub get
flutter run
```

Replace `getIntentId` with a call to your backend that creates an intent via
`QattaPayClient` (or `@hadawi/sdk` / `qattapay/laravel`).
