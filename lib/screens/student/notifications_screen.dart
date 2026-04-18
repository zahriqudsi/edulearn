import 'package:edulearn/core/network/api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:edulearn/core/constants/app_colors.dart';
import 'package:skeletonizer/skeletonizer.dart';

final notificationsProvider = FutureProvider.autoDispose((ref) async {
  final api = ref.read(apiClientProvider);
  final response = await api.get('/notifications');
  return response.data as List;
});

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(
          "Notifications",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () async {
              final api = ref.read(apiClientProvider);
              await api.post('/notifications/read-all');
              ref.invalidate(notificationsProvider);
            },
            child: const Text(
              "Mark all as read",
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: notificationsAsync.when(
        data: (data) {
          if (data.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.bellOff,
                    size: 64,
                    color: Colors.grey.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "No notifications yet",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];
              return _NotificationTile(
                id: item['id'].toString(),
                title: item['title'],
                message: item['message'],
                type: item['type'] ?? 'info',
                isRead: item['read_at'] != null,
                index: index,
              );
            },
          );
        },
        loading: () => Skeletonizer(
          ignoreContainers: true,
          enabled: true,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            itemCount: 8,
            itemBuilder: (context, index) => _NotificationTile(
              id: 'skeleton',
              title: 'Loading Notification Title',
              message: 'This is a mock message for the skeleton loading state.',
              type: 'info',
              isRead: false,
              index: index,
            ),
          ),
        ),
        error: (e, stack) => Center(child: Text("Error: $e")),
      ),
    );
  }
}

class _NotificationTile extends ConsumerWidget {
  final String id;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final int index;

  const _NotificationTile({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.index,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    IconData icon;
    Color color;

    switch (type) {
      case 'announcement':
        icon = LucideIcons.megaphone;
        color = AppColors.primary;
        break;
      case 'reminder':
        icon = LucideIcons.calendar;
        color = AppColors.warning;
        break;
      default:
        icon = LucideIcons.info;
        color = Colors.blue;
    }

    return GestureDetector(
      onTap: () async {
        if (!isRead) {
          final api = ref.read(apiClientProvider);
          await api.post('/notifications/$id/read');
          ref.invalidate(notificationsProvider);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isRead
              ? (isDark ? Colors.white.withOpacity(0.05) : Colors.white)
              : (isDark ? AppColors.surfaceDark : Colors.white),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
          ],
          border: Border.all(
            color: isRead
                ? Colors.transparent
                : (isDark
                      ? AppColors.primary.withOpacity(0.3)
                      : AppColors.primary.withOpacity(0.1)),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message,
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black54,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Just now",
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark ? Colors.white30 : Colors.black38,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: (200 + index * 50).ms).slideX(begin: 0.1);
  }
}
