import 'package:edulearn/core/constants/app_colors.dart';
import 'package:edulearn/core/utils/toast_service.dart';
import 'package:edulearn/core/widgets/glass_container.dart';
import 'package:edulearn/providers/auth/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:edulearn/core/widgets/app_loader.dart';

class VerificationScreen extends ConsumerStatefulWidget {
  const VerificationScreen({super.key});

  @override
  ConsumerState<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends ConsumerState<VerificationScreen> {
  bool _isLoading = false;

  Future<void> _handleResendEmail() async {
    setState(() => _isLoading = true);
    try {
      final message = await ref
          .read(authProvider.notifier)
          .resendVerification();
      ToastService.showSuccess(message);
    } catch (e) {
      ToastService.showError("Failed to resend verification email.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _checkVerificationStatus() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(authProvider.notifier).refreshUser();
      final user = ref.read(authProvider);
      if (user?.emailVerifiedAt != null) {
        if (mounted) context.go('/');
      } else {
        ToastService.showInfo(
          "Email still not verified. Please check your inbox.",
        );
      }
    } catch (e) {
      ToastService.showError("Failed to refresh status.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.watch(authProvider);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    LucideIcons.mailCheck,
                    size: 80,
                    color: Colors.white,
                  ).animate().scale(
                    duration: 600.ms,
                    curve: Curves.easeOutBack,
                  ),
                  const SizedBox(height: 32),
                  Text(
                    "Verify Your Email",
                    style: theme.textTheme.displayMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: 16),
                  Text(
                    "We've sent a verification link to:\n${user?.email ?? 'your email'}",
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white70,
                    ),
                  ).animate().fadeIn(delay: 400.ms),
                  const SizedBox(height: 48),
                  GlassContainer(
                    padding: const EdgeInsets.all(24),
                    color: Colors.white,
                    opacity: 0.1,
                    child: Column(
                      children: [
                        ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : _checkVerificationStatus,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.primary,
                            minimumSize: const Size(double.infinity, 56),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: _isLoading
                              ? const AppLoader(
                                  color: AppColors.primary,
                                  size: 20,
                                )
                              : const Text(
                                  "I've Verified My Email",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _handleResendEmail,
                          child: const Text(
                            "Resend Verification Email",
                            style: TextStyle(
                              color: Colors.white,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      await ref.read(authProvider.notifier).logout();
                      if (mounted) context.go('/login');
                    },
                    child: const Text(
                      "Back to Login",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
