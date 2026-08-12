import 'package:flutter/material.dart';

import '../env/hosts.dart';
import '../types/types.dart';
import 'button_theme.dart';
import 'qattapay_checkout.dart';

/// Official branded QattaPay checkout button.
///
/// On tap, calls [getIntentId] (your backend creates the intent), then opens
/// hosted checkout. Do not invent a custom “Pay / Split” CTA — use this widget
/// so branding stays consistent.
///
/// ```dart
/// QattaPayButton(
///   mode: QattaPayMode.live,
///   getIntentId: () async {
///     final res = await api.createContribution(cartId);
///     return res.intentId;
///   },
///   onOpened: () {},
///   onError: (e) => debugPrint('$e'),
/// )
/// ```
class QattaPayButton extends StatefulWidget {
  const QattaPayButton({
    super.key,
    required this.getIntentId,
    this.mode,
    this.baseUrl,
    this.variant = QattaPayButtonVariant.primary,
    this.size = QattaPayButtonSize.md,
    this.label = QattaPayButtonLabel.split,
    this.labelText,
    this.locale = QattaPayLocale.en,
    this.showBadge = true,
    this.showIcon = true,
    this.openMode = CheckoutOpenMode.inAppWebView,
    this.returnUrl,
    this.enabled = true,
    this.onOpened,
    this.onSuccess,
    this.onCancel,
    this.onError,
    this.width = double.infinity,
  });

  /// Called when the shopper taps. Create the intent on your server, return its id.
  final Future<String> Function() getIntentId;

  final QattaPayMode? mode;
  final String? baseUrl;
  final QattaPayButtonVariant variant;
  final QattaPayButtonSize size;
  final QattaPayButtonLabel label;

  /// Custom label — overrides [label] when non-null / non-empty.
  final String? labelText;
  final QattaPayLocale locale;
  final bool showBadge;
  final bool showIcon;

  /// How to present hosted checkout. Defaults to in-app WebView.
  final CheckoutOpenMode openMode;
  final Uri? returnUrl;
  final bool enabled;

  /// Fired after checkout is presented (WebView pushed / browser opened).
  final VoidCallback? onOpened;

  /// Fired when [returnUrl] is reached inside the in-app WebView.
  final void Function(CheckoutSuccessData data)? onSuccess;

  /// Fired when the shopper closes the in-app WebView without completing.
  final VoidCallback? onCancel;
  final void Function(Object error)? onError;
  final double? width;

  @override
  State<QattaPayButton> createState() => _QattaPayButtonState();
}

class _QattaPayButtonState extends State<QattaPayButton> {
  bool _loading = false;

  Future<void> _onPressed() async {
    if (_loading || !widget.enabled) return;
    setState(() => _loading = true);
    try {
      final intentId = await widget.getIntentId();
      if (intentId.isEmpty) {
        throw StateError('getIntentId returned an empty intent id');
      }
      if (!mounted) return;
      final checkout = QattaPayCheckout(
        mode: widget.mode,
        baseUrl: widget.baseUrl,
      );
      await checkout.open(
        intentId,
        context: context,
        mode: widget.openMode,
        returnUrl: widget.returnUrl,
        onSuccess: widget.onSuccess,
        onCancel: widget.onCancel,
      );
      widget.onOpened?.call();
    } catch (err) {
      widget.onError?.call(err);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = sizeTokens(widget.size);
    final text = resolveButtonLabel(
      locale: widget.locale,
      label: widget.label,
      labelText: widget.labelText,
    );
    final colors = _colorsFor(widget.variant);
    final disabled = !widget.enabled || _loading;

    final button = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: disabled ? null : _onPressed,
        borderRadius: BorderRadius.circular(tokens.radius),
        child: Ink(
          decoration: BoxDecoration(
            gradient: colors.gradient,
            color: colors.gradient == null ? colors.background : null,
            borderRadius: BorderRadius.circular(tokens.radius),
            border: colors.border,
            boxShadow: disabled ? null : colors.shadow,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: tokens.vertical,
              horizontal: tokens.horizontal,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              textDirection: widget.locale == QattaPayLocale.ar
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              children: [
                if (_loading)
                  SizedBox(
                    width: tokens.fontSize * 1.05,
                    height: tokens.fontSize * 1.05,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(colors.foreground),
                    ),
                  )
                else ...[
                  if (widget.showIcon) ...[
                    _Logo(size: tokens.fontSize * 1.25),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      text,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.foreground,
                        fontSize: tokens.fontSize,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.1,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );

    return Opacity(
      opacity: disabled ? 0.65 : 1,
      child: Directionality(
        textDirection: widget.locale == QattaPayLocale.ar
            ? TextDirection.rtl
            : TextDirection.ltr,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(width: widget.width, child: button),
            if (widget.showBadge) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    poweredByLabel(widget.locale),
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF8A8494),
                      letterSpacing: 0.01,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const _Logo(size: 14),
                  const SizedBox(width: 4),
                  const Text(
                    'QattaPay',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF454C80),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ButtonColors {
  const _ButtonColors({
    required this.foreground,
    this.background,
    this.gradient,
    this.border,
    this.shadow,
  });

  final Color foreground;
  final Color? background;
  final Gradient? gradient;
  final Border? border;
  final List<BoxShadow>? shadow;
}

_ButtonColors _colorsFor(QattaPayButtonVariant variant) {
  switch (variant) {
    case QattaPayButtonVariant.primary:
      return const _ButtonColors(
        foreground: Colors.white,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF454C80), Color(0xFF5C639F)],
        ),
        shadow: [
          BoxShadow(
            color: Color(0x4D454C80),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      );
    case QattaPayButtonVariant.dark:
      return const _ButtonColors(
        foreground: Colors.white,
        background: Color(0xFF262A48),
        shadow: [
          BoxShadow(
            color: Color(0x40262A48),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      );
    case QattaPayButtonVariant.light:
      return const _ButtonColors(
        foreground: Color(0xFF454C80),
        background: Colors.white,
        border: Border.fromBorderSide(
          BorderSide(color: Color(0xFFD3D9EE)),
        ),
        shadow: [
          BoxShadow(
            color: Color(0x0F262A48),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      );
    case QattaPayButtonVariant.outline:
      return const _ButtonColors(
        foreground: Color(0xFF454C80),
        background: Colors.transparent,
        border: Border.fromBorderSide(
          BorderSide(color: Color(0xFF5C639F), width: 1.5),
        ),
      );
  }
}

/// Official QattaPay logo — bundled asset with network fallback.
class _Logo extends StatelessWidget {
  const _Logo({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        kQattaPayLogoAsset,
        width: size,
        height: size,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        errorBuilder: (_, __, ___) => Image.network(
          kQattaPayLogoUrl,
          width: size,
          height: size,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => Icon(
            Icons.groups_rounded,
            size: size,
            color: const Color(0xFF454C80),
          ),
        ),
      ),
    );
  }
}