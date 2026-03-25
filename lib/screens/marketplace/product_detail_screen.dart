// =============================================================
// product_detail_screen.dart
// Chi tiết sản phẩm
//
// Phân quyền hiển thị (Role-based UI):
// FARMER  : Xem + Chọn số lượng + Thêm vào giỏ + Nút xem Giỏ hàng
// SME     : Xem + Nút Sửa/Xoá (nếu là hàng của mình) - Ẩn giỏ hàng
// ADMIN   : Xem + Nút Xoá (mọi sản phẩm) - Ẩn giỏ hàng
// =============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/product_controller.dart';
import '../../controllers/cart_controller.dart';
import '../../models/product_model.dart';
import '../../core/utils/formatter.dart';
import 'package:guardian/routes/app_routes.dart';
import 'product_form_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.productId});
  final int productId;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  ProductModel? _product;
  List<String> _images = [];
  bool _loading = true;
  double _qty = 1;
  int _currentImage = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final ctrl = context.read<ProductController>();
    _product = await ctrl.getProductDetail(widget.productId);
    _images = await ctrl.getProductImages(widget.productId);
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final cartCtrl = context.watch<CartController>();
    final productCtrl = context.watch<ProductController>();

    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_product == null) {
      return const Scaffold(body: Center(child: Text('Không tìm thấy sản phẩm')));
    }

    final p = _product!;
    final images = _images.isNotEmpty ? _images : [p.imageUrl].whereType<String>().toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(p.title, overflow: TextOverflow.ellipsis),
        actions: [
          // ── ROLE: FARMER ───────────────────────────────────────────
          // Thêm icon giỏ hàng trên góc để Khách hàng tiện bấm
          if (cartCtrl.canBuy)
            Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart_outlined),
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoutes.marketplaceCart),
                ),
                if (cartCtrl.itemCount > 0)
                  Positioned(
                    right: 6,
                    top: 8,
                    child: CircleAvatar(
                      radius: 9,
                      backgroundColor: Colors.red,
                      child: Text(
                        '${cartCtrl.itemCount}',
                        style: const TextStyle(fontSize: 11, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),

          // ── ROLE: SME ──────────────────────────────────────────────
          // SME: Nút sửa (chỉ hiện nếu là sản phẩm của chính họ)
          if (productCtrl.canEdit(p))
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () async {
                final updated = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductFormScreen(product: p),
                  ),
                );
                if (updated == true) _load();
              },
            ),

          // ── ROLE: SME hoặc ADMIN ───────────────────────────────────
          // Nút Xoá (SME xoá hàng của mình, ADMIN xoá mọi thứ)
          if (productCtrl.canDelete(p))
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () async {
                final ok = await _confirmDelete(context);
                if (ok && context.mounted) {
                  await productCtrl.deleteProduct(p);
                  Navigator.pop(context); // Xoá xong thì lùi về trang trước
                }
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image carousel ──────────────────────────────
            if (images.isNotEmpty)
              SizedBox(
                height: 260,
                child: Stack(
                  children: [
                    PageView.builder(
                      itemCount: images.length,
                      onPageChanged: (i) => setState(() => _currentImage = i),
                      itemBuilder: (_, i) => Image.network(
                        images[i],
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                    if (images.length > 1)
                      Positioned(
                        bottom: 8,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            images.length,
                            (i) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              width: _currentImage == i ? 12 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: _currentImage == i
                                    ? Colors.white
                                    : Colors.white54,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              )
            else
              Container(
                height: 200,
                color: Colors.green.shade50,
                child: const Center(
                    child: Icon(Icons.eco, size: 80, color: Colors.green)),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Title + price ────────────────────────
                  Text(p.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        AppFormatter.currency(p.price),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      if (p.unit != null)
                        Text(' / ${p.unit}',
                            style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // ── Category + seller ────────────────────
                  if (p.category != null)
                    Chip(
                      label: Text(p.category!),
                      visualDensity: VisualDensity.compact,
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.store_outlined, size: 16),
                      const SizedBox(width: 4),
                      Text(p.sellerName ?? 'Người bán',
                          style: const TextStyle(fontWeight: FontWeight.w500)),
                    ],
                  ),

                  const Divider(height: 24),

                  // ── Description ──────────────────────────
                  if (p.description != null && p.description!.isNotEmpty) ...[
                    const Text('Mô tả sản phẩm',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(p.description!),
                    const SizedBox(height: 16),
                  ],

                  // ── ROLE: FARMER (CHỈ KHÁCH HÀNG MỚI THẤY PHẦN NÀY) ────────
                  if (cartCtrl.canBuy) ...[
                    const Text('Số lượng',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () =>
                              setState(() => _qty = (_qty - 1).clamp(1, 999)),
                          icon: const Icon(Icons.remove_circle_outline),
                        ),
                        Text('$_qty ${p.unit ?? ''}',
                            style: const TextStyle(fontSize: 16)),
                        IconButton(
                          onPressed: () => setState(() => _qty++),
                          icon: const Icon(Icons.add_circle_outline),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.add_shopping_cart),
                        label: Text(
                          'Thêm vào giỏ  ·  ${AppFormatter.currency(p.price * _qty)}',
                        ),
                        style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                        ),
                        onPressed: () async {
                          await cartCtrl.addToCart(
                            productId: p.productId!,
                            quantity: _qty,
                          );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Đã thêm vào giỏ hàng!')),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Xác nhận xoá'),
            content: const Text('Xoá sản phẩm này?'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Huỷ')),
              TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Xoá', style: TextStyle(color: Colors.red))),
            ],
          ),
        ) ??
        false;
  }
}