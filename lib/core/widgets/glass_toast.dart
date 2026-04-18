import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:edulearn/core/constants/app_colors.dart';
import 'package:edulearn/core/widgets/glass_container.dart';

enum ToastType { info, success, warning, error }

class GlassToast extends StatelessWidget {
  final String message;
  final ToastType type;
  final VoidCallback onDismiss;

  const GlassToast({
    super.key,
    required this.message,
    required this.type,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    Color mainColor;
    IconData icon;

    switch (type) {
      case ToastType.success:
        mainColor = AppColors.success;
        icon = LucideIcons.checkCircle2;
        break;
      case ToastType.warning:
        mainColor = AppColors.warning;
        icon = LucideIcons.alertTriangle;
        break;
      case ToastType.error:
        mainColor = AppColors.error;
        icon = LucideIcons.alertCircle;
        break;
      case ToastType.info:
      default:
        mainColor = AppColors.primary;
        icon = LucideIcons.info;
        break;
    }

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
        alignment: Alignment.topCenter,
        child: GlassContainer(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          color: mainColor.withOpacity(0.1),
          borderColor: mainColor.withOpacity(0.3),
          opacity: 0.8,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: mainColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: mainColor, size: 20),
              ),
              const SizedBox(width: 16),
              Flexible(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(LucideIcons.x, color: Colors.white54, size: 16),
                onPressed: onDismiss,
              ),
            ],
          ),
        )
            .animate()
            .fadeIn(duration: 400.ms)
            .slideY(begin: -0.5, end: 0, curve: Curves.easeOutBack),
      ),
    );
  }
}
