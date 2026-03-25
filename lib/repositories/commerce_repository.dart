// =============================================================
// commerce_repository.dart
// Data Layer – tất cả SQL query cho Marketplace
// =============================================================

import '../core/database/database_helper.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';

class CommerceRepository {
  CommerceRepository(this._db);

  final DatabaseService _db;

  // ===========================================================
  // PRODUCTS
  // ===========================================================

  /// Lấy tất cả sản phẩm (kèm tên người bán + ảnh chính)
  Future<List<ProductModel>> getAllProducts({String? category}) async {
    String sql = '''
      SELECT
        p.ProductId, p.SellerId, p.Title, p.Description,
        p.Category, p.Price, p.Unit, p.CreatedAt,
        u.DisplayName AS SellerName,
        i.ImageUrl AS ImageUrl
      FROM commerce_Products p
      JOIN Users u ON p.SellerId = u.UserId
      LEFT JOIN Images i ON i.ReferenceId = p.ProductId
        AND i.ReferenceType = 'PRODUCT' AND i.IsPrimary = 1
    ''';

    final args = <dynamic>[];
    if (category != null && category.isNotEmpty) {
      sql += ' WHERE p.Category = ?';
      args.add(category);
    }

    sql += ' ORDER BY p.CreatedAt DESC';

    final rows = await _db.rawQuery(sql, args.isEmpty ? null : args);
    return rows.map(ProductModel.fromMap).toList();
  }

  /// Lấy sản phẩm theo người bán (SME/FARMER tự xem hàng mình)
  Future<List<ProductModel>> getProductsBySeller(int sellerId) async {
    final rows = await _db.rawQuery(
      '''
      SELECT
        p.ProductId, p.SellerId, p.Title, p.Description,
        p.Category, p.Price, p.Unit, p.CreatedAt,
        u.DisplayName AS SellerName,
        i.ImageUrl AS ImageUrl
      FROM commerce_Products p
      JOIN Users u ON p.SellerId = u.UserId
      LEFT JOIN Images i ON i.ReferenceId = p.ProductId
        AND i.ReferenceType = 'PRODUCT' AND i.IsPrimary = 1
      WHERE p.SellerId = ?
      ORDER BY p.CreatedAt DESC
    ''',
      [sellerId],
    );

    return rows.map(ProductModel.fromMap).toList();
  }

  /// Lấy chi tiết 1 sản phẩm
  Future<ProductModel?> getProductById(int productId) async {
    final rows = await _db.rawQuery(
      '''
      SELECT
        p.ProductId, p.SellerId, p.Title, p.Description,
        p.Category, p.Price, p.Unit, p.CreatedAt,
        u.DisplayName AS SellerName, u.Email AS SellerEmail,
        i.ImageUrl AS ImageUrl
      FROM commerce_Products p
      JOIN Users u ON p.SellerId = u.UserId
      LEFT JOIN Images i ON i.ReferenceId = p.ProductId
        AND i.ReferenceType = 'PRODUCT' AND i.IsPrimary = 1
      WHERE p.ProductId = ?
    ''',
      [productId],
    );

    if (rows.isEmpty) return null;
    return ProductModel.fromMap(rows.first);
  }

  /// Lấy tất cả ảnh của sản phẩm
  Future<List<String>> getProductImages(int productId) async {
    final rows = await _db.query(
      'Images',
      columns: ['ImageUrl'],
      where: "ReferenceId = ? AND ReferenceType = 'PRODUCT'",
      whereArgs: [productId],
      orderBy: 'IsPrimary DESC, DisplayOrder ASC',
    );
    return rows.map((r) => r['ImageUrl'] as String).toList();
  }

  /// Tạo sản phẩm mới – chỉ SME / FARMER
  Future<int> createProduct(ProductModel product) async {
    return _db.insert('commerce_Products', product.toMap());
  }

  /// Cập nhật sản phẩm – chỉ chủ sở hữu
  Future<int> updateProduct(ProductModel product) async {
    assert(product.productId != null, 'productId phải có để update');
    return _db.update(
      'commerce_Products',
      product.toMap(),
      where: 'ProductId = ? AND SellerId = ?',
      whereArgs: [product.productId, product.sellerId],
    );
  }

