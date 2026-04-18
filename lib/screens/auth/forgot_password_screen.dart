import 'package:edulearn/providers/auth/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:edulearn/core/constants/app_colors.dart';
import 'package:edulearn/core/widgets/glass_container.dart';
import 'package:edulearn/core/utils/toast_service.dart';
import 'package:edulearn/core/network/api_client.dart';

import 'package:edulearn/core/widgets/app_loader.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _tokenController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _isTokenSent = false;

  Future<void> _handleRequestToken() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ToastService.showError("Please enter your email");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final message = await ref
          .read(authProvider.notifier)
          .forgotPassword(email);
      ToastService.showSuccess(message);
      setState(() => _isTokenSent = true);
    } catch (e) {
      ToastService.showError(ApiClient.getErrorMessage(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleResetPassword() async {
    final email = _emailController.text.trim();
    final token = _tokenController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (token.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ToastService.showError("Please fill in all fields");
      return;
    }

    if (password != confirmPassword) {
      ToastService.showError("Passwords do not match");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final message = await ref
          .read(authProvider.notifier)
          .resetPassword(
            email: email,
            token: token,
            password: password,
            passwordConfirmation: confirmPassword,
          );
      ToastService.showSuccess(message);
      if (mounted) context.pop();
    } catch (e) {
      ToastService.showError(ApiClient.getErrorMessage(e));
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
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
              ),
            ),
          ),

          Positioned(
            bottom: -50,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ).animate().scale(duration: 2.seconds, curve: Curves.easeOut),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(
                        LucideIcons.arrowLeft,
                        color: Colors.white,
                      ),
                      onPressed: () => context.pop(),
                    ),
                  ).animate().fadeIn(delay: 100.ms),

                  const SizedBox(height: 60),

                  const Icon(
                    LucideIcons.keyRound,
                    size: 80,
                    color: Colors.white,
                  ).animate().scale(
                    duration: 600.milliseconds,
                    curve: Curves.easeOutBack,
                  ),
                  const SizedBox(height: 32),

                  Text(
                    _isTokenSent ? "Set New Password" : "Reset Password",
                    style: theme.textTheme.displayMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 300.milliseconds),
                  const SizedBox(height: 16),

                  Text(
                    _isTokenSent
                        ? "Enter the code sent to your email and your new password."
                        : "Enter your email address to receive a password reset token.",
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white70,
                    ),
                  ).animate().fadeIn(delay: 500.milliseconds),

                  const SizedBox(height: 48),

                  GlassContainer(
                        padding: const EdgeInsets.all(24),
                        color: Colors.white,
                        opacity: 0.1,
                        child: Column(
                          children: [
                            if (!_isTokenSent)
                              _buildTextField(
                                controller: _emailController,
                                hint: "Email Address",
                                icon: LucideIcons.mail,
                                keyboardType: TextInputType.emailAddress,
                              )
                            else ...[
                              _buildTextField(
                                controller: _tokenController,
                                hint: "Reset Token",
                                icon: LucideIcons.hash,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _passwordController,
                                hint: "New Password",
                                icon: LucideIcons.lock,
                                obscureText: true,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _confirmPasswordController,
                                hint: "Confirm New Password",
                                icon: LucideIcons.lock,
                                obscureText: true,
                              ),
                            ],
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: _isLoading
                                  ? null
                                  : (_isTokenSent
                                        ? _handleResetPassword
                                        : _handleRequestToken),
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
                                  : Text(
                                      _isTokenSent
                                          ? "Reset Password"
                                          : "Get Reset Token",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      )
                      .animate()
                      .fadeIn(delay: 700.milliseconds)
                      .slideY(begin: 0.1),

                  if (_isTokenSent) ...[
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () => setState(() => _isTokenSent = false),
                      child: const Text(
                        "Use different email",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
          prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.6)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
