import 'package:edulearn/models/user_model.dart';
import 'package:edulearn/providers/auth/auth_provider.dart';
import 'package:edulearn/screens/auth/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edulearn/screens/auth/login_screen.dart';
import 'package:edulearn/screens/student/home_screen.dart';
import 'package:edulearn/screens/teacher/teacher_dashboard.dart';
import 'package:edulearn/screens/admin/admin_dashboard.dart';
import 'package:edulearn/screens/manager/manager_dashboard.dart';
import 'package:edulearn/screens/auth/verification_screen.dart';

class RootWrapper extends ConsumerWidget {
  const RootWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);

    if (user == null) {
      return const LoginScreen();
    }

    // Check verification (Admin exempt)
    if (user.role != UserRole.admin && user.emailVerifiedAt == null) {
      return const VerificationScreen();
    }

    switch (user.role) {
      case UserRole.student:
        if (user.institutionId == null) {
          return const OnboardingScreen();
        }
        return const HomeScreen();
      case UserRole.teacher:
        return const TeacherDashboard();
      case UserRole.admin:
        return const AdminDashboard();
      case UserRole.manager:
        return const ManagerDashboard();
    }
  }
}
