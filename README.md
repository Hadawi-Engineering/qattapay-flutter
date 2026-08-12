# QattaPay Flutter SDK

Official [QattaPay](https://qatta.sa) SDK for Flutter — add group contribution checkout to your app.

```yaml
dependencies:
  qattapay_flutter: ^1.0.4
```

QattaPay lets groups of people split the cost of a purchase. This package handles:

- **Server-side (Dart)**: creating checkout intents and managing orders with your merchant API key
- **Webhooks**: verifying and parsing events when a session is funded
- **Flutter UI**: official branded `QattaPayButton` + hosted checkout opener

Parity with [`@hadawi/sdk`](https://www.npmjs.com/package/@hadawi/sdk) and [`qattapay/laravel`](https://packagist.org/packages/qattapay/laravel).

---

## Requirements

- Dart ^3.5 / Flutter ≥ 3.24
- A QattaPay merchant account ([qatta.sa](https://qatta.sa))

---

## Architecture (important)

```
Flutter app                         Your backend                      QattaPay
───────────                         ────────────                      ────────
QattaPayButton ──POST /intent──►  QattaPayClient.intents.create ──► POST /intents
     │                                  │
     │◄────────── intentId ─────────────┘
     │
     └── opens hosted checkout ──────────────────────────────────► /checkout/{id}
```

**Never put your merchant API key or webhook secret in the mobile app.** Create intents on your server (Node, Laravel, Dart Frog, etc.), then pass only the `intentId` to Flutter.

Checkout is the **hosted web flow**. Do **not** embed it in an HTML iframe —
framing is blocked. Loading checkout as a **full-page in-app WebView** (or
external browser / Custom Tabs / SFSafariViewController) is supported.

---

## Installation

```yaml
dependencies:
  qattapay_flutter: ^1.0.4
```

```bash
flutter pub get
```

Platform setup for `url_launcher` follows the [official docs](https://pub.dev/packages/url_launcher) (Android queries / iOS LSApplicationQueriesSchemes as needed).

---

## Quick start

### 1 — Create an intent (server)

Using this package on a Dart backend:

```dart
import 'package:qattapay_flutter/qattapay_flutter.dart';

final qattapay = QattaPayClient(
  apiKey: Platform.environment['QATTAPAY_API_KEY']!,
  mode: QattaPayMode.dev, // or live
  webhookSecret: Platform.environment['QATTAPAY_WEBHOOK_SECRET'],
);

final result = await qattapay.intents.create(
  CreateIntentParams(
    itemSnapshot: [
      ItemSnapshot(
        name: 'Luxury Watch',
        price: 150000, // 1500.00 SAR in halalas
        reference: 'watch-001',
      ),
    ],
    totalAmount: 150000,
    currency: 'SAR',
    metadata: {'cart_id': 'abc'},
  ),
);

return {'intentId': result.intent.id};
```

Or use Node (`@hadawi/sdk`) / Laravel (`qattapay/laravel`) — same API.

Amounts are integers in the **smallest currency unit** (halalas for SAR — e.g. `15000` = 150.00 SAR).

### 2 — Mount the branded button (Flutter)

```dart
import 'package:qattapay_flutter/qattapay_flutter.dart';

QattaPayButton(
  mode: QattaPayMode.live,
  variant: QattaPayButtonVariant.primary,
  label: QattaPayButtonLabel.split,
  locale: QattaPayLocale.en,
  openMode: CheckoutOpenMode.inAppWebView, // or externalBrowser
  getIntentId: () async {
    final res = await http.post(Uri.parse('https://api.my-store.com/qattapay/intent'));
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return data['intentId'] as String;
  },
  returnUrl: Uri.parse('myapp://thank-you'),
  onSuccess: (data) => debugPrint('done ${data.intentId}'),
  onError: (err) => debugPrint('QattaPay error: $err'),
)
```

### 3 — Verify webhooks (server)

```dart
final event = qattapay.webhooks.constructEvent(
  requestBodyBytes,
  request.headers['x-qattapay-signature']!,
);

if (event.type == WebhookEventType.orderFunded) {
  final orderId = event.payload.orderId;
  if (orderId != null) {
    await qattapay.orders.fulfill(orderId);
  }
}
```

Event types: `order.funded`, `order.partially_funded`, `order.cancelled`, `order.expired`.

---

## API surface

### `QattaPayClient` (server)

| API | Methods |
| --- | --- |
| `intents` | `create`, `get` |
| `orders` | `list`, `get`, `fulfill`, `deliver` |
| `webhooks` | `verifySignature`, `constructEvent` |

Config: `apiKey`, `mode` (`dev` \| `live`), optional `baseUrl` (disables host fallback), optional `webhookSecret`.

Host fallback when using `mode`: `qatta.sa` → `hadawi.sa` (same as the Node / Laravel SDKs).

### `QattaPayButton` / `QattaPayCheckout` (mobile)

| Option | Values |
| --- | --- |
| `variant` | `primary`, `dark`, `light`, `outline` |
| `size` | `sm`, `md`, `lg` |
| `label` | `split`, `splitCart`, `pay` (or `labelText`) |
| `locale` | `en`, `ar` |
| `showBadge` / `showIcon` | booleans |
| `openMode` | `inAppWebView` (default) or `externalBrowser` |
| `returnUrl` | deep link / https URL — hosted checkout redirects here after success with `intentId`, `sessionId`, `status` (required for in-app WebView completion) |

Imperative open:

```dart
final checkout = QattaPayCheckout(mode: QattaPayMode.live);
await checkout.open(
  intentId,
  context: context, // required for inAppWebView
  mode: CheckoutOpenMode.inAppWebView,
  returnUrl: Uri.parse('myapp://thank-you'),
  onSuccess: (data) {},
);
```

After payment, hosted checkout navigates to your `returnUrl` with
`intentId`, `sessionId`, and `status=success|cancel|failed`. The in-app
WebView intercepts that navigation (and a `qattapay:success` bridge backup)
and closes, calling `onSuccess` / `onCancel`.

---

## Exceptions

- `QattaPayApiException` — HTTP / API errors (`status`, `code`)
- `QattaPayWebhookException` — invalid signature or payload

---

## Links

- Docs: https://qatta.sa/docs/sdk
- Node SDK: https://www.npmjs.com/package/@hadawi/sdk
- Laravel SDK: https://packagist.org/packages/qattapay/laravel
- Issues: https://github.com/Hadawi-Engineering/qattapay-flutter/issues

## License

MIT © Hadawi Engineering
