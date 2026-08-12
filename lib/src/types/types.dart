// ignore_for_file: public_member_api_docs

/// Shared models mirroring `@hadawi/sdk` / the QattaPay REST API.
library;

typedef JsonMap = Map<String, dynamic>;

// ============================================================
// Enums
// ============================================================

enum SessionStatus {
  collecting,
  funded,
  partiallyFunded,
  expired,
  refunding,
  refunded,
  cancelled;

  static SessionStatus? tryParse(String? value) {
    switch (value) {
      case 'collecting':
        return SessionStatus.collecting;
      case 'funded':
        return SessionStatus.funded;
      case 'partially_funded':
        return SessionStatus.partiallyFunded;
      case 'expired':
        return SessionStatus.expired;
      case 'refunding':
        return SessionStatus.refunding;
      case 'refunded':
        return SessionStatus.refunded;
      case 'cancelled':
        return SessionStatus.cancelled;
      default:
        return null;
    }
  }

  String get apiValue {
    switch (this) {
      case SessionStatus.partiallyFunded:
        return 'partially_funded';
      default:
        return name;
    }
  }
}

enum SplitMode {
  equal,
  flexible;

  static SplitMode? tryParse(String? value) {
    switch (value) {
      case 'equal':
        return SplitMode.equal;
      case 'flexible':
        return SplitMode.flexible;
      default:
        return null;
    }
  }
}

enum PaymentStatus {
  pending,
  authorized,
  captured,
  failed,
  refunded;

  static PaymentStatus? tryParse(String? value) {
    switch (value) {
      case 'pending':
        return PaymentStatus.pending;
      case 'authorized':
        return PaymentStatus.authorized;
      case 'captured':
        return PaymentStatus.captured;
      case 'failed':
        return PaymentStatus.failed;
      case 'refunded':
        return PaymentStatus.refunded;
      default:
        return null;
    }
  }
}

enum OrderStatus {
  pendingFunding,
  funded,
  notified,
  fulfilling,
  delivered,
  cancelled;

  static OrderStatus? tryParse(String? value) {
    switch (value) {
      case 'pending_funding':
        return OrderStatus.pendingFunding;
      case 'funded':
        return OrderStatus.funded;
      case 'notified':
        return OrderStatus.notified;
      case 'fulfilling':
        return OrderStatus.fulfilling;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return null;
    }
  }

  String get apiValue {
    switch (this) {
      case OrderStatus.pendingFunding:
        return 'pending_funding';
      default:
        return name;
    }
  }
}

enum CheckoutIntentStatus {
  pending,
  used,
  expired;

  static CheckoutIntentStatus? tryParse(String? value) {
    switch (value) {
      case 'pending':
        return CheckoutIntentStatus.pending;
      case 'used':
        return CheckoutIntentStatus.used;
      case 'expired':
        return CheckoutIntentStatus.expired;
      default:
        return null;
    }
  }
}

enum WebhookEventType {
  orderFunded,
  orderPartiallyFunded,
  orderCancelled,
  orderExpired;

  static WebhookEventType? tryParse(String? value) {
    switch (value) {
      case 'order.funded':
        return WebhookEventType.orderFunded;
      case 'order.partially_funded':
        return WebhookEventType.orderPartiallyFunded;
      case 'order.cancelled':
        return WebhookEventType.orderCancelled;
      case 'order.expired':
        return WebhookEventType.orderExpired;
      default:
        return null;
    }
  }

  String get apiValue {
    switch (this) {
      case WebhookEventType.orderFunded:
        return 'order.funded';
      case WebhookEventType.orderPartiallyFunded:
        return 'order.partially_funded';
      case WebhookEventType.orderCancelled:
        return 'order.cancelled';
      case WebhookEventType.orderExpired:
        return 'order.expired';
    }
  }
}

// ============================================================
// Item snapshot
// ============================================================

