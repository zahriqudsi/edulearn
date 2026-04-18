import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:edulearn/core/constants/app_colors.dart';
import 'widgets/manager_navigation_widgets.dart';
import 'views/manager_overview_view.dart';
import 'views/timetable_view.dart';
import 'views/manager_users_view.dart';
import 'views/manager_courses_view.dart';
import 'views/manager_enrolments_view.dart';
import 'views/manager_settings_view.dart';
import 'views/manager_announcements_view.dart';

class ManagerDashboard extends StatefulWidget {
  const ManagerDashboard({super.key});

  @override
  State<ManagerDashboard> createState() => _ManagerDashboardState();
}

class _ManagerDashboardState extends State<ManagerDashboard> {
  int _selectedIndex = 0;

  void _onMenuSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildBodyContent(BuildContext context, ThemeData theme, bool isWide) {
    switch (_selectedIndex) {
      case 0:
        return ManagerOverviewView(isWide: isWide);
      case 1:
        return const ManagerUsersView(role: "Teacher");
      case 2:
        return const ManagerUsersView(role: "Student");
      case 3:
        return const ManagerCoursesView();
      case 4:
        return const ManagerEnrolmentsView();
      case 5:
        return const TimetableView();
      case 6:
        return const ManagerAnnouncementsView();
      case 7:
        return const ManagerSettingsView();
      default:
        return ManagerOverviewView(isWide: isWide);
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
                "Institution Admin",
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
          : ManagerDrawer(
              selectedIndex: _selectedIndex,
              onMenuSelected: _onMenuSelected,
            ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // ENSURE FINITE CONSTRAINTS: This is the critical fix for rendering errors.
          // If the engine provides unconstrained width/height, we force it to the screen's actual dimensions.
          final safeMaxWidth = constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : MediaQuery.of(context).size.width;

          final safeMaxHeight = constraints.maxHeight.isFinite
              ? constraints.maxHeight
              : MediaQuery.of(context).size.height;

          return ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: safeMaxWidth,
              maxHeight: safeMaxHeight,
            ),
            child: Row(
              children: [
                if (isWide)
                  ManagerSidebar(
                    selectedIndex: _selectedIndex,
                    onMenuSelected: _onMenuSelected,
                  ),
                Expanded(child: _buildBodyContent(context, theme, isWide)),
              ],
            ),
          );
        },
      ),
    );
  }
}
