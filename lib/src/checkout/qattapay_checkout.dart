import 'package:url_launcher/url_launcher.dart';

import '../env/hosts.dart';
import '../types/types.dart';
import 'button_theme.dart';

/// Mobile-side QattaPay checkout controller.
///
/// Opens the hosted web checkout. Do **not** embed checkout in a framed
/// WebView — the payment page sends `X-Frame-Options: deny`.
///
/// Prefer [QattaPayButton] for the storefront CTA.
///
/// ```dart
/// final checkout = QattaPayCheckout(mode: QattaPayMode.live);
/// await checkout.open(intentId, returnUrl: Uri.parse('myapp://thank-you'));
/// ```
class QattaPayCheckout {
  QattaPayCheckout({
    QattaPayMode? mode,
    String? baseUrl,
  }) : _hosts = checkoutHosts(mode: mode, baseUrl: baseUrl) {
    if (mode == null && (baseUrl == null || baseUrl.isEmpty)) {
      throw ArgumentError(
        '[QattaPayCheckout] `mode` is required ("dev" | "live"). '
        'Pass mode: QattaPayMode.dev for testing or QattaPayMode.live for production.',
      );
    }
  }

  final List<String> _hosts;

  /// Build the hosted checkout URL for [intentId] (primary host).
  Uri checkoutUrl(String intentId, {Uri? returnUrl}) {
    return buildCheckoutUri(
      host: _hosts.first,
      intentId: intentId,
      returnUrl: returnUrl,
    );
  }

  /// Open hosted checkout in an external browser / Custom Tabs /
  /// SFSafariViewController.
  ///
  /// Tries each configured host until one can be launched.
  Future<void> open(
    String intentId, {
    CheckoutOpenMode mode = CheckoutOpenMode.externalBrowser,
    Uri? returnUrl,
    LaunchMode launchMode = LaunchMode.externalApplication,
  }) async {
    if (mode != CheckoutOpenMode.externalBrowser) {
      throw ArgumentError(
        '[QattaPayCheckout] Unsupported mode "$mode". '
        'Use CheckoutOpenMode.externalBrowser — WebView/iframe checkout is not supported.',
      );
    }
    if (intentId.isEmpty) {
      throw ArgumentError('[QattaPayCheckout] intentId must not be empty');
    }

    Object? lastError;
    for (final host in _hosts) {
      final uri = buildCheckoutUri(
        host: host,
        intentId: intentId,
        returnUrl: returnUrl,
      );
      try {
        final ok = await launchUrl(uri, mode: launchMode);
        if (ok) return;
        lastError = StateError('launchUrl returned false for $uri');
      } catch (err) {
        lastError = err;
      }
    }

    throw StateError(
      '[QattaPayCheckout] Unable to open checkout '
      '(tried ${_hosts.length} host${_hosts.length > 1 ? 's' : ''}): $lastError',
    );
  }
}
