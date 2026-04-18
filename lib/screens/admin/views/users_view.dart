import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:edulearn/core/constants/app_colors.dart';
import 'package:edulearn/providers/admin/admin_provider.dart';
import 'package:edulearn/core/utils/toast_service.dart';
import 'package:edulearn/core/network/api_client.dart';
import '../widgets/admin_common_widgets.dart';

class UsersView extends ConsumerStatefulWidget {
  const UsersView({super.key});

  @override
  ConsumerState<UsersView> createState() => _UsersViewState();
}

class _UsersViewState extends ConsumerState<UsersView>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  late TabController _tabController;
  String _searchQuery = "";
  int _currentPage = 1;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _currentPage = 1; // Reset pagination on tab change
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Server-side parameters
    String? roleFilter;
    if (_tabController.index == 1) roleFilter = "Student";
    if (_tabController.index == 2) roleFilter = "Teacher";

    final usersAsync = ref.watch(
      adminUsersProvider((_currentPage, _searchQuery, roleFilter)),
    );

    final institutionsAsync = ref.watch(adminInstitutionsProvider((1, null)));

    return usersAsync.when(
      loading: () => const AdminLoadingShimmer(),
      error: (err, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              LucideIcons.alertTriangle,
              color: Colors.redAccent,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              "Failed to load users: $err",
              style: const TextStyle(color: Colors.white70),
            ),
            ElevatedButton(
              onPressed: () => ref.invalidate(adminUsersProvider),
              child: const Text("Retry"),
            ),
          ],
        ),
      ),
      data: (paginatedData) {
        final List<dynamic> displayUsers = paginatedData['data'] ?? [];
        final int totalPages = paginatedData['last_page'] ?? 1;

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header Section
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Access Control",
                              style: theme.textTheme.displaySmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                fontSize: 32,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Managing platform identities",
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.white54,
                              ),
                            ),
                          ],
                        ),
                        HeaderActionButton(
                          icon: LucideIcons.userPlus,
                          onPressed: () => _showUserForm(context, ref),
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Search Bar
                    ElegantSearchBar(
                      controller: _searchController,
                      onChanged: (val) {
                        if (_debounce?.isActive ?? false) _debounce?.cancel();
                        _debounce = Timer(
                          const Duration(milliseconds: 500),
                          () {
                            setState(() {
                              _searchQuery = val;
                              _currentPage = 1;
                            });
                          },
                        );
                      },
                      onClear: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = "";
                          _currentPage = 1;
                        });
                      },
                      searchQuery: _searchQuery,
                      hint: "Search accounts...",
                    ),
                    const SizedBox(height: 18),

                    // Sub Tabs
                    ElegantSegmentedTab(
                      controller: _tabController,
                      tabs: const ["OVERVIEW", "STUDENTS", "TEACHERS"],
                    ),
                  ],
                ),
              ),
            ),

            // User List Section
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: displayUsers.isEmpty
                  ? SliverToBoxAdapter(
                      child: Center(
                        child: Column(
                          children: [
                            const SizedBox(height: 60),
                            Icon(
                              LucideIcons.searchX,
                              color: Colors.white.withOpacity(0.1),
                              size: 100,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              "No matches found.",
                              style: TextStyle(color: Colors.white38),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final user = displayUsers[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _UserManagementCard(
                            user: user,
                            institutionsAsync: institutionsAsync,
                          ),
                        );
                      }, childCount: displayUsers.length),
                    ),
            ),

            // Pagination Footer
            if (totalPages > 1)
              SliverToBoxAdapter(
                child: PaginationFooter(
                  currentPage: _currentPage - 1, // Component was 0-indexed
                  totalPages: totalPages,
                  onPageChanged: (page) =>
                      setState(() => _currentPage = page + 1),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        );
      },
    );
  }

  void _showUserForm(
    BuildContext context,
    WidgetRef ref, [
    Map<String, dynamic>? user,
  ]) {
    final isEditing = user != null;
    final nameController = TextEditingController(text: user?["name"]);
    final emailController = TextEditingController(text: user?["email"]);
    final passwordController = TextEditingController();
    String role = user?["role"] ?? "Student";
    String status = user?["status"] ?? "Active";

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surfaceDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            isEditing ? "Edit User" : "Add New User",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DialogTextField(controller: nameController, label: "Full Name"),
                const SizedBox(height: 16),
                DialogTextField(
                  controller: emailController,
                  label: "Email Address",
                ),
                if (!isEditing) ...[
                  const SizedBox(height: 16),
                  DialogTextField(
                    controller: passwordController,
                    label: "Initial Password",
                  ),
                ],
                const SizedBox(height: 20),
                // Role Selector
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: role,
                      isExpanded: true,
                      dropdownColor: AppColors.surfaceDark,
                      style: const TextStyle(color: Colors.white),
                      items: ["Admin", "Teacher", "Student"].map((r) {
                        return DropdownMenuItem(value: r, child: Text(r));
                      }).toList(),
                      onChanged: (v) => setDialogState(() => role = v!),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Status Selector
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: status,
                      isExpanded: true,
                      dropdownColor: AppColors.surfaceDark,
                      style: const TextStyle(color: Colors.white),
                      items: ["Active", "Suspended", "Pending"].map((s) {
                        return DropdownMenuItem(value: s, child: Text(s));
                      }).toList(),
                      onChanged: (v) => setDialogState(() => status = v!),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.white54),
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: () async {
                try {
                  final data = {
                    "name": nameController.text,
                    "email": emailController.text,
                    "role": role,
                    "status": status,
                  };
                  if (!isEditing) data["password"] = passwordController.text;

                  if (isEditing) {
                    await ref
                        .read(adminRepositoryProvider)
                        .updateUser(user["id"].toString(), data);
                  } else {
                    await ref.read(adminRepositoryProvider).createUser(data);
                  }

                  if (context.mounted) Navigator.pop(context);
                  ref.invalidate(adminUsersProvider);
                  ToastService.showSuccess(
                    isEditing ? "User Updated" : "User Created",
                  );
                } catch (e) {
                  ToastService.showError(ApiClient.getErrorMessage(e));
                }
              },
              child: Text(isEditing ? "Save Changes" : "Create User"),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> user,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          "Delete User?",
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          "Are you sure you want to permanently delete ${user["name"]}? This action cannot be undone.",
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.white54),
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              try {
                await ref
                    .read(adminRepositoryProvider)
                    .deleteUser(user["id"].toString());
                if (context.mounted) Navigator.pop(context);
                ref.invalidate(adminUsersProvider);
                ToastService.showSuccess("User Deleted");
              } catch (e) {
                ToastService.showError(ApiClient.getErrorMessage(e));
              }
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  Future<void> _updateUserStatus(
    WidgetRef ref,
    String id,
    String newStatus,
  ) async {
    try {
      await ref.read(adminRepositoryProvider).updateUserStatus(id, newStatus);
      ref.invalidate(adminUsersProvider);
      ToastService.showSuccess("Status updated to $newStatus");
    } catch (e) {
      ToastService.showError(ApiClient.getErrorMessage(e));
    }
  }
}

