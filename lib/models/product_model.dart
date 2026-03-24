// =============================================================
// product_model.dart
// Model cho sản phẩm trong marketplace
// =============================================================

class ProductModel {
  final int? productId;
  final int sellerId;
  final String title;
  final String? description;
  final String? category;
  final double price;
  final String? unit;
  final String? createdAt;

  // Extra fields từ JOIN (không lưu trong DB)
  final String? sellerName;
  final String? sellerEmail;
  final String? imageUrl;

  const ProductModel({
    this.productId,
    required this.sellerId,
    required this.title,
    this.description,
    this.category,
    required this.price,
    this.unit,
    this.createdAt,
    this.sellerName,
    this.sellerEmail,
    this.imageUrl,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      productId: map['ProductId'] as int?,
      sellerId: map['SellerId'] as int,
      title: map['Title'] as String,
      description: map['Description'] as String?,
      category: map['Category'] as String?,
      price: (map['Price'] as num).toDouble(),
      unit: map['Unit'] as String?,
      createdAt: map['CreatedAt'] as String?,
      sellerName: map['SellerName'] as String?,
      sellerEmail: map['SellerEmail'] as String?,
      imageUrl: map['ImageUrl'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (productId != null) 'ProductId': productId,
      'SellerId': sellerId,
      'Title': title,
      if (description != null) 'Description': description,
      if (category != null) 'Category': category,
      'Price': price,
      if (unit != null) 'Unit': unit,
    };
  }

  ProductModel copyWith({
    int? productId,
    int? sellerId,
    String? title,
    String? description,
    String? category,
    double? price,
    String? unit,
    String? sellerName,
    String? imageUrl,
  }) {
    return ProductModel(
      productId: productId ?? this.productId,
      sellerId: sellerId ?? this.sellerId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      price: price ?? this.price,
      unit: unit ?? this.unit,
      createdAt: createdAt,
      sellerName: sellerName ?? this.sellerName,
      sellerEmail: sellerEmail,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}