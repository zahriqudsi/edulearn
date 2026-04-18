import 'package:edulearn/core/constants/app_colors.dart';
import 'package:edulearn/core/widgets/glass_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edulearn/core/network/api_client.dart';
import 'package:edulearn/core/utils/toast_service.dart';
import 'package:edulearn/providers/auth/auth_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:edulearn/core/widgets/app_loader.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _codeController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleVerify() async {
    final code = _codeController.text.trim();
    if (code.length != 6) {
      ToastService.showError("Please enter a valid 6-digit code.");
      return;
    }

    setState(() => _isLoading = true);
    try {
      final message = await ref
          .read(authProvider.notifier)
          .linkInstitution(code);
      if (mounted) {
        ToastService.showSuccess(message);
        context.pushReplacement('/');
      }
    } catch (e) {
      if (mounted) ToastService.showError(ApiClient.getErrorMessage(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
              ),
            ),
          ),

          // Abstract shapes
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ).animate().fade(duration: 1.seconds).scale(curve: Curves.easeOut),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    LucideIcons.school,
                    size: 80,
                    color: Colors.white,
                  ).animate().scale(
                    duration: 600.milliseconds,
                    curve: Curves.easeOutBack,
                  ),
                  const SizedBox(height: 32),

                  Text(
                    "Link Your Institution",
                    style: theme.textTheme.displayMedium?.copyWith(
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 300.milliseconds),
                  const SizedBox(height: 16),

                  Text(
                    "Enter the unique 6-digit code provided by your school to unlock your courses.",
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white70,
                    ),
                  ).animate().fadeIn(delay: 500.milliseconds),

                  const SizedBox(height: 48),

                  // Glassform
                  GlassContainer(
                        padding: const EdgeInsets.all(32),
                        color: Colors.white,
                        opacity: 0.1,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _codeController,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 12,
                                color: Colors.white,
                              ),
                              decoration: InputDecoration(
                                hintText: "000000",
                                hintStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.3),
                                ),
                                counterText: "",
                                fillColor: Colors.white.withOpacity(0.05),
                                filled: true,
                              ),
                              maxLength: 6,
                              keyboardType: TextInputType.number,
                              enabled: !_isLoading,
                            ),
                            const SizedBox(height: 32),
                            ElevatedButton(
                              onPressed: _isLoading ? null : _handleVerify,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: AppColors.primary,
                                minimumSize: const Size(double.infinity, 50),
                              ),
                              child: _isLoading
                                  ? const AppLoader(size: 20)
                                  : const Text(
                                      "Verify & Continue",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      )
                      .animate()
                      .fadeIn(delay: 700.milliseconds)
                      .slideY(begin: 0.1),

                  const SizedBox(height: 24),

                  TextButton.icon(
                    onPressed: () => context.go('/login'),
                    icon: const Icon(
                      LucideIcons.arrowLeft,
                      color: Colors.white,
                    ),
                    label: const Text(
                      "Go Back",
                      style: TextStyle(color: Colors.white),
                    ),
                  ).animate().fadeIn(delay: 1.seconds),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
