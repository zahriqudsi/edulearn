import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:edulearn/core/constants/app_colors.dart';
import 'package:edulearn/providers/admin/admin_provider.dart';
import 'package:edulearn/core/utils/toast_service.dart';
import 'package:edulearn/core/network/api_client.dart';
import '../widgets/admin_common_widgets.dart';
import 'curriculum_editor_view.dart';

class AdminCoursesView extends ConsumerStatefulWidget {
  const AdminCoursesView({super.key});

  @override
  ConsumerState<AdminCoursesView> createState() => _AdminCoursesViewState();
}

class _AdminCoursesViewState extends ConsumerState<AdminCoursesView> {
  final _searchController = TextEditingController();
  String _searchQuery = "";
  int _currentPage = 1;
  String? _selectedInstitution;
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final coursesAsync = ref.watch(
      adminCoursesProvider((_currentPage, _searchQuery, _selectedInstitution)),
    );
    final isWide = MediaQuery.of(context).size.width > 900;

    return coursesAsync.when(
      loading: () => const AdminLoadingShimmer(),
      error: (err, stack) => Center(child: Text("Error: $err")),
      data: (paginatedData) {
        final List<dynamic> courses = paginatedData['data'] ?? [];
        final int totalPages = paginatedData['last_page'] ?? 1;

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              sliver: SliverToBoxAdapter(
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
                              "Courses",
                              style: theme.textTheme.displaySmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                fontSize: 32,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              "Global curriculum management",
                              style: TextStyle(color: Colors.white54),
                            ),
                          ],
                        ),
                        HeaderActionButton(
                          icon: LucideIcons.plus,
                          onPressed: () => _showCourseForm(context, ref),
                          color: AppColors.accent,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Search & Filter Bar
                    Row(
                      children: [
                        Expanded(
                          child: ElegantSearchBar(
                            controller: _searchController,
                            hint: "Search courses...",
                            searchQuery: _searchQuery,
                            onChanged: (val) {
                              if (_debounce?.isActive ?? false)
                                _debounce?.cancel();
                              _debounce = Timer(
                                const Duration(milliseconds: 500),
                                () {
                                  setState(() {
                                    _searchQuery = val;
                                    _currentPage = 1;
                                  });
                                },
                              );
                            },
                            onClear: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = "";
                                _currentPage = 1;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        _buildInstitutionFilter(),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.all(24),
              sliver: courses.isEmpty
                  ? const SliverToBoxAdapter(
                      child: Center(
                        child: Text(
                          "No courses found",
                          style: TextStyle(color: Colors.white38),
                        ),
                      ),
                    )
                  : SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isWide ? 3 : 1,
                        childAspectRatio: isWide ? 1.5 : 1.3,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                      ),
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final course = courses[index];
                        return _CourseManagementCard(
                          course: course,
                          onEdit: () => _showCourseForm(context, ref, course),
                          onDelete: () => _confirmDelete(context, ref, course),
                        );
                      }, childCount: courses.length),
                    ),
            ),

