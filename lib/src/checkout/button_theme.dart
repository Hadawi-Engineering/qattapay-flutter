import '../env/hosts.dart';
import '../types/types.dart';

const String kQattaPayLogoUrl = 'https://qatta.sa/brand/qatta-pay-icon.svg';

const Map<QattaPayLocale, Map<String, String>> kButtonLabels = {
  QattaPayLocale.en: {
    'split': 'Split with Friends',
    'split_cart': 'Split Cart with Friends',
    'pay': 'Pay with QattaPay',
    'poweredBy': 'Powered by',
  },
  QattaPayLocale.ar: {
    'split': 'قسّم مع الأصدقاء',
    'split_cart': 'قسّم السلة مع الأصدقاء',
    'pay': 'ادفع مع قطة باي',
    'poweredBy': 'مدعوم من',
  },
};

String resolveButtonLabel({
  required QattaPayLocale locale,
  QattaPayButtonLabel? label,
  String? labelText,
}) {
  if (labelText != null && labelText.isNotEmpty) return labelText;
  final map = kButtonLabels[locale]!;
  switch (label ?? QattaPayButtonLabel.split) {
    case QattaPayButtonLabel.split:
      return map['split']!;
    case QattaPayButtonLabel.splitCart:
      return map['split_cart']!;
    case QattaPayButtonLabel.pay:
      return map['pay']!;
  }
}

String poweredByLabel(QattaPayLocale locale) =>
    kButtonLabels[locale]!['poweredBy']!;

/// Brand colors matching `@hadawi/sdk` button styles.
abstract final class QattaPayColors {
  static const primary200 = ColorValue(0xFFD3D9EE);
  static const primary300 = ColorValue(0xFFB7C0E3);
  static const primary500 = ColorValue(0xFF7B85BF);
  static const primary600 = ColorValue(0xFF5C639F);
  static const primary700 = ColorValue(0xFF454C80);
  static const primary800 = ColorValue(0xFF353B61);
  static const primary900 = ColorValue(0xFF262A48);
  static const badgeMuted = ColorValue(0xFF8A8494);
}

/// Tiny ARGB holder so theme helpers stay free of Flutter imports.
class ColorValue {
  const ColorValue(this.value);
  final int value;
}

class ButtonSizeTokens {
  const ButtonSizeTokens({
    required this.vertical,
    required this.horizontal,
    required this.fontSize,
    required this.radius,
  });

  final double vertical;
  final double horizontal;
  final double fontSize;
  final double radius;
}

ButtonSizeTokens sizeTokens(QattaPayButtonSize size) {
  switch (size) {
    case QattaPayButtonSize.sm:
      return const ButtonSizeTokens(
        vertical: 8,
        horizontal: 14,
        fontSize: 13,
        radius: 8,
      );
    case QattaPayButtonSize.md:
      return const ButtonSizeTokens(
        vertical: 12,
        horizontal: 18,
        fontSize: 14,
        radius: 10,
      );
    case QattaPayButtonSize.lg:
      return const ButtonSizeTokens(
        vertical: 14,
        horizontal: 22,
        fontSize: 15,
        radius: 12,
      );
  }
}

List<String> checkoutHosts({
  QattaPayMode? mode,
  String? baseUrl,
}) {
  if (baseUrl != null && baseUrl.isNotEmpty) {
    return [baseUrl.replaceAll(RegExp(r'/$'), '')];
  }
  final resolved = mode ?? QattaPayMode.live;
  return resolveCheckoutHosts(resolved)
      .map((h) => h.replaceAll(RegExp(r'/$'), ''))
      .toList();
}

Uri buildCheckoutUri({
  required String host,
  required String intentId,
  Uri? returnUrl,
}) {
  final base = Uri.parse('$host/checkout/${Uri.encodeComponent(intentId)}');
  if (returnUrl == null) return base;
  return base.replace(
    queryParameters: {
      ...base.queryParameters,
      'returnUrl': returnUrl.toString(),
    },
  );
}
