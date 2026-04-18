import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:edulearn/core/constants/app_colors.dart';
import 'package:edulearn/providers/admin/admin_provider.dart';
import 'package:edulearn/core/utils/toast_service.dart';
import 'package:edulearn/core/network/api_client.dart';
import '../widgets/admin_common_widgets.dart';

class InstitutionsView extends ConsumerStatefulWidget {
  const InstitutionsView({super.key});

  @override
  ConsumerState<InstitutionsView> createState() => _InstitutionsViewState();
}

class _InstitutionsViewState extends ConsumerState<InstitutionsView> {
  final _searchController = TextEditingController();
  String _searchQuery = "";
  int _currentPage = 1;
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final instAsync = ref.watch(
      adminInstitutionsProvider((_currentPage, _searchQuery)),
    );
    final isWide = MediaQuery.of(context).size.width > 900;

    return instAsync.when(
      loading: () => const AdminLoadingShimmer(),
      error: (err, stack) => Center(child: Text("Error: $err")),
      data: (paginatedData) {
        final List<dynamic> displayInsts = paginatedData['data'] ?? [];
        final int totalPages = paginatedData['last_page'] ?? 1;

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
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
                              "Institutions",
                              style: theme.textTheme.displaySmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                fontSize: 32,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              "Partner organization management",
                              style: TextStyle(color: Colors.white54),
                            ),
                          ],
                        ),
                        HeaderActionButton(
                          icon: LucideIcons.plus,
                          onPressed: () => _showInstitutionForm(context, ref),
                          color: AppColors.accent,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Search Bar
                    ElegantSearchBar(
                      controller: _searchController,
                      hint: "Filter institutions...",
                      searchQuery: _searchQuery,
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
                    ),
                  ],
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: displayInsts.isEmpty
                  ? const SliverToBoxAdapter(
                      child: Center(
                        child: Text(
                          "No institutions found",
                          style: TextStyle(color: Colors.white38),
                        ),
                      ),
                    )
                  : SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isWide ? 3 : 1,
                        childAspectRatio: isWide ? 1.6 : 1.4,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final inst = displayInsts[index];
                        return _InstitutionManagementCard(inst: inst);
                      }, childCount: displayInsts.length),
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

  void _showInstitutionForm(
    BuildContext context,
    WidgetRef ref, [
    Map<String, dynamic>? inst,
  ]) {
    final isEditing = inst != null;
    final nameController = TextEditingController(text: inst?["name"]);
    final codeController = TextEditingController(text: inst?["linking_code"]);
    String status = inst?["status"] ?? "Active";
    String? selectedPlanId = inst?["subscription_plan_id"]?.toString();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surfaceDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            isEditing ? "Edit Institution" : "Add Institution",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DialogTextField(
                controller: nameController,
                label: "Institution Name",
              ),
              const SizedBox(height: 16),
              DialogTextField(
                controller: codeController,
                label: "Linking Code",
              ),
              const SizedBox(height: 20),
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
                    items: ["Active", "Maintenance", "Archived"].map((s) {
                      return DropdownMenuItem(value: s, child: Text(s));
                    }).toList(),
                    onChanged: (v) => setDialogState(() => status = v!),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Subscription Plan Selector
              ref
                  .watch(adminSubscriptionsProvider)
                  .maybeWhen(
                    data: (plans) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedPlanId,
                          isExpanded: true,
                          hint: const Text(
                            "Select Subscription Plan",
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 14,
                            ),
                          ),
                          dropdownColor: AppColors.surfaceDark,
                          style: const TextStyle(color: Colors.white),
                          items: plans.map((p) {
                            return DropdownMenuItem<String>(
                              value: p["id"].toString(),
                              child: Text("${p["name"]} (${p["price"]}/mo)"),
                            );
                          }).toList(),
                          onChanged: (v) =>
                              setDialogState(() => selectedPlanId = v),
                        ),
                      ),
                    ),
                    orElse: () => const SizedBox.shrink(),
                  ),
            ],
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
                    "linking_code": codeController.text,
                    "status": status,
                    "subscription_plan_id": selectedPlanId,
                  };

                  if (isEditing) {
                    await ref
                        .read(adminRepositoryProvider)
                        .updateInstitution(inst["id"].toString(), data);
                  } else {
                    await ref
                        .read(adminRepositoryProvider)
                        .createInstitution(data);
                  }

                  if (context.mounted) Navigator.pop(context);
                  ref.invalidate(adminInstitutionsProvider);
                  ToastService.showSuccess(
                    isEditing ? "Institution Updated" : "Institution Created",
                  );
                } catch (e) {
                  ToastService.showError(ApiClient.getErrorMessage(e));
                }
              },
              child: Text(isEditing ? "Save" : "Create"),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteInstitution(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> inst,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          "Delete Institution?",
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          "Permanently delete ${inst["name"]}? All associated data will be lost.",
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
                    .deleteInstitution(inst["id"].toString());
                if (context.mounted) Navigator.pop(context);
                ref.invalidate(adminInstitutionsProvider);
                ToastService.showSuccess("Institution Deleted");
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
}

class _InstitutionManagementCard extends ConsumerWidget {
  final Map<String, dynamic> inst;
  const _InstitutionManagementCard({required this.inst});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isActive = inst["status"] == "Active";
    final plan = inst["subscription_plan"];
    final planName = plan?["name"] ?? "Free Tier";
    final bool isPremium = plan != null &&
        (double.tryParse(plan["price"]?.toString() ?? "0") ?? 0) > 0;

    return ElegantCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  LucideIcons.building,
                  color: AppColors.primaryLight,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              // Plan Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: (isPremium ? AppColors.success : Colors.white10)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: (isPremium ? AppColors.success : Colors.white10)
                        .withOpacity(0.2),
                  ),
                ),
                child: Text(
                  planName.toUpperCase(),
                  style: TextStyle(
                    color: isPremium ? AppColors.success : Colors.white38,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  ActionButton(
                    icon: LucideIcons.pencil,
                    color: Colors.white70,
                    onPressed: () {
                      final state = context
                          .findAncestorStateOfType<_InstitutionsViewState>();
                      if (state != null)
                        state._showInstitutionForm(context, ref, inst);
                    },
                  ),
                  const SizedBox(width: 8),
                  ActionButton(
                    icon: LucideIcons.trash2,
                    color: Colors.redAccent,
                    onPressed: () {
                      final state = context
                          .findAncestorStateOfType<_InstitutionsViewState>();
                      if (state != null)
                        state._confirmDeleteInstitution(context, ref, inst);
                    },
                  ),
                  const SizedBox(width: 8),
                  Switch.adaptive(
                    value: isActive,
                    onChanged: (v) async {
                      try {
                        await ref
                            .read(adminRepositoryProvider)
                            .updateInstitutionStatus(
                              inst["id"].toString(),
                              v ? "Active" : "Maintenance",
                            );
                        ref.invalidate(adminInstitutionsProvider);
                      } catch (e) {
                        ToastService.showError(ApiClient.getErrorMessage(e));
                      }
                    },
                    activeColor: AppColors.primary,
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          Text(
            inst["name"] ?? 'Unknown',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "LINKING CODE",
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      inst["linking_code"] ?? '------',
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(
                    LucideIcons.copy,
                    size: 16,
                    color: Colors.white38,
                  ),
                  onPressed: () {
                    ToastService.showSuccess("Code copied to clipboard");
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "${inst["student_count"] ?? 0} active students enrolled",
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
