import 'package:edulearn/providers/student/dashboard_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:edulearn/core/constants/app_colors.dart';
import 'package:edulearn/core/widgets/glass_container.dart';
import 'package:edulearn/providers/auth/auth_provider.dart';
import 'package:edulearn/models/course_model.dart';
import 'package:edulearn/providers/student/course_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final user = ref.watch(authProvider);

    return Scaffold(
      extendBody: true,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            backgroundColor: isDark
                ? AppColors.backgroundDark
                : AppColors.backgroundLight,
            surfaceTintColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  Positioned(
                        top: -100,
                        right: -50,
                        child: Container(
                          width: 250,
                          height: 250,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primaryLight.withOpacity(
                              isDark ? 0.2 : 0.8,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryLight.withOpacity(0.5),
                                blurRadius: 100,
                              ),
                            ],
                          ),
                        ),
                      )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .scaleXY(end: 1.1, duration: 4.seconds),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 20.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Hello, ${user?.name ?? 'Student'} 👋",
                                style: theme.textTheme.displaySmall,
                              ).animate().fadeIn().slideX(begin: -0.1),
                              const SizedBox(height: 4),
                              Text(
                                "Ready to learn today?",
                                style: theme.textTheme.bodyMedium,
                              ).animate().fadeIn(delay: 200.ms),
                            ],
                          ),
                          IconButton(
                            onPressed: () => context.push('/notifications'),
                            icon: Stack(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: AppColors.primaryGradient,
                                  ),
                                  child: CircleAvatar(
                                    radius: 26,
                                    backgroundColor: isDark
                                        ? AppColors.surfaceDark
                                        : Colors.white,
                                    child: const Icon(
                                      LucideIcons.bell,
                                      color: AppColors.primary,
                                      size: 28,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: Container(
                                    width: 14,
                                    height: 14,
                                    decoration: BoxDecoration(
                                      color: AppColors.error,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ).animate().scale(
                            delay: 400.ms,
                            curve: Curves.easeOutBack,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: (isDark ? Colors.black : AppColors.primary)
                              .withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: TextField(
                      readOnly: true,
                      onTap: () => context.push('/search'),
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          LucideIcons.search,
                          size: 22,
                          color: theme.hintColor,
                        ),
                        suffixIcon: Container(
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            LucideIcons.slidersHorizontal,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        hintText: "Search courses, topics...",
                      ),
                    ),
                  ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1),
                  const SizedBox(height: 36),
                  ref
                      .watch(studentDashboardProvider)
                      .when(
                        loading: () => Skeletonizer(
                          ignoreContainers: true,
                          enabled: true,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _OverallProgressCard(
                                stats: {
                                  'overall_progress': 50,
                                  'completed_lessons': 5,
                                  'total_lessons': 10,
                                  'total_courses': 2,
                                },
                              ),
                              const SizedBox(height: 36),
                              const _SectionHeader(title: "Ongoing Courses"),
                              const SizedBox(height: 20),
                              SizedBox(
                                height: 220,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: 2,
                                  itemBuilder: (context, i) => _PremiumCourseCard(
                                    course: Course(
                                      id: i.toString(),
                                      name: "Loading Course Title",
                                      description:
                                          "This is a placeholder description for skeleton loading state.",
                                      instructorId: "loading",
                                      category: "Category",
                                      progress: 0.5,
                                    ),
                                    index: i,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        error: (err, stack) => Text("Error: $err"),
                        data: (data) {
                          final enrollments = data['enrollments'] as List;
                          final classes = data['upcoming_classes'] as List;
                          final stats = data['stats'] as Map<String, dynamic>?;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (stats != null) ...[
                                _OverallProgressCard(stats: stats),
                                const SizedBox(height: 36),
                              ],
                              const _SectionHeader(title: "Ongoing Courses"),
                              const SizedBox(height: 20),
                              if (enrollments.isEmpty)
                                const Text(
                                  "No active courses.",
                                  style: TextStyle(color: Colors.white54),
                                )
                              else
                                SizedBox(
                                      height: 220,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        clipBehavior: Clip.none,
                                        itemCount: enrollments.length,
                                        itemBuilder: (context, index) {
                                          final enrollment = enrollments[index];
                                          final course = Course.fromJson(
                                            enrollment['course'],
                                          );
                                          return GestureDetector(
                                            onTap: () => context.push(
                                              '/course-details',
                                              extra: course,
                                            ),
                                            child: _PremiumCourseCard(
                                              course: course,
                                              index: index,
                                            ),
                                          );
                                        },
                                      ),
                                    )
                                    .animate()
                                    .fadeIn(delay: 800.ms)
                                    .slideX(begin: 0.1),
                              const SizedBox(height: 36),
                              const _SectionHeader(title: "Upcoming Classes"),
                              const SizedBox(height: 16),
                              if (classes.isEmpty)
                                const Text(
                                  "All caught up! No scheduled classes.",
                                  style: TextStyle(color: Colors.white54),
                                )
                              else
                                ...classes.map(
                                  (cls) => Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: 12.0,
                                    ),
                                      child: _PremiumClassTile(
                                        title: cls['title'] ?? 'Untitled Class',
                                        instructor: cls['instructor'] ?? (cls['type'] == 'live_session' ? 'Live Session' : 'Institution Staff'),
                                        time: cls['start_time']
                                            .toString()
                                            .substring(11, 16),
                                        room: cls['room_label'] ?? cls['room'],
                                        icon: cls['type'] == 'live_session' ? LucideIcons.video : LucideIcons.calendar,
                                        color: cls['type'] == 'live_session' ? AppColors.primary : AppColors.accent,
                                      ),
                                  ).animate().fadeIn().slideY(begin: 0.1),
                                ),
                            ],
                          );
                        },
                      ),
                  const SizedBox(height: 36),
                  const _SectionHeader(title: "Explore More Courses"),
                  const SizedBox(height: 20),
                  ref
                      .watch(coursesProvider)
                      .when(
                        loading: () => Skeletonizer(
                          ignoreContainers: true,
                          enabled: true,
                          child: SizedBox(
                            height: 220,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: 3,
                              itemBuilder: (context, i) => _PremiumCourseCard(
                                course: Course(
                                  id: (i + 100).toString(),
                                  name: "Loading Exploration",
                                  description: "Placeholder",
                                  instructorId: "0",
                                  category: "Modern Art",
                                  progress: 0.0,
                                ),
                                index: i,
                              ),
                            ),
                          ),
                        ),
                        error: (err, stack) =>
                            Text("Error loading catalog: $err"),
                        data: (catalog) {
                          return SizedBox(
                            height: 220,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              clipBehavior: Clip.none,
                              itemCount: catalog.length,
                              itemBuilder: (context, index) {
                                final course = catalog[index];
                                return GestureDetector(
                                  onTap: () => context.push(
                                    '/course-details',
                                    extra: course,
                                  ),
                                  child: _PremiumCourseCard(
                                    course: course,
                                    index: index + 10,
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: GlassContainer(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            borderRadius: BorderRadius.circular(32),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const _NavBarIcon(icon: LucideIcons.home, isActive: true),
                GestureDetector(
                  onTap: () => context.push('/course-details'),
                  child: const _NavBarIcon(icon: LucideIcons.bookOpen),
                ),
                GestureDetector(
                  onTap: () => context.push('/schedule'),
                  child: const _NavBarIcon(icon: LucideIcons.calendar),
                ),
                GestureDetector(
                  onTap: () => context.push('/profile'),
                  child: const _NavBarIcon(icon: LucideIcons.user),
                ),
              ],
            ),
          ),
        ),
      ).animate().fadeIn(delay: 1.seconds).slideY(begin: 0.5),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        GestureDetector(
          onTap: () => context.push('/search'),
          child: const Text(
            "See All",
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}

class _PremiumCourseCard extends StatelessWidget {
  final Course course;
  final int index;
  const _PremiumCourseCard({required this.course, required this.index});
  @override
  Widget build(BuildContext context) {
    final progress = course.progress;
    final colors = [
      [AppColors.primary, AppColors.accent],
      [AppColors.accent, const Color(0xFFD946EF)],
      [const Color(0xFF0EA5E9), const Color(0xFF2563EB)],
    ];
    final gradient = colors[index % colors.length];
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              LucideIcons.bookOpen,
              size: 120,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        course.category?.toUpperCase() ?? 'GENERAL',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      course.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Progress",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          "${(progress * 100).toInt()}%",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        valueColor: const AlwaysStoppedAnimation(Colors.white),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumClassTile extends StatelessWidget {
  final String title;
  final String instructor;
  final String time;
  final String? room;
  final IconData icon;
  final Color color;
  const _PremiumClassTile({
    required this.title,
    required this.instructor,
    required this.time,
    this.room,
    required this.icon,
    required this.color,
  });
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : AppColors.primary).withOpacity(
              0.04,
            ),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  instructor,
                  style: const TextStyle(
                    color: AppColors.textSecondaryLight,
                    fontSize: 13,
                  ),
                ),
                if (room != null && room!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(LucideIcons.mapPin, size: 12, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        room!,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
            ),
            child: Text(
              time,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textMainLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OverallProgressCard extends StatelessWidget {
  final Map<String, dynamic> stats;
  const _OverallProgressCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    final progress = (stats['overall_progress'] as num?)?.toDouble() ?? 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Platform Progress",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "${progress.toInt()}% Complete",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "${stats['completed_lessons']} of ${stats['total_lessons']} lessons finished across ${stats['total_courses']} courses.",
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  value: progress / 100,
                  strokeWidth: 10,
                  backgroundColor: Colors.white10,
                  valueColor: const AlwaysStoppedAnimation(Colors.white),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Icon(
                LucideIcons.trophy,
                color: Colors.white.withOpacity(0.8),
                size: 24,
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.1);
  }
}

class _NavBarIcon extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  const _NavBarIcon({required this.icon, this.isActive = false});
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: isActive ? AppColors.primary : Colors.grey, size: 28),
        if (isActive) ...[
          const SizedBox(height: 4),
          Container(
            width: 4,
            height: 4,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ],
    );
  }
}
