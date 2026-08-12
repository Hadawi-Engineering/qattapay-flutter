/// Thrown on HTTP / API errors from the QattaPay REST API.
class QattaPayApiException implements Exception {
  QattaPayApiException(this.message, {this.status = 0, this.code = ''});

  final String message;
  final int status;
  final String code;

  @override
  String toString() =>
      'QattaPayApiException($status${code.isEmpty ? '' : ', $code'}): $message';
}

/// Thrown when webhook signature verification fails or the payload is invalid.
class QattaPayWebhookException implements Exception {
  QattaPayWebhookException(this.message);

  final String message;

  @override
  String toString() => 'QattaPayWebhookException: $message';
}