class _UserManagementCard extends ConsumerWidget {
  final Map<String, dynamic> user;
  final AsyncValue<Map<String, dynamic>> institutionsAsync;

  const _UserManagementCard({
    required this.user,
    required this.institutionsAsync,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = (user["role"] ?? "Student").toString();
    final status = (user["status"] ?? "Active").toString();
    final String institutionId = user["institution_id"]?.toString() ?? "";

    Color roleColor = role == "Teacher"
        ? AppColors.warning
        : (role == "Admin" ? AppColors.accent : Colors.blueAccent);

    Color statusColor = status == "Suspended"
        ? Colors.redAccent
        : (status == "Pending" ? AppColors.warning : AppColors.success);

    return ElegantCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar Section
          Stack(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      roleColor.withOpacity(0.4),
                      roleColor.withOpacity(0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: roleColor.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    user["name"]?[0].toUpperCase() ?? '?',
                    style: TextStyle(
                      color: roleColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.backgroundDark,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),

          // Details Section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user["name"] ?? 'Unknown User',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                Text(
                  user["email"] ?? '',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white54,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),

                // Managed Selection (Institution) - Hide for Admin role
                if (role != "Admin")
                  institutionsAsync.maybeWhen(
                    data: (paginatedData) {
                      final institutions = List<Map<String, dynamic>>.from(
                        paginatedData['data'] ?? [],
                      );
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: institutionId.isEmpty ? null : institutionId,
                            isExpanded: true,
                            hint: const Text(
                              "Select School",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white38,
                              ),
                            ),
                            dropdownColor: AppColors.surfaceDark,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.white,
                            ),
                            icon: const Icon(
                              LucideIcons.school,
                              size: 14,
                              color: Colors.white38,
                            ),
                            items: institutions.map((inst) {
                              return DropdownMenuItem<String>(
                                value: inst["id"].toString(),
                                child: Text(
                                  inst["name"] ?? "Unknown",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (val) async {
                              if (val != null) {
                                try {
                                  await ref
                                      .read(adminRepositoryProvider)
                                      .updateUserStatus(
                                        user["id"].toString(),
                                        status,
                                        institutionId: val,
                                      );
                                  ref.invalidate(adminUsersProvider);
                                  ToastService.showSuccess(
                                    "Institution reassigned",
                                  );
                                } catch (e) {
                                  ToastService.showError(
                                    ApiClient.getErrorMessage(e),
                                  );
                                }
                              }
                            },
                          ),
                        ),
                      );
                    },
                    orElse: () => const SizedBox.shrink(),
                  ),
                const SizedBox(height: 12),

                // Badges
                Row(
                  children: [
                    CompactBadge(label: role, color: roleColor),
                    const SizedBox(width: 8),
                    CompactBadge(
                      label: status,
                      color: statusColor,
                      isOutline: true,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Actions Section
          const SizedBox(width: 12),
          Column(
            children: [
              ActionButton(
                icon: LucideIcons.pencil,
                color: Colors.white70,
                onPressed: () {
                  final state = context
                      .findAncestorStateOfType<_UsersViewState>();
                  if (state != null) state._showUserForm(context, ref, user);
                },
              ),
              const SizedBox(height: 12),
              ActionButton(
                icon: LucideIcons.trash2,
                color: Colors.redAccent,
                onPressed: () {
                  final state = context
                      .findAncestorStateOfType<_UsersViewState>();
                  if (state != null) state._confirmDelete(context, ref, user);
                },
              ),
              // Hide suspend button for Admins
              if (role != "Admin") ...[
                const SizedBox(height: 12),
                ActionButton(
                  icon: LucideIcons.ban,
                  color: AppColors.warning,
                  onPressed: () {
                    final state = context
                        .findAncestorStateOfType<_UsersViewState>();
                    if (state != null) {
                      state._updateUserStatus(
                        ref,
                        user["id"].toString(),
                        status == "Suspended" ? "Active" : "Suspended",
                      );
                    }
                  },
                  isActive: true,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
