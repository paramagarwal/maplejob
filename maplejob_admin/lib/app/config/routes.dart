import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/jobs/presentation/screens/jobs_list_screen.dart';
import '../../features/jobs/presentation/screens/job_form_screen.dart';
import '../../features/applications/presentation/screens/applicants_list_screen.dart';
import '../../features/applications/presentation/screens/applicant_details_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';

class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          'Admin $title Screen Placeholder',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }
}

final GoRouter adminRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/jobs',
      builder: (context, state) => const JobsListScreen(),
    ),
    GoRoute(
      path: '/jobs/create',
      builder: (context, state) => const JobFormScreen(),
    ),
    GoRoute(
      path: '/jobs/edit/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'];
        return JobFormScreen(jobId: id);
      },
    ),
    GoRoute(
      path: '/applicants',
      builder: (context, state) => const ApplicantsListScreen(),
    ),
    GoRoute(
      path: '/applicants/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return ApplicantDetailsScreen(applicationId: id);
      },
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const PlaceholderScreen(title: 'Notifications'),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const PlaceholderScreen(title: 'Settings'),
    ),
  ],
);
