import 'package:edulearn/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edulearn/providers/auth/auth_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ManagerSidebar extends ConsumerWidget {
  final int selectedIndex;
  final Function(int) onMenuSelected;

  const ManagerSidebar({
    super.key,
    required this.selectedIndex,
    required this.onMenuSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);

    return Container(
      width: 260,
      color: AppColors.surfaceDark,
      child: Column(
        children: [
          const SizedBox(height: 40),
          _buildLogo(),
          const SizedBox(height: 40),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _MenuItem(
                  title: "Overview",
                  icon: LucideIcons.layoutDashboard,
                  isSelected: selectedIndex == 0,
                  onTap: () => onMenuSelected(0),
                ),
                _MenuItem(
                  title: "Staff (Teachers)",
                  icon: LucideIcons.users,
                  isSelected: selectedIndex == 1,
                  onTap: () => onMenuSelected(1),
                ),
                _MenuItem(
                  title: "Students",
                  icon: LucideIcons.userPlus,
                  isSelected: selectedIndex == 2,
                  onTap: () => onMenuSelected(2),
                ),
                _MenuItem(
                  title: "Courses",
                  icon: LucideIcons.bookOpen,
                  isSelected: selectedIndex == 3,
                  onTap: () => onMenuSelected(3),
                ),
                _MenuItem(
                  title: "Enrolments",
                  icon: LucideIcons.userCheck,
                  isSelected: selectedIndex == 4,
                  onTap: () => onMenuSelected(4),
                ),
                _MenuItem(
                  title: "Timetable",
                  icon: LucideIcons.calendar,
                  isSelected: selectedIndex == 5,
                  onTap: () => onMenuSelected(5),
                ),
                _MenuItem(
                  title: "Announcements",
                  icon: LucideIcons.megaphone,
                  isSelected: selectedIndex == 6,
                  onTap: () => onMenuSelected(6),
                ),
                _MenuItem(
                  title: "Institution Settings",
                  icon: LucideIcons.settings,
                  isSelected: selectedIndex == 7,
                  onTap: () => onMenuSelected(7),
                ),
              ],
            ),
          ),
          _buildUserCard(context, ref, user?.name ?? "Manager"),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.accent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            LucideIcons.graduationCap,
            color: AppColors.accent,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          "School Admin",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildUserCard(BuildContext context, WidgetRef ref, String name) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.accent,
            child: const Icon(LucideIcons.user, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const Text(
                  "Inst. Admin",
                  style: TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              LucideIcons.logOut,
              color: Colors.white38,
              size: 18,
            ),
            onPressed: () => _showLogoutConfirm(context, ref),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirm(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: const Text("Logout", style: TextStyle(color: Colors.white)),
        content: const Text(
          "Are you sure you want to exit?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
            child: const Text(
              "Logout",
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }
}

class ManagerDrawer extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onMenuSelected;

  const ManagerDrawer({
    super.key,
    required this.selectedIndex,
    required this.onMenuSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.surfaceDark,
      child: ManagerSidebar(
        selectedIndex: selectedIndex,
        onMenuSelected: (idx) {
          onMenuSelected(idx);
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _MenuItem({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.accent.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(color: AppColors.accent.withOpacity(0.2))
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isSelected ? AppColors.accent : Colors.white54,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white54,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