  /// Xoá sản phẩm – chủ sở hữu hoặc ADMIN
  Future<int> deleteProduct({
    required int productId,
    int? sellerId, // null = ADMIN xoá bất kỳ
  }) async {
    if (sellerId != null) {
      return _db.delete(
        'commerce_Products',
        where: 'ProductId = ? AND SellerId = ?',
        whereArgs: [productId, sellerId],
      );
    }
    return _db.delete(
      'commerce_Products',
      where: 'ProductId = ?',
      whereArgs: [productId],
    );
  }

  // ===========================================================
  // CART
  // ===========================================================

  /// Lấy hoặc tạo CartId cho user
  Future<int> getOrCreateCart(int userId) async {
    final rows = await _db.query(
      'commerce_Carts',
      columns: ['CartId'],
      where: 'UserId = ?',
      whereArgs: [userId],
      limit: 1,
    );
    if (rows.isNotEmpty) return rows.first['CartId'] as int;
    return _db.insert('commerce_Carts', {'UserId': userId});
  }

  /// Lấy danh sách items trong giỏ (kèm thông tin sản phẩm)
  Future<List<CartItemModel>> getCartItems(int userId) async {
    final rows = await _db.rawQuery(
      '''
      SELECT
        ci.CartItemId, ci.CartId, ci.ProductId, ci.Quantity,
        p.Title, p.Price, p.Unit,
        i.ImageUrl
      FROM commerce_CartItems ci
      JOIN commerce_Carts c ON c.CartId = ci.CartId
      JOIN commerce_Products p ON p.ProductId = ci.ProductId
      LEFT JOIN Images i ON i.ReferenceId = ci.ProductId
        AND i.ReferenceType = 'PRODUCT' AND i.IsPrimary = 1
      WHERE c.UserId = ?
    ''',
      [userId],
    );

    return rows.map(CartItemModel.fromMap).toList();
  }

  /// Thêm hoặc cập nhật item trong giỏ
  Future<void> upsertCartItem({
    required int cartId,
    required int productId,
    required double quantity,
  }) async {
    // Kiểm tra đã có trong giỏ chưa
    final existing = await _db.query(
      'commerce_CartItems',
      where: 'CartId = ? AND ProductId = ?',
      whereArgs: [cartId, productId],
      limit: 1,
    );

    if (existing.isEmpty) {
      await _db.insert('commerce_CartItems', {
        'CartId': cartId,
        'ProductId': productId,
        'Quantity': quantity,
      });
    } else {
      final newQty = (existing.first['Quantity'] as num).toDouble() + quantity;
      await _db.update(
        'commerce_CartItems',
        {'Quantity': newQty},
        where: 'CartId = ? AND ProductId = ?',
        whereArgs: [cartId, productId],
      );
    }
  }

  /// Cập nhật số lượng 1 item
  Future<void> updateCartItemQty({
    required int cartItemId,
    required double quantity,
  }) async {
    if (quantity <= 0) {
      await _db.delete(
        'commerce_CartItems',
        where: 'CartItemId = ?',
        whereArgs: [cartItemId],
      );
    } else {
      await _db.update(
        'commerce_CartItems',
        {'Quantity': quantity},
        where: 'CartItemId = ?',
        whereArgs: [cartItemId],
      );
    }
  }

  /// Xoá item khỏi giỏ
  Future<void> removeCartItem(int cartItemId) async {
    await _db.delete(
      'commerce_CartItems',
      where: 'CartItemId = ?',
      whereArgs: [cartItemId],
    );
  }

  /// Xoá toàn bộ giỏ sau khi đặt hàng
  Future<void> clearCart(int cartId) async {
    await _db.delete(
      'commerce_CartItems',
      where: 'CartId = ?',
      whereArgs: [cartId],
    );
  }

  // ===========================================================
  // ORDERS
  // ===========================================================

  /// Tạo đơn hàng mới từ danh sách items
  Future<int> createOrder({
    required int buyerId,
    required List<CartItemModel> items,
  }) async {
    final total = items.fold<double>(0, (sum, i) => sum + i.subtotal);

    final orderId = await _db.insert('commerce_Orders', {
      'BuyerId': buyerId,
      'OrderTotal': total,
      'Status': 'CREATED',
    });

    await _db.batchInsert(
      'commerce_OrderItems',
      items
          .map(
            (i) => {
              'OrderId': orderId,
              'ProductId': i.productId,
              'Quantity': i.quantity,
              'Price': i.productPrice ?? 0,
            },
          )
          .toList(),
    );

    return orderId;
  }

