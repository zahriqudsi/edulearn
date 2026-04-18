import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:edulearn/core/constants/app_colors.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:edulearn/core/widgets/glass_container.dart';
import 'package:edulearn/providers/auth/auth_provider.dart';
import 'package:edulearn/models/course_model.dart';
import 'package:edulearn/providers/student/course_provider.dart';
import 'package:edulearn/core/utils/toast_service.dart';
import 'package:edulearn/core/network/api_client.dart';

class CourseDetailsScreen extends ConsumerWidget {
  final Course? course;
  const CourseDetailsScreen({super.key, this.course});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (course == null)
      return const Scaffold(body: Center(child: Text("Course not found")));
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 350,
            pinned: true,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: () => context.pop(),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(LucideIcons.arrowLeft, color: Colors.white),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: AppColors.premiumDarkGradient,
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: -50,
                          right: -50,
                          child:
                              Container(
                                    width: 250,
                                    height: 250,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.primary.withValues(
                                        alpha: 0.5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primary.withValues(
                                            alpha: 0.5,
                                          ),
                                          blurRadius: 100,
                                        ),
                                      ],
                                    ),
                                  )
                                  .animate(
                                    onPlay: (c) => c.repeat(reverse: true),
                                  )
                                  .scaleXY(end: 1.2, duration: 4.seconds),
                        ),
                        Center(
                          child:
                              Icon(
                                LucideIcons.code2,
                                size: 100,
                                color: Colors.white.withValues(alpha: 0.15),
                              ).animate().scale(
                                curve: Curves.easeOutBack,
                                duration: 800.ms,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black87],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 24,
                    left: 24,
                    right: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Colors.orange, Colors.deepOrange],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.orange.withValues(alpha: 0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                course!.category?.toUpperCase() ?? "GENERAL",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              if (course!.level != null) ...[
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 8),
                                  width: 4,
                                  height: 4,
                                  decoration: const BoxDecoration(
                                      color: Colors.white54,
                                      shape: BoxShape.circle),
                                ),
                                Text(
                                  course!.level!.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                        const SizedBox(height: 16),
                        Text(
                          course!.name,
                          style: theme.textTheme.displaySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GlassContainer(
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 16,
                    ),
                    color: isDark ? AppColors.surfaceDark : Colors.white,
                    opacity: isDark ? 0.3 : 0.8,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        const _StatColumn(
                          icon: LucideIcons.clock,
                          label: "18 Hours",
                          color: Colors.blueAccent,
                        ),
                        GestureDetector(
                          onTap: () => context.push(
                            '/course-reviews',
                            extra: {'id': course!.id, 'name': course!.name},
                          ),
                          child: const _StatColumn(
                            icon: LucideIcons.star,
                            label: "4.9 (View)",
                            color: Colors.orangeAccent,
                          ),
                        ),
                        _StatColumn(
                          icon: LucideIcons.barChart,
                          label: course!.level ?? "General",
                          color: AppColors.success,
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
                  const SizedBox(height: 36),
                  Text(
                    "About this Course",
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    course!.description,
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
                  ).animate().fadeIn(delay: 500.ms),
                  ref
                      .watch(courseDetailsProvider(course!.id))
                      .when(
                        loading: () => Skeletonizer(
                          ignoreContainers: true,
                          enabled: true,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 36),
                              Container(width: 150, height: 24, color: Colors.white),
                              const SizedBox(height: 16),
                              ...List.generate(
                                3,
                                (index) => _SubjectSection(
                                  subject: Subject(
                                    id: index.toString(),
                                    title: "Loading Subject Title",
                                    modules: [
                                      Module(
                                        id: (index * 10).toString(),
                                        title: "Module Loading title",
                                        lessons: [],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        error: (err, stack) =>
                            Padding(
                              padding: const EdgeInsets.only(top: 32),
                              child: Text("Error loading content: $err"),
                            ),
                        data: (updatedCourse) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (updatedCourse.materials.isNotEmpty) ...[
                                const SizedBox(height: 36),
                                Text(
                                  "Resources & Materials",
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ...updatedCourse.materials.map((m) => ListTile(
                                      leading: const Icon(LucideIcons.fileText,
                                          color: Colors.orangeAccent),
                                      title: Text(m.title),
                                      subtitle: Text(m.type.toUpperCase()),
                                      trailing: const Icon(LucideIcons.download, size: 20),
                                      onTap: () => ToastService.showSuccess("Downloading ${m.title}..."),
                                    )),
                              ],
                              if (updatedCourse.liveClasses.any((lc) => lc.recordingUrl != null)) ...[
                                const SizedBox(height: 36),
                                Text(
                                  "Watch Recordings",
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ...updatedCourse.liveClasses
                                    .where((lc) => lc.recordingUrl != null)
                                    .map((lc) => ListTile(
                                          leading: const Icon(LucideIcons.video,
                                              color: AppColors.primary),
                                          title: Text(lc.title),
                                          subtitle: const Text("Recorded Session"),
                                          trailing: const Icon(LucideIcons.playCircle, size: 20),
                                          onTap: () => ToastService.showSuccess("Opening recording for ${lc.title}"),
                                        )),
                              ],
                              const SizedBox(height: 36),
                              Text(
                                "Curriculum",
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              if (updatedCourse.subjects.isEmpty)
                                const Center(
                                  child: Text(
                                    "No subjects available yet.",
                                    style: TextStyle(color: Colors.white54),
                                  ),
                                )
                              else
                                ...updatedCourse.subjects
                                    .map(
                                      (subject) =>
                                          _SubjectSection(subject: subject),
                                    )
                                    .toList(),
                            ],
                          );
                        },
                      ),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -10),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: () async {
              try {
                final user = ref.read(authProvider);
                if (user == null) throw "You must be logged in to enroll";
                await ref
                    .read(courseRepositoryProvider)
                    .enroll(course!.id, user.id);
                ToastService.showSuccess(
                  "Successfully enrolled in ${course!.name}!",
                );
              } catch (e) {
                ToastService.showError(ApiClient.getErrorMessage(e));
              }
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              "Enroll Now",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ).animate().slideY(begin: 1.0, delay: 600.ms, curve: Curves.easeOutBack),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _StatColumn({
    required this.icon,
    required this.label,
    required this.color,
  });
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.textMainLight,
          ),
        ),
      ],
    );
  }
}

class _SubjectSection extends StatelessWidget {
  final Subject subject;
  const _SubjectSection({required this.subject});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getSubjectIcon(subject.title),
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  subject.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                ),
              ),
            ],
          ),
        ),
        ...subject.modules.map(
          (module) => _ModuleExpansionTile(module: module),
        ),
        const Divider(height: 32, color: Colors.white10),
      ],
    );
  }

  IconData _getSubjectIcon(String title) {
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('math')) return LucideIcons.calculator;
    if (lowerTitle.contains('science')) return LucideIcons.beaker;
    if (lowerTitle.contains('physics')) return LucideIcons.zap;
    if (lowerTitle.contains('chem')) return LucideIcons.flaskConical;
    if (lowerTitle.contains('english')) return LucideIcons.languages;
    if (lowerTitle.contains('history')) return LucideIcons.landmark;
    if (lowerTitle.contains('ict') || lowerTitle.contains('computer'))
      return LucideIcons.cpu;
    if (lowerTitle.contains('arts')) return LucideIcons.palette;
    if (lowerTitle.contains('geography')) return LucideIcons.globe;
    if (lowerTitle.contains('biology')) return LucideIcons.dna;
    return LucideIcons.bookOpen;
  }
}

