import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:edulearn/core/theme/app_theme.dart';
import 'package:edulearn/core/constants/app_colors.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:edulearn/core/utils/toast_service.dart';
import 'package:edulearn/screens/auth/login_screen.dart';
import 'package:edulearn/screens/student/home_screen.dart';
import 'package:edulearn/screens/student/course_details_screen.dart';
import 'package:edulearn/screens/teacher/teacher_dashboard.dart';
import 'package:edulearn/screens/student/schedule_screen.dart';
import 'package:edulearn/screens/auth/profile_screen.dart';
import 'package:edulearn/screens/admin/admin_dashboard.dart';
import 'package:edulearn/screens/auth/onboarding_screen.dart';
import 'package:edulearn/screens/auth/splash_screen.dart';
import 'package:edulearn/screens/auth/register_screen.dart';
import 'package:edulearn/screens/auth/forgot_password_screen.dart';
import 'package:edulearn/screens/student/notifications_screen.dart';
import 'package:edulearn/screens/teacher/material_management_screen.dart';
import 'package:edulearn/screens/student/live_class_screen.dart';
import 'package:edulearn/screens/student/review_list_screen.dart';
import 'package:edulearn/screens/student/search_screen.dart';
import 'package:edulearn/screens/teacher/teacher_history_screen.dart';
import 'package:edulearn/screens/teacher/teacher_enrollments_screen.dart';
import 'package:edulearn/screens/auth/verification_screen.dart';
import 'package:edulearn/core/root_wrapper.dart';
import 'package:edulearn/models/course_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // USER REQUEST: Commented out Firebase initialization for now to prevent offline network hangs
  // await Firebase.initializeApp();

  runApp(const ProviderScope(child: EduLearnApp()));
}

final _router = GoRouter(
  navigatorKey: ToastService.navigatorKey,
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/', builder: (context, state) => const RootWrapper()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/course-details',
      builder: (context, state) {
        final course = state.extra as Course?;
        return CourseDetailsScreen(course: course);
      },
    ),
    GoRoute(
      path: '/live-class',
      builder: (context, state) => const LiveClassScreen(),
    ),
    GoRoute(
      path: '/teacher',
      builder: (context, state) => const TeacherDashboard(),
    ),
    GoRoute(
      path: '/schedule',
      builder: (context, state) => const ScheduleScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminDashboard(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/materials',
      builder: (context, state) {
        final course = state.extra as Course?;
        return MaterialManagementScreen(course: course);
      },
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),
    GoRoute(
      path: '/search',
      builder: (context, state) {
        final query = state.extra as String?;
        return SearchScreen(initialQuery: query);
      },
    ),
    GoRoute(
      path: '/course-reviews',
      builder: (context, state) {
        final Map<String, dynamic> args = state.extra as Map<String, dynamic>;
        return ReviewListScreen(courseId: args['id'], courseName: args['name']);
      },
    ),
    GoRoute(
      path: '/teacher/history',
      builder: (context, state) => const TeacherHistoryScreen(),
    ),
    GoRoute(
      path: '/teacher/enrollments',
      builder: (context, state) => const TeacherEnrollmentsScreen(),
    ),
    GoRoute(
      path: '/verify-email',
      builder: (context, state) => const VerificationScreen(),
    ),
  ],
);

class EduLearnApp extends StatelessWidget {
  const EduLearnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'EduLearn',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: _router,
      builder: (context, child) {
        return SkeletonizerConfig(
          data: SkeletonizerConfigData(
            effect: ShimmerEffect(
              baseColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.black.withOpacity(0.05),
              highlightColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.1),
            ),
          ),
          child: Stack(children: [if (child != null) child]),
        );
      },
    );
  }
}
