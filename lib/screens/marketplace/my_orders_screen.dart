import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/order_model.dart';
import '../../repositories/commerce_repository.dart';
import '../../core/utils/formatter.dart';
import 'package:guardian/routes/app_routes.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key, required this.buyerId});
  final int buyerId;

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  List<OrderModel> _orders = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = context.read<CommerceRepository>();
    _orders = await repo.getOrdersByBuyer(widget.buyerId);
    setState(() => _loading = false);
  }

  static const _statusLabel = {
    'CREATED': 'Đã tạo',
    'PAID': 'Đã thanh toán',
    'SHIPPING': 'Đang giao',
    'COMPLETED': 'Hoàn thành',
    'CANCELLED': 'Đã huỷ',
  };

  static const _statusColor = {
    'CREATED': Colors.orange,
    'PAID': Colors.blue,
    'SHIPPING': Colors.purple,
    'COMPLETED': Colors.green,
    'CANCELLED': Colors.red,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đơn hàng của tôi'), centerTitle: true),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
          ? const Center(child: Text('Bạn chưa có đơn hàng nào'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _orders.length,
              itemBuilder: (_, i) {
                final o = _orders[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    // Dùng InkWell để có hiệu ứng nhấn toàn Card
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.marketplaceOrderDetail,
                      arguments: o,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // --- Header: ID đơn hàng và Trạng thái ---
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Đơn hàng #${o.orderId}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              _buildStatusBadge(o.status),
                            ],
                          ),
                          if (o.createdAt != null)
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 4,
                                bottom: 12,
                              ),
                              child: Text(
                                o.createdAt!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ),

                          const Divider(),

                          // --- Danh sách sản phẩm con ---
                          const Text(
                            'Sản phẩm:',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...o.items
                              .map((item) => _buildProductRow(item))
                              .toList(),

                          const Divider(height: 24),

                          // --- Footer: Tổng cộng tiền ---
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Tổng cộng:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Row(
                                children: [
                                  Text(
                                    AppFormatter.currency(o.orderTotal),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.chevron_right,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  // Widget: Dòng hiển thị từng sản phẩm
  // Trong MyOrdersScreen
  Widget _buildProductRow(OrderItemModel item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 6, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              // Đảm bảo dùng ProductTitle từ JOIN trong SQL của bạn
              '${item.productTitle ?? "Sản phẩm"} (x${item.quantity.toInt()} ${item.productUnit ?? ""})',
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Text(
            AppFormatter.currency(item.subtotal),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // Widget: Badge trạng thái đơn hàng
  Widget _buildStatusBadge(String status) {
    final color = _statusColor[status] ?? Colors.grey;
    final label = _statusLabel[status] ?? status;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
