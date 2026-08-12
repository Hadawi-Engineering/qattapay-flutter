import 'package:flutter/material.dart';
import 'package:qattapay_flutter/qattapay_flutter.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QattaPay Flutter Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF454C80)),
        useMaterial3: true,
      ),
      home: const CheckoutPage(),
    );
  }
}

class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QattaPay button')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'In production, getIntentId must call YOUR backend. '
              'Never embed the merchant API key in the app.',
              style: TextStyle(height: 1.4),
            ),
            const SizedBox(height: 24),
            QattaPayButton(
              mode: QattaPayMode.dev,
              variant: QattaPayButtonVariant.primary,
              label: QattaPayButtonLabel.split,
              getIntentId: () async {
                // Replace with: POST https://your-api/qattapay/intent → intentId
                throw StateError(
                  'Wire getIntentId to your backend before opening checkout.',
                );
              },
              onError: (err) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$err')),
                );
              },
            ),
            const SizedBox(height: 16),
            QattaPayButton(
              mode: QattaPayMode.dev,
              variant: QattaPayButtonVariant.outline,
              label: QattaPayButtonLabel.pay,
              locale: QattaPayLocale.ar,
              getIntentId: () async => 'intent_demo',
              onError: (err) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$err')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
