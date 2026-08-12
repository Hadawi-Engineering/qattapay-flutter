import 'dart:convert';

import 'package:http/http.dart' as http;

import '../exceptions/exceptions.dart';
import '../types/types.dart';

/// Lightweight HTTP wrapper shared by all server-side modules.
///
/// Uses the `X-API-Key` header for merchant authentication.
///
/// When [baseUrls] has multiple hosts, later hosts are only tried on
/// network-level failure (DNS / connection / timeout). An application-level
/// 4xx/5xx from a reachable host is thrown immediately.
class QattaPayHttp {
  QattaPayHttp({
    required this.baseUrls,
    required this.apiKey,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final List<String> baseUrls;
  final String apiKey;
  final http.Client _client;

  Future<T> request<T>(
    String path, {
    String method = 'GET',
    Object? body,
    T Function(JsonMap json)? parse,
  }) async {
    Object? lastNetworkError;

    for (final host in baseUrls) {
      final url = Uri.parse('${host.replaceAll(RegExp(r'/$'), '')}$path');
      final headers = <String, String>{
        'Content-Type': 'application/json',
        'X-API-Key': apiKey,
        'ngrok-skip-browser-warning': 'true',
      };

      try {
        late http.Response res;
        final encoded =
            body == null ? null : jsonEncode(body is JsonMap ? body : body);

        switch (method.toUpperCase()) {
          case 'GET':
            res = await _client.get(url, headers: headers);
          case 'POST':
            res = await _client.post(url, headers: headers, body: encoded);
          case 'PATCH':
            res = await _client.patch(url, headers: headers, body: encoded);
          case 'PUT':
            res = await _client.put(url, headers: headers, body: encoded);
          case 'DELETE':
            res = await _client.delete(url, headers: headers, body: encoded);
          default:
            throw QattaPayApiException('Unsupported HTTP method: $method');
        }

        if (res.statusCode < 200 || res.statusCode >= 300) {
          throw _parseError(res);
        }

        if (res.statusCode == 204 || res.body.isEmpty) {
          return null as T;
        }

        final decoded = jsonDecode(res.body);
        if (parse != null) {
          return parse(decoded as JsonMap);
        }
        return decoded as T;
      } on QattaPayApiException {
        rethrow;
      } catch (err) {
        lastNetworkError = err;
        continue;
      }
    }

    final reason = lastNetworkError is Exception
        ? lastNetworkError.toString()
        : 'network error';
    throw QattaPayApiException(
      'Unable to reach QattaPay API '
      '(tried ${baseUrls.length} host${baseUrls.length > 1 ? 's' : ''}: $reason)',
      status: 0,
      code: 'network_error',
    );
  }

  QattaPayApiException _parseError(http.Response res) {
    try {
      final decoded = jsonDecode(res.body);
      if (decoded is JsonMap) {
        final err = decoded['error'];
        if (err is JsonMap) {
          return QattaPayApiException(
            err['message'] as String? ?? 'HTTP ${res.statusCode}',
            status: res.statusCode,
            code: err['code'] as String? ?? '',
          );
        }
      }
    } catch (_) {
      // fall through
    }
    return QattaPayApiException(
      'HTTP ${res.statusCode}',
      status: res.statusCode,
    );
  }

  void close() => _client.close();
}
