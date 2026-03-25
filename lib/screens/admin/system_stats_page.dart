import 'package:flutter/material.dart';
import 'package:guardian/controllers/session_controller.dart';
import 'package:guardian/core/widgets/app_back_button.dart';
import 'package:guardian/models/system_stat.dart';
import 'package:guardian/routes/app_routes.dart';

class SystemStatsPage extends StatefulWidget {
  const SystemStatsPage({super.key});

  @override
  State<SystemStatsPage> createState() => _SystemStatsPageState();
}

class _SystemStatsPageState extends State<SystemStatsPage> {
  bool _isLoading = true;
  List<SystemStat> _stats = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final stats = await SessionController.instance.systemStats();
    if (!mounted) {
      return;
    }
    setState(() {
      _stats = stats;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(fallbackRoute: AppRoutes.adminDashboard),
        title: const Text('Thống kê hệ thống'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (_stats.isNotEmpty)
                  Card(
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFE8F3ED),
                        child: Icon(Icons.track_changes_outlined, color: Color(0xFF1E6B47)),
                      ),
                      title: Text(_stats.first.label),
                      subtitle: const Text('Chỉ số tổng hợp cập nhật theo dữ liệu hiện tại'),
                      trailing: Text(
                        _stats.first.value,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1E6B47),
                            ),
                      ),
                    ),
                  ),
                if (_stats.isNotEmpty) const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: (_stats.length > 1 ? _stats.sublist(1) : _stats)
                      .map((stat) => _StatCard(stat: stat))
                      .toList(),
                ),
              ],
            ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.stat});

  final SystemStat stat;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width - 56) / 2,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(stat.label, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 8),
              Text(
                stat.value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E6B47),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
