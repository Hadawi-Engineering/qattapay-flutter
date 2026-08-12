import '../types/types.dart';
import 'http_client.dart';

/// Wraps the `/orders` API endpoints (merchant-authenticated).
class OrdersApi {
  OrdersApi(this._http);

  final QattaPayHttp _http;

  /// List all orders for the authenticated merchant.
  Future<List<Order>> list() async {
    final res = await _http.request<JsonMap>('/orders');
    final orders = res['orders'] as List<dynamic>? ?? const [];
    return orders.map((e) => Order.fromJson(e as JsonMap)).toList();
  }

  /// Fetch a single order with its full contribution breakdown.
  Future<OrderDetail> get(String orderId) {
    return _http.request(
      '/orders/${Uri.encodeComponent(orderId)}',
      parse: OrderDetail.fromJson,
    );
  }

  /// Transition the order from `funded` / `notified` → `fulfilling`.
  Future<Order> fulfill(String orderId) => _mutate(orderId, 'fulfill');

  /// Transition the order from `fulfilling` → `delivered`.
  Future<Order> deliver(String orderId) => _mutate(orderId, 'deliver');

  Future<Order> _mutate(String orderId, String action) async {
    final res = await _http.request<JsonMap>(
      '/orders/${Uri.encodeComponent(orderId)}/$action',
      method: 'PATCH',
    );
    if (res.containsKey('order')) {
      return Order.fromJson(res['order'] as JsonMap);
    }
    return Order.fromJson(res);
  }
}