class ItemSnapshot {
  const ItemSnapshot({
    required this.name,
    required this.price,
    this.nameAr,
    this.image,
    this.reference,
  });

  final String name;
  final String? nameAr;

  /// Line-item price in the currency's smallest unit (halalas for SAR).
  final int price;
  final String? image;
  final String? reference;

  JsonMap toJson() => {
        'name': name,
        if (nameAr != null) 'nameAr': nameAr,
        'price': price,
        if (image != null) 'image': image,
        if (reference != null) 'reference': reference,
      };

  factory ItemSnapshot.fromJson(JsonMap json) => ItemSnapshot(
        name: json['name'] as String,
        nameAr: json['nameAr'] as String?,
        price: (json['price'] as num).toInt(),
        image: json['image'] as String?,
        reference: json['reference'] as String?,
      );
}

// ============================================================
// Intents
// ============================================================

class CreateIntentParams {
  const CreateIntentParams({
    required this.itemSnapshot,
    required this.totalAmount,
    this.currency = 'SAR',
    this.metadata,
  });

  final List<ItemSnapshot> itemSnapshot;
  final int totalAmount;
  final String currency;
  final Map<String, dynamic>? metadata;

  JsonMap toJson() => {
        'itemSnapshot': itemSnapshot.map((e) => e.toJson()).toList(),
        'totalAmount': totalAmount,
        'currency': currency,
        if (metadata != null) 'metadata': metadata,
      };
}

class MerchantSummary {
  const MerchantSummary({
    required this.id,
    required this.name,
    this.nameAr,
    this.logoUrl,
  });

  final String id;
  final String name;
  final String? nameAr;
  final String? logoUrl;

  factory MerchantSummary.fromJson(JsonMap json) => MerchantSummary(
        id: json['id'] as String,
        name: json['name'] as String,
        nameAr: json['nameAr'] as String?,
        logoUrl: json['logoUrl'] as String?,
      );
}

class CheckoutIntent {
  const CheckoutIntent({
    required this.id,
    required this.merchantId,
    required this.itemSnapshot,
    required this.totalAmount,
    required this.currency,
    required this.metadata,
    required this.status,
    required this.expiresAt,
    required this.createdAt,
    this.apiKeyId,
    this.apiKeyLabel,
    this.merchant,
  });

  final String id;
  final String merchantId;
  final String? apiKeyId;
  final String? apiKeyLabel;
  final List<ItemSnapshot> itemSnapshot;
  final int totalAmount;
  final String currency;
  final Map<String, dynamic> metadata;
  final CheckoutIntentStatus status;
  final DateTime expiresAt;
  final DateTime createdAt;
  final MerchantSummary? merchant;

  factory CheckoutIntent.fromJson(JsonMap json) => CheckoutIntent(
        id: json['id'] as String,
        merchantId: json['merchantId'] as String,
        apiKeyId: json['apiKeyId'] as String?,
        apiKeyLabel: json['apiKeyLabel'] as String?,
        itemSnapshot: (json['itemSnapshot'] as List<dynamic>)
            .map((e) => ItemSnapshot.fromJson(e as JsonMap))
            .toList(),
        totalAmount: (json['totalAmount'] as num).toInt(),
        currency: json['currency'] as String? ?? 'SAR',
        metadata: (json['metadata'] as JsonMap?) ?? const {},
        status: CheckoutIntentStatus.tryParse(json['status'] as String?) ??
            CheckoutIntentStatus.pending,
        expiresAt: DateTime.parse(json['expiresAt'] as String),
        createdAt: DateTime.parse(json['createdAt'] as String),
        merchant: json['merchant'] is JsonMap
            ? MerchantSummary.fromJson(json['merchant'] as JsonMap)
            : null,
      );
}

class CreateIntentResponse {
  const CreateIntentResponse({
    required this.intent,
    required this.redirectUrl,
  });

  final CheckoutIntent intent;
  final String redirectUrl;

