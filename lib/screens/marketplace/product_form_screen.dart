// =============================================================
// product_form_screen.dart
// Màn hình dùng chung để Tạo mới hoặc Chỉnh sửa sản phẩm.
// Role: SME (Chủ doanh nghiệp vừa và nhỏ).
// =============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/product_controller.dart';
import '../../models/product_model.dart';

class ProductFormScreen extends StatefulWidget {
  const ProductFormScreen({super.key, this.product});

  /// Nếu [product] null -> Chế độ Tạo mới.
  /// Nếu [product] có giá trị -> Chế độ Chỉnh sửa (Edit).
  final ProductModel? product;

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  // Key để định danh và quản lý trạng thái của Form (validate, save)
  final _formKey = GlobalKey<FormState>();

  // Khai báo các bộ điều khiển cho các ô nhập liệu (TextFields)
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _unitCtrl;
  
  String? _category; // Lưu giá trị danh mục được chọn từ Dropdown
  bool _saving = false; // Trạng thái đang gửi dữ liệu lên server (Loading)

  // Danh sách cứng các danh mục sản phẩm
  static const _categories = ['Nông sản', 'Trái cây', 'Vật tư', 'Thực phẩm chế biến', 'Khác'];

  // Getter tiện ích để kiểm tra xem đang ở chế độ Edit hay Create
  bool get _isEdit => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    
    // Khởi tạo controller với dữ liệu cũ nếu là Edit, hoặc rỗng nếu là Create
    _titleCtrl = TextEditingController(text: p?.title ?? '');
    _descCtrl = TextEditingController(text: p?.description ?? '');
    _priceCtrl = TextEditingController(text: p != null ? '${p.price.toInt()}' : '');
    _unitCtrl = TextEditingController(text: p?.unit ?? '');
    _category = p?.category;
  }

  @override
  void dispose() {
    // Luôn luôn dispose các controller để tránh rò rỉ bộ nhớ (memory leak)
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _unitCtrl.dispose();
    super.dispose();
  }

  /// Hàm xử lý khi nhấn nút Lưu/Tạo
  Future<void> _submit() async {
    // 1. Kiểm tra tính hợp lệ của dữ liệu đầu vào (Validation)
    if (!_formKey.currentState!.validate()) return;

    // 2. Bật trạng thái loading
    setState(() => _saving = true);

    final ctrl = context.read<ProductController>();

    // 3. Gom dữ liệu từ các ô nhập vào Model
    final product = ProductModel(
      productId: widget.product?.productId,
      sellerId: 0, // ID này sẽ được backend hoặc controller gán lại theo User hiện tại
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      category: _category,
      price: double.parse(_priceCtrl.text.trim()),
      unit: _unitCtrl.text.trim().isEmpty ? null : _unitCtrl.text.trim(),
    );

    // 4. Gọi API thông qua Controller
    bool success;
    if (_isEdit) {
      // Giữ nguyên sellerId cũ khi cập nhật
      success = await ctrl.updateProduct(
        product.copyWith(sellerId: widget.product!.sellerId),
      );
    } else {
      success = await ctrl.createProduct(product);
    }

    // 5. Xử lý kết quả sau khi gọi API
    if (context.mounted) {
      if (success) {
        // Trả về true để màn hình danh sách biết cần load lại dữ liệu
        Navigator.pop(context, true);
      } else {
        // Tắt loading và hiển thị lỗi nếu thất bại
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ctrl.errorMessage ?? 'Có lỗi xảy ra')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Sửa sản phẩm' : 'Thêm sản phẩm mới'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey, // Gán key để quản lý Form
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Tên sản phẩm ---
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Tên sản phẩm *',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Vui lòng nhập tên sản phẩm' : null,
              ),
              const SizedBox(height: 16),

              // --- Mô tả ---
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(
                  labelText: 'Mô tả',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3, // Cho phép nhập nhiều dòng
              ),
              const SizedBox(height: 16),

              // --- Danh mục (Dropdown) ---
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(
                  labelText: 'Danh mục',
                  border: OutlineInputBorder(),
                ),
                items: _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _category = v),
              ),
              const SizedBox(height: 16),

              // --- Giá & Đơn vị (Nằm trên cùng một hàng) ---
              Row(
                children: [
                  Expanded(
                    flex: 2, // Ô giá chiếm 2 phần không gian
                    child: TextFormField(
                      controller: _priceCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Giá (VNĐ) *',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number, // Hiển thị bàn phím số
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Nhập giá';
                        if (double.tryParse(v.trim()) == null) return 'Giá không hợp lệ';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField( // Ô đơn vị chiếm 1 phần không gian
                      controller: _unitCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Đơn vị',
                        border: OutlineInputBorder(),
                        hintText: 'kg, hộp...',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // --- Nút hành động ---
              ElevatedButton(
                onPressed: _saving ? null : _submit, // Vô hiệu hóa nút khi đang lưu
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14)),
                child: _saving
                    ? const SizedBox( // Hiển thị vòng xoay loading khi đang lưu
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_isEdit ? 'Lưu thay đổi' : 'Tạo sản phẩm'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}