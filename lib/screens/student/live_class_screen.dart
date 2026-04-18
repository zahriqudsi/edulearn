import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:edulearn/core/constants/app_colors.dart';
import 'package:edulearn/core/widgets/glass_container.dart';

class LiveClassScreen extends StatelessWidget {
  const LiveClassScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: Colors.black, // Dark background for focus
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Mock Video Feed Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0F172A), Color(0xFF1E1E2F)],
              ),
            ),
            child: Stack(
               children: [
                 Positioned.fill(
                    child: Center(
                       child: Column(
                         mainAxisAlignment: MainAxisAlignment.center,
                         children: [
                           Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.05)),
                              child: const CircleAvatar(radius: 60, backgroundColor: AppColors.primary, child: Icon(LucideIcons.user, size: 60, color: Colors.white)),
                           ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(begin: const Offset(1, 1), end: const Offset(1.05, 1.05), duration: 2.seconds),
                           const SizedBox(height: 20),
                           Text(
                             "Dr. Elizabeth is presenting...",
                             style: theme.textTheme.titleMedium?.copyWith(color: Colors.white70),
                           ).animate().fadeIn(delay: 400.ms),
                         ],
                       ),
                    ),
                 ),
                 // Background Mesh
                 Positioned(
                    top: -100,
                    right: -50,
                    child: Container(
                       width: 300,
                       height: 300,
                       decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primary.withOpacity(0.2), boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.1), blurRadius: 100)]),
                    ),
                 ),
               ],
            ),
          ),
          
          SafeArea(
             child: Stack(
                children: [
                   // Participant Counter & Info
                   Positioned(
                     top: 16,
                     left: 20,
                     child: GlassContainer(
                       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                       color: Colors.black,
                       opacity: 0.4,
                       borderRadius: BorderRadius.circular(30),
                       child: Row(
                         children: [
                            Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle)).animate(onPlay: (c) => c.repeat(reverse: true)).fade(duration: 1.seconds),
                            const SizedBox(width: 12),
                            Text("LIVE · 42 Students", style: theme.textTheme.bodySmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                         ],
                       ),
                     ).animate().fadeIn(delay: 200.ms).slideY(begin: -0.2),
                   ),

                   // User's Small Camera Preview (PIP)
                   Positioned(
                     top: 16,
                     right: 20,
                     child: Container(
                       height: 160,
                       width: 120,
                       decoration: BoxDecoration(
                         gradient: LinearGradient(colors: [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)]),
                         borderRadius: BorderRadius.circular(24),
                         border: Border.all(color: Colors.white24, width: 1.5),
                         boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 30, offset: const Offset(0, 10))],
                       ),
                       child: Stack(
                          children: [
                             const Center(child: Icon(LucideIcons.camera, color: Colors.white24, size: 32)),
                             Positioned(
                                bottom: 12,
                                left: 12,
                                child: Container(
                                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                   decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(10)),
                                   child: const Text("You", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                ),
                             )
                          ],
                       ),
                     ).animate().fadeIn(delay: 500.ms).slideX(begin: 0.2),
                   ),
                   
                   // Chat Overlay Peek
                   Positioned(
                     bottom: 120,
                     left: 20,
                     child: GlassContainer(
                        width: 280,
                        padding: const EdgeInsets.all(16),
                        color: Colors.black,
                        opacity: 0.3,
                        borderColor: Colors.white24,
                        child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                              Row(
                                 children: [
                                    const CircleAvatar(radius: 10, backgroundColor: Colors.orange, child: Icon(LucideIcons.user, size: 12, color: Colors.white)),
                                    const SizedBox(width: 8),
                                    Expanded(child: const Text("Zahri: Any questions on this part?", style: TextStyle(color: Colors.white, fontSize: 13, height: 1.3))),
                                 ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                 children: [
                                    const CircleAvatar(radius: 10, backgroundColor: AppColors.success, child: Icon(LucideIcons.user, size: 12, color: Colors.white)),
                                    const SizedBox(width: 8),
                                    Expanded(child: const Text("Alex: Joining now! Excited.", style: TextStyle(color: AppColors.primaryLight, fontSize: 13, fontWeight: FontWeight.bold))),
                                 ],
                              ),
                           ],
                        ),
                     ).animate().fadeIn(delay: 1.5.seconds).slideX(begin: -0.1),
                   ),

                   // Floating Controls Navigation Bar
                   Positioned(
                     bottom: 24,
                     left: 20,
                     right: 20,
                     child: GlassContainer(
                       padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                       color: Colors.black,
                       opacity: 0.6,
                       borderRadius: BorderRadius.circular(40),
                       borderColor: Colors.white24,
                       child: Row(
                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                         children: [
                            _ControlButton(icon: LucideIcons.mic, color: Colors.white12, isActive: true),
                            _ControlButton(icon: LucideIcons.video, color: Colors.white12, isActive: true),
                            _ControlButton(icon: LucideIcons.monitorUp, color: Colors.white12),
                            _ControlButton(icon: LucideIcons.hand, color: AppColors.warning.withOpacity(0.2), iconColor: AppColors.warning),
                            InkWell(
                               onTap: () => context.pop(),
                               child: _ControlButton(icon: LucideIcons.phoneOff, color: AppColors.error, iconColor: Colors.white),
                            ),
                         ],
                       ),
                     ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.5),
                   ),
                ],
             ),
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color iconColor;
  final bool isActive;

  const _ControlButton({
    required this.icon,
    required this.color,
    this.iconColor = Colors.white,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
       padding: const EdgeInsets.all(16),
       decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isActive ? Border.all(color: Colors.white24, width: 1.5) : null,
          boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 10)],
       ),
       child: Icon(icon, color: iconColor, size: 24),
    );
  }
}




