import 'package:edulearn/providers/auth/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:edulearn/core/constants/app_colors.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    // Wait for splash animation and auth check
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    final user = ref.read(authProvider);
    if (user != null) {
      context.go('/'); // Already logged in
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              gradient: AppColors.premiumDarkGradient,
            ),
          ),

          // Subtle glowing orb
          Positioned(
                top: MediaQuery.of(context).size.height * 0.3,
                left: MediaQuery.of(context).size.width * 0.1,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.accent.withOpacity(0.15),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withOpacity(0.2),
                        blurRadius: 120,
                      ),
                    ],
                  ),
                ),
              )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scaleXY(end: 1.2, duration: 3.seconds),

          // Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Icon
                Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.05),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: const Icon(
                        LucideIcons.graduationCap,
                        color: Colors.white,
                        size: 80,
                      ),
                    )
                    .animate()
                    .fade(duration: 800.ms)
                    .scale(
                      delay: 200.ms,
                      curve: Curves.elasticOut,
                      duration: 1200.ms,
                    )
                    .shimmer(
                      delay: 1500.ms,
                      duration: 1000.ms,
                      color: Colors.white30,
                    ),

                const SizedBox(height: 32),

                // Brand Name
                const Text(
                      "EduLearn",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                      ),
                    )
                    .animate()
                    .fadeIn(delay: 800.ms)
                    .slideY(begin: 0.2, duration: 600.ms),

                const SizedBox(height: 12),

                // Tagline
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "Premium Digital Education",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ).animate().fadeIn(delay: 1200.ms).scale(curve: Curves.easeOut),
              ],
            ),
          ),
        ],
      ),
    );
  }
}




