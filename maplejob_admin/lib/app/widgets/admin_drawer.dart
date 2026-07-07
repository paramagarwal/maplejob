import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../config/theme.dart';

class AdminDrawer extends StatelessWidget {
  final String activeRoute;
  const AdminDrawer({super.key, required this.activeRoute});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppTheme.primaryColor,
      child: Column(
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
          ListTile(
            leading: const Icon(Icons.dashboard_outlined, color: Colors.white70),
            title: const Text('Job Management', style: TextStyle(color: Colors.white)),
            selected: activeRoute == '/jobs',
            selectedTileColor: Colors.white12,
            onTap: () {
              Navigator.pop(context);
              context.go('/jobs');
            },
          ),
          ListTile(
            leading: const Icon(Icons.people_outline, color: Colors.white70),
            title: const Text('Applicant Tracking', style: TextStyle(color: Colors.white)),
            selected: activeRoute == '/applicants',
            selectedTileColor: Colors.white12,
            onTap: () {
              Navigator.pop(context);
              context.go('/applicants');
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
      ),
    );
  }
}
