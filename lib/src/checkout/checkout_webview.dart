import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../types/types.dart';

/// Full-screen hosted checkout as a **top-level** WebView document.
///
/// This is not an HTML iframe. Framing the payment page inside another page
/// is unsupported; loading checkout as the WebView's main URL is fine.
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

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _loading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
          },
          onNavigationRequest: (request) {
            if (_isReturnUrl(request.url)) {
              _completeSuccess(request.url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onUrlChange: (change) {
            final url = change.url;
            if (url != null && _isReturnUrl(url)) {
              _completeSuccess(url);
            }
          },
        ),
      )
      ..loadRequest(widget.checkoutUrl);
  }

  bool _isReturnUrl(String url) {
    final returnUrl = widget.returnUrl;
    if (returnUrl == null) return false;
    final current = Uri.tryParse(url);
    if (current == null) return false;

    // Exact or prefix match on scheme+host+path
    if (url.startsWith(returnUrl.toString())) return true;
    if (current.scheme == returnUrl.scheme &&
        current.host == returnUrl.host &&
        current.path.startsWith(returnUrl.path) &&
        returnUrl.path.isNotEmpty) {
      return true;
    }

    // Custom scheme deep links (myapp://thank-you)
    if (returnUrl.hasScheme &&
        current.scheme == returnUrl.scheme &&
        (returnUrl.host.isEmpty || current.host == returnUrl.host)) {
      return true;
    }
    return false;
  }

  void _completeSuccess(String url) {
    if (_finished || !mounted) return;
    _finished = true;
    final uri = Uri.tryParse(url);
    final sessionId = uri?.queryParameters['sessionId'] ??
        uri?.queryParameters['session_id'];
    widget.onSuccess?.call(
      CheckoutSuccessData(intentId: widget.intentId, sessionId: sessionId),
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
