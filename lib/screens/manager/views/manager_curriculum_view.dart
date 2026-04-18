import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:edulearn/core/constants/app_colors.dart';
import 'package:edulearn/providers/manager/manager_provider.dart';
import 'package:edulearn/core/utils/toast_service.dart';
import 'package:edulearn/core/network/api_client.dart';
import '../../admin/widgets/admin_common_widgets.dart';

class ManagerCurriculumView extends ConsumerWidget {
  final String courseId;
  const ManagerCurriculumView({super.key, required this.courseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courseAsync = ref.watch(managerCourseDetailsProvider(courseId));
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Curriculum Builder",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.rotateCcw),
            onPressed: () =>
                ref.invalidate(managerCourseDetailsProvider(courseId)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: courseAsync.when(
        loading: () => const AdminLoadingShimmer(),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  LucideIcons.alertTriangle,
                  color: Colors.orangeAccent,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  "Unable to Load Curriculum",
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  err.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () =>
                      ref.invalidate(managerCourseDetailsProvider(courseId)),
                  icon: const Icon(LucideIcons.refreshCcw, size: 18),
                  label: const Text("Retry Connection"),
                ),
              ],
            ),
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
                  "${course['category'] ?? 'General'}",
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
      'Arts',
    ];

    String? selectedTitle = subject?['title'];
    if (selectedTitle != null && !subjectsList.contains(selectedTitle)) {
      selectedTitle = null; // Reset if not in standard list
    }

    final descController = TextEditingController(text: subject?['description']);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surfaceDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
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
            const SizedBox(height: 10),
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
                    await ref
                        .read(managerRepositoryProvider)
                        .updateSubject(subject['id'].toString(), data);
                  } else {
                    await ref
                        .read(managerRepositoryProvider)
                        .createSubject(courseId, data);
                  }
                  if (context.mounted) Navigator.pop(context);
                  ref.invalidate(managerCourseDetailsProvider(courseId));
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
                "Select Category",
                style: TextStyle(color: Colors.white24, fontSize: 14),
              ),
              style: const TextStyle(color: Colors.white),
              items: items
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
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
                    .map(
                      (m) => _ModuleTile(
                        courseId: courseId,
                        module: m,
                        subjectId: subject['id'].toString(),
                      ),
                    )
                    .toList(),
                _buildAddButton(
                  label: "Add Module",
                  onTap: () => _showModuleForm(context, ref),
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
                await ref
                    .read(managerRepositoryProvider)
                    .deleteSubject(sub['id'].toString());
                if (context.mounted) Navigator.pop(context);
                ref.invalidate(managerCourseDetailsProvider(courseId));
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
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () async {
              try {
                await ref.read(managerRepositoryProvider).updateSubject(
                  sub['id'].toString(),
                  {
                    "title": titleController.text,
                    "description": descController.text,
                  },
                );
                if (context.mounted) Navigator.pop(context);
                ref.invalidate(managerCourseDetailsProvider(courseId));
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

  void _showModuleForm(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: const Text("New Module", style: TextStyle(color: Colors.white)),
        content: DialogTextField(
          controller: titleController,
          label: "Module Title",
          maxLines: 1,
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
                await ref.read(managerRepositoryProvider).createModule(
                  subject['id'].toString(),
                  {"title": titleController.text},
                );
                if (context.mounted) Navigator.pop(context);
                ref.invalidate(managerCourseDetailsProvider(courseId));
              } catch (e) {
                ToastService.showError(ApiClient.getErrorMessage(e));
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }
}

class _ModuleTile extends ConsumerWidget {
  final String courseId;
  final String subjectId;
  final Map<String, dynamic> module;
  const _ModuleTile({
    required this.courseId,
    required this.subjectId,
    required this.module,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lessons = (module['lessons'] as List? ?? []);

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
              icon: const Icon(
                LucideIcons.pencil,
                size: 14,
                color: Colors.white24,
              ),
              onPressed: () => _showModuleEditForm(context, ref),
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
              onPressed: () => _showLessonForm(context, ref),
            ),
          ),
        ],
      ),
    );
  }

  void _showModuleEditForm(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController(text: module['title']);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: const Text("Edit Module", style: TextStyle(color: Colors.white)),
        content: DialogTextField(
          controller: titleController,
          label: "Module Title",
          maxLines: 1,
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              try {
                await ref
                    .read(managerRepositoryProvider)
                    .deleteModule(module['id'].toString());
                if (context.mounted) Navigator.pop(context);
                ref.invalidate(managerCourseDetailsProvider(courseId));
                ToastService.showSuccess("Module Deleted");
              } catch (e) {
                ToastService.showError(ApiClient.getErrorMessage(e));
              }
            },
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () async {
              try {
                await ref.read(managerRepositoryProvider).updateModule(
                  module['id'].toString(),
                  {"title": titleController.text},
                );
                if (context.mounted) Navigator.pop(context);
                ref.invalidate(managerCourseDetailsProvider(courseId));
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

  void _showLessonForm(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    String type = "video";

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surfaceDark,
          title: const Text(
            "New Lesson",
            style: TextStyle(color: Colors.white),
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
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                try {
                  await ref.read(managerRepositoryProvider).createLesson(
                    module['id'].toString(),
                    {"title": titleController.text, "content_type": type},
                  );
                  if (context.mounted) Navigator.pop(context);
                  ref.invalidate(managerCourseDetailsProvider(courseId));
                } catch (e) {
                  ToastService.showError(ApiClient.getErrorMessage(e));
                }
              },
              child: const Text("Add"),
            ),
          ],
        ),
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
      trailing: IconButton(
        icon: const Icon(LucideIcons.trash2, size: 14, color: Colors.redAccent),
        onPressed: () async {
          try {
            await ref
                .read(managerRepositoryProvider)
                .deleteLesson(lesson['id'].toString());
            ref.invalidate(managerCourseDetailsProvider(courseId));
          } catch (e) {
            ToastService.showError(ApiClient.getErrorMessage(e));
          }
        },
      ),
    );
  }
}
