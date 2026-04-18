import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:edulearn/core/constants/app_colors.dart';
import 'package:edulearn/providers/manager/manager_provider.dart';
import '../../admin/widgets/admin_common_widgets.dart';

class ManagerOverviewView extends ConsumerWidget {
  final bool isWide;
  const ManagerOverviewView({super.key, required this.isWide});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(managerStatsProvider);

    return SingleChildScrollView(
      padding: EdgeInsets.all(isWide ? 32 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Institution Overview",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Quick statistics for your institution.",
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
          const SizedBox(height: 32),
          statsAsync.when(
            data: (stats) => GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: isWide ? 4 : 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: isWide ? 1.5 : 1.2,
              children: [
                _StatCard(
                  title: "Total Students",
                  value: stats.totalStudents.toString(),
                  icon: LucideIcons.users,
                  color: Colors.blue,
                ),
                _StatCard(
                  title: "Total Teachers",
                  value: stats.totalTeachers.toString(),
                  icon: LucideIcons.graduationCap,
                  color: Colors.purple,
                ),
                _StatCard(
                  title: "Total Courses",
                  value: stats.totalCourses.toString(),
                  icon: LucideIcons.bookOpen,
                  color: Colors.orange,
                ),
                _StatCard(
                  title: "Schedules",
                  value: stats.upcomingSchedules.toString(),
                  icon: LucideIcons.calendar,
                  color: Colors.green,
                ),
              ],
            ),
            loading: () => const AdminLoadingShimmer(),
            error: (err, stack) => Center(child: Text("Error: $err", style: const TextStyle(color: Colors.red))),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
