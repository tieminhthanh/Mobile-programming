import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:guardian/routes/app_routes.dart';
import '../../controllers/cart_controller.dart';
import '../../models/order_model.dart';
import '../../core/utils/formatter.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({
    super.key,
    required this.selectedItems,
    required this.totalAmount,
  });

  final List<CartItemModel> selectedItems;
  final double totalAmount;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  // Tạo bản sao local để có thể xóa item tạm thời nếu cần
  late List<CartItemModel> _displayItems;
  late double _currentTotal;

  @override
  void initState() {
    super.initState();
    _displayItems = List.from(widget.selectedItems);
    _currentTotal = widget.totalAmount;
  }

  // 1. Hàm xác nhận xóa sản phẩm
  Future<void> _removeItem(int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn muốn bỏ "${_displayItems[index].productTitle}" khỏi đơn hàng này?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _currentTotal -= _displayItems[index].subtotal;
        _displayItems.removeAt(index);
      });
      
      // Nếu xóa hết sạch thì quay về
      if (_displayItems.isEmpty && mounted) {
        Navigator.pop(context);
      }
    }
  }

  // 2. Hàm xác nhận đặt hàng cuối cùng
  Future<void> _confirmOrder(CartController ctrl) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận đặt hàng'),
        content: Text('Tổng tiền: ${AppFormatter.currency(_currentTotal)}\nBạn có chắc chắn muốn đặt đơn hàng này?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Kiểm tra lại')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Đồng ý'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final ok = await ctrl.checkout(_displayItems);
      if (ok && mounted) {
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.marketplaceOrderSuccess,
          arguments: ctrl.lastOrderId!,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<CartController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Xác nhận đơn hàng')),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _displayItems.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (ctx, index) {
                final item = _displayItems[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(item.productTitle ?? 'Sản phẩm', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                      '${item.quantity} ${item.productUnit ?? ''} × ${AppFormatter.currency(item.productPrice ?? 0)}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(AppFormatter.currency(item.subtotal), style: const TextStyle(fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => _removeItem(index),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Hiển thị tổng tiền và nút thanh toán
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, spreadRadius: 1)],
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Tổng thanh toán', style: TextStyle(fontSize: 16)),
                      Text(
                        AppFormatter.currency(_currentTotal),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: ctrl.status == CartStatus.ordering ? null : () => _confirmOrder(ctrl),
                      child: ctrl.status == CartStatus.ordering
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('XÁC NHẬN ĐẶT HÀNG', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}