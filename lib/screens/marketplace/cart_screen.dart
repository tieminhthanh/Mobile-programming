import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/cart_controller.dart';
import '../../models/order_model.dart';
import '../../core/utils/formatter.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final Set<int> _selectedIds = {};

  // 1. Hàm hiển thị xác nhận xóa (Dùng chung cho cả xóa lẻ và giảm về 0)
  Future<bool> _confirmDelete(BuildContext context, String title) async {
    return await showModalBottomSheet<bool>(
          context: context,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
          builder: (ctx) => Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 48),
                const SizedBox(height: 16),
                Text('Xác nhận bỏ sản phẩm?',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Bạn muốn xóa "$title" khỏi giỏ hàng?', textAlign: TextAlign.center),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Giữ lại'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red, foregroundColor: Colors.white),
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Đồng ý xóa'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<CartController>();

    if (!ctrl.canBuy) {
      return const Scaffold(body: Center(child: Text('Bạn không có quyền xem giỏ hàng')));
    }

    final selectedItems = ctrl.items.where((item) => _selectedIds.contains(item.cartItemId)).toList();
    final selectedTotal = selectedItems.fold<double>(0, (sum, item) => sum + item.subtotal);
    final isAllSelected = ctrl.items.isNotEmpty && _selectedIds.length == ctrl.items.length;

    return Scaffold(
      appBar: AppBar(title: Text('Giỏ hàng (${ctrl.itemCount})')),
      body: ctrl.items.isEmpty
          ? _buildEmptyCart()
          : Column(
              children: [
                // ── Thanh công cụ: Chọn tất cả & Xóa hàng loạt ──────────
                _buildHeaderActions(isAllSelected, ctrl),
                const Divider(height: 1),

                // ── Danh sách sản phẩm ────────────────────────────
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: ctrl.items.length,
                    itemBuilder: (_, i) {
                      final item = ctrl.items[i];
                      return _CartItemTile(
                        item: item,
                        isSelected: _selectedIds.contains(item.cartItemId),
                        // Truyền callback xác nhận vào Tile
                        onConfirmDelete: () => _confirmDelete(context, item.productTitle ?? ''),
                        onToggleSelect: (val) {
                          setState(() {
                            if (val == true) {
                              _selectedIds.add(item.cartItemId!);
                            } else {
                              _selectedIds.remove(item.cartItemId);
                            }
                          });
                        },
                      );
                    },
                  ),
                ),

                // ── Thanh thanh toán đáy màn hình ───────────────────
                _buildBottomCheckout(selectedTotal, selectedItems),
              ],
            ),
    );
  }

  // Widget: Giỏ hàng trống
  Widget _buildEmptyCart() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 12),
          Text('Giỏ hàng đang trống', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  // Widget: Header chọn tất cả
  Widget _buildHeaderActions(bool isAllSelected, CartController ctrl) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Checkbox(
            value: isAllSelected,
            onChanged: (val) {
              setState(() {
                if (val == true) {
                  _selectedIds.addAll(ctrl.items.map((e) => e.cartItemId!).toList());
                } else {
                  _selectedIds.clear();
                }
              });
            },
          ),
          const Text('Chọn tất cả', style: TextStyle(fontWeight: FontWeight.bold)),
          const Spacer(),
          if (_selectedIds.isNotEmpty)
            TextButton.icon(
              onPressed: () async {
                // Hỏi trước khi xóa hàng loạt
                final confirm = await _confirmDelete(context, "${_selectedIds.length} sản phẩm đã chọn");
                if (confirm) {
                  for (var id in _selectedIds) {
                    await ctrl.removeItem(id);
                  }
                  setState(() => _selectedIds.clear());
                }
              },
              icon: const Icon(Icons.delete_outline, size: 18),
              label: const Text('Xoá đã chọn'),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
            )
        ],
      ),
    );
  }

  // Widget: Bottom Checkout
  Widget _buildBottomCheckout(double total, List<CartItemModel> items) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -2))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Tổng thanh toán', style: TextStyle(color: Colors.grey)),
                Text(AppFormatter.currency(total),
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: items.isEmpty
                ? null
                : () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CheckoutScreen(selectedItems: items, totalAmount: total),
                      ),
                    ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            child: Text('Mua hàng (${items.length})'),
          ),
        ],
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  const _CartItemTile({
    required this.item,
    required this.isSelected,
    required this.onToggleSelect,
    required this.onConfirmDelete,
  });

  final CartItemModel item;
  final bool isSelected;
  final ValueChanged<bool?> onToggleSelect;
  final Future<bool> Function() onConfirmDelete;

  @override
  Widget build(BuildContext context) {
    final ctrl = context.read<CartController>();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Checkbox(value: isSelected, onChanged: onToggleSelect),
            
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: item.productImageUrl != null
                  ? Image.network(item.productImageUrl!, width: 60, height: 60, fit: BoxFit.cover)
                  : Container(width: 60, height: 60, color: Colors.green.shade50, child: const Icon(Icons.eco)),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.productTitle ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(AppFormatter.currency(item.subtotal),
                      style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                  
                  // Bộ tăng giảm số lượng
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, size: 18),
                              onPressed: () async {
                                if (item.quantity > 1) {
                                  ctrl.updateQuantity(cartItemId: item.cartItemId!, quantity: item.quantity - 1);
                                } else {
                                  // Khi số lượng = 1, nhấn trừ sẽ hỏi xóa
                                  if (await onConfirmDelete()) {
                                    ctrl.removeItem(item.cartItemId!);
                                  }
                                }
                              },
                            ),
                            Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: const Icon(Icons.add, size: 18),
                              onPressed: () => ctrl.updateQuantity(
                                  cartItemId: item.cartItemId!, quantity: item.quantity + 1),
                            ),
                          ],
                        ),
                      ),
                      
                      // Nút xóa nhanh
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () async {
                          if (await onConfirmDelete()) {
                            ctrl.removeItem(item.cartItemId!);
                          }
                        },
                      ),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}