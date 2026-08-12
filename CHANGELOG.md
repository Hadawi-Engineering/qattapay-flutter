# Changelog

## 1.0.2

- Use the official QattaPay brand mark on `QattaPayButton` (bundled asset)

## 1.0.1

- Docs/comments: describe iframe blocking without naming the payment provider

## 1.0.0

- Initial release of the official QattaPay Flutter SDK
- Server client: intents, orders, webhook verification (HMAC-SHA256)
- Hosted checkout opener via Custom Tabs / SFSafariViewController (`url_launcher`)
- Branded `QattaPayButton` widget (variants, sizes, EN/AR labels)
- Multi-host API fallback (`qatta.sa` → `hadawi.sa`) matching `@hadawi/sdk` / `qattapay/laravel`
