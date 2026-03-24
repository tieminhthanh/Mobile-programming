// =============================================================
// order_success_screen.dart
// Màn hình sau khi đặt hàng thành công
// =============================================================

import 'package:flutter/material.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key, required this.orderId});
  final int orderId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_outline,
                  size: 80, color: Colors.green),
              const SizedBox(height: 20),
              const Text('Đặt hàng thành công!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Mã đơn hàng: #$orderId',
                  style: const TextStyle(color: Colors.grey, fontSize: 16)),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () =>
                    Navigator.popUntil(context, (route) => route.isFirst),
                child: const Text('Về trang chủ'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                  // Navigate to order history – tuỳ vào routing setup
                },
                child: const Text('Xem lịch sử đơn hàng'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}