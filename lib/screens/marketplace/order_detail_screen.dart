import 'package:flutter/material.dart';
import '../../models/order_model.dart';
import '../../core/utils/formatter.dart';

class OrderDetailScreen extends StatelessWidget {
  // Sử dụng đúng model OrderModel bạn đã cung cấp
  final OrderModel order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Đơn hàng #${order.orderId ?? '...'}'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Trạng thái & Thời gian
            _buildInfoCard(context),
            const SizedBox(height: 20),

            // 2. Danh sách sản phẩm (OrderItemModel)
            const Text('Sản phẩm đã đặt', 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildItemsList(),
            
            const Divider(height: 40),

            // 3. Tổng cộng (orderTotal)
            _buildTotalSection(context),
            const SizedBox(height: 32),

            // 4. Các nút hành động
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  // Widget: Thẻ thông tin chung (Status & Ngày tạo)
  Widget _buildInfoCard(BuildContext context) {
    // Map trạng thái sang màu sắc cho dễ nhìn
    Color statusColor;
    String statusLabel;
    
    switch (order.status.toUpperCase()) {
      case 'COMPLETED':
        statusColor = Colors.green;
        statusLabel = 'Đã hoàn thành';
        break;
      case 'CANCELLED':
        statusColor = Colors.red;
        statusLabel = 'Đã hủy';
        break;
      case 'CREATED':
      default:
        statusColor = Colors.orange;
        statusLabel = 'Đang xử lý';
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Ngày đặt: ${order.createdAt ?? 'Không rõ'}', 
                  style: const TextStyle(fontSize: 13, color: Colors.black54)),
              const SizedBox(height: 4),
              Text(statusLabel, 
                  style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          Icon(Icons.assignment_turned_in_outlined, color: statusColor, size: 32),
        ],
      ),
    );
  }

  // Widget: Danh sách các Item
  Widget _buildItemsList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: order.items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (ctx, index) {
        final item = order.items[index];
        return Row(
          children: [
            // Ảnh sản phẩm
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: item.productImageUrl != null
                  ? Image.network(item.productImageUrl!, width: 55, height: 55, fit: BoxFit.cover)
                  : Container(width: 55, height: 55, color: Colors.green.shade50, child: const Icon(Icons.eco, color: Colors.green)),
            ),
            const SizedBox(width: 12),
            // Thông tin tên, đơn giá, số lượng
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.productTitle ?? 'Sản phẩm', 
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  Text(
                    '${AppFormatter.currency(item.price)} × ${item.quantity} ${item.productUnit ?? ''}',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
              ),
            ),
            // Thành tiền từng món (Sử dụng getter subtotal bạn đã viết)
            Text(AppFormatter.currency(item.subtotal), 
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        );
      },
    );
  }

  // Widget: Tổng kết thanh toán
  Widget _buildTotalSection(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Tổng thanh toán', 
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            Text(
              AppFormatter.currency(order.orderTotal),
              style: TextStyle(
                fontSize: 22, 
                fontWeight: FontWeight.bold, 
                color: Theme.of(context).colorScheme.primary
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Widget: Nút hỗ trợ & Mua lại
  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: () {
              // TODO: Thêm logic copy các item này vào giỏ hàng để mua lại
            },
            icon: const Icon(Icons.refresh),
            label: const Text('ĐẶT MUA LẠI ĐƠN NÀY'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: () {
              // TODO: Chuyển hướng đến Zalo/SDT hỗ trợ
            },
            icon: const Icon(Icons.headset_mic_outlined),
            label: const Text('LIÊN HỆ HỖ TRỢ'),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
      ],
    );
  }
}