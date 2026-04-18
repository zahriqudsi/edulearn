import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:edulearn/core/constants/app_colors.dart';
import 'widgets/admin_navigation_widgets.dart';
import 'views/overview_view.dart';
import 'views/users_view.dart';
import 'views/institutions_view.dart';
import 'views/settings_view.dart';
import 'views/subscriptions_view.dart';
import 'views/analytics_view.dart';
import 'views/admin_courses_view.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  void _onMenuSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildBodyContent(BuildContext context, ThemeData theme, bool isWide) {
    switch (_selectedIndex) {
      case 0:
        return OverviewView(isWide: isWide);
      case 1:
        return const InstitutionsView();
      case 2:
        return const UsersView();
      case 3:
        return const AnalyticsView();
      case 4:
        return const SettingsView();
      case 5:
        return const SubscriptionsView();
      case 6:
        return const AdminCoursesView();
      default:
        return OverviewView(isWide: isWide);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 900;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: isWide
          ? null
          : AppBar(
              title: const Text(
                "Management Desktop",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              elevation: 0,
              backgroundColor: AppColors.backgroundDark,
              actions: [
                IconButton(
                  icon: const Icon(LucideIcons.bell),
                  onPressed: () {},
                ),
              ],
            ),
      drawer: isWide
          ? null
          : AdminDrawer(
              selectedIndex: _selectedIndex,
              onMenuSelected: _onMenuSelected,
            ),
      body: Row(
        children: [
          if (isWide)
            AdminSidebar(
              selectedIndex: _selectedIndex,
              onMenuSelected: _onMenuSelected,
            ),
          Expanded(
            child: Stack(
              children: [
                Positioned(
                  top: -150,
                  right: 0,
                  child: Container(
                    width: 400,
                    height: 400,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.accent.withOpacity(0.15),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withOpacity(0.2),
                          blurRadius: 100,
                        ),
                      ],
                    ),
                  ),
                ),
                _buildBodyContent(context, theme, isWide),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
