import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:edulearn/core/constants/app_colors.dart';
import 'package:edulearn/providers/admin/admin_provider.dart';
import 'package:edulearn/providers/teacher/teacher_provider.dart';
import 'package:edulearn/providers/auth/auth_provider.dart';
import 'package:edulearn/models/user_model.dart';
import 'package:edulearn/core/utils/toast_service.dart';
import 'package:edulearn/core/network/api_client.dart';
import '../widgets/admin_common_widgets.dart';

class CurriculumEditorView extends ConsumerWidget {
  final String courseId;
  const CurriculumEditorView({super.key, required this.courseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final isTeacher = user?.role == UserRole.teacher;
    
    final courseAsync = isTeacher 
        ? ref.watch(teacherCourseDetailsProvider(courseId))
        : ref.watch(adminCourseDetailsProvider(courseId));

    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Curriculum Builder",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.rotateCcw),
            onPressed: () =>
                ref.invalidate(isTeacher ? teacherCourseDetailsProvider(courseId) : adminCourseDetailsProvider(courseId)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: courseAsync.when(
        loading: () => const AdminLoadingShimmer(),
        error: (err, stack) => Center(
          child: Text(
            "Error: $err",
            style: const TextStyle(color: Colors.white70),
          ),
        ),
        data: (course) {
          final subjects = (course['subjects'] as List? ?? []);

          return Column(
            children: [
              _buildCourseHeader(course),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: subjects.length + 1,
                  itemBuilder: (context, index) {
                    if (index == subjects.length) {
                      return _buildAddButton(
                        label: "Add New Subject",
                        onTap: () => _showSubjectForm(context, ref),
                        color: AppColors.primary,
                      );
                    }
                    return _SubjectTile(
                      courseId: courseId,
                      subject: subjects[index],
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCourseHeader(Map<String, dynamic> course) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(LucideIcons.book, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course['title'] ?? 'Untitled',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "${course['category']} • ${course['level']}",
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton({
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
              style: BorderStyle.solid,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(LucideIcons.plus, size: 18, color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSubjectForm(
    BuildContext context,
    WidgetRef ref, [
    Map<String, dynamic>? subject,
  ]) {
    final isEditing = subject != null;
    final subjectsList = [
      'Mathematics',
      'Science',
      'English',
      'Eng Literature',
      'History',
      'ICT',
      'Geography',
      'Physics',
      'Chemistry',
      'Biology',
      'Civics',
      'Arts'
    ];

    String? selectedTitle = subject?['title'];
    final user = ref.read(authProvider);
    final isTeacher = user?.role == UserRole.teacher;
    final repository = (isTeacher
        ? ref.read(teacherRepositoryProvider)
        : ref.read(adminRepositoryProvider)) as dynamic;

    if (selectedTitle != null && !subjectsList.contains(selectedTitle)) {
      selectedTitle = null; // Reset if not in standard list
    }

    final descController = TextEditingController(text: subject?['description']);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surfaceDark,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(
            isEditing ? "Edit Subject" : "New Subject",
            style: const TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSimpleDropdown(
                "Select Subject",
                selectedTitle,
                subjectsList,
                (val) => setDialogState(() => selectedTitle = val),
              ),
              const SizedBox(height: 16),
              DialogTextField(
                controller: descController,
                label: "Description (Optional)",
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: () async {
                if (selectedTitle == null) {
                  ToastService.showError("Please select a subject");
                  return;
                }
                try {
                  final data = {
                    "title": selectedTitle,
                    "description": descController.text,
                  };
                  if (isEditing) {
                    await repository.updateSubject(subject['id'].toString(), data);
                  } else {
                    await repository.createSubject(courseId, data);
                  }
                  if (context.mounted) Navigator.pop(context);
                  ref.invalidate(isTeacher ? teacherCourseDetailsProvider(courseId) : adminCourseDetailsProvider(courseId));
                  ToastService.showSuccess(
                    isEditing ? "Subject Updated" : "Subject Added",
                  );
                } catch (e) {
                  ToastService.showError(ApiClient.getErrorMessage(e));
                }
              },
              child: Text(isEditing ? "Save" : "Add"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleDropdown(
    String label,
    String? value,
    List<String> items,
    Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: AppColors.surfaceDark,
              hint: const Text(
                "Select Subject",
                style: TextStyle(color: Colors.white24, fontSize: 14),
              ),
              style: const TextStyle(color: Colors.white),
              items: items
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(e),
                    ),
                  )
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

class _SubjectTile extends ConsumerWidget {
  final String courseId;
  final Map<String, dynamic> subject;
  const _SubjectTile({required this.courseId, required this.subject});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modules = (subject['modules'] as List? ?? []);
    final isTeacher = ref.watch(authProvider)?.role == UserRole.teacher;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: ExpansionTile(
        key: PageStorageKey(subject['id']),
        leading: const Icon(
          LucideIcons.folder,
          color: AppColors.primaryLight,
          size: 20,
        ),
        title: Text(
          subject['title'] ?? 'Untitled Subject',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          "${modules.length} modules",
          style: const TextStyle(color: Colors.white24, fontSize: 11),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(
                LucideIcons.pencil,
                size: 16,
                color: Colors.white24,
              ),
              onPressed: () => _showSubjectForm(context, ref, subject),
            ),
            const Icon(LucideIcons.chevronDown, color: Colors.white24),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                ...modules
                    .map((m) => _ModuleTile(courseId: courseId, module: m))
                    .toList(),
                _buildAddButton(
                  label: "Add Module",
                  onTap: () => _showModuleForm(context, ref, courseId: courseId, subject: subject),
                  color: AppColors.accent,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton({
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.plus, size: 16, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSubjectForm(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> sub,
  ) {
    final titleController = TextEditingController(text: sub['title']);
    final descController = TextEditingController(text: sub['description']);
    final user = ref.read(authProvider);
    final isTeacher = user?.role == UserRole.teacher;
    final repository = (isTeacher
        ? ref.read(teacherRepositoryProvider)
        : ref.read(adminRepositoryProvider)) as dynamic;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          "Edit Subject",
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DialogTextField(
              controller: titleController,
              label: "Subject Title",
              maxLines: 1,
            ),
            const SizedBox(height: 16),
            DialogTextField(
              controller: descController,
              label: "Description",
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              try {
                await repository.deleteSubject(sub['id'].toString());
                if (context.mounted) Navigator.pop(context);
                ref.invalidate(isTeacher ? teacherCourseDetailsProvider(courseId) : adminCourseDetailsProvider(courseId));
                ToastService.showSuccess("Subject Deleted");
              } catch (e) {
                ToastService.showError(ApiClient.getErrorMessage(e));
              }
            },
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: () async {
              try {
                await repository.updateSubject(
                  sub['id'].toString(),
                  {
                    "title": titleController.text,
                    "description": descController.text,
                  },
                );
                if (context.mounted) Navigator.pop(context);
                ref.invalidate(isTeacher ? teacherCourseDetailsProvider(courseId) : adminCourseDetailsProvider(courseId));
              } catch (e) {
                ToastService.showError(ApiClient.getErrorMessage(e));
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}

class _ModuleTile extends ConsumerWidget {
  final String courseId;
  final Map<String, dynamic> module;
  const _ModuleTile({required this.courseId, required this.module});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lessons = (module['lessons'] as List? ?? []);
    final isTeacher = ref.watch(authProvider)?.role == UserRole.teacher;

    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        key: PageStorageKey(module['id']),
        leading: const Icon(
          LucideIcons.layout,
          color: AppColors.accent,
          size: 18,
        ),
        title: Text(
          module['title'] ?? 'Untitled Module',
          style: const TextStyle(color: Colors.white, fontSize: 13),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(LucideIcons.pencil, size: 14, color: Colors.white24),
              onPressed: () => _showModuleForm(context, ref, courseId: courseId, module: module),
            ),
            const Icon(LucideIcons.chevronDown, color: Colors.white24),
          ],
        ),
        children: [
          ...lessons
              .map((l) => _LessonTile(courseId: courseId, lesson: l))
              .toList(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextButton.icon(
              icon: const Icon(LucideIcons.plus, size: 14),
              label: const Text("Add Lesson", style: TextStyle(fontSize: 11)),
              onPressed: () => _showLessonForm(context, ref, courseId: courseId, module: module),
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonTile extends ConsumerWidget {
  final String courseId;
  final Map<String, dynamic> lesson;
  const _LessonTile({required this.courseId, required this.lesson});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTeacher = ref.watch(authProvider)?.role == UserRole.teacher;
    final repository = (isTeacher ? ref.read(teacherRepositoryProvider) : ref.read(adminRepositoryProvider)) as dynamic;
    IconData icon;
    switch (lesson['content_type']) {
      case 'video':
        icon = LucideIcons.playCircle;
        break;
      case 'file':
        icon = LucideIcons.fileText;
        break;
      case 'live':
        icon = LucideIcons.video;
        break;
      default:
        icon = LucideIcons.helpCircle;
    }

    return ListTile(
      dense: true,
      leading: Icon(icon, size: 16, color: Colors.white38),
      title: Text(
        lesson['title'] ?? 'Untitled Lesson',
        style: const TextStyle(color: Colors.white70, fontSize: 12),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(LucideIcons.pencil, size: 14, color: Colors.white24),
            onPressed: () => _showLessonForm(context, ref, courseId: courseId, lesson: lesson),
          ),
          IconButton(
            icon: const Icon(LucideIcons.trash2, size: 14, color: Colors.redAccent),
            onPressed: () async {
              try {
                await repository.deleteLesson(lesson['id'].toString());
                ref.invalidate(isTeacher ? teacherCourseDetailsProvider(courseId) : adminCourseDetailsProvider(courseId));
              } catch (e) {
                ToastService.showError(ApiClient.getErrorMessage(e));
              }
            },
          ),
        ],
      ),
    );
  }
}

void _showModuleForm(BuildContext context, WidgetRef ref, {required String courseId, Map<String, dynamic>? subject, Map<String, dynamic>? module}) {
  final isEditing = module != null;
  final titleController = TextEditingController(text: module?['title']);
  final user = ref.read(authProvider);
  final isTeacher = user?.role == UserRole.teacher;
  final repository = (isTeacher ? ref.read(teacherRepositoryProvider) : ref.read(adminRepositoryProvider)) as dynamic;

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: AppColors.surfaceDark,
      title: Text(isEditing ? "Edit Module" : "New Module", style: const TextStyle(color: Colors.white)),
      content: DialogTextField(
        controller: titleController,
        label: "Module Title",
        maxLines: 1,
      ),
      actions: [
        if (isEditing)
          ElevatedButton(
            onPressed: () async {
              try {
                await repository.deleteModule(module['id'].toString());
                if (context.mounted) Navigator.pop(context);
                ref.invalidate(isTeacher ? teacherCourseDetailsProvider(courseId) : adminCourseDetailsProvider(courseId));
              } catch (e) {
                ToastService.showError(ApiClient.getErrorMessage(e));
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.redAccent)),
          ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: () async {
            try {
              if (isEditing) {
                await repository.updateModule(module['id'].toString(), {"title": titleController.text});
              } else {
                await repository.createModule(
                  subject!['id'].toString(),
                  {"title": titleController.text},
                );
              }
              if (context.mounted) Navigator.pop(context);
              ref.invalidate(isTeacher ? teacherCourseDetailsProvider(courseId) : adminCourseDetailsProvider(courseId));
            } catch (e) {
              ToastService.showError(ApiClient.getErrorMessage(e));
            }
          },
          child: Text(isEditing ? "Save" : "Add"),
        ),
      ],
    ),
  );
}

void _showLessonForm(BuildContext context, WidgetRef ref, {required String courseId, Map<String, dynamic>? module, Map<String, dynamic>? lesson}) {
  final isEditing = lesson != null;
  final titleController = TextEditingController(text: lesson?['title']);
  String type = lesson?['content_type'] ?? "video";
  final user = ref.read(authProvider);
  final isTeacher = user?.role == UserRole.teacher;
  final repository = (isTeacher ? ref.read(teacherRepositoryProvider) : ref.read(adminRepositoryProvider)) as dynamic;

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: Text(
          isEditing ? "Edit Lesson" : "New Lesson",
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DialogTextField(
              controller: titleController,
              label: "Lesson Title",
              maxLines: 1,
            ),
            const SizedBox(height: 16),
            DropdownButton<String>(
              value: type,
              isExpanded: true,
              dropdownColor: AppColors.surfaceDark,
              style: const TextStyle(color: Colors.white),
              items: ["video", "file", "live"]
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(e.toUpperCase()),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setDialogState(() => type = v!),
            ),
          ],
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
                if (isEditing) {
                  await repository.updateLesson(lesson['id'].toString(), {"title": titleController.text, "content_type": type});
                } else {
                  await repository.createLesson(
                    module!['id'].toString(),
                    {"title": titleController.text, "content_type": type},
                  );
                }
                if (context.mounted) Navigator.pop(context);
                ref.invalidate(isTeacher ? teacherCourseDetailsProvider(courseId) : adminCourseDetailsProvider(courseId));
              } catch (e) {
                ToastService.showError(ApiClient.getErrorMessage(e));
              }
            },
            child: Text(isEditing ? "Save" : "Add"),
          ),
        ],
      ),
    ),
  );
}
