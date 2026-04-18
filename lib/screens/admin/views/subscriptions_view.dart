import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:edulearn/core/constants/app_colors.dart';
import 'package:edulearn/providers/admin/admin_provider.dart';
import 'package:edulearn/core/utils/toast_service.dart';
import 'package:edulearn/core/network/api_client.dart';
import '../widgets/admin_common_widgets.dart';

class SubscriptionsView extends ConsumerStatefulWidget {
  const SubscriptionsView({super.key});

  @override
  ConsumerState<SubscriptionsView> createState() => _SubscriptionsViewState();
}

class _SubscriptionsViewState extends ConsumerState<SubscriptionsView> {
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subsAsync = ref.watch(adminSubscriptionsProvider);
    final isWide = MediaQuery.of(context).size.width > 900;

    return subsAsync.when(
      loading: () => const AdminLoadingShimmer(),
      error: (err, stack) => Center(child: Text("Error: $err")),
      data: (plans) {
        final filteredPlans = plans.where((p) {
          final query = _searchQuery.toLowerCase();
          return (p["name"] ?? "").toString().toLowerCase().contains(query);
        }).toList();

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
                              "Subscription Tiers",
                              style: theme.textTheme.displaySmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                fontSize: 32,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              "Revenue & partnership models",
                              style: TextStyle(color: Colors.white54),
                            ),
                          ],
                        ),
                        HeaderActionButton(
                          icon: LucideIcons.plus,
                          onPressed: () => _showPlanForm(context, ref),
                          color: AppColors.success,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    ElegantSearchBar(
                      hint: "Filter plans...",
                      searchQuery: _searchQuery,
                      onChanged: (val) => setState(() => _searchQuery = val),
                      onClear: () => setState(() => _searchQuery = ""),
                    ),
                  ],
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.all(24),
              sliver: filteredPlans.isEmpty
                  ? SliverToBoxAdapter(
                      child: Center(
                        child: Column(
                          children: [
                            const SizedBox(height: 60),
                            Icon(
                              LucideIcons.packageX,
                              color: Colors.white.withOpacity(0.1),
                              size: 100,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              "No subscription plans found.",
                              style: TextStyle(color: Colors.white38),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () =>
                                  ref.invalidate(adminSubscriptionsProvider),
                              child: const Text("Refresh List"),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isWide ? 3 : 1,
                        childAspectRatio: isWide ? 0.8 : 1.1,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                      ),
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final plan = filteredPlans[index];
                        return _SubscriptionPlanCard(plan: plan);
                      }, childCount: filteredPlans.length),
                    ),
            ),
          ],
        );
      },
    );
  }

  void _showPlanForm(
    BuildContext context,
    WidgetRef ref, [
    Map<String, dynamic>? plan,
  ]) {
    final isEditing = plan != null;
    final nameController = TextEditingController(text: plan?["name"]);
    final priceController = TextEditingController(
      text: plan?["price"]?.toString(),
    );
    final studentsController = TextEditingController(
      text: plan?["max_students"]?.toString() ?? "0",
    );
    final descController = TextEditingController(text: plan?["description"]);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          isEditing ? "Edit Plan" : "New Plan",
          style: const TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DialogTextField(
                controller: nameController,
                label: "Plan Name (e.g. Basic, Premium)",
              ),
              const SizedBox(height: 16),
              DialogTextField(
                controller: priceController,
                label: "Price (Monthly USD)",
              ),
              const SizedBox(height: 16),
              DialogTextField(
                controller: studentsController,
                label: "Max Students (0 = Unlimited)",
              ),
              const SizedBox(height: 16),
              DialogTextField(controller: descController, label: "Description"),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: () async {
              try {
                final data = {
                  "name": nameController.text,
                  "price": double.tryParse(priceController.text) ?? 0.0,
                  "max_students": int.tryParse(studentsController.text) ?? 0,
                  "description": descController.text,
                };
                if (isEditing) {
                  await ref
                      .read(adminRepositoryProvider)
                      .updateSubscriptionPlan(plan["id"].toString(), data);
                } else {
                  await ref
                      .read(adminRepositoryProvider)
                      .createSubscriptionPlan(data);
                }
                if (context.mounted) Navigator.pop(context);
                ref.invalidate(adminSubscriptionsProvider);
                ToastService.showSuccess("Subscription plan saved");
              } catch (e) {
                ToastService.showError(ApiClient.getErrorMessage(e));
              }
            },
            child: const Text("Save Plan"),
          ),
        ],
      ),
    );
  }

  void _confirmDeletePlan(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> plan,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          "Delete Plan?",
          style: TextStyle(color: Colors.white),
        ),
        content: Text("Are you sure you want to delete ${plan["name"]}?"),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              try {
                await ref
                    .read(adminRepositoryProvider)
                    .deleteSubscriptionPlan(plan["id"].toString());
                if (context.mounted) Navigator.pop(context);
                ref.invalidate(adminSubscriptionsProvider);
                ToastService.showSuccess("Plan deleted");
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

class _SubscriptionPlanCard extends ConsumerWidget {
  final Map<String, dynamic> plan;
  const _SubscriptionPlanCard({required this.plan});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsCount = plan["max_students"] == 0
        ? "Unlimited"
        : "${plan["max_students"]}";

    return ElegantCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  LucideIcons.gem,
                  color: AppColors.success,
                  size: 24,
                ),
              ),
              Row(
                children: [
                  ActionButton(
                    icon: LucideIcons.pencil,
                    color: Colors.white70,
                    onPressed: () {
                      final state = context
                          .findAncestorStateOfType<_SubscriptionsViewState>();
                      if (state != null)
                        state._showPlanForm(context, ref, plan);
                    },
                  ),
                  const SizedBox(width: 8),
                  ActionButton(
                    icon: LucideIcons.trash2,
                    color: Colors.redAccent,
                    onPressed: () {
                      final state = context
                          .findAncestorStateOfType<_SubscriptionsViewState>();
                      if (state != null)
                        state._confirmDeletePlan(context, ref, plan);
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            plan["name"] ?? "Standard Plan",
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "\$${plan["price"]}",
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
                const TextSpan(
                  text: " / month",
                  style: TextStyle(fontSize: 14, color: Colors.white38),
                ),
              ],
            ),
          ),
          const Divider(height: 32, color: Colors.white10),
          _FeatureRow(
            icon: LucideIcons.users,
            label: "$studentsCount Student Capacity",
          ),
          const SizedBox(height: 12),
          _FeatureRow(
            icon: LucideIcons.building,
            label: "${plan["institutions_count"] ?? 0} active subscribers",
          ),
          const Spacer(),
          Text(
            plan["description"] ?? "No description provided.",
            style: const TextStyle(color: Colors.white54, fontSize: 13),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String label;
  const _FeatureRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.white38),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
      ],
    );
  }
}
