import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:edulearn/core/constants/app_colors.dart';
import 'package:edulearn/core/widgets/glass_container.dart';
import 'package:edulearn/providers/admin/admin_provider.dart';
import 'package:edulearn/core/utils/toast_service.dart';
import 'package:edulearn/core/network/api_client.dart';
import '../widgets/admin_common_widgets.dart';

class SettingsView extends ConsumerStatefulWidget {
  const SettingsView({super.key});

  @override
  ConsumerState<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends ConsumerState<SettingsView> {
  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(adminSettingsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Platform Control Panel",
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 32,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Global ecosystem configurations",
            style: TextStyle(color: Colors.white54),
          ),
          const SizedBox(height: 32),

          settingsAsync
              .when(
                loading: () => const AdminLoadingShimmer(),
                error: (err, stack) => Center(
                  child: Text(
                    "Error: $err",
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
                data: (groups) {
                  final generalSettings = groups['general'] ?? [];

                  // Helper to find setting value
                  String getVal(String key, String def) {
                    final s = generalSettings.firstWhere(
                      (e) => e['key'] == key,
                      orElse: () => {'value': def},
                    );
                    return s['value'] ?? def;
                  }

                  return Column(
                    children: [
                      _buildSettingSection(
                        title: "Access Control",
                        children: [
                          SwitchListTile(
                            title: const Text(
                              "Allow Public Registrations",
                              style: TextStyle(color: Colors.white),
                            ),
                            subtitle: const Text(
                              "Allow new users to create accounts independently",
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                            value: getVal("allow_registrations", "1") == "1",
                            onChanged: (v) =>
                                _updateToggle("allow_registrations", v),
                            activeColor: AppColors.primary,
                          ),
                          const Divider(color: Colors.white10, height: 1),
                          SwitchListTile(
                            title: const Text(
                              "Maintenance Mode",
                              style: TextStyle(
                                color: Colors.redAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: const Text(
                              "Lock out all non-admin users from the application",
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                            value: getVal("maintenance_mode", "0") == "1",
                            onChanged: (v) =>
                                _updateToggle("maintenance_mode", v),
                            activeColor: Colors.redAccent,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildSettingSection(
                        title: "System Defaults",
                        children: [
                          _SettingInputTile(
                            label: "Default Language",
                            value: getVal("default_language", "English"),
                            onSave: (v) =>
                                _updateTextSetting("default_language", v),
                          ),
                          const Divider(color: Colors.white10, height: 1),
                          _SettingInputTile(
                            label: "Support Email",
                            value: getVal(
                              "support_email",
                              "support@edulearn.com",
                            ),
                            onSave: (v) =>
                                _updateTextSetting("support_email", v),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              )
              .animate()
              .fadeIn(delay: 200.ms),
        ],
      ),
    );
  }

  Widget _buildSettingSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        GlassContainer(
          padding: const EdgeInsets.symmetric(vertical: 8),
          color: Colors.white,
          opacity: 0.05,
          child: Column(children: children),
        ),
      ],
    );
  }

  Future<void> _updateToggle(String key, bool value) async {
    try {
      await ref.read(adminRepositoryProvider).updateSettings([
        {'key': key, 'value': value ? "1" : "0", 'group': 'general'},
      ]);
      ref.invalidate(adminSettingsProvider);
      ToastService.showSuccess("Settings updated");
    } catch (e) {
      ToastService.showError(ApiClient.getErrorMessage(e));
    }
  }

  Future<void> _updateTextSetting(String key, String value) async {
    try {
      await ref.read(adminRepositoryProvider).updateSettings([
        {'key': key, 'value': value, 'group': 'general'},
      ]);
      ref.invalidate(adminSettingsProvider);
      ToastService.showSuccess("Settings saved");
    } catch (e) {
      ToastService.showError(ApiClient.getErrorMessage(e));
    }
  }
}

class _SettingInputTile extends StatelessWidget {
  final String label;
  final String value;
  final Function(String) onSave;

  const _SettingInputTile({
    required this.label,
    required this.value,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 15),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(color: Colors.white38, fontSize: 12),
      ),
      trailing: IconButton(
        icon: const Icon(LucideIcons.pencil, size: 18, color: Colors.white38),
        onPressed: () => _showEditDialog(context),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final controller = TextEditingController(text: value);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text("Edit $label", style: const TextStyle(color: Colors.white)),
        content: DialogTextField(controller: controller, label: label),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: () {
              onSave(controller.text);
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}
