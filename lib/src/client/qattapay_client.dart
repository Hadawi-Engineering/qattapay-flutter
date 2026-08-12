import '../env/hosts.dart';
import 'http_client.dart';
import 'intents_api.dart';
import 'orders_api.dart';
import 'webhooks_api.dart';

/// Main server-side QattaPay SDK client.
///
/// Initialise once (e.g. at app / server startup) and reuse.
///
/// **Security:** only use this with a merchant API key on a trusted backend
/// (Dart Frog, Shelf, Cloud Function, etc.). Never embed `apiKey` /
/// `webhookSecret` in a shipped mobile app binary.
///
/// ```dart
/// final qattapay = QattaPayClient(
///   apiKey: Platform.environment['QATTAPAY_API_KEY']!,
///   mode: QattaPayMode.live,
///   webhookSecret: Platform.environment['QATTAPAY_WEBHOOK_SECRET'],
/// );
///
/// final result = await qattapay.intents.create(
///   CreateIntentParams(
///     itemSnapshot: [
///       ItemSnapshot(name: 'Luxury Watch', price: 150000),
///     ],
///     totalAmount: 150000,
///   ),
/// );
/// ```
class QattaPayClient {
  QattaPayClient({
    required String apiKey,
    QattaPayMode? mode,
    String? baseUrl,
    String? webhookSecret,
    QattaPayHttp? http,
  }) {
    if (baseUrl == null && mode == null) {
      throw ArgumentError(
        '[QattaPayClient] `mode` is required ("dev" | "live"). '
        'Pass mode: QattaPayMode.dev for testing or QattaPayMode.live for production.',
      );
    }

    final hosts = baseUrl != null
        ? [baseUrl.replaceAll(RegExp(r'/$'), '')]
        : resolveApiHosts(mode!);

    _http = http ?? QattaPayHttp(baseUrls: hosts, apiKey: apiKey);
    intents = IntentsApi(_http);
    orders = OrdersApi(_http);
    webhooks = WebhooksApi(webhookSecret ?? '');
  }

  late final QattaPayHttp _http;

  /// Create and inspect checkout intents.
  late final IntentsApi intents;

  /// List, view, and update orders once they are funded.
  late final OrdersApi orders;

  /// Verify and parse incoming webhook events from QattaPay.
  late final WebhooksApi webhooks;

  /// Close the underlying HTTP client when you no longer need this instance.
  void close() => _http.close();
}
