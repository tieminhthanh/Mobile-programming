// =============================================================
// my_products_screen.dart
// SME quản lý sản phẩm của mình
// =============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/product_controller.dart';
import '../../models/product_model.dart';
import '../../core/utils/formatter.dart';
import 'product_form_screen.dart';
import 'product_detail_screen.dart';

class MyProductsScreen extends StatefulWidget {
  const MyProductsScreen({super.key});

  @override
  State<MyProductsScreen> createState() => _MyProductsScreenState();
}

class _MyProductsScreenState extends State<MyProductsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductController>().loadMyProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<ProductController>();

    if (!ctrl.isSME && !ctrl.isAdmin) {
      return const Scaffold(
        body: Center(child: Text('Bạn không có quyền truy cập trang này')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Sản phẩm của tôi')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final ok = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const ProductFormScreen()),
          );
          if (ok == true) ctrl.loadMyProducts();
        },
        icon: const Icon(Icons.add),
        label: const Text('Thêm mới'),
      ),
      body: ctrl.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ctrl.products.isEmpty
              ? const Center(child: Text('Bạn chưa có sản phẩm nào'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: ctrl.products.length,
                  itemBuilder: (_, i) {
                    final p = ctrl.products[i];
                    return _ProductManageTile(
                      product: p,
                      onEdit: () async {
                        final ok = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductFormScreen(product: p),
                          ),
                        );
                        if (ok == true) ctrl.loadMyProducts();
                      },
                      onDelete: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Xác nhận'),
                            content: Text('Xoá "${p.title}"?'),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Huỷ')),
                              TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Xoá',
                                      style: TextStyle(color: Colors.red))),
                            ],
                          ),
                        );
                        if (confirm == true) ctrl.deleteProduct(p);
                      },
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ProductDetailScreen(productId: p.productId!),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

class _ProductManageTile extends StatelessWidget {
  const _ProductManageTile({
    required this.product,
    required this.onEdit,
    required this.onDelete,
    required this.onTap,
  });

  final ProductModel product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: product.imageUrl != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(product.imageUrl!,
                    width: 56, height: 56, fit: BoxFit.cover),
              )
            : Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.eco, color: Colors.green),
              ),
        title: Text(product.title,
            maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          '${AppFormatter.currency(product.price)} / ${product.unit ?? ''}  ·  ${product.category ?? ''}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: Colors.blue),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}