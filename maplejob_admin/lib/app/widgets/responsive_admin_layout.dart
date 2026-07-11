import 'package:flutter/material.dart';
import '../config/theme.dart';
import 'admin_drawer.dart';

class ResponsiveAdminLayout extends StatelessWidget {
  final String activeRoute;
  final Widget body;
  final Widget? floatingActionButton;
  final PreferredSizeWidget? appBar;

  const ResponsiveAdminLayout({
    super.key,
    required this.activeRoute,
    required this.body,
    this.floatingActionButton,
    this.appBar,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1000;

    if (isDesktop) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        floatingActionButton: floatingActionButton,
        body: Row(
          children: [
            SizedBox(
              width: 260,
              child: AdminDrawer(activeRoute: activeRoute, isPersistent: true),
            ),
            const VerticalDivider(width: 1, color: AppTheme.outlineVariantColor),
            Expanded(
              child: Scaffold(
                backgroundColor: AppTheme.backgroundColor,
                appBar: appBar,
                body: body,
              ),
            ),
          ],
        ),
      );
    } else {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        drawer: AdminDrawer(activeRoute: activeRoute),
        appBar: appBar,
        body: body,
        floatingActionButton: floatingActionButton,
      );
    }
  }
}
