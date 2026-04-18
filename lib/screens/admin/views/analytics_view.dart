import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:edulearn/core/constants/app_colors.dart';
import 'package:edulearn/providers/admin/admin_provider.dart';
import '../widgets/admin_common_widgets.dart';

class AnalyticsView extends ConsumerWidget {
  const AnalyticsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(adminAnalyticsProvider);
    final theme = Theme.of(context);

    return analyticsAsync.when(
      loading: () => const AdminLoadingShimmer(),
      error: (err, stack) => Center(child: Text("Error: $err")),
      data: (data) {
        final growth = List<Map<String, dynamic>>.from(data['growth_trends'] ?? []);
        final categories = List<Map<String, dynamic>>.from(data['category_distribution'] ?? []);
        final recentEnrollments = List<Map<String, dynamic>>.from(data['recent_enrollments'] ?? []);

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(24),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "System Analytics",
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 32, letterSpacing: -0.5),
                    ),
                    const SizedBox(height: 4),
                    const Text("Deep-dive into platform growth and health", style: TextStyle(color: Colors.white54)),
                    const SizedBox(height: 32),
                    
                    // User Growth Chart
                    _AnalyticsCard(
                      title: "User Growth",
                      subtitle: "New account registrations (Last 6 Months)",
                      child: SizedBox(
                        height: 250,
                        child: _UserGrowthChart(data: growth),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category Distribution
                        Expanded(
                          flex: 3,
                          child: _AnalyticsCard(
                            title: "Course Categories",
                            subtitle: "Content distribution by subject",
                            child: SizedBox(
                              height: 300,
                              child: _CategoryPieChart(data: categories),
                            ),
                          ),
                        ),
                        const SizedBox(width: 24),
                        // Recent Enrollments
                        Expanded(
                          flex: 4,
                          child: _AnalyticsCard(
                            title: "Recent Enrollments",
                            subtitle: "Latest live activity",
                            child: Column(
                              children: recentEnrollments.map((e) => _EnrollmentTile(enrollment: e)).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _AnalyticsCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _AnalyticsCard({required this.title, required this.subtitle, required this.child});

  @override
  Widget build(BuildContext context) {
    return ElegantCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.white38)),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }
}

class _UserGrowthChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  const _UserGrowthChart({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const Center(child: Text("Insufficient data", style: TextStyle(color: Colors.white24)));

    // Prepare data points
    final spots = <FlSpot>[];
    final titles = <String>[];
    
    final sortedData = data.reversed.toList(); // Oldest to newest
    for (int i = 0; i < sortedData.length; i++) {
        spots.add(FlSpot(i.toDouble(), (sortedData[i]['count'] ?? 0).toDouble()));
        titles.add(sortedData[i]['month'] ?? "");
    }

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (val, meta) {
                if (val.toInt() >= titles.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    titles[val.toInt()].split('-').last,
                    style: const TextStyle(color: Colors.white38, fontSize: 10),
                  ),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.primary,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [AppColors.primary.withOpacity(0.3), AppColors.primary.withOpacity(0.0)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryPieChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  const _CategoryPieChart({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const Center(child: Text("No courses recorded", style: TextStyle(color: Colors.white24)));

    final colors = [
        AppColors.primary, AppColors.accent, AppColors.success, AppColors.warning, Colors.purpleAccent, Colors.cyanAccent
    ];

    return PieChart(
      PieChartData(
        sectionsSpace: 4,
        centerSpaceRadius: 40,
        sections: List.generate(data.length, (i) {
          final val = (data[i]['count'] ?? 0).toDouble();
          return PieChartSectionData(
            color: colors[i % colors.length],
            value: val,
            title: '${data[i]['category']}',
            radius: 50,
            titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
          );
        }),
      ),
    );
  }
}

class _EnrollmentTile extends StatelessWidget {
  final Map<String, dynamic> enrollment;
  const _EnrollmentTile({required this.enrollment});

  @override
  Widget build(BuildContext context) {
    final user = enrollment['user'] ?? {};
    final course = enrollment['course'] ?? {};
    final dateStr = enrollment['created_at'] != null 
        ? DateFormat('MMM dd, HH:mm').format(DateTime.parse(enrollment['created_at']))
        : "";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 16,
            backgroundColor: Colors.white10,
            child: Icon(LucideIcons.user, size: 14, color: Colors.white38),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['name'] ?? 'Unknown User',
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Enrolled in ${course['title'] ?? 'Course'}",
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(dateStr, style: const TextStyle(color: Colors.white24, fontSize: 10)),
        ],
      ),
    );
  }
}
