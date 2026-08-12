import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../types/types.dart';

/// Full-screen hosted checkout as a **top-level** WebView document.
///
/// This is not an HTML iframe. Framing the payment page inside another page
/// is unsupported; loading checkout as the WebView's main URL is fine.
///
/// Completion signals (in order of preference):
/// 1. Navigation to [returnUrl] (https or custom scheme) with `status=success`
/// 2. `qattapay` JavaScript channel message from hosted checkout postMessage
class QattaPayCheckoutWebView extends StatefulWidget {
  const QattaPayCheckoutWebView({
    super.key,
    required this.checkoutUrl,
    required this.intentId,
    this.returnUrl,
    this.onSuccess,
    this.onCancel,
  });

  final Uri checkoutUrl;
  final String intentId;
  final Uri? returnUrl;
  final void Function(CheckoutSuccessData data)? onSuccess;
  final VoidCallback? onCancel;

  @override
  State<QattaPayCheckoutWebView> createState() =>
      _QattaPayCheckoutWebViewState();
}

class _QattaPayCheckoutWebViewState extends State<QattaPayCheckoutWebView> {
  late final WebViewController _controller;
  var _loading = true;
  var _finished = false;

  static const _bridgeName = 'QattaPayBridge';

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        _bridgeName,
        onMessageReceived: _onBridgeMessage,
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _loading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
            _injectPostMessageBridge();
          },
          onNavigationRequest: (request) {
            if (_isReturnUrl(request.url)) {
              _completeFromReturnUrl(request.url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onUrlChange: (change) {
            final url = change.url;
            if (url != null && _isReturnUrl(url)) {
              _completeFromReturnUrl(url);
            }
          },
        ),
      )
      ..loadRequest(widget.checkoutUrl);
  }

  void _injectPostMessageBridge() {
    // Forward window postMessage qattapay:* events into the Flutter channel
    // so popup-style success still completes the WebView when returnUrl
    // navigation is delayed or blocked.
    _controller.runJavaScript('''
(function () {
  if (window.__qattapayBridgeInstalled) return;
  window.__qattapayBridgeInstalled = true;
  function forward(data) {
    try {
      if (!data || typeof data !== 'object') return;
      if (data.type !== 'qattapay:success' && data.type !== 'qattapay:cancel') return;
      QattaPayBridge.postMessage(JSON.stringify(data));
    } catch (e) {}
  }
  window.addEventListener('message', function (event) {
    forward(event.data);
  });
})();
''');
  }

  void _onBridgeMessage(JavaScriptMessage message) {
    try {
      final decoded = jsonDecode(message.message);
      if (decoded is! Map) return;
      final type = decoded['type'] as String?;
      final payload = decoded['payload'];
      final map = payload is Map ? Map<String, dynamic>.from(payload) : null;
      if (type == 'qattapay:success') {
        _completeSuccess(
          sessionId: map?['sessionId'] as String?,
          intentId: map?['intentId'] as String? ?? widget.intentId,
        );
      } else if (type == 'qattapay:cancel') {
        _cancel();
      }
    } catch (_) {
      /* ignore malformed bridge payloads */
    }
  }

  bool _isReturnUrl(String url) {
    final returnUrl = widget.returnUrl;
    if (returnUrl == null) return false;
    final current = Uri.tryParse(url);
    if (current == null) return false;

    // Exact or prefix match on the configured return URL string
    if (url.startsWith(returnUrl.toString())) return true;

    if (current.scheme == returnUrl.scheme &&
        current.host == returnUrl.host &&
        (returnUrl.path.isEmpty ||
            current.path == returnUrl.path ||
            current.path.startsWith(
              returnUrl.path.endsWith('/')
                  ? returnUrl.path
                  : '${returnUrl.path}/',
            ) ||
            current.path.startsWith(returnUrl.path))) {
      return true;
    }

    // Custom scheme deep links (myapp://thank-you)
    if (returnUrl.hasScheme &&
        !returnUrl.isScheme('http') &&
        !returnUrl.isScheme('https') &&
        current.scheme == returnUrl.scheme &&
        (returnUrl.host.isEmpty || current.host == returnUrl.host)) {
      return true;
    }
    return false;
  }

  void _completeFromReturnUrl(String url) {
    final uri = Uri.tryParse(url);
    final status = uri?.queryParameters['status'];
    if (status == 'cancel' || status == 'failed') {
      _cancel();
      return;
    }
    final sessionId = uri?.queryParameters['sessionId'] ??
        uri?.queryParameters['session_id'];
    final intentId =
        uri?.queryParameters['intentId'] ?? widget.intentId;
    _completeSuccess(sessionId: sessionId, intentId: intentId);
  }

  void _completeSuccess({String? sessionId, required String intentId}) {
    if (_finished || !mounted) return;
    _finished = true;
    widget.onSuccess?.call(
      CheckoutSuccessData(intentId: intentId, sessionId: sessionId),
    );
    Navigator.of(context).pop(true);
  }

  void _cancel() {
    if (_finished || !mounted) return;
    _finished = true;
    widget.onCancel?.call();
    Navigator.of(context).pop(false);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _cancel();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('QattaPay'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: _cancel,
          ),
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_loading)
              const Align(
                alignment: Alignment.topCenter,
                child: LinearProgressIndicator(minHeight: 2),
              ),
          ],
        ),
      ),
    );
  }
}