            if (totalPages > 1)
              SliverToBoxAdapter(
                child: PaginationFooter(
                  currentPage: _currentPage - 1,
                  totalPages: totalPages,
                  onPageChanged: (page) =>
                      setState(() => _currentPage = page + 1),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        );
      },
    );
  }

  Widget _buildInstitutionFilter() {
    final instAsync = ref.watch(adminInstitutionsProvider((1, null)));

    return instAsync.maybeWhen(
      data: (data) {
        final List<dynamic> insts = data['data'] ?? [];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedInstitution,
              hint: const Text(
                "All Institutions",
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),
              dropdownColor: AppColors.surfaceDark,
              style: const TextStyle(color: Colors.white),
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text("All Institutions"),
                ),
                ...insts.map(
                  (i) => DropdownMenuItem<String>(
                    value: i['id'].toString(),
                    child: Text(i['name']),
                  ),
                ),
              ],
              onChanged: (v) => setState(() {
                _selectedInstitution = v;
                _currentPage = 1;
              }),
            ),
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }

  void _showCourseForm(
    BuildContext context,
    WidgetRef ref, [
    Map<String, dynamic>? course,
  ]) {
    final isEditing = course != null;
    final titleController = TextEditingController(text: course?['title']);
    final descController = TextEditingController(text: course?['description']);
    String? category = isEditing ? (course['category'] ?? "General") : null;
    String? level = isEditing ? (course['level'] ?? "Grade 8") : null;
    String? status = isEditing ? (course['status'] ?? "Draft") : null;
    String? instId = course?['institution_id']?.toString();
    String? instructorId = course?['instructor_id']?.toString();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Consumer(
          builder: (context, ref, _) => AlertDialog(
            backgroundColor: AppColors.surfaceDark,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: Text(
              isEditing ? "Edit Course" : "New Course",
              style: const TextStyle(color: Colors.white),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DialogTextField(
                    controller: titleController,
                    label: "Course Title",
                    hint: "e.g. Grade 10 Mathematics",
                    maxLines: 1,
                  ),
                  const SizedBox(height: 16),
                  DialogTextField(
                    controller: descController,
                    label: "Description",
                    hint: "Enter a detailed course description...",
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),

                  _buildSimpleDropdown(
                    "Subject Category",
                    category,
                    [
                      "Mathematics",
                      "Science",
                      "English",
                      "Eng Literature",
                      "History",
                      "ICT",
                      "Geography",
                      "Physics",
                      "Chemistry",
                      "Biology",
                      "Civics",
                      "Arts",
                      "General",
                    ],
                    (v) => setDialogState(() => category = v),
                    "Select Subject",
                  ),
                  const SizedBox(height: 12),
                  _buildSimpleDropdown(
                    "Grade Level",
                    level,
                    ["Grade 8", "Grade 9", "Grade 10", "Grade 11", "Grade 12"],
                    (v) => setDialogState(() => level = v),
                    "Select Grade",
                  ),
                  const SizedBox(height: 12),
                  _buildSimpleDropdown(
                    "Status",
                    status,
                    ["Draft", "Published", "Archived"],
                    (v) => setDialogState(() => status = v),
                    "Select Status",
                  ),
                  const SizedBox(height: 12),

                  // Instructor Selector
                  ref.watch(adminUsersProvider((1, "", "Teacher"))).when(
                        data: (data) {
                          final teachers = (data['data'] as List? ?? []);
                          return _buildSimpleDropdown(
                            "Instructor",
                            instructorId,
                            teachers
                                .map(
                                  (t) => {
                                    "id": t['id'].toString(),
                                    "label": t['name'] as String,
                                  },
                                )
                                .toList(),
                            (v) => setDialogState(() => instructorId = v),
                            "Select Instructor",
                          );
                        },
                        loading: () => const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: LinearProgressIndicator(),
                        ),
                        error: (e, s) => Text(
                          "Error loading teachers: $e",
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                  const SizedBox(height: 12),

                  // Institution Selector
                  ref.watch(adminInstitutionsProvider((1, ""))).when(
                        data: (data) {
                          final insts = (data['data'] as List? ?? []);
                          return _buildSimpleDropdown(
                            "Institution",
                            instId,
                            insts
                                .map(
                                  (i) => {
                                    "id": i['id'].toString(),
                                    "label": i['name'] as String,
                                  },
                                )
                                .toList(),
                            (v) => setDialogState(() => instId = v),
                            "Select Institution",
                          );
                        },
                        loading: () => const SizedBox.shrink(),
                        error: (e, s) => const SizedBox.shrink(),
                      ),
                ],
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () async {
                  try {
                    if (category == null) {
                      ToastService.showError("Please select a subject category");
                      return;
                    }
                    if (level == null) {
                      ToastService.showError("Please select a grade level");
                      return;
                    }
                    if (status == null) {
                      ToastService.showError("Please select a status");
                      return;
                    }
                    if (instructorId == null) {
                      ToastService.showError("Please select an instructor");
                      return;
                    }
                    final data = {
                      "title": titleController.text,
                      "description": descController.text,
                      "category": category,
                      "level": level,
                      "status": status,
                      "instructor_id": instructorId,
                      "institution_id": instId,
                    };

                    if (isEditing) {
                      await ref
                          .read(adminRepositoryProvider)
                          .updateCourse(course['id'].toString(), data);
                    } else {
                      await ref.read(adminRepositoryProvider).createCourse(data);
                    }

                    if (context.mounted) Navigator.pop(context);
                    ref.invalidate(adminCoursesProvider);
                    ToastService.showSuccess(
                      isEditing ? "Course Updated" : "Course Created",
                    );
                  } catch (e) {
                    ToastService.showError(ApiClient.getErrorMessage(e));
                  }
                },
                child: Text(isEditing ? "Save" : "Create"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSimpleDropdown(
    String label,
    String? value,
    dynamic items,
    Function(String?) onChanged,
    String placeholder,
  ) {
    List<DropdownMenuItem<String>> menuItems = [];

    if (items is List<String>) {
      menuItems = items
          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
          .toList();
    } else if (items is List<Map<String, String>>) {
      menuItems = items.map((item) {
        return DropdownMenuItem<String>(
          value: item['id'],
          child: Text(item['label'] ?? 'Unknown'),
        );
      }).toList();
    }

    // Bugfix: Ensure the current value exists in menuItems to prevent DropdownButton crash
    if (value != null && !menuItems.any((item) => item.value == value)) {
      menuItems.add(DropdownMenuItem<String>(value: value, child: Text(value)));
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

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> course,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: const Text(
          "Delete Course",
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          "Are you sure you want to delete '${course['title']}'? This will permanently remove all related curriculum and enrollments.",
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              try {
                await ref
                    .read(adminRepositoryProvider)
                    .deleteCourse(course['id'].toString());
                if (context.mounted) Navigator.pop(context);
                ref.invalidate(adminCoursesProvider);
                ToastService.showSuccess("Course Deleted");
              } catch (e) {
                ToastService.showError("Failed to delete course: $e");
              }
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }
}

class _CourseManagementCard extends ConsumerWidget {
  final Map<String, dynamic> course;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _CourseManagementCard({
    required this.course,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElegantCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  LucideIcons.bookOpen,
                  color: AppColors.primaryLight,
                  size: 24,
                ),
              ),
              Row(
                children: [
                  ActionButton(
                    icon: LucideIcons.layers,
                    color: AppColors.accent,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CurriculumEditorView(
                            courseId: course['id'].toString(),
                          ),
                        ),
                      );
                    },
                    tooltip: "Curriculum",
                  ),
                  const SizedBox(width: 8),
                  ActionButton(
                    icon: LucideIcons.pencil,
                    color: Colors.white70,
                    onPressed: onEdit,
                    tooltip: "Edit Course",
                  ),
                  const SizedBox(width: 8),
                  ActionButton(
                    icon: LucideIcons.trash2,
                    color: Colors.redAccent,
                    onPressed: onDelete,
                    tooltip: "Delete Course",
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          Text(
            course["title"] ?? 'Untitled Course',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            "${course["category"]} • ${course["level"]}",
            style: const TextStyle(color: Colors.white38, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(LucideIcons.user, size: 14, color: Colors.white24),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  course["instructor"]?["name"] ?? "No Instructor",
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (course["institution"] != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  LucideIcons.building,
                  size: 14,
                  color: Colors.white24,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    course["institution"]["name"],
                    style: const TextStyle(color: Colors.white54, fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