  factory CreateIntentResponse.fromJson(JsonMap json) => CreateIntentResponse(
        intent: CheckoutIntent.fromJson(json['intent'] as JsonMap),
        redirectUrl: json['redirectUrl'] as String,
      );
}

// ============================================================
// Orders
// ============================================================

class SessionSummary {
  const SessionSummary({
    required this.totalAmount,
    required this.collectedAmount,
    required this.itemSnapshot,
    required this.deadline,
    required this.status,
    this.splitMode,
  });

  final int totalAmount;
  final int collectedAmount;
  final List<ItemSnapshot> itemSnapshot;
  final DateTime deadline;
  final SessionStatus status;
  final SplitMode? splitMode;

  factory SessionSummary.fromJson(JsonMap json) => SessionSummary(
        totalAmount: (json['totalAmount'] as num).toInt(),
        collectedAmount: (json['collectedAmount'] as num).toInt(),
        itemSnapshot: (json['itemSnapshot'] as List<dynamic>? ?? const [])
            .map((e) => ItemSnapshot.fromJson(e as JsonMap))
            .toList(),
        deadline: DateTime.parse(json['deadline'] as String),
        status: SessionStatus.tryParse(json['status'] as String?) ??
            SessionStatus.collecting,
        splitMode: SplitMode.tryParse(json['splitMode'] as String?),
      );
}

class Order {
  const Order({
    required this.id,
    required this.sessionId,
    required this.merchantId,
    required this.status,
    required this.settlementAmount,
    required this.createdAt,
    required this.updatedAt,
    this.merchantReference,
    this.settledAt,
    this.session,
  });

  final String id;
  final String sessionId;
  final String merchantId;
  final OrderStatus status;
  final String? merchantReference;
  final int settlementAmount;
  final DateTime? settledAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final SessionSummary? session;

  factory Order.fromJson(JsonMap json) => Order(
        id: json['id'] as String,
        sessionId: json['sessionId'] as String,
        merchantId: json['merchantId'] as String,
        status: OrderStatus.tryParse(json['status'] as String?) ??
            OrderStatus.pendingFunding,
        merchantReference: json['merchantReference'] as String?,
        settlementAmount: (json['settlementAmount'] as num?)?.toInt() ?? 0,
        settledAt: json['settledAt'] != null
            ? DateTime.tryParse(json['settledAt'] as String)
            : null,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        session: json['session'] is JsonMap
            ? SessionSummary.fromJson(json['session'] as JsonMap)
            : null,
      );
}

class ContributorInfo {
  const ContributorInfo({
    required this.id,
    this.firstName,
    this.lastName,
    this.phone,
    this.email,
  });

  final String id;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? email;

  factory ContributorInfo.fromJson(JsonMap json) => ContributorInfo(
        id: json['id'] as String,
        firstName: json['firstName'] as String?,
        lastName: json['lastName'] as String?,
        phone: json['phone'] as String?,
        email: json['email'] as String?,
      );
}

class ContributionInvitation {
  const ContributionInvitation({
    this.inviteePhone,
    this.inviteeEmail,
    this.assignedAmount,
  });

  final String? inviteePhone;
  final String? inviteeEmail;
  final int? assignedAmount;

  factory ContributionInvitation.fromJson(JsonMap json) =>
      ContributionInvitation(
        inviteePhone: json['inviteePhone'] as String?,
        inviteeEmail: json['inviteeEmail'] as String?,
        assignedAmount: (json['assignedAmount'] as num?)?.toInt(),
      );
}

class Contribution {
  const Contribution({
    required this.id,
    required this.amount,
    required this.paymentStatus,
    required this.createdAt,
    required this.invitation,
    this.paidAt,
    this.user,
  });

  final String id;
  final int amount;
  final PaymentStatus paymentStatus;
  final DateTime? paidAt;
  final DateTime createdAt;
  final ContributorInfo? user;
  final ContributionInvitation invitation;

