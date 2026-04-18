import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:edulearn/core/constants/app_colors.dart';
import 'package:edulearn/providers/admin/admin_provider.dart';
import '../widgets/admin_common_widgets.dart';
import 'package:skeletonizer/skeletonizer.dart';

class OverviewView extends ConsumerWidget {
  final bool isWide;
  const OverviewView({super.key, required this.isWide});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final statsAsync = ref.watch(adminStatsProvider);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(24),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Platform Monitor",
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 32,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Real-time ecosystem metrics",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white54,
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),

        statsAsync.when(
          loading: () => SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverToBoxAdapter(
              child: Skeletonizer(
                ignoreContainers: true,
                enabled: true,
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: isWide ? 4 : 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.1,
                  children: List.generate(
                    4,
                    (index) => const StatCard(
                      label: "Loading...",
                      value: "000",
                      icon: LucideIcons.activity,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
          ),
          error: (err, stack) =>
              SliverToBoxAdapter(child: Center(child: Text("Error: $err"))),
          data: (stats) => SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverGrid.count(
              crossAxisCount: isWide ? 4 : 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: [
                StatCard(
                  label: "Total Students",
                  value: stats.totalStudents.toString(),
                  icon: LucideIcons.users,
                  color: const Color(0xFF6366F1),
                  trend: "+12%",
                ),
                StatCard(
                  label: "Instructors",
                  value: stats.totalTeachers.toString(),
                  icon: LucideIcons.userCheck,
                  color: const Color(0xFF10B981),
                  trend: "+3%",
                ),
                StatCard(
                  label: "Live Courses",
                  value: stats.totalCourses.toString(),
                  icon: LucideIcons.bookOpen,
                  color: const Color(0xFFF59E0B),
                  trend: "+8%",
                ),
                StatCard(
                  label: "Institutions",
                  value: stats.activeInstitutions.toString(),
                  icon: LucideIcons.school,
                  color: const Color(0xFFEC4899),
                ),
              ],
            ),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.all(24),
          sliver: SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 16),
                const UtilityPanel(
                  title: "Platform Health",
                  subtitle:
                      "Infrastructure status is optimal. All systems nominal.",
                  icon: LucideIcons.activity,
                  color: AppColors.success,
                ),
                const SizedBox(height: 16),
                const UtilityPanel(
                  title: "Security & Access",
                  subtitle:
                      "Unified management of identity and access protocols.",
                  icon: LucideIcons.shieldCheck,
                  color: AppColors.accent,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
