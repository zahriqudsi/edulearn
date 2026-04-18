import 'package:edulearn/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edulearn/providers/auth/auth_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AdminSidebar extends ConsumerWidget {
  final int selectedIndex;
  final Function(int) onMenuSelected;
  const AdminSidebar({
    super.key,
    required this.selectedIndex,
    required this.onMenuSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: 280,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.primaryDark, AppColors.backgroundDark],
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 60),
          const Hero(
            tag: 'admin_shield',
            child: Icon(LucideIcons.shieldCheck, color: Colors.white, size: 50),
          ),
          const SizedBox(height: 16),
          const Text(
            "Security Hub",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          const Text(
            "Management Console",
            style: TextStyle(color: Colors.white38, fontSize: 12),
          ),
          const SizedBox(height: 60),
          _SidebarItem(
            icon: LucideIcons.layoutDashboard,
            label: "Monitor",
            isActive: selectedIndex == 0,
            onTap: () => onMenuSelected(0),
          ),
          _SidebarItem(
            icon: LucideIcons.barChart3,
            label: "Analytics",
            isActive: selectedIndex == 3,
            onTap: () => onMenuSelected(3),
          ),
          _SidebarItem(
            icon: LucideIcons.users,
            label: "Accounts",
            isActive: selectedIndex == 2,
            onTap: () => onMenuSelected(2),
          ),
          _SidebarItem(
            icon: LucideIcons.school,
            label: "Institutions",
            isActive: selectedIndex == 1,
            onTap: () => onMenuSelected(1),
          ),
          _SidebarItem(
            icon: LucideIcons.gem,
            label: "Subscriptions",
            isActive: selectedIndex == 5,
            onTap: () => onMenuSelected(5),
          ),
          _SidebarItem(
            icon: LucideIcons.bookOpen,
            label: "Curriculum",
            isActive: selectedIndex == 6,
            onTap: () => onMenuSelected(6),
          ),
          _SidebarItem(
            icon: LucideIcons.settings,
            label: "Platform",
            isActive: selectedIndex == 4,
            onTap: () => onMenuSelected(4),
          ),
          const Spacer(),
          ListTile(
            onTap: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
            leading: const Icon(LucideIcons.logOut, color: Colors.redAccent),
            title: const Text(
              "Sign Out",
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class AdminDrawer extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onMenuSelected;
  const AdminDrawer({
    super.key,
    required this.selectedIndex,
    required this.onMenuSelected,
  });
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.backgroundDark,
      child: AdminSidebar(
        selectedIndex: selectedIndex,
        onMenuSelected: (i) {
          onMenuSelected(i);
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? Colors.white.withOpacity(0.08) : null,
            borderRadius: BorderRadius.circular(12),
            border: isActive
                ? Border.all(color: Colors.white.withOpacity(0.1))
                : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isActive ? Colors.white : Colors.white38,
                size: 20,
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.white38,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
