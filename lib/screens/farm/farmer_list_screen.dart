// =============================================================
// farmer_list_screen.dart
// Screen: Danh sách nông dân - "Bảng Làng"
// Hiển thị danh sách profile nông dân với chức năng tìm kiếm
// =============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:guardian/controllers/farmer_controller.dart';
import 'package:guardian/models/farmer.dart';
import 'package:guardian/screens/farm/farmer_detail_screen.dart';
import 'package:guardian/core/widgets/custom_button.dart';
import 'package:guardian/core/widgets/loading_widget.dart';

class FarmerListScreen extends StatefulWidget {
  const FarmerListScreen({super.key});

  @override
  State<FarmerListScreen> createState() => _FarmerListScreenState();
}

class _FarmerListScreenState extends State<FarmerListScreen> {
  final TextEditingController _searchController = TextEditingController();
  late FarmerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = context.read<FarmerController>();
    _loadFarmers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadFarmers() {
    _controller.loadFarmers();
  }

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      _loadFarmers();
    } else {
      _controller.searchFarmers(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Nông dân'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Consumer<FarmerController>(
        builder: (context, controller, child) {
          if (controller.isLoading && controller.farmers.isEmpty) {
            return const Center(child: LoadingWidget());
          }

          if (controller.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(controller.errorMessage!),
                  const SizedBox(height: 16),
                  CustomButton(
                    label: 'Thử lại',
                    onPressed: _loadFarmers,
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm nông dân theo tên hoặc làng...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _loadFarmers();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                ),
              ),

              // Farmers List
              Expanded(
                child: controller.farmers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.person_outline,
                              size: 48,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            const Text('Không có nông dân nào'),
                            const SizedBox(height: 16),
                            CustomButton(
                              label: 'Thêm nông dân',
                              onPressed: () => _navigateToDetailScreen(null),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: controller.farmers.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final farmer = controller.farmers[index];
                          return FarmerCard(
                            farmer: farmer,
                            onTap: () => _navigateToDetailScreen(farmer),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToDetailScreen(null),
        tooltip: 'Thêm nông dân',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _navigateToDetailScreen(Farmer? farmer) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FarmerDetailScreen(farmer: farmer),
      ),
    ).then((_) => _loadFarmers());
  }
}

// =============================================================
// FarmerCard Widget
// =============================================================

class FarmerCard extends StatelessWidget {
  final Farmer farmer;
  final VoidCallback onTap;

  const FarmerCard({
    super.key,
    required this.farmer,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 32,
                backgroundColor: Colors.teal.shade100,
                child: Text(
                  farmer.fullName.characters.first.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      farmer.fullName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Làng: ${farmer.village}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (farmer.contactPhone != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        farmer.contactPhone!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              // Trailing Icon
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
