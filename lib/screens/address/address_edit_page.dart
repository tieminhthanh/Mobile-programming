import 'package:flutter/material.dart';
import 'package:guardian/controllers/session_controller.dart';
import 'package:guardian/core/widgets/app_back_button.dart';
import 'package:guardian/models/address.dart';
import 'package:guardian/routes/app_routes.dart';

class AddressEditPage extends StatefulWidget {
  const AddressEditPage({super.key});

  @override
  State<AddressEditPage> createState() => _AddressEditPageState();
}

class _AddressEditPageState extends State<AddressEditPage> {
  final _provinceController = TextEditingController();
  final _districtController = TextEditingController();
  final _communeController = TextEditingController();
  final _lineController = TextEditingController();
  Address? _editing;
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Address && _editing == null) {
      _editing = args;
      _provinceController.text = args.province;
      _districtController.text = args.district;
      _communeController.text = args.commune;
      _lineController.text = args.addressLine;
    }
  }

  @override
  void dispose() {
    _provinceController.dispose();
    _districtController.dispose();
    _communeController.dispose();
    _lineController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final user = SessionController.instance.currentUser.value;
    if (user == null) {
      return;
    }
    setState(() => _isSaving = true);
    final address = Address(
      id: _editing?.id ?? 0,
      userId: user.id,
      province: _provinceController.text.trim(),
      district: _districtController.text.trim(),
      commune: _communeController.text.trim(),
      addressLine: _lineController.text.trim(),
    );
    await SessionController.instance.saveAddress(address);
    if (!mounted) {
      return;
    }
    setState(() => _isSaving = false);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(fallbackRoute: AppRoutes.addressList),
        title: Text(_editing == null ? 'Thêm địa chỉ' : 'Cập nhật địa chỉ'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      _editing == null
                          ? 'Thêm địa chỉ mới để giao dịch thuận tiện hơn.'
                          : 'Cập nhật địa chỉ để thông tin luôn chính xác.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _provinceController,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.map_outlined),
                        labelText: 'Tỉnh/Thành phố',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nhập tỉnh/thành phố';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _districtController,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.location_city_outlined),
                        labelText: 'Quận/Huyện',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nhập quận/huyện';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _communeController,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.signpost_outlined),
                        labelText: 'Phường/Xã',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nhập phường/xã';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _lineController,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.home_work_outlined),
                        labelText: 'Địa chỉ chi tiết',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nhập địa chỉ chi tiết';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _isSaving ? null : _save,
                      icon: const Icon(Icons.save_outlined),
                      label: Text(_isSaving ? 'Đang lưu...' : 'Lưu địa chỉ'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
