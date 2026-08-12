# Changelog

## 1.0.4

- Hosted checkout return-to-merchant: WebView completes on `returnUrl` navigation
  (`intentId`, `sessionId`, `status` query params) and via `qattapay:success` /
  `qattapay:cancel` JS bridge backup
- Treat `status=cancel|failed` on the return URL as cancel
- Docs: clarify that `returnUrl` is required for in-app WebView completion

## 1.0.3

- Add `CheckoutOpenMode.inAppWebView` — load hosted checkout in a full-screen WebView
- Default button/checkout open mode is now in-app WebView (external browser still available)
- Clarify that HTML iframe embedding is unsupported; top-level WebView is fine

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