  /// Lấy danh sách đơn hàng của người mua
  // Trong file commerce_repository.dart

  Future<List<OrderModel>> getOrdersByBuyer(int buyerId) async {
    // 1. Lấy danh sách đơn hàng "thô" từ bảng Orders
    final rows = await _db.query(
      'commerce_Orders',
      where: 'BuyerId = ?',
      whereArgs: [buyerId],
      orderBy: 'CreatedAt DESC',
    );

    List<OrderModel> orders = [];

    // 2. Với mỗi đơn hàng, ta đi lấy danh sách Items của nó
    for (var row in rows) { 
      OrderModel order = OrderModel.fromMap(row);

      // Gọi hàm getOrderItems đã có sẵn của bạn để lấy chi tiết sản phẩm
      final items = await getOrderItems(order.orderId!);

      // Gán danh sách items vào đơn hàng và thêm vào list kết quả
      orders.add(order.copyWith(items: items));
    }

    return orders;
  }

  /// Lấy items của 1 đơn hàng
  Future<List<OrderItemModel>> getOrderItems(int orderId) async {
    final rows = await _db.rawQuery(
      '''
      SELECT
        oi.OrderItemId, oi.OrderId, oi.ProductId, oi.Quantity, oi.Price,
        p.Title AS ProductTitle, p.Unit AS ProductUnit,
        i.ImageUrl AS ProductImageUrl
      FROM commerce_OrderItems oi
      JOIN commerce_Products p ON p.ProductId = oi.ProductId
      LEFT JOIN Images i ON i.ReferenceId = oi.ProductId
        AND i.ReferenceType = 'PRODUCT' AND i.IsPrimary = 1
      WHERE oi.OrderId = ?
    ''',
      [orderId],
    );

    return rows.map(OrderItemModel.fromMap).toList();
  }

  /// Admin lấy tất cả đơn hàng
  Future<List<OrderModel>> getAllOrders() async {
    final rows = await _db.query('commerce_Orders', orderBy: 'CreatedAt DESC');
    return rows.map(OrderModel.fromMap).toList();
  }

  /// Cập nhật trạng thái đơn hàng
  Future<int> updateOrderStatus({
    required int orderId,
    required String status,
  }) async {
    return _db.update(
      'commerce_Orders',
      {'Status': status},
      where: 'OrderId = ?',
      whereArgs: [orderId],
    );
  }

  // ===========================================================
  // CATEGORIES (derived from data)
  // ===========================================================

  Future<List<String>> getCategories() async {
    final rows = await _db.rawQuery(
      "SELECT DISTINCT Category FROM commerce_Products WHERE Category IS NOT NULL ORDER BY Category",
    );
    return rows.map((r) => r['Category'] as String).toList();
  }

  /// Thống kê doanh thu theo ngày cho biểu đồ (7 ngày gần nhất)
  Future<List<Map<String, dynamic>>> getRevenueStats({int? sellerId}) async {
    String sql = '''
      SELECT 
        date(CreatedAt) as day, 
        SUM(OrderTotal) as total 
      FROM commerce_Orders 
      WHERE Status = 'COMPLETED' 
    ''';
    
    if (sellerId != null) {
      // Nếu là SME, chỉ tính doanh thu từ sản phẩm của họ
      sql = '''
        SELECT date(o.CreatedAt) as day, SUM(oi.Price * oi.Quantity) as total
        FROM commerce_Orders o
        JOIN commerce_OrderItems oi ON o.OrderId = oi.OrderId
        JOIN commerce_Products p ON oi.ProductId = p.ProductId
        WHERE p.SellerId = ? AND o.Status = 'COMPLETED'
        GROUP BY day ORDER BY day DESC LIMIT 7
      ''';
      return await _db.rawQuery(sql, [sellerId]);
    }
    
    sql += ' GROUP BY day ORDER BY day DESC LIMIT 7';
    return await _db.rawQuery(sql);
  }
}
