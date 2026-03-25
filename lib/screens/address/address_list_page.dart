import 'package:flutter/material.dart';
import 'package:guardian/controllers/session_controller.dart';
import 'package:guardian/core/widgets/app_back_button.dart';
import 'package:guardian/models/address.dart';
import 'package:guardian/routes/app_routes.dart';

class AddressListPage extends StatefulWidget {
  const AddressListPage({super.key});

  @override
  State<AddressListPage> createState() => _AddressListPageState();
}

class _AddressListPageState extends State<AddressListPage> {
  bool _isLoading = true;
  List<Address> _addresses = [];

  @override
  void initState() {
    super.initState();
    _load();
    SessionController.instance.currentUser.addListener(_load);
  }

  @override
  void dispose() {
    SessionController.instance.currentUser.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    final user = SessionController.instance.currentUser.value;
    if (user == null) {
      return;
    }
    final addresses = await SessionController.instance.addressesForUser(user.id);
    if (!mounted) {
      return;
    }
    setState(() {
      _addresses = addresses;
      _isLoading = false;
    });
  }

  void _openEdit({Address? address}) {
    Navigator.of(context)
        .pushNamed(AppRoutes.addressEdit, arguments: address)
        .then((_) => _load());
  }

  Future<void> _delete(Address address) async {
    await SessionController.instance.deleteAddress(address.id);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(fallbackRoute: AppRoutes.home),
        title: const Text('Quản lý địa chỉ'),
        actions: [
          IconButton(
            tooltip: 'Thêm địa chỉ',
            onPressed: () => _openEdit(),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _addresses.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.place_outlined, size: 48, color: Color(0xFF9CA3AF)),
                      const SizedBox(height: 8),
                      Text(
                        'Chưa có địa chỉ nào',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () => _openEdit(),
                        icon: const Icon(Icons.add_location_alt_outlined),
                        label: const Text('Thêm địa chỉ'),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final address = _addresses[index];
                    return Card(
                      child: ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFE8F3ED),
                          child: Icon(Icons.place_outlined, color: Color(0xFF1E6B47)),
                        ),
                        title: Text('${address.province} - ${address.district}'),
                        subtitle: Text('${address.commune}, ${address.addressLine}'),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              _openEdit(address: address);
                            } else if (value == 'delete') {
                              _delete(address);
                            }
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(value: 'edit', child: Text('Sửa')),
                            PopupMenuItem(value: 'delete', child: Text('Xóa')),
                          ],
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemCount: _addresses.length,
                ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Thêm địa chỉ',
        onPressed: () => _openEdit(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
