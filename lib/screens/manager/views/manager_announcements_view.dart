import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:edulearn/core/constants/app_colors.dart';
import 'package:edulearn/providers/manager/manager_provider.dart';
import 'package:edulearn/core/utils/toast_service.dart';
import '../../admin/widgets/admin_common_widgets.dart';

class ManagerAnnouncementsView extends ConsumerStatefulWidget {
  const ManagerAnnouncementsView({super.key});

  @override
  ConsumerState<ManagerAnnouncementsView> createState() =>
      _ManagerAnnouncementsViewState();
}

class _ManagerAnnouncementsViewState extends ConsumerState<ManagerAnnouncementsView> {
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  String _targetRole = 'student';
  bool _isPosting = false;

  Future<void> _postAnnouncement() async {
    if (_titleController.text.isEmpty || _messageController.text.isEmpty) {
      ToastService.showError("Please fill in all fields");
      return;
    }

    setState(() => _isPosting = true);
    try {
      await ref.read(managerRepositoryProvider).postAnnouncement({
        'title': _titleController.text,
        'message': _messageController.text,
        'target_role': _targetRole,
      });
      _titleController.clear();
      _messageController.clear();
      ref.invalidate(managerAnnouncementsProvider);
      ToastService.showSuccess("Announcement posted!");
    } catch (e) {
      ToastService.showError("Failed to post: $e");
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final announcementsAsync = ref.watch(managerAnnouncementsProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Announcements",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    "Broadcast messages to students, teachers, or staff.",
                    style: TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _showCreateDialog(),
                icon: const Icon(LucideIcons.plus, size: 18),
                label: const Text("New Announcement"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Expanded(
            child: announcementsAsync.when(
              data: (data) {
                if (data.isEmpty) {
                  return const Center(
                    child: Text("No announcements yet.", style: TextStyle(color: Colors.white38)),
                  );
                }
                return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final item = data[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceDark,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.05)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                item['title'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  item['target_role'].toUpperCase(),
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            item['message'],
                            style: const TextStyle(color: Colors.white70, height: 1.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Posted on ${item['created_at'].toString().substring(0, 10)}",
                            style: const TextStyle(color: Colors.white38, fontSize: 11),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => Skeletonizer(
                enabled: true,
                child: ListView.builder(
                  itemCount: 3,
                  itemBuilder: (context, index) => Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
              error: (err, s) => Center(child: Text("Error: $err")),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surfaceDark,
          title: const Text("Create Announcement", style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DialogTextField(controller: _titleController, label: "Title"),
              const SizedBox(height: 16),
              DialogTextField(controller: _messageController, label: "Message", maxLines: 4),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _targetRole,
                dropdownColor: AppColors.surfaceDark,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Target Role",
                  labelStyle: const TextStyle(color: Colors.white54),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: ['student', 'teacher', 'staff', 'all']
                    .map((r) => DropdownMenuItem(value: r, child: Text(r.toUpperCase())))
                    .toList(),
                onChanged: (v) => setDialogState(() => _targetRole = v!),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: _isPosting ? null : () async {
                await _postAnnouncement();
                if (mounted) Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: Text(_isPosting ? "Posting..." : "Post Now"),
            ),
          ],
        ),
      ),
    );
  }
}
