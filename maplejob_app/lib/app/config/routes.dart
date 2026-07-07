import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/resume_upload_screen.dart';
import '../../features/jobs/presentation/screens/jobs_list_screen.dart';
import '../../features/jobs/presentation/screens/job_details_screen.dart';
import '../../features/applications/presentation/screens/applications_list_screen.dart';
import '../../features/applications/presentation/screens/application_status_screen.dart';
import '../../features/applications/presentation/screens/success_screen.dart';
import '../../features/notifications/presentation/screens/notification_center_screen.dart';

// Placeholder screens for routes
class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          '$title Screen Placeholder',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }
}

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const JobsListScreen(),
    ),
    GoRoute(
      path: '/job/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return JobDetailsScreen(jobId: id);
      },
    ),
    GoRoute(
      path: '/apply/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return PlaceholderScreen(title: 'Apply to Job: $id');
      },
    ),
    GoRoute(
      path: '/success',
      builder: (context, state) => const SuccessScreen(),
    ),
    GoRoute(
      path: '/applications',
      builder: (context, state) => const ApplicationsListScreen(),
    ),
    GoRoute(
      path: '/application/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return ApplicationStatusScreen(applicationId: id);
      },
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/profile/edit',
      builder: (context, state) => const EditProfileScreen(),
    ),
    GoRoute(
      path: '/profile/resume',
      builder: (context, state) => const ResumeUploadScreen(),
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationCenterScreen(),
    ),
  ],
);
