import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../config/theme.dart';

class AdminDrawer extends StatelessWidget {
  final String activeRoute;
  final bool isPersistent;
  const AdminDrawer({
    super.key,
    required this.activeRoute,
    this.isPersistent = false,
  });

  @override
  Widget build(BuildContext context) {
    final content = Column(
      children: [
        DrawerHeader(
          decoration: const BoxDecoration(
            color: AppTheme.primaryColor,
            border: Border(bottom: BorderSide(color: Color.fromRGBO(255, 255, 255, 0.1))),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.admin_panel_settings, color: Colors.white, size: 40),
                const SizedBox(height: 12),
                Text(
                  'MapleHub Portal',
                  style: AppTheme.titleLg.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
        // Dashboard
        ListTile(
          leading: const Icon(Icons.dashboard_outlined, color: Colors.white70),
          title: const Text('Dashboard', style: TextStyle(color: Colors.white)),
          selected: activeRoute == '/dashboard',
          selectedTileColor: Colors.white12,
          onTap: () {
            if (!isPersistent) Navigator.pop(context);
            context.go('/dashboard');
          },
        ),
        // Jobs
        ListTile(
          leading: const Icon(Icons.work_outline, color: Colors.white70),
          title: const Text('Job Management', style: TextStyle(color: Colors.white)),
          selected: activeRoute == '/jobs',
          selectedTileColor: Colors.white12,
          onTap: () {
            if (!isPersistent) Navigator.pop(context);
            context.go('/jobs');
          },
        ),
        // Applications
        ListTile(
          leading: const Icon(Icons.people_outline, color: Colors.white70),
          title: const Text('Applicant Tracking', style: TextStyle(color: Colors.white)),
          selected: activeRoute == '/applicants',
          selectedTileColor: Colors.white12,
          onTap: () {
            if (!isPersistent) Navigator.pop(context);
            context.go('/applicants');
          },
        ),
        // Notifications
        ListTile(
          leading: const Icon(Icons.notifications_none, color: Colors.white70),
          title: const Text('Notifications', style: TextStyle(color: Colors.white)),
          selected: activeRoute == '/notifications',
          selectedTileColor: Colors.white12,
          onTap: () {
            if (!isPersistent) Navigator.pop(context);
            context.go('/notifications');
          },
        ),
        // Settings
        ListTile(
          leading: const Icon(Icons.settings_outlined, color: Colors.white70),
          title: const Text('Settings', style: TextStyle(color: Colors.white)),
          selected: activeRoute == '/settings',
          selectedTileColor: Colors.white12,
          onTap: () {
            if (!isPersistent) Navigator.pop(context);
            context.go('/settings');
          },
        ),
        const Spacer(),
        const Divider(color: Color.fromRGBO(255, 255, 255, 0.1)),
        ListTile(
          leading: const Icon(Icons.logout, color: AppTheme.errorColor),
          title: const Text('Sign Out', style: TextStyle(color: AppTheme.errorColor)),
          onTap: () async {
            await FirebaseAuth.instance.signOut();
            if (context.mounted) {
              context.go('/login');
            }
          },
        ),
        const SizedBox(height: 16),
      ],
    );

    if (isPersistent) {
      return Container(
        color: AppTheme.primaryColor,
        child: content,
      );
    } else {
      return Drawer(
        backgroundColor: AppTheme.primaryColor,
        child: content,
      );
    }
  }
}
