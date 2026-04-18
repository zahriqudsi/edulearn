import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:edulearn/core/constants/app_colors.dart';
import 'package:edulearn/models/course_model.dart';
import 'package:edulearn/providers/student/course_provider.dart';
import 'package:edulearn/providers/teacher/teacher_provider.dart';
import 'package:edulearn/core/utils/toast_service.dart';

import 'package:skeletonizer/skeletonizer.dart';

class MaterialManagementScreen extends ConsumerWidget {
  final Course? course;
  const MaterialManagementScreen({super.key, this.course});

  Future<void> _showAddSubjectDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
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

    String? selectedSubject;

    return showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppColors.surfaceDark,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text("Add New Subject",
              style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSimpleDropdown(
                "Select Subject",
                selectedSubject,
                subjectsList,
                (val) => setState(() => selectedSubject = val),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () async {
                if (selectedSubject == null) {
                  ToastService.showError("Please select a subject");
                  return;
                }
                try {
                  await ref
                      .read(teacherRepositoryProvider)
                      .createSubject(course!.id, {"title": selectedSubject!});
                  ref.invalidate(courseDetailsProvider(course!.id));
                  if (context.mounted) Navigator.pop(context);
                  ToastService.showSuccess("Subject added");
                } catch (e) {
                  ToastService.showError("Failed to add subject");
                }
              },
              child: const Text("Add"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddModuleDialog(
    BuildContext context,
    WidgetRef ref,
    String subjectId,
  ) async {
    final titleController = TextEditingController();
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title:
            const Text("Add New Module", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DialogTextField(
              controller: titleController,
              label: "Module Title",
              maxLines: 1,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isEmpty) {
                ToastService.showError("Module title is required");
                return;
              }
              try {
                await ref
                    .read(teacherRepositoryProvider)
                    .createModule(subjectId, {"title": titleController.text});
                ref.invalidate(courseDetailsProvider(course!.id));
                if (context.mounted) Navigator.pop(context);
                ToastService.showSuccess("Module added");
              } catch (e) {
                ToastService.showError("Failed to add module");
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddLessonDialog(
    BuildContext context,
    WidgetRef ref,
    String moduleId,
  ) async {
    final titleController = TextEditingController();
    final urlController = TextEditingController();
    String contentType = 'file';

    return showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppColors.surfaceDark,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text("Add New Lesson",
              style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DialogTextField(
                controller: titleController,
                label: "Lesson Title",
                maxLines: 1,
              ),
              const SizedBox(height: 16),
              _buildSimpleDropdown(
                "Content Type",
                contentType,
                ['file', 'video', 'live'],
                (val) => setState(() => contentType = val!),
              ),
              const SizedBox(height: 16),
              DialogTextField(
                controller: urlController,
                label: "URL / Link (Optional)",
                maxLines: 1,
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isEmpty) {
                  ToastService.showError("Lesson title is required");
                  return;
                }
                try {
                  await ref.read(teacherRepositoryProvider).createLesson(
                        moduleId,
                        {
                          "title": titleController.text,
                          "content_type": contentType,
                          "file_url": urlController.text.isNotEmpty ? urlController.text : null,
                        },
                      );
                  ref.invalidate(courseDetailsProvider(course!.id));
                  if (context.mounted) Navigator.pop(context);
                  ToastService.showSuccess("Lesson added");
                } catch (e) {
                  ToastService.showError("Failed to add lesson");
                }
              },
              child: const Text("Add"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (course == null)
      return const Scaffold(body: Center(child: Text("No course selected.")));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text("Curriculum: ${course!.name}"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton.icon(
            onPressed: () => _showAddSubjectDialog(context, ref),
            icon: const Icon(LucideIcons.plus, size: 16),
            label: const Text("Add Subject"),
          ),
        ],
      ),
      body: ref
          .watch(courseDetailsProvider(course!.id))
          .when(
            loading: () => Skeletonizer(
              ignoreContainers: true,
              enabled: true,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: 4,
                itemBuilder: (context, index) => Card(
                  margin: const EdgeInsets.only(bottom: 24),
                  child: Container(height: 100, width: double.infinity),
                ),
              ),
            ),
            error: (err, stack) => Center(child: Text("Error: $err")),
            data: (details) {
              if (details.subjects.isEmpty) {
                return const Center(
                  child: Text("No subjects yet. Add one above."),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: details.subjects.length,
                itemBuilder: (context, sIdx) {
                  final subject = details.subjects[sIdx];
                  return Card(
                    color: isDark ? AppColors.surfaceDark : Colors.white,
                    margin: const EdgeInsets.only(bottom: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          title: Text(
                            subject.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(LucideIcons.plusCircle, size: 20),
                            onPressed: () =>
                                _showAddModuleDialog(context, ref, subject.id),
                            tooltip: "Add Module",
                          ),
                        ),
                        const Divider(height: 1),
                        ...subject.modules.map(
                          (module) => ExpansionTile(
                            title: Text(
                              module.title,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            leading: const Icon(LucideIcons.package, size: 18),
                            trailing: IconButton(
                              icon: const Icon(LucideIcons.plus),
                              onPressed: () =>
                                  _showAddLessonDialog(context, ref, module.id),
                            ),
                            children: module.lessons
                                .map(
                                  (lesson) => ListTile(
                                    dense: true,
                                    leading: Icon(
                                      lesson.type == 'video'
                                          ? LucideIcons.playCircle
                                          : (lesson.type == 'live'
                                              ? LucideIcons.video
                                              : LucideIcons.file),
                                      size: 16,
                                      color: lesson.type == 'live'
                                          ? AppColors.primary
                                          : null,
                                    ),
                                    title: Text(
                                      lesson.title,
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                    trailing: const Icon(
                                      LucideIcons.moreVertical,
                                      size: 14,
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
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
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: AppColors.surfaceDark,
              hint: const Text(
                "Select...",
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

class DialogTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final int maxLines;

  const DialogTextField({
    super.key,
    required this.controller,
    required this.label,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
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
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Enter $label...",
            hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.05),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }
}
