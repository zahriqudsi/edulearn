import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:edulearn/core/constants/app_colors.dart';
import 'package:edulearn/providers/teacher/teacher_provider.dart';
import 'package:edulearn/core/utils/toast_service.dart';
import 'package:edulearn/core/network/api_client.dart';
import '../../admin/widgets/admin_common_widgets.dart';
import '../../admin/views/curriculum_editor_view.dart';
import 'package:edulearn/providers/student/course_provider.dart';

class TeacherCoursesView extends ConsumerStatefulWidget {
  const TeacherCoursesView({super.key});

  @override
  ConsumerState<TeacherCoursesView> createState() => _TeacherCoursesViewState();
}

class _TeacherCoursesViewState extends ConsumerState<TeacherCoursesView> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String _category = 'Academic';
  String _level = 'Beginner';
  String _status = 'Published';
  bool _isLoading = false;

  void _showCourseDialog(
    List<String> categories,
    List<String> levels, [
    Map<String, dynamic>? course,
  ]) {
    final isEditing = course != null;
    if (isEditing) {
      _titleController.text = course['title'];
      _descController.text = course['description'];
      _category = course['category'] ?? 'Academic';
      _level = course['level'] ?? 'Beginner';
      _status = course['status'] ?? 'Published';
    } else {
      _titleController.clear();
      _descController.clear();
      _status = 'Published';
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surfaceDark,
          title: Text(
            isEditing ? "Edit Course" : "New Course",
            style: const TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DialogTextField(
                  controller: _titleController,
                  label: "Course Title",
                ),
                const SizedBox(height: 16),
                DialogTextField(
                  controller: _descController,
                  label: "Description",
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                _buildDropdown(
                  "Category",
                  _category,
                  categories,
                  (v) => setDialogState(() => _category = v!),
                ),
                const SizedBox(height: 16),
                _buildDropdown(
                  "Level",
                  _level,
                  levels,
                  (v) => setDialogState(() => _level = v!),
                ),
                const SizedBox(height: 16),
                _buildDropdown(
                  "Status",
                  _status,
                  ['Draft', 'Published', 'Archived'],
                  (v) => setDialogState(() => _status = v!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () async {
                      setDialogState(() => _isLoading = true);
                      try {
                        final data = {
                          'title': _titleController.text,
                          'description': _descController.text,
                          'category': _category,
                          'level': _level,
                          'status': _status,
                        };
                        if (isEditing) {
                          await ref
                              .read(teacherRepositoryProvider)
                              .updateCourse(course['id'].toString(), data);
                        } else {
                          await ref
                              .read(teacherRepositoryProvider)
                              .createCourse(data);
                        }
                        ref.invalidate(teacherCoursesProvider);
                        ToastService.showSuccess(
                          isEditing ? "Course Updated" : "Course Created",
                        );
                        if (context.mounted) Navigator.pop(context);
                      } catch (e) {
                        ToastService.showError(ApiClient.getErrorMessage(e));
                      } finally {
                        setDialogState(() => _isLoading = false);
                      }
                    },
              child: Text(_isLoading ? "Saving..." : "Save"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    String value,
    List<String> items,
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
        DropdownButtonFormField<String>(
          value: value,
          dropdownColor: AppColors.surfaceDark,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          items: (items.contains(value) ? items : [value, ...items])
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Future<void> _handleDeleteCourse(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: const Text("Delete Course", style: TextStyle(color: Colors.white)),
        content: const Text(
          "Are you sure you want to delete this course? This action cannot be undone.",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(teacherRepositoryProvider).deleteCourse(id);
        ref.invalidate(teacherCoursesProvider);
        ToastService.showSuccess("Course Deleted");
      } catch (e) {
        ToastService.showError(ApiClient.getErrorMessage(e));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final coursesAsync = ref.watch(teacherCoursesProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final levelsAsync = ref.watch(levelsProvider);

    // Fallback defaults if DB is empty
    final categories = categoriesAsync.value ??
        ['Academic', 'Vocational', 'Language', 'Arts'];
    final levels = levelsAsync.value ??
        ['Beginner', 'Intermediate', 'Advance Level', 'Professional'];

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  "My Courses",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const Text(
                "Manage your curriculum and content.",
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: coursesAsync.when(
                  data: (data) {
                    if (data.isEmpty) {
                      return const AdminEmptyState(
                        message: "You haven't created any courses yet.",
                      );
                    }
                    return ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        final course = data[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceDark,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.05),
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(20),
                            leading: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                LucideIcons.book,
                                color: AppColors.primary,
                              ),
                            ),
                            title: Text(
                              course['title'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              "${course['category']} • ${course['level']}",
                              style: const TextStyle(
                                color: Colors.white38,
                                fontSize: 12,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    LucideIcons.layers,
                                    color: AppColors.accent,
                                    size: 20,
                                  ),
                                  tooltip: "Curriculum Builder",
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => CurriculumEditorView(
                                        courseId: course['id'].toString(),
                                      ),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    LucideIcons.edit3,
                                    color: Colors.white38,
                                    size: 20,
                                  ),
                                  onPressed: () => _showCourseDialog(
                                    categories,
                                    levels,
                                    course,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    LucideIcons.trash2,
                                    color: Colors.redAccent,
                                    size: 20,
                                  ),
                                  onPressed: () => _handleDeleteCourse(
                                    course['id'].toString(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const AdminLoadingShimmer(),
                  error: (err, s) => Center(
                    child: Text(
                      "Error: $err",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCourseDialog(categories, levels),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(LucideIcons.plus),
        label: const Text("New Course"),
      ),
    );
  }
}
