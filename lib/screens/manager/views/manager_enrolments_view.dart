import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:edulearn/core/constants/app_colors.dart';
import 'package:edulearn/providers/manager/manager_provider.dart';
import 'package:edulearn/core/utils/toast_service.dart';
import 'package:edulearn/core/widgets/app_loader.dart';
import '../../admin/widgets/admin_common_widgets.dart';

class ManagerEnrolmentsView extends ConsumerStatefulWidget {
  const ManagerEnrolmentsView({super.key});

  @override
  ConsumerState<ManagerEnrolmentsView> createState() =>
      _ManagerEnrolmentsViewState();
}

class _ManagerEnrolmentsViewState extends ConsumerState<ManagerEnrolmentsView> {
  int _currentPage = 1;

  @override
  Widget build(BuildContext context) {
    final enrollmentsAsync = ref.watch(
      managerEnrollmentsProvider(_currentPage),
    );

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 16,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Student Enrolments",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Assign students to courses and manage active learning seats.",
                    style: TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _showEnrollDialog(),
                icon: const Icon(LucideIcons.userPlus, size: 18),
                label: const Text("Enroll Student"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Expanded(
            child: enrollmentsAsync.when(
              data: (data) {
                final enrollments = (data['data'] as List? ?? []);
                if (enrollments.isEmpty)
                  return const AdminEmptyState(
                    message: "No enrollments found.",
                  );

                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: enrollments.length,
                        itemBuilder: (context, index) =>
                            _buildEnrollmentTile(enrollments[index]),
                      ),
                    ),
                    _buildPagination(data['last_page'] ?? 1),
                  ],
                );
              },
              loading: () => Skeletonizer(
                ignoreContainers: true,
                enabled: true,
                child: ListView.builder(
                  itemCount: 6,
                  itemBuilder: (context, index) => _buildEnrollmentTile({
                    'user': {'name': 'Loading Student'},
                    'course': {'title': 'Loading Course Title'},
                  }),
                ),
              ),
              error: (err, s) => Center(
                child: Text(
                  "Error: $err",
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnrollmentTile(Map<String, dynamic> enrollment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: const Icon(
              LucideIcons.graduationCap,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  enrollment['user']?['name'] ?? "Unknown Student",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Enrolled in: ${enrollment['course']?['title'] ?? 'Unknown Course'}",
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              LucideIcons.userMinus,
              color: Colors.redAccent,
              size: 18,
            ),
            onPressed: () => _handleUnenroll(enrollment),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination(int lastPage) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(LucideIcons.chevronLeft, color: Colors.white54),
            onPressed: _currentPage > 1
                ? () => setState(() => _currentPage--)
                : null,
          ),
          Text(
            "Page $_currentPage of $lastPage",
            style: const TextStyle(color: Colors.white70),
          ),
          IconButton(
            icon: const Icon(LucideIcons.chevronRight, color: Colors.white54),
            onPressed: _currentPage < lastPage
                ? () => setState(() => _currentPage++)
                : null,
          ),
        ],
      ),
    );
  }

  void _showEnrollDialog() {
    showDialog(
      context: context,
      builder: (context) => const _EnrollFormDialog(),
    ).then((updated) {
      if (updated == true) {
        ref.invalidate(managerEnrollmentsProvider);
        ref.invalidate(managerStatsProvider);
      }
    });
  }

  Future<void> _handleUnenroll(Map<String, dynamic> enrollment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: const Text(
          "Cancel Enrolment?",
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          "Remove ${enrollment['user']?['name']} from ${enrollment['course']?['title']}?",
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("No"),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "Yes, Remove",
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref
            .read(managerRepositoryProvider)
            .unenrollStudent(enrollment['id'].toString());
        ref.invalidate(managerEnrollmentsProvider);
        ref.invalidate(managerStatsProvider);
        ToastService.showSuccess("Student unenrolled");
      } catch (e) {
        ToastService.showError("Failed to unenroll: $e");
      }
    }
  }
}

class _EnrollFormDialog extends ConsumerStatefulWidget {
  const _EnrollFormDialog();

  @override
  ConsumerState<_EnrollFormDialog> createState() => _EnrollFormDialogState();
}

class _EnrollFormDialogState extends ConsumerState<_EnrollFormDialog> {
  String? _selectedStudentId;
  String? _selectedCourseId;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final studentsAsync = ref.watch(managerUsersProvider((1, null, "Student")));
    final coursesAsync = ref.watch(managerCoursesProvider((1, null)));

    return AlertDialog(
      backgroundColor: AppColors.surfaceDark,
      title: const Text(
        "Enroll Student",
        style: TextStyle(color: Colors.white),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          studentsAsync.when(
            data: (data) {
              final students = (data['data'] as List? ?? []);
              return _buildDropdown(
                "Select Student",
                _selectedStudentId,
                students
                    .map(
                      (s) => DropdownMenuItem(
                        value: s['id'].toString(),
                        child: Text(s['name']),
                      ),
                    )
                    .toList(),
                (val) => setState(() => _selectedStudentId = val),
              );
            },
            loading: () => const LinearProgressIndicator(),
            error: (err, s) => Text("Error loading students: $err"),
          ),
          const SizedBox(height: 16),
          coursesAsync.when(
            data: (data) {
              final courses = (data['data'] as List? ?? []);
              return _buildDropdown(
                "Select Course",
                _selectedCourseId,
                courses
                    .map(
                      (c) => DropdownMenuItem(
                        value: c['id'].toString(),
                        child: Text(c['title']),
                      ),
                    )
                    .toList(),
                (val) => setState(() => _selectedCourseId = val),
              );
            },
            loading: () => const LinearProgressIndicator(),
            error: (err, s) => Text("Error loading courses: $err"),
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
          onPressed: _isLoading ? null : _submit,
          child: _isLoading
              ? const AppLoader(color: AppColors.primary, size: 20)
              : const Text("Enroll"),
        ),
      ],
    );
  }

  Widget _buildDropdown(
    String label,
    String? value,
    List<DropdownMenuItem<String>> items,
    Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
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

  Future<void> _submit() async {
    if (_selectedStudentId == null || _selectedCourseId == null) {
      ToastService.showError("Please select both student and course");
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref.read(managerRepositoryProvider).enrollStudent({
        'user_id': _selectedStudentId,
        'course_id': _selectedCourseId,
      });
      ToastService.showSuccess("Student enrolled successfully");
      Navigator.pop(context, true);
    } catch (e) {
      ToastService.showError("Enrollment failed: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
