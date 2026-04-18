import 'package:edulearn/core/widgets/app_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:edulearn/core/constants/app_colors.dart';
import 'package:edulearn/providers/manager/manager_provider.dart';
import 'package:edulearn/core/utils/toast_service.dart';
import '../../admin/widgets/admin_common_widgets.dart';
import 'manager_curriculum_view.dart';

class ManagerCoursesView extends ConsumerStatefulWidget {
  const ManagerCoursesView({super.key});

  @override
  ConsumerState<ManagerCoursesView> createState() => _ManagerCoursesViewState();
}

class _ManagerCoursesViewState extends ConsumerState<ManagerCoursesView> {
  int _currentPage = 1;
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final coursesAsync = ref.watch(
      managerCoursesProvider((_currentPage, _searchQuery)),
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
                    "Institution Courses",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Manage your school's curriculum and instructor assignments.",
                    style: TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _showCourseDialog(),
                icon: const Icon(LucideIcons.plus, size: 18),
                label: const Text("Create Course"),
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
          const SizedBox(height: 24),
          _buildSearch(),
          const SizedBox(height: 24),
          Expanded(
            child: coursesAsync.when(
              data: (data) {
                final courses = (data['data'] as List? ?? []);
                if (courses.isEmpty)
                  return const AdminEmptyState(message: "No courses found.");

                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: courses.length,
                        itemBuilder: (context, index) =>
                            _buildCourseCard(courses[index]),
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
                  itemCount: 4,
                  itemBuilder: (context, index) => _buildCourseCard({
                    'title': 'Loading Course Title',
                    'category': 'Programming',
                    'status': 'Active',
                    'instructor': {'name': 'Loading Instructor'},
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

  Widget _buildSearch() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: TextField(
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          hintText: "Search courses by title...",
          hintStyle: TextStyle(color: Colors.white38, fontSize: 13),
          border: InputBorder.none,
          icon: Icon(LucideIcons.search, size: 18, color: Colors.white38),
        ),
        onChanged: (v) => setState(() {
          _searchQuery = v;
          _currentPage = 1;
        }),
      ),
    );
  }

  Widget _buildCourseCard(Map<String, dynamic> course) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ManagerCurriculumView(courseId: course['id'].toString()),
          ),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                LucideIcons.bookOpen,
                color: AppColors.accent,
                size: 32,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "${course['category'] ?? "General"} • ${course['level'] ?? ""}",
                          style: TextStyle(
                            color: AppColors.accent,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildStatusBadge(course['status'] ?? "Active"),
                    ],
                  ),
                  Text(
                    course['title'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        LucideIcons.user,
                        size: 14,
                        color: Colors.white38,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        course['instructor']?['name'] ?? "No Instructor",
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(LucideIcons.moreVertical, color: Colors.white38),
              onSelected: (val) {
                if (val == 'curriculum') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ManagerCurriculumView(
                        courseId: course['id'].toString(),
                      ),
                    ),
                  );
                }
                if (val == 'edit') _showCourseDialog(course: course);
                if (val == 'delete') _handleDelete(course);
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'curriculum',
                  child: Row(
                    children: [
                      Icon(
                        LucideIcons.layers,
                        size: 16,
                        color: AppColors.accent,
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Curriculum Builder",
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(LucideIcons.pencil, size: 16, color: Colors.white70),
                      SizedBox(width: 8),
                      Text(
                        "Edit Details",
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(
                        LucideIcons.trash2,
                        size: 16,
                        color: Colors.redAccent,
                      ),
                      SizedBox(width: 8),
                      Text("Delete", style: TextStyle(color: Colors.redAccent)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final color = status == "Active" ? Colors.green : Colors.white38;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
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

  void _showCourseDialog({Map<String, dynamic>? course}) {
    showDialog(
      context: context,
      builder: (context) => _CourseFormDialog(course: course),
    ).then((updated) {
      if (updated == true) {
        ref.invalidate(managerCoursesProvider);
        ref.invalidate(managerStatsProvider);
      }
    });
  }

  Future<void> _handleDelete(Map<String, dynamic> course) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: const Text(
          "Delete Course?",
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          "Delete '${course['title']}'? This cannot be undone.",
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "Delete",
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
            .deleteCourse(course['id'].toString());
        ref.invalidate(managerCoursesProvider);
        ref.invalidate(managerStatsProvider);
        ToastService.showSuccess("Course deleted successfully");
      } catch (e) {
        ToastService.showError("Failed to delete course: $e");
      }
    }
  }
}

class _CourseFormDialog extends ConsumerStatefulWidget {
  final Map<String, dynamic>? course;
  const _CourseFormDialog({this.course});

  @override
  ConsumerState<_CourseFormDialog> createState() => _CourseFormDialogState();
}

class _CourseFormDialogState extends ConsumerState<_CourseFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  String? _selectedCategory;
  String? _selectedLevel;
  String? _selectedInstructorId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.course?['title']);
    _descController = TextEditingController(
      text: widget.course?['description'],
    );
    _selectedCategory = widget.course?['category'];
    _selectedLevel = widget.course?['level'];
    _selectedInstructorId = widget.course?['instructor_id']?.toString();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final teachersAsync = ref.watch(managerUsersProvider((1, null, "Teacher")));

    return AlertDialog(
      backgroundColor: AppColors.surfaceDark,
      title: Text(
        widget.course == null ? "Create New Course" : "Edit Course",
        style: const TextStyle(color: Colors.white),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DialogTextField(
                controller: _titleController,
                label: "Course Title",
                hint: "e.g. Science - Grade 8",
              ),
              const SizedBox(height: 16),
              _buildDropdown(
                "Subject",
                _selectedCategory,
                [
                  "Mathematics",
                  "Science",
                  "English",
                  "English Literature",
                  "ICT",
                  "Social Studies",
                  "Arts",
                  "General",
                ],
                (v) => setState(() => _selectedCategory = v!),
                "Select Subject",
              ),
              const SizedBox(height: 16),
              _buildDropdown(
                "Grade Level",
                _selectedLevel,
                ["Grade 8", "Grade 9", "Grade 10", "Grade 11", "Grade 12"],
                (v) => setState(() => _selectedLevel = v),
                "Select Grade",
              ),
              const SizedBox(height: 16),
              DialogTextField(
                controller: _descController,
                label: "Description",
                hint: "Provide an overview of the curriculum...",
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              teachersAsync.when(
                data: (data) {
                  final teachers = (data['data'] as List? ?? []);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Assigned Instructor",
                        style: TextStyle(color: Colors.white54, fontSize: 12),
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
                            value: _selectedInstructorId,
                            isExpanded: true,
                            dropdownColor: AppColors.surfaceDark,
                            style: const TextStyle(color: Colors.white),
                            items: teachers
                                .map(
                                  (t) => DropdownMenuItem(
                                    value: t['id'].toString(),
                                    child: Text(t['name']),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) =>
                                setState(() => _selectedInstructorId = val),
                          ),
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const AppLoader(),
                error: (err, s) => Text(
                  "Error loading teachers: $err",
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading ? const AppLoader(size: 20) : const Text("Save"),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategory == null) {
      ToastService.showError("Please select a subject");
      return;
    }

    if (_selectedLevel == null) {
      ToastService.showError("Please select a grade level");
      return;
    }

    if (_selectedInstructorId == null) {
      ToastService.showError("Please select an instructor");
      return;
    }

    setState(() => _isLoading = true);

    final data = {
      'title': _titleController.text,
      'description': _descController.text,
      'category': _selectedCategory,
      'level': _selectedLevel,
      'instructor_id': _selectedInstructorId,
    };

    try {
      if (widget.course == null) {
        await ref.read(managerRepositoryProvider).createCourse(data);
        ToastService.showSuccess("Course created successfully");
      } else {
        await ref
            .read(managerRepositoryProvider)
            .updateCourse(widget.course!['id'].toString(), data);
        ToastService.showSuccess("Course updated successfully");
      }
      Navigator.pop(context, true);
    } catch (e) {
      ToastService.showError("Failed to save course: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildDropdown(
    String label,
    String? value,
    List<String> items,
    Function(String?) onChanged,
    String placeholder,
  ) {
    final menuItems = items
        .map((i) => DropdownMenuItem(value: i, child: Text(i)))
        .toList();

    // Bugfix: Ensure value exists in items to avoid DropdownButton assertion crash
    if (value != null && !items.contains(value)) {
      menuItems.add(DropdownMenuItem(value: value, child: Text(value)));
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(
            placeholder,
            style: const TextStyle(color: Colors.white24, fontSize: 13),
          ),
          isExpanded: true,
          dropdownColor: AppColors.surfaceDark,
          style: const TextStyle(color: Colors.white),
          items: menuItems,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
