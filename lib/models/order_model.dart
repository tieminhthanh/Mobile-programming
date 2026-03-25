// =============================================================
// order_model.dart
// Model cho đơn hàng
// =============================================================

class OrderModel {
  final int? orderId;
  final int buyerId;
  final double orderTotal;
  final String status;
  final String? createdAt;

  // Extra fields từ JOIN
  final List<OrderItemModel> items;

  const OrderModel({
    this.orderId,
    required this.buyerId,
    required this.orderTotal,
    this.status = 'CREATED',
    this.createdAt,
    this.items = const [],
  });
  
  OrderModel copyWith({List<OrderItemModel>? items}) {
    return OrderModel(
      orderId: orderId,
      buyerId: buyerId,
      orderTotal: orderTotal,
      status: status,
      createdAt: createdAt,
      items: items ?? this.items,
    );
  }

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      orderId: map['OrderId'] as int?,
      buyerId: map['BuyerId'] as int,
      orderTotal: (map['OrderTotal'] as num).toDouble(),
      status: map['Status'] as String? ?? 'CREATED',
      createdAt: map['CreatedAt'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (orderId != null) 'OrderId': orderId,
      'BuyerId': buyerId,
      'OrderTotal': orderTotal,
      'Status': status,
    };
  }
}

class OrderItemModel {
  final int? orderItemId;
  final int orderId;
  final int productId;
  final double quantity;
  final double price;

  // Extra fields từ JOIN
  final String? productTitle;
  final String? productUnit;
  final String? productImageUrl;

  const OrderItemModel({
    this.orderItemId,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.price,
    this.productTitle,
    this.productUnit,
    this.productImageUrl,
  });

  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    return OrderItemModel(
      orderItemId: map['OrderItemId'] as int?,
      orderId: map['OrderId'] as int,
      productId: map['ProductId'] as int,
      quantity: (map['Quantity'] as num).toDouble(),
      price: (map['Price'] as num).toDouble(),
      productTitle: map['ProductTitle'] as String?,
      productUnit: map['ProductUnit'] as String?,
      productImageUrl: map['ProductImageUrl'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (orderItemId != null) 'OrderItemId': orderItemId,
      'OrderId': orderId,
      'ProductId': productId,
      'Quantity': quantity,
      'Price': price,
    };
  }

  double get subtotal => quantity * price;
}

// =============================================================
// CartItemModel – dùng trong CartController
// =============================================================
class CartItemModel {
  final int? cartItemId;
  final int cartId;
  final int productId;
  double quantity;

  // Extra fields
  final String? productTitle;
  final double? productPrice;
  final String? productUnit;
  final String? productImageUrl;

  CartItemModel({
    this.cartItemId,
    required this.cartId,
    required this.productId,
    required this.quantity,
    this.productTitle,
    this.productPrice,
    this.productUnit,
    this.productImageUrl,
  });

  factory CartItemModel.fromMap(Map<String, dynamic> map) {
    return CartItemModel(
      cartItemId: map['CartItemId'] as int?,
      cartId: map['CartId'] as int,
      productId: map['ProductId'] as int,
      quantity: (map['Quantity'] as num).toDouble(),
      productTitle: map['Title'] as String?,
      productPrice: map['Price'] != null
          ? (map['Price'] as num).toDouble()
          : null,
      productUnit: map['Unit'] as String?,
      productImageUrl: map['ImageUrl'] as String?,
    );
  }

  double get subtotal => quantity * (productPrice ?? 0);
}
