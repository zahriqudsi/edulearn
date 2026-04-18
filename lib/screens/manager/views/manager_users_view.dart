import 'package:edulearn/core/constants/app_colors.dart';
import 'package:edulearn/core/widgets/app_loader.dart';
import 'package:edulearn/providers/manager/manager_provider.dart';
import 'package:edulearn/screens/admin/widgets/admin_common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ManagerUsersView extends ConsumerStatefulWidget {
  final String role;
  const ManagerUsersView({super.key, required this.role});

  @override
  ConsumerState<ManagerUsersView> createState() => _ManagerUsersViewState();
}

class _ManagerUsersViewState extends ConsumerState<ManagerUsersView> {
  int _currentPage = 1;
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(
      managerUsersProvider((_currentPage, _searchQuery, widget.role)),
    );

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 16,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.role == "Teacher"
                        ? "Institution Staff"
                        : "Student Registry",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Manage ${widget.role.toLowerCase()}s associated with your school.",
                    style: const TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _showUserDialog(),
                icon: const Icon(LucideIcons.userPlus, size: 18),
                label: Text("Add ${widget.role}"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildFilters(),
          const SizedBox(height: 24),
          Expanded(
            child: usersAsync.when(
              data: (data) {
                final users = (data['data'] as List? ?? []);
                if (users.isEmpty)
                  return const AdminEmptyState(message: "No users found.");

                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: users.length,
                        itemBuilder: (context, index) =>
                            _buildUserTile(users[index]),
                      ),
                    ),
                    _buildPagination(data['last_page'] ?? 1),
                  ],
                );
              },
              loading: () => Skeletonizer(
                ignoreContainers: true,
                enabled: true,
                child: ListView.builder(
                  itemCount: 5,
                  itemBuilder: (context, index) => _buildUserTile({
                    'name': 'Loading User Details',
                    'email': 'loading.details@example.com',
                    'status': 'Active',
                  }),
                ),
              ),
              error: (err, s) => Center(
                child: Text(
                  "Error: $err",
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "Search by name or email...",
                hintStyle: TextStyle(color: Colors.white38, fontSize: 13),
                border: InputBorder.none,
                icon: Icon(LucideIcons.search, size: 18, color: Colors.white38),
              ),
              onChanged: (v) => setState(() {
                _searchQuery = v;
                _currentPage = 1;
              }),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserTile(Map<String, dynamic> user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.accent.withOpacity(0.1),
            child: Text(
              user['name'][0].toUpperCase(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['name'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  user['email'],
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
          _buildStatusBadge(user['status'] ?? "Active"),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            icon: const Icon(
              LucideIcons.moreVertical,
              color: Colors.white38,
              size: 18,
            ),
            onSelected: (val) {
              if (val == 'edit') {
                _showUserDialog(user: user);
              } else if (val == 'delete') {
                _handleDelete(user);
              } else if (val == 'status') {
                _toggleStatus(user);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Text("Edit Info", style: TextStyle(color: Colors.white)),
              ),
              PopupMenuItem(
                value: 'status',
                child: Text(
                  user['status'] == 'Active'
                      ? "Suspend Account"
                      : "Activate Account",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Text(
                  "Delete",
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showUserDialog({Map<String, dynamic>? user}) {
    showDialog(
      context: context,
      builder: (context) => _UserFormDialog(role: widget.role, user: user),
    ).then((updated) {
      if (updated == true) ref.invalidate(managerUsersProvider);
    });
  }

  Future<void> _handleDelete(Map<String, dynamic> user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: const Text(
          "Delete User?",
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          "Are you sure you want to delete ${user['name']}? This action is permanent.",
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref
            .read(managerRepositoryProvider)
            .deleteUser(user['id'].toString());
        ref.invalidate(managerUsersProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User deleted successfully")),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  Future<void> _toggleStatus(Map<String, dynamic> user) async {
    final newStatus = user['status'] == 'Active' ? 'Suspended' : 'Active';
    try {
      await ref.read(managerRepositoryProvider).updateUser(
        user['id'].toString(),
        {'status': newStatus},
      );
      ref.invalidate(managerUsersProvider);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Widget _buildStatusBadge(String status) {
    Color color = Colors.green;
    if (status == "Suspended") color = Colors.red;
    if (status == "Pending") color = Colors.orange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPagination(int lastPage) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(LucideIcons.chevronLeft, color: Colors.white54),
            onPressed: _currentPage > 1
                ? () => setState(() => _currentPage--)
                : null,
          ),
          Text(
            "Page $_currentPage of $lastPage",
            style: const TextStyle(color: Colors.white70),
          ),
          IconButton(
            icon: const Icon(LucideIcons.chevronRight, color: Colors.white54),
            onPressed: _currentPage < lastPage
                ? () => setState(() => _currentPage++)
                : null,
          ),
        ],
      ),
    );
  }
}

class _UserFormDialog extends ConsumerStatefulWidget {
  final String role;
  final Map<String, dynamic>? user;
  const _UserFormDialog({required this.role, this.user});

  @override
  ConsumerState<_UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends ConsumerState<_UserFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user?['name']);
    _emailController = TextEditingController(text: widget.user?['email']);
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.user == null
        ? "Add ${widget.role}"
        : "Edit ${widget.role}";

    return AlertDialog(
      backgroundColor: AppColors.surfaceDark,
      title: Text(title, style: const TextStyle(color: Colors.white)),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DialogTextField(controller: _nameController, label: "Full Name"),
              const SizedBox(height: 16),
              DialogTextField(
                controller: _emailController,
                label: "Email Address",
              ),
              if (widget.user == null) ...[
                const SizedBox(height: 16),
                DialogTextField(
                  controller: _passwordController,
                  label: "Initial Password",
                  isPassword: true,
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading ? const AppLoader(size: 20) : const Text("Save"),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final data = {
      'name': _nameController.text,
      'email': _emailController.text,
      'role': widget.role,
    };

    if (widget.user == null) {
      data['password'] = _passwordController.text;
    }

    try {
      if (widget.user == null) {
        await ref.read(managerRepositoryProvider).createUser(data);
      } else {
        await ref
            .read(managerRepositoryProvider)
            .updateUser(widget.user!['id'].toString(), data);
      }
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
