import 'package:edulearn/providers/auth/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:edulearn/core/constants/app_colors.dart';
import 'package:edulearn/providers/student/dashboard_provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({super.key});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final user = ref.watch(authProvider);
    final isTeacher = user?.role == 'Teacher';

    // Dynamically watch the correct provider based on role
    final dashboardAsync = isTeacher
        ? ref.watch(teacherDashboardProvider)
        : ref.watch(studentDashboardProvider);

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text("Timetable", style: theme.textTheme.titleLarge),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: dashboardAsync.when(
        loading: () => Skeletonizer(
          ignoreContainers: true,
          enabled: true,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TableCalendar(
                  firstDay: DateTime.now(),
                  lastDay: DateTime.now(),
                  focusedDay: DateTime.now(),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: 3,
                  itemBuilder: (context, index) => const _ScheduleItem(
                    time: "09:00",
                    subject: "Loading subject",
                    instructor: "Loading staff",
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
        error: (err, stack) => Center(child: Text("Error: $err")),
        data: (data) {
          final List classes = data['upcoming_classes'] ?? [];

          final dayClasses = classes.where((c) {
            final classDate = DateTime.parse(c['start_time']);
            return isSameDay(classDate, _selectedDay);
          }).toList();

          return Column(
            children: [
              // Modern Calendar implementation
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TableCalendar(
                  firstDay: DateTime.now().subtract(const Duration(days: 90)),
                  lastDay: DateTime.now().add(const Duration(days: 180)),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  onFormatChanged: (format) {
                    setState(() => _calendarFormat = format);
                  },
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    markerDecoration: const BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: true,
                    titleCentered: true,
                    formatButtonShowsNext: false,
                  ),
                ),
              ).animate().fadeIn().slideY(begin: -0.1),

              const SizedBox(height: 16),

              // Timeline List for Selected Day
              Expanded(
                child: dayClasses.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              LucideIcons.calendarX2,
                              size: 64,
                              color: isDark
                                  ? Colors.white10
                                  : Colors.black.withOpacity(0.05),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "No classes scheduled",
                              style: TextStyle(
                                color: isDark ? Colors.white30 : Colors.black45,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 10,
                        ),
                        itemCount: dayClasses.length,
                        itemBuilder: (context, index) {
                          final cls = dayClasses[index];
                          final timeString = cls['start_time'].toString();
                          final time = DateTime.parse(timeString);

                          // Handle different labeling based on role
                          String displayInstructor = "";
                          if (isTeacher) {
                            displayInstructor =
                                "Course Session"; // For teachers, they ARE the instructor
                          } else {
                            displayInstructor =
                                cls['instructor'] ??
                                (cls['type'] == 'live_session'
                                    ? 'Live Session'
                                    : 'Institution Staff');
                          }

                          return _ScheduleItem(
                                time:
                                    "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}",
                                subject: cls['title'] ?? 'Untitled Class',
                                instructor: displayInstructor,
                                room: cls['room_label'] ?? cls['room'],
                                color: index % 2 == 0
                                    ? Colors.blueAccent
                                    : AppColors.primary,
                              )
                              .animate()
                              .fadeIn(delay: (index * 100).ms)
                              .slideX(begin: 0.1);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ScheduleItem extends StatelessWidget {
  final String time;
  final String subject;
  final String instructor;
  final String? room;
  final Color color;

  const _ScheduleItem({
    required this.time,
    required this.subject,
    required this.instructor,
    this.room,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Text(
                time,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 60,
                width: 2,
                color: Colors.grey.withOpacity(0.2),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark ? Colors.white10 : Colors.grey.withOpacity(0.1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(2),
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
                            fontSize: 16,
                            color: isDark
                                ? Colors.white
                                : AppColors.textMainLight,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          instructor,
                          style: TextStyle(
                            color: isDark
                                ? AppColors.textSecondaryDark
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
                                size: 12,
                                color: AppColors.primary,
                              ),
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
