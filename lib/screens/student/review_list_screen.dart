import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:edulearn/core/constants/app_colors.dart';
import 'package:edulearn/providers/student/course_provider.dart';
import 'package:edulearn/core/utils/toast_service.dart';
import 'package:edulearn/core/network/api_client.dart';

import 'package:skeletonizer/skeletonizer.dart';

final courseReviewsProvider = FutureProvider.family
    .autoDispose<List<dynamic>, String>((ref, id) async {
      return ref.watch(courseRepositoryProvider).getCourseReviews(id);
    });

class ReviewListScreen extends ConsumerWidget {
  final String courseId;
  final String courseName;

  const ReviewListScreen({
    super.key,
    required this.courseId,
    required this.courseName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviews = ref.watch(courseReviewsProvider(courseId));
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text("$courseName Reviews"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: reviews.when(
        data: (data) {
          if (data.isEmpty)
            return const Center(child: Text("No reviews yet. Be the first!"));
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final r = data[index] as Map<String, dynamic>;
              return _ReviewCard(
                userName:
                    (r['user'] as Map<String, dynamic>?)?['name'] ??
                    'Anonymous',
                rating: (r['rating'] as num?)?.toDouble() ?? 0.0,
                comment: r['comment'] ?? '',
                date: "Recently",
              );
            },
          );
        },
        loading: () => Skeletonizer(
          ignoreContainers: true,
          enabled: true,
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: 5,
            itemBuilder: (context, index) => const _ReviewCard(
              userName: 'Loading User',
              rating: 5.0,
              comment:
                  'This is a mock review comment for the skeleton loading state of the application.',
              date: "Recently",
            ),
          ),
        ),
        error: (e, _) => Center(child: Text("Error: $e")),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddReviewDialog(context, ref),
        label: const Text("Write a Review"),
        icon: const Icon(LucideIcons.edit3),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _showAddReviewDialog(BuildContext context, WidgetRef ref) {
    final commentController = TextEditingController();
    double rating = 5.0;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("Rate this Course"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (index) => IconButton(
                    icon: Icon(
                      index < rating ? LucideIcons.star : LucideIcons.star,
                      color: index < rating ? Colors.orange : Colors.grey,
                    ),
                    onPressed: () => setState(() => rating = index + 1.0),
                  ),
                ),
              ),
              TextField(
                controller: commentController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: "What did you think of this course?",
                ),
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
                  await ref
                      .read(courseRepositoryProvider)
                      .addReview(courseId, rating, commentController.text);
                  ToastService.showSuccess(
                    "Thank you! Your review has been submitted.",
                  );
                  ref.invalidate(courseReviewsProvider(courseId));
                  if (context.mounted) Navigator.pop(context);
                } catch (e) {
                  ToastService.showError(ApiClient.getErrorMessage(e));
                }
              },
              child: const Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final String userName;
  final double rating;
  final String comment;
  final String date;
  const _ReviewCard({
    required this.userName,
    required this.rating,
    required this.comment,
    required this.date,
  });
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                userName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Row(
                children: List.generate(
                  5,
                  (index) => Icon(
                    LucideIcons.star,
                    size: 14,
                    color: index < rating ? Colors.orange : Colors.grey,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            comment,
            style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
          ),
          const SizedBox(height: 8),
          const Text(
            "Recently",
            style: TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