  factory Contribution.fromJson(JsonMap json) => Contribution(
        id: json['id'] as String,
        amount: (json['amount'] as num).toInt(),
        paymentStatus: PaymentStatus.tryParse(json['paymentStatus'] as String?) ??
            PaymentStatus.pending,
        paidAt: json['paidAt'] != null
            ? DateTime.tryParse(json['paidAt'] as String)
            : null,
        createdAt: DateTime.parse(json['createdAt'] as String),
        user: json['user'] is JsonMap
            ? ContributorInfo.fromJson(json['user'] as JsonMap)
            : null,
        invitation: ContributionInvitation.fromJson(
          (json['invitation'] as JsonMap?) ?? const {},
        ),
      );
}

class OrderDetail {
  const OrderDetail({
    required this.order,
    required this.contributions,
  });

  final Order order;
  final List<Contribution> contributions;

  factory OrderDetail.fromJson(JsonMap json) {
    // API shape: { order, contributions }
    if (json.containsKey('order')) {
      return OrderDetail(
        order: Order.fromJson(json['order'] as JsonMap),
        contributions: (json['contributions'] as List<dynamic>? ?? const [])
            .map((e) => Contribution.fromJson(e as JsonMap))
            .toList(),
      );
    }
    // Flat OrderDetail-style payload (order fields + contributions)
    return OrderDetail(
      order: Order.fromJson(json),
      contributions: (json['contributions'] as List<dynamic>? ?? const [])
          .map((e) => Contribution.fromJson(e as JsonMap))
          .toList(),
    );
  }
}

// ============================================================
// Webhooks
// ============================================================

class QattaPayWebhookPayload {
  const QattaPayWebhookPayload({
    required this.event,
    required this.sessionId,
    required this.merchantId,
    required this.items,
    required this.totalAmount,
    required this.currency,
    required this.fundedAt,
    this.orderId,
    this.raw = const {},
  });

  final WebhookEventType event;
  final String? orderId;
  final String sessionId;
  final String merchantId;
  final List<ItemSnapshot> items;
  final int totalAmount;
  final String currency;
  final DateTime fundedAt;
  final JsonMap raw;

  factory QattaPayWebhookPayload.fromJson(JsonMap json) =>
      QattaPayWebhookPayload(
        event: WebhookEventType.tryParse(json['event'] as String?) ??
            WebhookEventType.orderFunded,
        orderId: json['order_id'] as String?,
        sessionId: json['session_id'] as String,
        merchantId: json['merchant_id'] as String,
        items: (json['items'] as List<dynamic>? ?? const [])
            .map((e) => ItemSnapshot.fromJson(e as JsonMap))
            .toList(),
        totalAmount: (json['total_amount'] as num).toInt(),
        currency: json['currency'] as String? ?? 'SAR',
        fundedAt: DateTime.parse(json['funded_at'] as String),
        raw: json,
      );
}

class QattaPayWebhookEvent {
  const QattaPayWebhookEvent({
    required this.type,
    required this.payload,
  });

  final WebhookEventType type;
  final QattaPayWebhookPayload payload;
}

// ============================================================
// Checkout / button
// ============================================================

/// How the hosted checkout page is presented.
///
/// WebView / iframe embedding is intentionally unsupported: the hosted
/// payment page sends `X-Frame-Options: deny`.
enum CheckoutOpenMode {
  /// Opens via Custom Tabs / SFSafariViewController / external browser.
  externalBrowser,
}

class CheckoutSuccessData {
  const CheckoutSuccessData({
    required this.intentId,
    this.sessionId,
  });

  final String intentId;
  final String? sessionId;
}

enum QattaPayButtonVariant { primary, dark, light, outline }

enum QattaPayButtonSize { sm, md, lg }

/// Preset label keys. Pass a custom [String] via [QattaPayButton.labelText].
enum QattaPayButtonLabel { split, splitCart, pay }

enum QattaPayLocale { en, ar }
