import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:edulearn/core/constants/app_colors.dart';
import 'package:edulearn/providers/manager/manager_provider.dart';
import 'package:edulearn/core/utils/toast_service.dart';
import '../../admin/widgets/admin_common_widgets.dart';

class TimetableView extends ConsumerStatefulWidget {
  const TimetableView({super.key});

  @override
  ConsumerState<TimetableView> createState() => _TimetableViewState();
}

class _TimetableViewState extends ConsumerState<TimetableView> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
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
    final schedulesAsync = ref.watch(managerSchedulesProvider);

    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 24,
                    runSpacing: 16,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    alignment: WrapAlignment.spaceBetween,
                    children: [
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 600),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Institution Timetable",
                              style: theme.textTheme.displaySmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                fontSize: 28,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              "Select a date to schedule a new session or manage existing ones.",
                              style: TextStyle(color: Colors.white54, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _showAddScheduleDialog(context, ref, initialDate: _selectedDay),
                        icon: const Icon(LucideIcons.plus, size: 18),
                        label: const Text("Schedule Session"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  // Calendar Implementation
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: TableCalendar(
                      firstDay: DateTime.now().subtract(const Duration(days: 365)),
                      lastDay: DateTime.now().add(const Duration(days: 365)),
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
                      headerStyle: const HeaderStyle(
                        formatButtonVisible: true,
                        titleCentered: true,
                        formatButtonShowsNext: false,
                        titleTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        leftChevronIcon: Icon(LucideIcons.chevronLeft, color: Colors.white),
                        rightChevronIcon: Icon(LucideIcons.chevronRight, color: Colors.white),
                      ),
                      calendarStyle: CalendarStyle(
                        defaultTextStyle: const TextStyle(color: Colors.white70),
                        weekendTextStyle: const TextStyle(color: Colors.white38),
                        todayDecoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  Text(
                    "Sessions for ${_selectedDay?.toString().split(' ')[0]}",
                    style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            schedulesAsync.when(
              data: (schedules) {
                final filteredSchedules = schedules.where((s) {
                  if (s['specific_date'] != null) {
                    return isSameDay(DateTime.parse(s['specific_date']), _selectedDay);
                  } else {
                    return s['day_of_week'] == (_selectedDay?.dayOfWeek ?? -1);
                  }
                }).toList();

                if (filteredSchedules.isEmpty) {
                  return SliverToBoxAdapter(child: _buildEmptyState());
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return _buildScheduleItem(context, ref, filteredSchedules[index]);
                    },
                    childCount: filteredSchedules.length,
                  ),
                );
              },
              loading: () => Skeletonizer.sliver(
                enabled: true,
                child: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildScheduleItem(context, ref, {
                      'day_of_week': 1,
                      'start_time': '09:00:00',
                      'end_time': '10:00:00',
                      'course': {'title': 'Mock Course Title'},
                      'teacher': {'name': 'Mock Teacher Name'},
                      'room_label': 'Mock Room',
                    }),
                    childCount: 3,
                  ),
                ),
              ),
              error: (err, stack) => SliverToBoxAdapter(
                child: Center(child: Text("Error: $err", style: const TextStyle(color: Colors.red))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 64),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.calendarX2, size: 48, color: Colors.white10),
          const SizedBox(height: 12),
          const Text("No sessions scheduled for this date", style: TextStyle(color: Colors.white38, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildScheduleItem(BuildContext context, WidgetRef ref, Map<String, dynamic> schedule) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            SizedBox(
              width: 100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    schedule['specific_date'] != null ? "One-off" : "Routine",
                    style: TextStyle(
                      color: schedule['specific_date'] != null ? AppColors.accent : Colors.white54,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "${schedule['start_time'].substring(0, 5)} - ${schedule['end_time'].substring(0, 5)}",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const VerticalDivider(color: Colors.white10),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(schedule['course']?['title'] ?? "Unknown Course", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 12,
                    children: [
                      _buildInfoTag(LucideIcons.user, schedule['teacher']?['name'] ?? "Staff"),
                      if (schedule['room_label'] != null) _buildInfoTag(LucideIcons.mapPin, schedule['room_label']),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(LucideIcons.trash2, color: Colors.redAccent, size: 18),
              onPressed: () => _handleDeleteSchedule(context, ref, schedule['id'].toString()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTag(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: Colors.white38),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(color: Colors.white38, fontSize: 11)),
      ],
    );
  }

  void _showAddScheduleDialog(BuildContext context, WidgetRef ref, {DateTime? initialDate}) {
    showDialog(
      context: context,
      builder: (context) => _AddScheduleForm(initialDate: initialDate),
    );
  }

  Future<void> _handleDeleteSchedule(BuildContext context, WidgetRef ref, String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: const Text("Delete entry?", style: TextStyle(color: Colors.white)),
        content: const Text("This action cannot be undone.", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete", style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(managerRepositoryProvider).deleteSchedule(id);
        ref.invalidate(managerSchedulesProvider);
        ToastService.showSuccess("Schedule deleted successfully");
      } catch (e) {
        ToastService.showError("Failed to delete schedule: $e");
      }
    }
  }
}

class _AddScheduleForm extends ConsumerStatefulWidget {
  final DateTime? initialDate;
  const _AddScheduleForm({this.initialDate});
  @override
  ConsumerState<_AddScheduleForm> createState() => _AddScheduleFormState();
}

class _AddScheduleFormState extends ConsumerState<_AddScheduleForm> {
  String? selectedCourseId;
  String? selectedTeacherId;
  DateTime? selectedDate;
  TimeOfDay startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay endTime = const TimeOfDay(hour: 10, minute: 0);
  final roomController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate;
  }

  @override
  void dispose() {
    roomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final coursesAsync = ref.watch(managerCoursesProvider((1, null)));
    final teachersAsync = ref.watch(managerUsersProvider((1, null, "Teacher")));

    return AlertDialog(
      backgroundColor: AppColors.surfaceDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: const Text("New Schedule Entry", style: TextStyle(color: Colors.white)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: selectedDate ?? DateTime.now(),
                  firstDate: DateTime.now().subtract(const Duration(days: 30)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) setState(() => selectedDate = date);
              },
              child: _buildValueDisplay("Selected Date", selectedDate?.toString().split(' ')[0] ?? "Choose Date"),
            ),
            const SizedBox(height: 16),
            coursesAsync.when(
              data: (data) {
                final courses = List<Map<String, dynamic>>.from(data['data'] ?? []);
                return _buildDropdown("Select Course", selectedCourseId, 
                  courses.map((c) => DropdownMenuItem(value: c['id'].toString(), child: Text(c['title']))).toList(),
                  (val) => setState(() => selectedCourseId = val));
              },
              loading: () => const LinearProgressIndicator(),
              error: (err, s) => Text("Error: $err"),
            ),
            const SizedBox(height: 16),
            teachersAsync.when(
              data: (data) {
                final teachers = List<Map<String, dynamic>>.from(data['data'] ?? []);
                return _buildDropdown("Select Teacher", selectedTeacherId,
                  teachers.map((t) => DropdownMenuItem(value: t['id'].toString(), child: Text(t['name']))).toList(),
                  (val) => setState(() => selectedTeacherId = val));
              },
              loading: () => const LinearProgressIndicator(),
              error: (err, s) => Text("Error: $err"),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final time = await showTimePicker(context: context, initialTime: startTime);
                      if (time != null) setState(() => startTime = time);
                    },
                    child: _buildValueDisplay("Start Time", startTime.format(context)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final time = await showTimePicker(context: context, initialTime: endTime);
                      if (time != null) setState(() => endTime = time);
                    },
                    child: _buildValueDisplay("End Time", endTime.format(context)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DialogTextField(controller: roomController, label: "Room / Location (Optional)"),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
        ElevatedButton(onPressed: _submit, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary), child: const Text("Save Entry")),
      ],
    );
  }

  Widget _buildDropdown(String label, String? value, List<DropdownMenuItem<String>> items, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: AppColors.surfaceDark,
              style: const TextStyle(color: Colors.white),
              items: items,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildValueDisplay(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (selectedCourseId == null || selectedTeacherId == null || selectedDate == null) {
      ToastService.showError("Please fill in all required fields (Date, Course, Teacher)");
      return;
    }

    final data = {
      "course_id": selectedCourseId,
      "teacher_id": selectedTeacherId,
      "specific_date": selectedDate?.toString().split(' ')[0],
      "start_time": "${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}:00",
      "end_time": "${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}:00",
      "room_label": roomController.text,
    };

    try {
      await ref.read(managerRepositoryProvider).createSchedule(data);
      ref.invalidate(managerSchedulesProvider);
      Navigator.pop(context);
      ToastService.showSuccess("Schedule entry created successfully");
    } catch (e) {
      ToastService.showError("Failed to create schedule: $e");
    }
  }
}

extension DateTimeExtension on DateTime {
  int get dayOfWeek => weekday % 7;
}
