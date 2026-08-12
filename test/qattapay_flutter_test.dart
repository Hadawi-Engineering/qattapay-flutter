import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:qattapay_flutter/src/client/qattapay_client.dart';
import 'package:qattapay_flutter/src/env/hosts.dart';
import 'package:qattapay_flutter/src/exceptions/exceptions.dart';
import 'package:qattapay_flutter/src/types/types.dart';
import 'package:test/test.dart';

void main() {
  group('hosts', () {
    test('live API hosts prefer qatta.sa', () {
      final hosts = resolveApiHosts(QattaPayMode.live);
      expect(hosts.first, 'https://qatta.sa/api');
      expect(hosts.last, 'https://beta.hadawi.sa/api');
    });

    test('dev checkout hosts prefer qatta.sa', () {
      final hosts = resolveCheckoutHosts(QattaPayMode.dev);
      expect(hosts.first, 'https://dev.qatta.sa');
      expect(hosts.last, 'https://dev.hadawi.sa');
    });
  });

  group('webhooks', () {
    const secret = 'whsec_test_secret';
    late QattaPayClient client;

    setUp(() {
      client = QattaPayClient(
        apiKey: 'mk_test',
        mode: QattaPayMode.dev,
        webhookSecret: secret,
      );
    });

    tearDown(() => client.close());

    test('constructEvent accepts a valid HMAC signature', () {
      final body = utf8.encode(
        jsonEncode({
          'event': 'order.funded',
          'order_id': 'ord_1',
          'session_id': 'ses_1',
          'merchant_id': 'mer_1',
          'items': [
            {'name': 'Watch', 'price': 1000},
          ],
          'total_amount': 1000,
          'currency': 'SAR',
          'funded_at': '2026-01-01T00:00:00.000Z',
        }),
      );

      final signature = _hmacHex(secret, body);
      final parsed = client.webhooks.constructEvent(body, signature);

      expect(parsed.type, WebhookEventType.orderFunded);
      expect(parsed.payload.orderId, 'ord_1');
      expect(parsed.payload.totalAmount, 1000);
    });

    test('constructEvent rejects a bad signature', () {
      final body = utf8.encode('{"event":"order.funded"}');
      expect(
        () => client.webhooks.constructEvent(body, '00' * 32),
        throwsA(isA<QattaPayWebhookException>()),
      );
    });
  });

  group('models', () {
    test('CreateIntentParams serializes', () {
      const params = CreateIntentParams(
        itemSnapshot: [
          ItemSnapshot(name: 'Watch', price: 150000, reference: 'w1'),
        ],
        totalAmount: 150000,
        metadata: {'a': 1},
      );
      final json = params.toJson();
      expect(json['totalAmount'], 150000);
      expect((json['itemSnapshot'] as List).first['reference'], 'w1');
    });

    test('OrderDetail parses wrapped API shape', () {
      final detail = OrderDetail.fromJson({
        'order': {
          'id': 'ord_1',
          'sessionId': 'ses_1',
          'merchantId': 'mer_1',
          'status': 'funded',
          'settlementAmount': 1000,
          'createdAt': '2026-01-01T00:00:00.000Z',
          'updatedAt': '2026-01-01T00:00:00.000Z',
        },
        'contributions': <Map<String, dynamic>>[],
      });
      expect(detail.order.id, 'ord_1');
      expect(detail.order.status, OrderStatus.funded);
    });
  });
}

String _hmacHex(String secret, List<int> body) {
  final digest = Hmac(sha256, utf8.encode(secret)).convert(body);
  return digest.toString();
}
