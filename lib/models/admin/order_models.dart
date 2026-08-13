// Backend-aligned Order models. List and detail return different field
// sets (the list omits discountCents/razorpay ids/updatedAt — see
// AdminOrdersService.list vs .detail), so they're modeled separately.

/// One row of `GET /admin/orders`.
class AdminOrderListItemModel {
  const AdminOrderListItemModel({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.currency,
    required this.subtotalCents,
    required this.taxCents,
    required this.totalCents,
    required this.createdAt,
    this.billingName,
    this.billingPhone,
    this.billingAddress,
    this.billingCity,
    this.billingState,
    this.billingPincode,
    this.userId,
    this.userName,
    this.userEmail,
  });

  final String id;
  final String orderNumber;

  /// Backend enum `OrderStatus`: PENDING | PAID | FAILED | REFUNDED.
  final String status;
  final String currency;
  final int subtotalCents;
  final int taxCents;
  final int totalCents;
  final DateTime createdAt;
  final String? billingName;
  final String? billingPhone;
  final String? billingAddress;
  final String? billingCity;
  final String? billingState;
  final String? billingPincode;
  final String? userId;
  final String? userName;
  final String? userEmail;

  factory AdminOrderListItemModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    return AdminOrderListItemModel(
      id: json['id'] as String,
      orderNumber: json['orderNumber'] as String,
      status: json['status'] as String? ?? 'PENDING',
      currency: json['currency'] as String? ?? 'INR',
      subtotalCents: json['subtotalCents'] as int? ?? 0,
      taxCents: json['taxCents'] as int? ?? 0,
      totalCents: json['totalCents'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      billingName: json['billingName'] as String?,
      billingPhone: json['billingPhone'] as String?,
      billingAddress: json['billingAddress'] as String?,
      billingCity: json['billingCity'] as String?,
      billingState: json['billingState'] as String?,
      billingPincode: json['billingPincode'] as String?,
      userId: user?['id'] as String?,
      userName: user?['name'] as String?,
      userEmail: user?['email'] as String?,
    );
  }
}

/// `GET /admin/orders/:id` and the result of `POST /admin/orders/:id/refund`
/// (refund omits `user`, everything else is the same shape).
class AdminOrderDetailModel {
  const AdminOrderDetailModel({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.region,
    required this.currency,
    required this.subtotalCents,
    required this.discountCents,
    required this.taxCents,
    required this.totalCents,
    required this.createdAt,
    required this.updatedAt,
    this.billingName,
    this.billingPhone,
    this.billingAddress,
    this.billingCity,
    this.billingState,
    this.billingPincode,
    this.razorpayOrderId,
    this.razorpayPaymentId,
    this.items = const [],
    this.userId,
    this.userName,
    this.userEmail,
    this.userPhone,
  });

  final String id;
  final String orderNumber;
  final String status;
  final String region;
  final String currency;
  final int subtotalCents;
  final int discountCents;
  final int taxCents;
  final int totalCents;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? billingName;
  final String? billingPhone;
  final String? billingAddress;
  final String? billingCity;
  final String? billingState;
  final String? billingPincode;
  final String? razorpayOrderId;
  final String? razorpayPaymentId;
  final List<AdminOrderItemModel> items;
  final String? userId;
  final String? userName;
  final String? userEmail;
  final String? userPhone;

  factory AdminOrderDetailModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    return AdminOrderDetailModel(
      id: json['id'] as String,
      orderNumber: json['orderNumber'] as String,
      status: json['status'] as String? ?? 'PENDING',
      region: json['region'] as String? ?? 'IN',
      currency: json['currency'] as String? ?? 'INR',
      subtotalCents: json['subtotalCents'] as int? ?? 0,
      discountCents: json['discountCents'] as int? ?? 0,
      taxCents: json['taxCents'] as int? ?? 0,
      totalCents: json['totalCents'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      billingName: json['billingName'] as String?,
      billingPhone: json['billingPhone'] as String?,
      billingAddress: json['billingAddress'] as String?,
      billingCity: json['billingCity'] as String?,
      billingState: json['billingState'] as String?,
      billingPincode: json['billingPincode'] as String?,
      razorpayOrderId: json['razorpayOrderId'] as String?,
      razorpayPaymentId: json['razorpayPaymentId'] as String?,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => AdminOrderItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      userId: user?['id'] as String?,
      userName: user?['name'] as String?,
      userEmail: user?['email'] as String?,
      userPhone: user?['phone'] as String?,
    );
  }
}

class AdminOrderItemModel {
  const AdminOrderItemModel({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.titleSnapshot,
    required this.priceCents,
  });

  final String id;
  final String orderId;
  final String productId;
  final String titleSnapshot;
  final int priceCents;

  factory AdminOrderItemModel.fromJson(Map<String, dynamic> json) => AdminOrderItemModel(
        id: json['id'] as String,
        orderId: json['orderId'] as String,
        productId: json['productId'] as String,
        titleSnapshot: json['titleSnapshot'] as String,
        priceCents: json['priceCents'] as int,
      );
}
