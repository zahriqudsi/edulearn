import 'package:edulearn/models/user_model.dart';
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

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  bool _isBiometricEnabled = false;
  bool _canCheckBiometrics = false;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    final auth = ref.read(authProvider.notifier);
    _canCheckBiometrics = await auth.canCheckBiometrics();
    _isBiometricEnabled = await auth.isBiometricEnabled();
    if (mounted) setState(() {});

    // Auto-trigger bio if enabled
    if (_isBiometricEnabled) {
      _handleBiometricLogin();
    }
  }

  Future<void> _handleBiometricLogin() async {
    try {
      final message = await ref
          .read(authProvider.notifier)
          .loginWithBiometrics();
      if (message != null) {
        if (mounted) {
          ToastService.showSuccess(message);
          // Navigation is now handled reactively by ref.listen
        }
      }
    } catch (e) {
      if (mounted) ToastService.showError(e.toString());
    }
  }

  void _navigateToDashboard(EduUser? user) {
    if (user == null) return;

    // Check email verification for students/teachers
    if (user.role != UserRole.admin && user.emailVerifiedAt == null) {
      context.go('/verify-email');
      return;
    }

    // Always go to root, let RootWrapper handle the specific dashboard/onboarding logic
    context.go('/');
    return;
  }

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ToastService.showError('Please fill in all fields');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final message = await ref
          .read(authProvider.notifier)
          .login(_emailController.text.trim(), _passwordController.text.trim());

      if (mounted) {
        ToastService.showSuccess(message);

        // Check for biometric enrollment
        if (_canCheckBiometrics && !_isBiometricEnabled) {
          _showBiometricEnrollmentDialog();
        }
        // Navigation is now handled reactively by ref.listen
      }
    } catch (e) {
      if (mounted) ToastService.showError(ApiClient.getErrorMessage(e));
      print(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showBiometricEnrollmentDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Enable Biometrics?"),
        content: const Text(
          "Would you like to use Face ID or Fingerprint for faster login next time?",
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToDashboard(ref.read(authProvider));
            },
            child: const Text("Later"),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () async {
              await ref
                  .read(authProvider.notifier)
                  .enrollBiometrics(
                    _emailController.text.trim(),
                    _passwordController.text.trim(),
                  );
              if (mounted) {
                Navigator.pop(context);
                _navigateToDashboard(ref.read(authProvider));
              }
            },
            child: const Text("Enable"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Reactive navigation: trigger when user transitions from null to non-null
    ref.listen<EduUser?>(authProvider, (previous, next) {
      if (next != null && previous == null) {
        _navigateToDashboard(next);
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          // Dynamic Animated Background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppColors.premiumDarkGradient,
              ),
            ),
          ),

          // Abstract background glows
          Positioned(
                top: -100,
                left: -100,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withOpacity(0.3),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 100,
                      ),
                    ],
                  ),
                ),
              )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .move(
                duration: 4.seconds,
                begin: const Offset(0, 0),
                end: const Offset(50, 50),
              ),

          Positioned(
                bottom: -50,
                right: -50,
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.accent.withOpacity(0.3),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withOpacity(0.3),
                        blurRadius: 100,
                      ),
                    ],
                  ),
                ),
              )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .move(
                duration: 5.seconds,
                begin: const Offset(0, 0),
                end: const Offset(-50, -50),
              ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 20.0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white24),
                      ),
                      child: const Icon(
                        LucideIcons.graduationCap,
                        color: Colors.white,
                        size: 48,
                      ),
                    ).animate().fade().scale(
                      curve: Curves.easeOutBack,
                      duration: 600.ms,
                    ),

                    const SizedBox(height: 24),

                    // Welcome Text
                    Text(
                      "EduLearn",
                      style: theme.textTheme.displayMedium?.copyWith(
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),

                    const SizedBox(height: 8),

                    Text(
                      "Sign in to your premium classroom.",
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white70,
                      ),
                    ).animate().fadeIn(delay: 400.ms),

                    const SizedBox(height: 48),

                    // Glass Form Container
                    GlassContainer(
                      padding: const EdgeInsets.all(32),
                      color: Colors.white,
                      opacity: 0.05,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: _emailController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: "Email address",
                              hintStyle: const TextStyle(color: Colors.white38),
                              prefixIcon: const Icon(
                                LucideIcons.mail,
                                color: Colors.white54,
                              ),
                              fillColor: Colors.white.withOpacity(0.05),
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ).animate().fadeIn(delay: 600.ms).slideX(begin: 0.1),

                          const SizedBox(height: 20),

                          TextFormField(
                            controller: _passwordController,
                            obscureText: !_isPasswordVisible,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: "Password",
                              hintStyle: const TextStyle(color: Colors.white38),
                              prefixIcon: const Icon(
                                LucideIcons.lock,
                                color: Colors.white54,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? LucideIcons.eye
                                      : LucideIcons.eyeOff,
                                  color: Colors.white54,
                                ),
                                onPressed: () => setState(
                                  () =>
                                      _isPasswordVisible = !_isPasswordVisible,
                                ),
                              ),
                              fillColor: Colors.white.withOpacity(0.05),
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ).animate().fadeIn(delay: 700.ms).slideX(begin: 0.1),

                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => context.push('/forgot-password'),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white70,
                              ),
                              child: const Text("Forgot Password?"),
                            ),
                          ).animate().fadeIn(delay: 800.ms),

                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _handleLogin,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: _isLoading
                                      ? const AppLoader(
                                          color: Colors.white,
                                          size: 20,
                                        )
                                      : const Text("Sign In"),
                                ),
                              ),
                              if (_canCheckBiometrics &&
                                  _isBiometricEnabled) ...[
                                const SizedBox(width: 12),
                                IconButton(
                                  onPressed: _handleBiometricLogin,
                                  icon: const Icon(
                                    LucideIcons.fingerprint,
                                    color: AppColors.primary,
                                    size: 32,
                                  ),
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.white.withOpacity(
                                      0.05,
                                    ),
                                    padding: const EdgeInsets.all(12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ).animate().fadeIn(delay: 900.ms).scale(),
                        ],
                      ),
                    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1),

                    const SizedBox(height: 32),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account?",
                          style: TextStyle(color: Colors.white54),
                        ),
                        TextButton(
                          onPressed: () => context.push('/register'),
                          child: const Text(
                            "Sign up",
                            style: TextStyle(
                              color: AppColors.primaryLight,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 1.2.seconds),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
