// =============================================================
// shop_home_screen.dart
// Màn hình chính Marketplace
// Hiển thị danh sách sản phẩm + filter category + search
// Không còn nút Xoá ngoài màn hình chính.
// =============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/product_controller.dart';
import '../../controllers/cart_controller.dart';
import '../../models/product_model.dart';
import '../../core/utils/formatter.dart';

class ShopHomeScreen extends StatefulWidget {
  const ShopHomeScreen({super.key});

  @override
  State<ShopHomeScreen> createState() => _ShopHomeScreenState();
}

class _ShopHomeScreenState extends State<ShopHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductController>().loadProducts();
      if (context.read<CartController>().canBuy) {
        context.read<CartController>().loadCart();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productCtrl = context.watch<ProductController>();
    final cartCtrl = context.watch<CartController>();

    final displayProducts = _searchQuery.isEmpty
        ? productCtrl.products
        : productCtrl.products
              .where(
                (p) =>
                    p.title.toLowerCase().contains(_searchQuery.toLowerCase()),
              )
              .toList();

    String roleName = 'Khách (Chỉ xem)';
    if (productCtrl.isSME) roleName = 'SME (Người Bán)';
    if (productCtrl.isFarmer) roleName = 'Khách Hàng (Nông Dân)';
    if (productCtrl.isAdmin) roleName = 'Quản Trị Viên (ADMIN)';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Cửa Hàng Xanh'),
            Text(
              'Đang đăng nhập: $roleName',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),

        actions: [
          // Trong phần actions của AppBar
          if (productCtrl.isAdmin || productCtrl.isSME)
            IconButton(
              icon: const Icon(Icons.dashboard_customize_outlined),
              tooltip: 'Bảng điều khiển',
              onPressed: () => Navigator.pushNamed(context, '/admin-dashboard'),
            ),
          if (cartCtrl.canBuy)
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart_outlined),
                  onPressed: () => Navigator.pushNamed(context, '/cart'),
                ),
                if (cartCtrl.itemCount > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: CircleAvatar(
                      radius: 9,
                      backgroundColor: Colors.red,
                      child: Text(
                        '${cartCtrl.itemCount}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          if (cartCtrl.canBuy)
            IconButton(
              icon: const Icon(Icons.receipt_long_outlined),
              onPressed: () =>
                  Navigator.pushNamed(context, '/my-orders', arguments: 1),
            ),
        ],
      ),

      floatingActionButton: productCtrl.isSME
          ? FloatingActionButton.extended(
              onPressed: () async {
                final created = await Navigator.pushNamed(
                  context,
                  '/product-form',
                );
                if (created == true) productCtrl.loadProducts();
              },
              icon: const Icon(Icons.add),
              label: const Text('Thêm sản phẩm'),
            )
          : null,

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm sản phẩm...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),

          if (productCtrl.categories.isNotEmpty)
            SizedBox(
              height: 52,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                children: [
                  _CategoryChip(
                    label: 'Tất cả',
                    selected: productCtrl.selectedCategory == null,
                    onTap: () => productCtrl.filterByCategory(null),
                  ),
                  ...productCtrl.categories.map(
                    (cat) => _CategoryChip(
                      label: cat,
                      selected: productCtrl.selectedCategory == cat,
                      onTap: () => productCtrl.filterByCategory(cat),
                    ),
                  ),
                ],
              ),
            ),

          Expanded(
            child: productCtrl.isLoading
                ? const Center(child: CircularProgressIndicator())
                : displayProducts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        const Text('Không tìm thấy sản phẩm nào'),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.72,
                        ),
                    itemCount: displayProducts.length,
                    itemBuilder: (_, i) => _ProductCard(
                      product: displayProducts[i],
                      canAddToCart: cartCtrl.canBuy,
                      // Đã bỏ truyền tham số onDelete ở đây
                      onAddToCart: () async {
                        await cartCtrl.addToCart(
                          productId: displayProducts[i].productId!,
                          quantity: 1,
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Đã thêm vào giỏ hàng'),
                            ),
                          );
                        }
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Widgets ───────────────────────────────────────────────────

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: Theme.of(context).colorScheme.primaryContainer,
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.canAddToCart,
    required this.onAddToCart,
  }); // Đã bỏ canManage và onDelete khỏi constructor

  final ProductModel product;
  final bool canAddToCart;
  final VoidCallback onAddToCart;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        '/product-detail',
        arguments: product.productId!,
      ),
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: product.imageUrl != null
                  ? Image.network(
                      product.imageUrl!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    )
                  : Container(
                      color: Colors.green.shade50,
                      child: const Center(
                        child: Icon(Icons.eco, size: 48, color: Colors.green),
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${AppFormatter.currency(product.price)} / ${product.unit ?? ''}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Chỉ còn duy nhất nút Thêm vào giỏ hàng
                  if (canAddToCart)
                    SizedBox(
                      width: double
                          .infinity, // Cho nút Thêm giãn dài ra nhìn đẹp hơn
                      child: ElevatedButton.icon(
                        onPressed: onAddToCart,
                        icon: const Icon(Icons.add_shopping_cart, size: 14),
                        label: const Text(
                          'Thêm',
                          style: TextStyle(fontSize: 12),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 32),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
