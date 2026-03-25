// =============================================================
// cart_controller.dart
// Controller – Giỏ hàng & Đặt hàng
// Role: chỉ FARMER mới được mua hàng
// =============================================================

import 'package:flutter/foundation.dart';
import 'package:guardian/controllers/session_controller.dart';
import 'package:guardian/models/user.dart';

import '../models/order_model.dart';
import '../models/user_model.dart';
import '../repositories/commerce_repository.dart';

enum CartStatus { idle, loading, ordering, success, error }

class CartController extends ChangeNotifier {
  CartController({
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

  List<CartItemModel> _items = [];
  CartStatus _status = CartStatus.idle;
  String? _errorMessage;
  int? _lastOrderId;

  // ── Getters ──────────────────────────────────────────────

  List<CartItemModel> get items => List.unmodifiable(_items);
  CartStatus get status => _status;
  String? get errorMessage => _errorMessage;
  int? get lastOrderId => _lastOrderId;

  int get itemCount => _items.length;

  double get total => _items.fold(0, (sum, i) => sum + i.subtotal);

  /// Chỉ FARMER mới được dùng giỏ hàng
  bool get canBuy => _activeUser.roleType == 'FARMER';

  // ── Load ─────────────────────────────────────────────────

  Future<void> loadCart() async {
    if (!canBuy) return; // ADMIN / SME không có giỏ

    _setStatus(CartStatus.loading);
    try {
      _items = await _repo.getCartItems(_activeUser.userId);
      _setStatus(CartStatus.idle);
    } catch (e) {
      _setError('Không thể tải giỏ hàng: $e');
    }
  }

  // ── Add / Update / Remove ────────────────────────────────

  Future<void> addToCart({
    required int productId,
    required double quantity,
  }) async {
    if (!canBuy) {
      _setError('Chỉ nông dân mới được thêm vào giỏ hàng');
      return;
    }

    try {
      final cartId = await _repo.getOrCreateCart(_activeUser.userId);
      await _repo.upsertCartItem(
        cartId: cartId,
        productId: productId,
        quantity: quantity,
      );
      await loadCart();
    } catch (e) {
      _setError('Thêm thất bại: $e');
    }
  }

  Future<void> updateQuantity({
    required int cartItemId,
    required double quantity,
  }) async {
    try {
      await _repo.updateCartItemQty(cartItemId: cartItemId, quantity: quantity);
      await loadCart();
    } catch (e) {
      _setError('Cập nhật thất bại: $e');
    }
  }

  Future<void> removeItem(int cartItemId) async {
    try {
      await _repo.removeCartItem(cartItemId);
      _items.removeWhere((i) => i.cartItemId == cartItemId);
      notifyListeners();
    } catch (e) {
      _setError('Xoá thất bại: $e');
    }
  }

  // ── Checkout ─────────────────────────────────────────────
  // ── Checkout ─────────────────────────────────────────────

  // CẬP NHẬT: Nhận vào danh sách những món được tích chọn để mua
  Future<bool> checkout(List<CartItemModel> itemsToBuy) async {
    if (!canBuy) {
      _setError('Không có quyền đặt hàng');
      return false;
    }

    // Đổi biến kiểm tra thành itemsToBuy
    if (itemsToBuy.isEmpty) {
      _setError('Chưa có sản phẩm nào được chọn');
      return false;
    }

    _setStatus(CartStatus.ordering);
    try {
      // 1. Tạo đơn hàng CHỈ VỚI những món được chọn
      _lastOrderId = await _repo.createOrder(
        buyerId: _activeUser.userId,
        items: itemsToBuy,
      );

      // 2. CHỈ XOÁ những món đã thanh toán (giữ lại các món chưa chọn trong giỏ)
      for (final item in itemsToBuy) {
        if (item.cartItemId != null) {
          await _repo.removeCartItem(item.cartItemId!);
        }
      }

      // 3. Tải lại danh sách giỏ hàng mới từ Database
      await loadCart();

      _setStatus(CartStatus.success);
      return true;
    } catch (e) {
      _setError('Đặt hàng thất bại: $e');
      return false;
    }
  }

  // ── Helpers ───────────────────────────────────────────────

  void _setStatus(CartStatus s) {
    _status = s;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String msg) {
    _status = CartStatus.error;
    _errorMessage = msg;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
