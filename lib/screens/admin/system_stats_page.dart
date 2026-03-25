import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
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
  DateTime? _lastUpdated;
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
      _lastUpdated = DateTime.now();
    });
  }

  int _extractNumericValue(String label) {
    final matched = _stats.where((s) => s.label == label);
    if (matched.isEmpty) {
      return 0;
    }
    return int.tryParse(matched.first.value) ?? 0;
  }

  String _formatDateTime(DateTime? value) {
    if (value == null) {
      return '--';
    }
    final twoDigits = (int n) => n.toString().padLeft(2, '0');
    return '${twoDigits(value.day)}/${twoDigits(value.month)}/${value.year} '
        '${twoDigits(value.hour)}:${twoDigits(value.minute)}';
  }

  _HealthLevel _healthLevel({
    required int totalUsers,
    required int lockedUsers,
  }) {
    if (totalUsers <= 0) {
      return _HealthLevel.warning;
    }
    final ratio = lockedUsers / totalUsers;
    if (ratio >= 0.3) {
      return _HealthLevel.critical;
    }
    if (ratio >= 0.15) {
      return _HealthLevel.warning;
    }
    return _HealthLevel.good;
  }

  @override
  Widget build(BuildContext context) {
    final totalUsers = _extractNumericValue('Tổng người dùng');
    final lockedUsers = _extractNumericValue('Tài khoản bị khóa');
    final addresses = _extractNumericValue('Địa chỉ đã tạo');
    final activeUsers = (totalUsers - lockedUsers).clamp(0, totalUsers);
    final health = _healthLevel(
      totalUsers: totalUsers,
      lockedUsers: lockedUsers,
    );

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(fallbackRoute: AppRoutes.adminDashboard),
        title: const Text('Thống kê hệ thống'),
        actions: [
          IconButton(
            tooltip: 'Làm mới dữ liệu',
            onPressed: _isLoading ? null : _load,
            icon: const Icon(Icons.refresh_outlined),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _SystemHealthCard(
                    level: health,
                    lockedUsers: lockedUsers,
                    totalUsers: totalUsers,
                    lastUpdatedText: _formatDateTime(_lastUpdated),
                  ),
                  const SizedBox(height: 12),
                  _SectionHeader(
                    title: 'Chỉ số trọng tâm',
                    subtitle: 'Theo dõi nhanh các chỉ số chính.',
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _SimpleMetric(
                          label: 'Tổng',
                          value: totalUsers.toString(),
                          color: const Color(0xFF2D5E8A),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _SimpleMetric(
                          label: 'Hoạt động',
                          value: activeUsers.toString(),
                          color: const Color(0xFF1E6B47),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _SimpleMetric(
                          label: 'Bị khóa',
                          value: lockedUsers.toString(),
                          color: const Color(0xFFD32F2F),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _SectionHeader(
                    title: 'Biểu đồ phân tích',
                    subtitle:
                        'Trực quan hóa nhanh cơ cấu tài khoản và tương quan các chỉ số.',
                  ),
                  const SizedBox(height: 10),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final compact = constraints.maxWidth < 760;
                      final chartWidth = compact
                          ? constraints.maxWidth
                          : (constraints.maxWidth - 12) / 2;
                      return Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          SizedBox(
                            width: chartWidth,
                            child: _AccountDistributionChartCard(
                              activeUsers: activeUsers,
                              lockedUsers: lockedUsers,
                            ),
                          ),
                          SizedBox(
                            width: chartWidth,
                            child: _MetricBarChartCard(
                              totalUsers: totalUsers,
                              activeUsers: activeUsers,
                              lockedUsers: lockedUsers,
                              addresses: addresses,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                  _SectionHeader(
                    title: 'Danh sách chỉ số hệ thống',
                    subtitle: 'Mở rộng để xem đầy đủ.',
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: ExpansionTile(
                      title: const Text('Xem toàn bộ chỉ số'),
                      childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                      children: _stats
                          .map(
                            (stat) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: _DetailMetricRow(
                                stat: stat,
                                color: _metricColor(stat.label),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Text(
                        'Gợi ý vận hành: duy trì tỉ lệ tài khoản bị khóa dưới 15% tổng người dùng để đảm bảo hệ thống ổn định và hạn chế hỗ trợ phát sinh.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Color _metricColor(String label) {
    if (label.contains('khóa')) {
      return const Color(0xFFD32F2F);
    }
    if (label.contains('Địa chỉ')) {
      return const Color(0xFF7A5A1E);
    }
    return const Color(0xFF1E6B47);
  }
}

enum _HealthLevel { good, warning, critical }

class _SystemHealthCard extends StatelessWidget {
  const _SystemHealthCard({
    required this.level,
    required this.lockedUsers,
    required this.totalUsers,
    required this.lastUpdatedText,
  });

  final _HealthLevel level;
  final int lockedUsers;
  final int totalUsers;
  final String lastUpdatedText;

  @override
  Widget build(BuildContext context) {
    final ratio = totalUsers > 0 ? (lockedUsers / totalUsers) * 100 : 0.0;

    final (
      Color color,
      IconData icon,
      String title,
      String message,
    ) = switch (level) {
      _HealthLevel.good => (
        const Color(0xFF1E6B47),
        Icons.check_circle_outline,
        'Hệ thống ổn định',
        'Tỉ lệ tài khoản bị khóa đang ở mức an toàn.',
      ),
      _HealthLevel.warning => (
        const Color(0xFF7A5A1E),
        Icons.warning_amber_outlined,
        'Cần theo dõi',
        'Tỉ lệ tài khoản bị khóa đang tăng, nên rà soát nguyên nhân.',
      ),
      _HealthLevel.critical => (
        const Color(0xFFD32F2F),
        Icons.gpp_bad_outlined,
        'Cảnh báo cao',
        'Tỉ lệ tài khoản bị khóa cao, cần ưu tiên xử lý ngay.',
      ),
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    message,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tài khoản bị khóa: ${ratio.toStringAsFixed(1)}% • Cập nhật: $lastUpdatedText',
                    style: Theme.of(
                      context,
                    ).textTheme.labelSmall?.copyWith(color: Colors.grey[600]),
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
        ),
      ],
    );
  }
}

class _SimpleMetric extends StatelessWidget {
  const _SimpleMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        child: Column(
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(label, style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}

class _DetailMetricRow extends StatelessWidget {
  const _DetailMetricRow({required this.stat, required this.color});

  final SystemStat stat;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.insights_outlined, color: color, size: 18),
        ),
        title: Text(stat.label),
        subtitle: const Text('Đồng bộ trực tiếp từ dữ liệu hệ thống'),
        trailing: Text(
          stat.value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _AccountDistributionChartCard extends StatelessWidget {
  const _AccountDistributionChartCard({
    required this.activeUsers,
    required this.lockedUsers,
  });

  final int activeUsers;
  final int lockedUsers;

  @override
  Widget build(BuildContext context) {
    final total = activeUsers + lockedUsers;
    final safeTotal = total == 0 ? 1 : total;
    final activeRatio = (activeUsers / safeTotal) * 100;
    final lockedRatio = (lockedUsers / safeTotal) * 100;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cơ cấu trạng thái tài khoản',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 190,
              child: PieChart(
                PieChartData(
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                  sections: [
                    PieChartSectionData(
                      value: activeUsers.toDouble(),
                      color: const Color(0xFF1E6B47),
                      radius: 50,
                      title: '${activeRatio.toStringAsFixed(0)}%',
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                    PieChartSectionData(
                      value: lockedUsers.toDouble(),
                      color: const Color(0xFFD32F2F),
                      radius: 50,
                      title: '${lockedRatio.toStringAsFixed(0)}%',
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            const _ChartLegendItem(
              label: 'Đang hoạt động',
              color: Color(0xFF1E6B47),
            ),
            const SizedBox(height: 4),
            const _ChartLegendItem(label: 'Bị khóa', color: Color(0xFFD32F2F)),
          ],
        ),
      ),
    );
  }
}

class _MetricBarChartCard extends StatelessWidget {
  const _MetricBarChartCard({
    required this.totalUsers,
    required this.activeUsers,
    required this.lockedUsers,
    required this.addresses,
  });

  final int totalUsers;
  final int activeUsers;
  final int lockedUsers;
  final int addresses;

  @override
  Widget build(BuildContext context) {
    final values = [
      totalUsers.toDouble(),
      activeUsers.toDouble(),
      lockedUsers.toDouble(),
      addresses.toDouble(),
    ];
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final double maxY = (maxValue <= 0 ? 1.0 : maxValue * 1.2) + 1.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'So sánh các chỉ số chính',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 210,
              child: BarChart(
                BarChartData(
                  maxY: maxY,
                  gridData: FlGridData(
                    show: true,
                    horizontalInterval: maxY / 4,
                    getDrawingHorizontalLine: (_) =>
                        const FlLine(color: Color(0xFFE5E7EB), strokeWidth: 1),
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 34,
                        interval: maxY / 4,
                        getTitlesWidget: (value, _) => Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, _) {
                          const labels = [
                            'Tổng',
                            'Hoạt động',
                            'Khóa',
                            'Địa chỉ',
                          ];
                          final index = value.toInt();
                          if (index < 0 || index >= labels.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              labels[index],
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  barGroups: [
                    _barGroup(
                      x: 0,
                      y: totalUsers.toDouble(),
                      color: const Color(0xFF2D5E8A),
                    ),
                    _barGroup(
                      x: 1,
                      y: activeUsers.toDouble(),
                      color: const Color(0xFF1E6B47),
                    ),
                    _barGroup(
                      x: 2,
                      y: lockedUsers.toDouble(),
                      color: const Color(0xFFD32F2F),
                    ),
                    _barGroup(
                      x: 3,
                      y: addresses.toDouble(),
                      color: const Color(0xFF7A5A1E),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _barGroup({
    required int x,
    required double y,
    required Color color,
  }) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          width: 18,
          borderRadius: BorderRadius.circular(6),
          color: color,
        ),
      ],
    );
  }
}

class _ChartLegendItem extends StatelessWidget {
  const _ChartLegendItem({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
        ),
      ],
    );
  }
}
