import 'package:edulearn/core/widgets/app_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:edulearn/core/constants/app_colors.dart';
import 'package:edulearn/providers/manager/manager_provider.dart';
import 'package:edulearn/core/utils/toast_service.dart';
import '../../admin/widgets/admin_common_widgets.dart';

class ManagerSettingsView extends ConsumerStatefulWidget {
  const ManagerSettingsView({super.key});

  @override
  ConsumerState<ManagerSettingsView> createState() =>
      _ManagerSettingsViewState();
}

class _ManagerSettingsViewState extends ConsumerState<ManagerSettingsView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _descController;

  Map<String, bool> _notifications = {
    'email_on_new_enrolment': true,
    'email_on_schedule_change': true,
    'push_on_announcement': true,
    'weekly_report': false,
  };

  bool _initialized = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
    _descController = TextEditingController();
  }

  void _initFields(Map<String, dynamic> institution) {
    if (_initialized) return;
    _nameController.text = institution['name'] ?? "";
    _emailController.text = institution['contact_email'] ?? "";
    _phoneController.text = institution['phone'] ?? "";
    _addressController.text = institution['address'] ?? "";
    _descController.text = institution['description'] ?? "";

    if (institution['notification_settings'] != null) {
      final settings = Map<String, dynamic>.from(
        institution['notification_settings'],
      );
      settings.forEach((key, value) {
        if (_notifications.containsKey(key)) {
          _notifications[key] = value == true || value == 1;
        }
      });
    }
    _initialized = true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      await ref.read(managerRepositoryProvider).updateInstitution({
        'name': _nameController.text,
        'contact_email': _emailController.text,
        'phone': _phoneController.text,
        'address': _addressController.text,
        'description': _descController.text,
        'notification_settings': _notifications,
      });
      ref.invalidate(managerInstitutionProvider);
      ToastService.showSuccess("Settings updated successfully");
    } catch (e) {
      ToastService.showError("Failed to update settings: $e");
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final institutionAsync = ref.watch(managerInstitutionProvider);

    return institutionAsync.when(
      data: (institution) {
        _initFields(institution);
        return DefaultTabController(
          length: 2,
          child: Padding(
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
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Institution Settings",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          "Configure your profile and notification preferences.",
                          style: TextStyle(color: Colors.white54, fontSize: 13),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: _isSaving ? null : _saveSettings,
                      icon: _isSaving
                          ? const AppLoader(size: 18)
                          : const Icon(LucideIcons.save, size: 18),
                      label: Text(_isSaving ? "Saving..." : "Save Changes"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                TabBar(
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  indicatorColor: AppColors.accent,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white38,
                  dividerColor: Colors.transparent,
                  indicatorSize: TabBarIndicatorSize.label,
                  tabs: const [
                    Tab(text: "Public Profile"),
                    Tab(text: "Notifications"),
                  ],
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: TabBarView(
                    children: [_buildProfileTab(), _buildNotificationsTab()],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => Skeletonizer(
        ignoreContainers: true,
        enabled: true,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(width: 200, height: 40, color: Colors.white),
              const SizedBox(height: 8),
              Container(width: 300, height: 20, color: Colors.white),
              const SizedBox(height: 48),
              Expanded(
                child: Column(
                  children: List.generate(
                    4,
                    (i) => Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      height: 60,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      error: (err, s) => Center(
        child: Text("Error: $err", style: const TextStyle(color: Colors.red)),
      ),
    );
  }

  Widget _buildProfileTab() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader("Identification", LucideIcons.building2),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DialogTextField(
                      controller: _nameController,
                      label: "Institution Name",
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DialogTextField(
                      controller: _emailController,
                      label: "Public Contact Email",
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSectionHeader("Contact & Location", LucideIcons.mapPin),
              const SizedBox(height: 16),
              DialogTextField(
                controller: _phoneController,
                label: "Phone Number",
              ),
              const SizedBox(height: 16),
              DialogTextField(
                controller: _addressController,
                label: "Physical Address",
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              _buildSectionHeader("About", LucideIcons.info),
              const SizedBox(height: 16),
              DialogTextField(
                controller: _descController,
                label: "Short Description",
                maxLines: 4,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationsTab() {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Column(
          children: [
            _buildNotificationSwitch(
              "Enrolment Alerts",
              "Receive email notifications when a student enrolls in a course.",
              'email_on_new_enrolment',
            ),
            _buildNotificationSwitch(
              "Schedule Updates",
              "Notify affected members when a class schedule is modified or deleted.",
              'email_on_schedule_change',
            ),
            _buildNotificationSwitch(
              "Announcement Pushes",
              "Automatically send push notifications for new institution announcements.",
              'push_on_announcement',
            ),
            _buildNotificationSwitch(
              "Weekly Analytics",
              "Receive a weekly summary of institution activity and growth.",
              'weekly_report',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.accent),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationSwitch(String title, String subtitle, String key) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
          Switch(
            value: _notifications[key] ?? false,
            onChanged: (val) {
              setState(() => _notifications[key] = val);
            },
            activeColor: AppColors.accent,
          ),
        ],
      ),
    );
  }
}
