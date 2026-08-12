import '../types/types.dart';
import 'http_client.dart';

/// Wraps the `/intents` API endpoints.
class IntentsApi {
  IntentsApi(this._http);

  final QattaPayHttp _http;

  /// Create a checkout intent.
  ///
  /// Returns `{ intent, redirectUrl }` — send [CreateIntentResponse.redirectUrl]
  /// to the browser / [QattaPayCheckout], or pass `intent.id` to the Flutter button.
  ///
  /// Amounts are in the currency's smallest unit (halalas for SAR).
  Future<CreateIntentResponse> create(CreateIntentParams params) {
    return _http.request(
      '/intents',
      method: 'POST',
      body: params.toJson(),
      parse: CreateIntentResponse.fromJson,
    );
  }

  /// Fetch details of an existing intent.
  Future<CheckoutIntent> get(String intentId) async {
    final res = await _http.request<JsonMap>(
      '/intents/${Uri.encodeComponent(intentId)}',
    );
    return CheckoutIntent.fromJson(res['intent'] as JsonMap);
  }
}
