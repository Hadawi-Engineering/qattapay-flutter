import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../exceptions/exceptions.dart';
import '../types/types.dart';

/// Utilities for verifying and parsing incoming QattaPay webhook events.
///
/// QattaPay signs every outgoing webhook POST with HMAC-SHA256 over the raw
/// JSON body using your `webhookSecret`. The hex digest is sent in the
/// `X-QattaPay-Signature` request header.
class WebhooksApi {
  WebhooksApi(this._webhookSecret);

  final String _webhookSecret;

  /// Verify the `X-QattaPay-Signature` header against the raw request body.
  bool verifySignature(List<int> rawBody, String signature) {
    if (_webhookSecret.isEmpty) {
      throw QattaPayWebhookException(
        'webhookSecret is required to verify webhook signatures. '
        'Pass it as webhookSecret in QattaPayClient config.',
      );
    }
    if (signature.isEmpty) return false;

    final digest = Hmac(sha256, utf8.encode(_webhookSecret)).convert(rawBody);
    final expected = digest.toString().toLowerCase();
    final received = signature.toLowerCase();

    if (expected.length != received.length) return false;

    // Constant-time compare
    var diff = 0;
    for (var i = 0; i < expected.length; i++) {
      diff |= expected.codeUnitAt(i) ^ received.codeUnitAt(i);
    }
    return diff == 0;
  }

  /// Verify the signature and parse the raw body into a typed event.
  ///
  /// **Important:** pass the raw request body bytes — do not re-encode JSON
  /// before verification.
  QattaPayWebhookEvent constructEvent(List<int> rawBody, String signature) {
    if (!verifySignature(rawBody, signature)) {
      throw QattaPayWebhookException('Invalid webhook signature');
    }

    final decoded = jsonDecode(utf8.decode(rawBody));
    if (decoded is! JsonMap || decoded['event'] is! String) {
      throw QattaPayWebhookException('Invalid webhook payload');
    }

    final payload = QattaPayWebhookPayload.fromJson(decoded);
    return QattaPayWebhookEvent(type: payload.event, payload: payload);
  }
}
