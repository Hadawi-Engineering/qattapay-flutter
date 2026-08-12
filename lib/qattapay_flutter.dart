/// Official QattaPay Flutter SDK.
///
/// - **Server / backend (Dart):** [QattaPayClient] — intents, orders, webhooks.
///   Keep your merchant API key on the server. Never ship it in a mobile app.
/// - **Mobile UI:** [QattaPayButton] / [QattaPayCheckout] — open hosted checkout
///   after your backend returns an `intentId`.
library;

export 'src/checkout/qattapay_button.dart';
export 'src/checkout/qattapay_checkout.dart';
export 'src/checkout/checkout_webview.dart';
export 'src/client/qattapay_client.dart';
export 'src/env/hosts.dart' show QattaPayMode;
export 'src/exceptions/exceptions.dart';
export 'src/types/types.dart';