class _ModuleExpansionTile extends StatelessWidget {
  final Module module;
  const _ModuleExpansionTile({required this.module});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final completedCount = module.lessons.where((l) => l.isCompleted).length;
    final totalCount = module.lessons.length;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
        ),
      ),
      child: ExpansionTile(
        title: Text(
          module.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  "$completedCount/$totalCount lessons",
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMutedLight,
                  ),
                ),
                const Spacer(),
                Text(
                  "${(progress * 100).toInt()}%",
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 4,
                backgroundColor: isDark ? Colors.white10 : Colors.black12,
                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              ),
            ),
          ],
        ),
        shape: const RoundedRectangleBorder(side: BorderSide.none),
        childrenPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        children: module.lessons
            .asMap()
            .entries
            .map((entry) => _LessonTile(lesson: entry.value, index: entry.key))
            .toList(),
      ),
    );
  }
}

class _LessonTile extends ConsumerWidget {
  final Lesson lesson;
  final int index;
  const _LessonTile({required this.lesson, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    IconData icon;
    Color color;
    switch (lesson.type.toLowerCase()) {
      case 'video':
        icon = LucideIcons.playCircle;
        color = Colors.redAccent;
        break;
      case 'file':
        icon = LucideIcons.fileText;
        color = Colors.orangeAccent;
        break;
      case 'live':
        icon = LucideIcons.video;
        color = AppColors.primary;
        break;
      default:
        icon = LucideIcons.fileText;
        color = Colors.blueAccent;
    }

    return ListTile(
      onTap: () {
        if (lesson.type.toLowerCase() == 'live') {
          context.push('/live-class', extra: {'title': lesson.title});
        } else {
          ToastService.showSuccess("Opening ${lesson.title}");
        }
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
      title: Text(lesson.title, style: const TextStyle(fontSize: 14)),
      trailing: IconButton(
        icon: Icon(
          lesson.isCompleted ? LucideIcons.checkCircle2 : LucideIcons.circle,
          color: lesson.isCompleted ? AppColors.success : Colors.white24,
          size: 20,
        ),
        onPressed: () async {
          try {
            await ref
                .read(courseRepositoryProvider)
                .toggleLessonCompletion(lesson.id, !lesson.isCompleted);
            // Refresh details to update UI
            ref.invalidate(courseDetailsProvider);
            ToastService.showSuccess(
              lesson.isCompleted
                  ? "Marked as incomplete"
                  : "Marked as complete!",
            );
          } catch (e) {
            ToastService.showError("Failed to update status");
          }
        },
      ),
    ).animate().fadeIn(delay: (index * 50).ms);
  }
}
