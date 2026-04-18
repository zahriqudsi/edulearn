import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edulearn/core/constants/app_colors.dart';
import 'package:edulearn/core/widgets/glass_container.dart';
import 'package:edulearn/providers/auth/auth_provider.dart';
import 'package:edulearn/models/course_model.dart';
import 'package:edulearn/providers/teacher/teacher_provider.dart';
import 'package:edulearn/core/utils/toast_service.dart';
import 'views/teacher_courses_view.dart';
import 'package:skeletonizer/skeletonizer.dart';

class TeacherDashboard extends ConsumerWidget {
  const TeacherDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final user = ref.watch(authProvider);
    final dashboardAsync = ref.watch(teacherDashboardProvider);

    return dashboardAsync.when(
      loading: () => Skeletonizer(
        ignoreContainers: true,
        enabled: true,
        child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 200, height: 40, color: Colors.white),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 48),
                Container(width: 150, height: 24, color: Colors.white),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: 3,
                    itemBuilder: (context, i) => Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      error: (err, stack) => Scaffold(body: Center(child: Text("Error: $err"))),
      data: (data) {
        final stats = data['stats'];
        final classes = data['upcoming_classes'] as List;
        final teacherCourses = (data['courses'] as List)
            .map((c) => Course.fromJson(c))
            .toList();

        return Scaffold(
          body: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: isDark ? AppColors.premiumDarkGradient : null,
                    color: isDark ? null : AppColors.backgroundLight,
                  ),
                ),
              ),
              Positioned(
                top: -100,
                left: -50,
                child:
                    Container(
                          width: 300,
                          height: 300,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary.withOpacity(
                              isDark ? 0.2 : 0.05,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.1),
                                blurRadius: 100,
                              ),
                            ],
                          ),
                        )
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .scaleXY(end: 1.1, duration: 3.seconds),
              ),

              SafeArea(
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24.0,
                          vertical: 24.0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Hi, ${user?.name ?? 'Teacher'}! 👋",
                                      style: theme.textTheme.displaySmall,
                                    ).animate().fadeIn().slideX(begin: -0.1),
                                    const SizedBox(height: 4),
                                    Text(
                                      "You have ${classes.length} classes scheduled.",
                                      style: theme.textTheme.bodyMedium,
                                    ).animate().fadeIn(delay: 200.ms),
                                  ],
                                ),
                                InkWell(
                                  onTap: () => context.push('/profile'),
                                  child:
                                      Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: AppColors.primaryGradient,
                                        ),
                                        child: CircleAvatar(
                                          radius: 26,
                                          backgroundColor: isDark
                                              ? AppColors.surfaceDark
                                              : Colors.white,
                                          child: const Icon(
                                            LucideIcons.graduationCap,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ).animate().scale(
                                        delay: 400.ms,
                                        curve: Curves.easeOutBack,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                            Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () =>
                                        context.push('/teacher/enrollments'),
                                    child:
                                        _StatCard(
                                              title: "Total Students",
                                              value: stats['total_students']
                                                  .toString(),
                                              icon: LucideIcons.users,
                                              color: Colors.blueAccent,
                                            )
                                            .animate()
                                            .fadeIn(delay: 500.ms)
                                            .slideY(begin: 0.1),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: InkWell(
                                    onTap: () =>
                                        context.push('/teacher/history'),
                                    child:
                                        _StatCard(
                                              title: "Class History",
                                              value: "View",
                                              icon: LucideIcons.history,
                                              color: AppColors.accent,
                                            )
                                            .animate()
                                            .fadeIn(delay: 600.ms)
                                            .slideY(begin: 0.1),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 40),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Today's Schedule",
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(LucideIcons.calendarDays),
                                  onPressed: () => context.push('/schedule'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            if (classes.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 20.0),
                                child: Text(
                                  "No classes scheduled yet.",
                                  style: TextStyle(color: Colors.white54),
                                ),
                              )
                            else
                              ...List.generate(classes.length, (index) {
                                final cls = classes[index];
                                return _TimelineItem(
                                  subject: cls['title'] ?? 'Unknown Session',
                                  time: cls['start_time'].toString().substring(
                                    11,
                                    16,
                                  ),
                                  room: cls['room_label'] ?? cls['room'],
                                  students: 0,
                                  status: cls['status'] ?? "Upcoming",
                                  index: index,
                                );
                              }),
                            const SizedBox(height: 40),
                            Text(
                              "Teacher Tools",
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _ToolButton(
                              icon: LucideIcons.layers,
                              label: "Manage Courses",
                              subtitle: "Manage curriculum & subjects",
                              color: AppColors.accent,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const TeacherCoursesView(),
                                ),
                              ),
                            ),
                            _ToolButton(
                              icon: LucideIcons.uploadCloud,
                              label: "Upload Materials",
                              color: Colors.indigo,
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (context) => Container(
                                    padding: const EdgeInsets.all(24),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text(
                                          "Select Course",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        ...teacherCourses.map(
                                          (course) => ListTile(
                                            leading: const Icon(
                                              LucideIcons.book,
                                            ),
                                            title: Text(course.name),
                                            onTap: () {
                                              Navigator.pop(context);
                                              context.push(
                                                '/materials',
                                                extra: course,
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                            _ToolButton(
                              icon: LucideIcons.users,
                              label: "Student Enrollments",
                              color: AppColors.primary,
                              onTap: () => context.push('/teacher/enrollments'),
                            ),
                            _ToolButton(
                              icon: LucideIcons.history,
                              label: "Class History",
                              color: Colors.blue,
                              onTap: () => context.push('/teacher/history'),
                            ),
                            _ToolButton(
                              icon: LucideIcons.clipboardCheck,
                              label: "Manage Attendance",
                              subtitle: "Coming Soon",
                              color: AppColors.success,
                              onTap: () => ToastService.showInfo(
                                "Manage Attendance is coming soon!",
                              ),
                            ),
                            _ToolButton(
                              icon: LucideIcons.messageSquare,
                              label: "Announcements",
                              color: AppColors.warning,
                              onTap: () =>
                                  _showAnnouncementDialog(context, ref),
                            ),
                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              final titleController = TextEditingController();
              Course? selectedCourse;
              bool isRecurring = false;
              int? selectedDay;
              String? recordingUrl;

              showDialog(
                context: context,
                builder: (context) => StatefulBuilder(
                  builder: (context, setState) => AlertDialog(
                    title: const Text("Schedule Live Session"),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DropdownButtonFormField<Course>(
                          value: selectedCourse,
                          hint: const Text("Select Course"),
                          items: (teacherCourses)
                              .map(
                                (c) => DropdownMenuItem(
                                  value: c,
                                  child: Text(c.name),
                                ),
                              )
                              .toList(),
                          onChanged: (v) => setState(() => selectedCourse = v),
                        ),
                        TextField(
                          controller: titleController,
                          decoration: const InputDecoration(
                            labelText: "Session Title",
                          ),
                        ),
                        const SizedBox(height: 10),
                        CheckboxListTile(
                          title: const Text(
                            "Recurring Session",
                            style: TextStyle(fontSize: 14),
                          ),
                          value: isRecurring,
                          onChanged: (v) => setState(() => isRecurring = v!),
                        ),
                        if (isRecurring)
                          DropdownButtonFormField<int>(
                            value: selectedDay,
                            hint: const Text("Select Day"),
                            items: List.generate(
                              7,
                              (i) => DropdownMenuItem(
                                value: i,
                                child: Text(
                                  [
                                    'Sunday',
                                    'Monday',
                                    'Tuesday',
                                    'Wednesday',
                                    'Thursday',
                                    'Friday',
                                    'Saturday',
                                    'Sunday',
                                  ][i],
                                ),
                              ),
                            ),
                            onChanged: (v) => setState(() => selectedDay = v),
                          ),
                        const SizedBox(height: 10),
                        const Text(
                          "Start: Today @ 10:00 PM (Default)",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          decoration: const InputDecoration(
                            labelText: "Recording URL (Optional)",
                            hintText: "https://youtube.com/...",
                          ),
                          onChanged: (v) => recordingUrl = v,
                        ),
                      ],
                    ),
                    actions: [
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel"),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () async {
                          if (selectedCourse == null) return;
                          if (titleController.text.isEmpty) {
                            ToastService.showError(
                              "Please enter a session title",
                            );
                            return;
                          }

                          // Conflict Detection logic
                          final proposedStart = DateTime.now().add(
                            const Duration(hours: 2),
                          );
                          final proposedEnd = proposedStart.add(
                            const Duration(hours: 1),
                          );

                          final hasConflict = (classes).any((c) {
                            final existingStart = DateTime.parse(
                              c['start_time'],
                            );
                            final existingEnd = existingStart.add(
                              const Duration(hours: 1),
                            );
                            return (proposedStart.isBefore(existingEnd) &&
                                proposedEnd.isAfter(existingStart));
                          });

                          if (hasConflict) {
                            ToastService.showError("Conflict Detected!");
                            return;
                          }

                          try {
                            await ref
                                .read(teacherRepositoryProvider)
                                .scheduleSession(
                                  selectedCourse!.id,
                                  titleController.text,
                                  proposedStart,
                                  isRecurring: isRecurring,
                                  dayOfWeek: selectedDay,
                                  recordingUrl: recordingUrl,
                                );
                            ref.invalidate(teacherDashboardProvider);
                            if (context.mounted) {
                              Navigator.pop(context);
                              ToastService.showSuccess("Session scheduled!");
                            }
                          } catch (e) {
                            ToastService.showError("Failed to schedule");
                          }
                        },
                        child: const Text("Schedule"),
                      ),
                    ],
                  ),
                ),
              );
            },
            backgroundColor: AppColors.primary,
            icon: const Icon(LucideIcons.video, color: Colors.white),
            label: const Text(
              "Start Live Session",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ).animate().scale(delay: 1.seconds, curve: Curves.easeOutBack),
        );
      },
    );
  }

  void _showAnnouncementDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final messageController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("New Announcement"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Title"),
            ),
            TextField(
              controller: messageController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: "Message"),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () async {
              try {
                await ref
                    .read(teacherRepositoryProvider)
                    .postAnnouncement(
                      titleController.text,
                      messageController.text,
                      'student',
                    );
                if (context.mounted) Navigator.pop(context);
              } catch (e) {
                print('❌ [UI ERROR]: Announcement failed: $e');
              }
            },
            child: const Text("Post"),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      color: isDark ? AppColors.surfaceDark : Colors.white,
      opacity: isDark ? 0.3 : 0.8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 20),
          Text(
            value,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: isDark
                  ? AppColors.textSecondaryLight
                  : AppColors.textSecondaryDark,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final String subject;
  final String time;
  final String? room;
  final int students;
  final String status;
  final int index;
  const _TimelineItem({
    required this.subject,
    required this.time,
    this.room,
    required this.students,
    required this.status,
    required this.index,
  });
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
          ],
          border: Border.all(
            color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
          ),
        ),
        child: _buildContent(context, false, isDark),
      ),
    ).animate().fadeIn(delay: (400 + index * 100).ms).slideX(begin: 0.1);
  }

  Widget _buildContent(BuildContext context, bool current, bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: current
                ? Colors.white.withOpacity(0.2)
                : (isDark ? Colors.white10 : AppColors.backgroundLight),
            shape: BoxShape.circle,
          ),
          child: Icon(
            LucideIcons.clock,
            color: current ? Colors.white : AppColors.textMutedLight,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                subject,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: current
                      ? Colors.white
                      : (isDark ? Colors.white : AppColors.textMainLight),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                time,
                style: TextStyle(
                  color: current
                      ? Colors.white70
                      : AppColors.textSecondaryLight,
                  fontSize: 13,
                ),
              ),
              if (room != null && room!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      LucideIcons.mapPin,
                      size: 10,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      room!,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 10,
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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: current
                ? Colors.white.withOpacity(0.2)
                : (isDark
                      ? Colors.white10
                      : AppColors.primary.withOpacity(0.05)),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Text(
            status,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: current ? Colors.white : AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}

class _ToolButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final Color color;
  final VoidCallback onTap;
  const _ToolButton({
    required this.icon,
    required this.label,
    this.subtitle,
    required this.color,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
          ],
          border: Border.all(
            color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: TextStyle(
                      color: isDark ? Colors.white38 : Colors.black38,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
            const Spacer(),
            const Icon(
              LucideIcons.chevronRight,
              size: 20,
              color: AppColors.textMutedLight,
            ),
          ],
        ),
      ).animate().fadeIn().slideY(begin: 0.1),
    );
  }
}
