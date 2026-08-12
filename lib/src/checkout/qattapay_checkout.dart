import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../env/hosts.dart';
import '../types/types.dart';
import 'button_theme.dart';
import 'checkout_webview.dart';

/// Mobile-side QattaPay checkout controller.
///
/// Opens the hosted web checkout as a **top-level** page (in-app WebView or
/// external browser). Do **not** embed checkout inside an HTML iframe — the
/// payment page blocks framing. A full-page WebView is fine.
///
/// Prefer [QattaPayButton] for the storefront CTA.
///
/// ```dart
/// final checkout = QattaPayCheckout(mode: QattaPayMode.live);
/// await checkout.open(
///   intentId,
///   context: context,
///   mode: CheckoutOpenMode.inAppWebView,
///   returnUrl: Uri.parse('myapp://thank-you'),
/// );
/// ```
class QattaPayCheckout {
  QattaPayCheckout({
    QattaPayMode? mode,
    String? baseUrl,
  }) : _hosts = checkoutHosts(mode: mode, baseUrl: baseUrl) {
    if (mode == null && (baseUrl == null || baseUrl.isEmpty)) {
      throw ArgumentError(
        '[QattaPayCheckout] `mode` is required ("dev" | "live"). '
        'Pass mode: QattaPayMode.dev for testing or mode: QattaPayMode.live for production.',
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

  /// Open hosted checkout.
  ///
  /// - [CheckoutOpenMode.inAppWebView] (default) — full-screen WebView inside
  ///   your app. Requires [context].
  /// - [CheckoutOpenMode.externalBrowser] — Safari / Custom Tabs / browser.
  Future<void> open(
    String intentId, {
    BuildContext? context,
    CheckoutOpenMode mode = CheckoutOpenMode.inAppWebView,
    Uri? returnUrl,
    LaunchMode launchMode = LaunchMode.externalApplication,
    void Function(CheckoutSuccessData data)? onSuccess,
    VoidCallback? onCancel,
  }) async {
    if (intentId.isEmpty) {
      throw ArgumentError('[QattaPayCheckout] intentId must not be empty');
    }

    final uri = checkoutUrl(intentId, returnUrl: returnUrl);

    switch (mode) {
      case CheckoutOpenMode.inAppWebView:
        if (context == null || !context.mounted) {
          throw ArgumentError(
            '[QattaPayCheckout] `context` is required for '
            'CheckoutOpenMode.inAppWebView.',
          );
        }
        await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            fullscreenDialog: true,
            builder: (_) => QattaPayCheckoutWebView(
              checkoutUrl: uri,
              intentId: intentId,
              returnUrl: returnUrl,
              onSuccess: onSuccess,
              onCancel: onCancel,
            ),
          ),
        );
        return;

      case CheckoutOpenMode.externalBrowser:
        Object? lastError;
        for (final host in _hosts) {
          final hostUri = buildCheckoutUri(
            host: host,
            intentId: intentId,
            returnUrl: returnUrl,
          );
          try {
            final ok = await launchUrl(hostUri, mode: launchMode);
            if (ok) return;
            lastError = StateError('launchUrl returned false for $hostUri');
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
}
