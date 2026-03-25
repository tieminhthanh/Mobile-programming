// =============================================================
// product_controller.dart
// Controller – Quản lý sản phẩm Marketplace
//
// Phân quyền:
//   FARMER  → chỉ xem & mua (qua CartController)
//   SME     → xem + tạo/sửa/xoá sản phẩm của mình
//   ADMIN   → xem tất cả + xoá bất kỳ sản phẩm
// =============================================================

import 'package:flutter/foundation.dart';
import 'package:guardian/controllers/session_controller.dart';
import 'package:guardian/models/user.dart';

import '../models/product_model.dart';
import '../models/user_model.dart';
import '../repositories/commerce_repository.dart';

enum ProductStatus { idle, loading, saving, deleting, error }

class ProductController extends ChangeNotifier {
  ProductController({
    required CommerceRepository repository,
  }) : _repo = repository;

  final CommerceRepository _repo;

  UserModel get _activeUser {
    final sessionUser = SessionController.instance.currentUser.value;
    final roleType = switch (sessionUser?.role) {
      UserRole.admin => 'ADMIN',
      UserRole.sme => 'SME',
      UserRole.farmer => 'FARMER',
      null => 'GUEST',
    };

    return UserModel(
      userId: sessionUser?.id ?? 0,
      phoneNumber: sessionUser?.phoneNumber ?? '',
      roleType: roleType,
      displayName: sessionUser?.displayName ?? 'Guest',
    );
  }

  List<ProductModel> _products = [];
  List<String> _categories = [];
  String? _selectedCategory;
  ProductStatus _status = ProductStatus.idle;
  String? _errorMessage;

  // ── Getters ──────────────────────────────────────────────

  List<ProductModel> get products => List.unmodifiable(_products);
  List<String> get categories => List.unmodifiable(_categories);
  String? get selectedCategory => _selectedCategory;
  ProductStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == ProductStatus.loading;

  // Phân quyền
  bool get canSell =>
      _activeUser.roleType == 'SME' || _activeUser.roleType == 'FARMER';
  bool get isAdmin => _activeUser.roleType == 'ADMIN';
  bool get isSME => _activeUser.roleType == 'SME';
  bool get isFarmer => _activeUser.roleType == 'FARMER';

  bool canEdit(ProductModel product) {
    if (isAdmin) return true;
    if (!isSME) {
      return false; // CHẶN: Nếu không phải Admin và không phải SME thì cấm sửa
    }
    return product.sellerId == _activeUser.userId;
  }

  bool canDelete(ProductModel product) {
    if (isAdmin) return true;
    if (!isSME) {
      return false; // CHẶN: Nếu không phải Admin và không phải SME thì cấm xoá
    }
    return product.sellerId == _activeUser.userId;
  }

  // ── Load ─────────────────────────────────────────────────

  Future<void> loadProducts() async {
    _setStatus(ProductStatus.loading);
    try {
      _products = await _repo.getAllProducts(category: _selectedCategory);
      _categories = await _repo.getCategories();
      _setStatus(ProductStatus.idle);
    } catch (e) {
      _setError('Không thể tải sản phẩm: $e');
    }
  }

  /// SME tải sản phẩm của chính mình
  Future<void> loadMyProducts() async {
    if (!canSell) return;
    _setStatus(ProductStatus.loading);
    try {
      _products = await _repo.getProductsBySeller(_activeUser.userId);
      _setStatus(ProductStatus.idle);
    } catch (e) {
      _setError('Không thể tải sản phẩm: $e');
    }
  }

  Future<ProductModel?> getProductDetail(int productId) async {
    try {
      return await _repo.getProductById(productId);
    } catch (e) {
      _setError('Không thể tải chi tiết: $e');
      return null;
    }
  }

  Future<List<String>> getProductImages(int productId) async {
    try {
      return await _repo.getProductImages(productId);
    } catch (_) {
      return [];
    }
  }

  // ── Filter ───────────────────────────────────────────────

  void filterByCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
    loadProducts();
  }

  // ── Create / Update / Delete ─────────────────────────────

  /// Tạo sản phẩm – chỉ SME (FARMER thường không bán qua app)
  Future<bool> createProduct(ProductModel product) async {
    if (!isSME && !isAdmin) {
      _setError('Chỉ SME mới được tạo sản phẩm');
      return false;
    }

    _setStatus(ProductStatus.saving);
    try {
      // Gắn đúng sellerId từ user hiện tại
      final toSave = ProductModel(
        sellerId: _activeUser.userId,
        title: product.title,
        description: product.description,
        category: product.category,
        price: product.price,
        unit: product.unit,
      );

      await _repo.createProduct(toSave);
      await loadMyProducts();
      return true;
    } catch (e) {
      _setError('Tạo sản phẩm thất bại: $e');
      return false;
    }
  }

  /// Sửa sản phẩm – chỉ chủ sở hữu hoặc ADMIN
  Future<bool> updateProduct(ProductModel product) async {
    if (!canEdit(product)) {
      _setError('Bạn không có quyền sửa sản phẩm này');
      return false;
    }

    _setStatus(ProductStatus.saving);
    try {
      await _repo.updateProduct(product);

      // CHỖ CẦN SỬA: Tải lại toàn bộ danh sách để UI nhận giá trị mới
      await loadProducts();

      _setStatus(ProductStatus.idle);
      return true;
    } catch (e) {
      _setError('Cập nhật thất bại: $e');
      return false;
    }
  }

  /// Xoá sản phẩm
  Future<bool> deleteProduct(ProductModel product) async {
    if (!canDelete(product)) {
      _setError('Bạn không có quyền xoá sản phẩm này');
      return false;
    }

    _setStatus(ProductStatus.deleting);
    try {
      await _repo.deleteProduct(
        productId: product.productId!,
        sellerId: isAdmin ? null : _activeUser.userId,
      );
      _products.removeWhere((p) => p.productId == product.productId);
      _setStatus(ProductStatus.idle);
      return true;
    } catch (e) {
      _setError('Xoá thất bại: $e');
      return false;
    }
  }

  // ── Helpers ───────────────────────────────────────────────

  void _setStatus(ProductStatus s) {
    _status = s;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String msg) {
    _status = ProductStatus.error;
    _errorMessage = msg;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
