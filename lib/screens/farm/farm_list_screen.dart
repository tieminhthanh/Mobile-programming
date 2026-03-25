// =============================================================
// farm_list_screen.dart
// Screen: Danh sách Trang trại
// Hiển thị tất cả trang trại hoặc của một nông dân cụ thể
// =============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:guardian/controllers/farmer_controller.dart';
import 'package:guardian/models/farm.dart';
import 'package:guardian/screens/farm/farm_detail_screen.dart';
import 'package:guardian/core/widgets/custom_button.dart';
import 'package:guardian/core/widgets/loading_widget.dart';

class FarmListScreen extends StatefulWidget {
  final String? farmerId; // Nếu có, chỉ hiển thị farm của nông dân này

  const FarmListScreen({super.key, this.farmerId});

  @override
  State<FarmListScreen> createState() => _FarmListScreenState();
}

class _FarmListScreenState extends State<FarmListScreen> {
  final TextEditingController _searchController = TextEditingController();
  late FarmerController _controller;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _controller = context.read<FarmerController>();
    _loadFarms();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadFarms() {
    if (widget.farmerId != null) {
      _controller.loadFarmsByFarmerId(widget.farmerId!);
    } else {
      _controller.loadAllFarms();
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.trim().toLowerCase();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Trang trại'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Consumer<FarmerController>(
        builder: (context, controller, child) {
          final visibleFarms = controller.farms.where((farm) {
            if (_searchQuery.isEmpty) return true;
            final name = farm.farmName.toLowerCase();
            final location = farm.location.toLowerCase();
            final crop = farm.cropType.toLowerCase();
            return name.contains(_searchQuery) ||
                location.contains(_searchQuery) ||
                crop.contains(_searchQuery);
          }).toList();

          if (controller.isLoading && controller.farms.isEmpty) {
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
                    onPressed: _loadFarms,
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
                    hintText: 'Tìm kiếm trang trại theo tên...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _loadFarms();
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

              // Farms List
              Expanded(
                child: visibleFarms.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.landscape_outlined,
                              size: 48,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            const Text('Không có trang trại nào'),
                            const SizedBox(height: 16),
                            CustomButton(
                              label: 'Thêm trang trại',
                              onPressed: () => _navigateToDetailScreen(null),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: visibleFarms.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final farm = visibleFarms[index];
                          return FarmCard(
                            farm: farm,
                            onTap: () => _navigateToDetailScreen(farm),
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
        tooltip: 'Thêm trang trại',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _navigateToDetailScreen(Farm? farm) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FarmDetailScreen(farm: farm, farmerId: widget.farmerId),
      ),
    ).then((_) => _loadFarms());
  }
}

// =============================================================
// FarmCard Widget
// =============================================================

class FarmCard extends StatelessWidget {
  final Farm farm;
  final VoidCallback onTap;

  const FarmCard({
    super.key,
    required this.farm,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.landscape_outlined,
                      color: Colors.green.shade700,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          farm.farmName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          farm.location,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
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

              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),

              // Details
              Row(
                children: [
                  Expanded(
                    child: _DetailTile(
                      label: 'Loại cây',
                      value: farm.cropType,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _DetailTile(
                      label: 'Diện tích',
                      value: '${farm.areaHectares} ha',
                    ),
                  ),
                ],
              ),

              if (farm.certifications != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.verified, size: 16, color: Colors.green),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        farm.certifications!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.green,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailTile extends StatelessWidget {
  final String label;
  final String value;

  const _DetailTile({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
