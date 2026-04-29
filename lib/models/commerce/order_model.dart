class OrderModel {
  final String id;
  final String clientId;
  final String shopId;
  final int totalPrice;
  final String status;
  final DateTime createdAt;
  final List<OrderItemModel> items;

  OrderModel({
    required this.id,
    required this.clientId,
    required this.shopId,
    required this.totalPrice,
    this.status = 'pending',
    required this.createdAt,
    this.items = const [],
  });

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id'],
      clientId: map['client_id'],
      shopId: map['shop_id'],
      totalPrice: map['total_price'] ?? 0,
      status: map['status'] ?? 'pending',
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'client_id': clientId,
      'shop_id': shopId,
      'total_price': totalPrice,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class OrderItemModel {
  final String id;
  final String orderId;
  final String productId;
  final int quantity;
  final int priceAtTime;

  OrderItemModel({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.priceAtTime,
  });

  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    return OrderItemModel(
      id: map['id'],
      orderId: map['order_id'],
      productId: map['product_id'],
      quantity: map['quantity'] ?? 1,
      priceAtTime: map['price_at_time'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'order_id': orderId,
      'product_id': productId,
      'quantity': quantity,
      'price_at_time': priceAtTime,
    };
  }
}
