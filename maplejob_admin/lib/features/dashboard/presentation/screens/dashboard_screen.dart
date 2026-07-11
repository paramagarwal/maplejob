import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../app/config/theme.dart';
import '../../../../app/widgets/responsive_admin_layout.dart';
import '../../../jobs/presentation/providers/job_provider.dart';
import '../../../applications/presentation/providers/application_provider.dart';
import '../providers/dashboard_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  void _showCategoriesDialog(BuildContext context, WidgetRef ref) {
    final jobsAsync = ref.read(jobsStreamProvider);
    final jobs = jobsAsync.value ?? [];

    final categoryCounts = <String, int>{};
    for (final job in jobs) {
      categoryCounts[job.category] = (categoryCounts[job.category] ?? 0) + 1;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Browse Categories', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
          content: SizedBox(
            width: 400,
            child: categoryCounts.isEmpty
                ? const Text('No categories found. Assign categories by creating or editing job postings.')
                : ListView(
                    shrinkWrap: true,
                    children: categoryCounts.entries.map((entry) {
                      return ListTile(
                        leading: const Icon(Icons.folder_open, color: AppTheme.secondaryColor),
                        title: Text(entry.key, style: const TextStyle(fontWeight: FontWeight.w500)),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${entry.value} Job${entry.value == 1 ? "" : "s"}',
                            style: AppTheme.labelSm.copyWith(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final applicationsAsync = ref.watch(allApplicationsStreamProvider);

    return ResponsiveAdminLayout(
      activeRoute: '/dashboard',
      appBar: AppBar(
        title: const Text('Recruitment Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: statsAsync.when(
        data: (stats) {
          final recentApps = (applicationsAsync.value ?? []).take(5).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Welcome header section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back, hiring manager',
                          style: AppTheme.headlineLg.copyWith(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Here is an overview of your active candidate pipeline.',
                          style: AppTheme.bodyLg.copyWith(color: AppTheme.outlineColor),
                        ),
                      ],
                    ),
                    Text(
                      DateFormat('EEEE, MMMM dd, yyyy').format(DateTime.now()),
                      style: AppTheme.labelLg.copyWith(color: AppTheme.secondaryColor, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 32.0),

                // Metrics Grid Section
                LayoutBuilder(
                  builder: (context, constraints) {
                    final double cardWidth = constraints.maxWidth > 800 ? (constraints.maxWidth - 48) / 3 : (constraints.maxWidth - 24) / 2;
                    return Wrap(
                      spacing: 24.0,
                      runSpacing: 24.0,
                      children: [
                        _buildMetricCard(
                          title: 'Total Jobs',
                          value: stats.totalJobs.toString(),
                          icon: Icons.work_outline,
                          color: AppTheme.primaryColor,
                          width: cardWidth,
                        ),
                        _buildMetricCard(
                          title: 'Active Jobs',
                          value: stats.activeJobs.toString(),
                          icon: Icons.play_circle_outline,
                          color: AppTheme.shortlistedText,
                          width: cardWidth,
                        ),
                        _buildMetricCard(
                          title: 'Closed Jobs',
                          value: stats.closedJobs.toString(),
                          icon: Icons.check_circle_outline,
                          color: AppTheme.outlineColor,
                          width: cardWidth,
                        ),
                        _buildMetricCard(
                          title: 'Total Candidates',
                          value: stats.totalApplicants.toString(),
                          icon: Icons.people_outline,
                          color: AppTheme.secondaryColor,
                          width: cardWidth,
                        ),
                        _buildMetricCard(
                          title: 'Applications Today',
                          value: stats.applicationsToday.toString(),
                          icon: Icons.today,
                          color: AppTheme.appliedText,
                          width: cardWidth,
                        ),
                        _buildMetricCard(
                          title: 'Applications This Month',
                          value: stats.applicationsThisMonth.toString(),
                          icon: Icons.calendar_view_month,
                          color: Colors.deepPurple,
                          width: cardWidth,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 32.0),

                // Split layout for Quick Actions and Recent applications
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth > 1000) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 4,
                            child: _buildQuickActionsCard(context, ref),
                          ),
                          const SizedBox(width: 24.0),
                          Expanded(
                            flex: 6,
                            child: _buildRecentApplicationsCard(context, recentApps),
                          ),
                        ],
                      );
                    } else {
                      return Column(
                        children: [
                          _buildQuickActionsCard(context, ref),
                          const SizedBox(height: 24.0),
                          _buildRecentApplicationsCard(context, recentApps),
                        ],
                      );
                    }
                  },
                ),
              ],
            ),
          );
        },
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Text('Failed to load dashboard metrics: $err', style: const TextStyle(color: AppTheme.errorColor)),
          ),
        ),
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.all(100.0),
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required double width,
  }) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.outlineVariantColor, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTheme.labelLg.copyWith(color: AppTheme.outlineColor)),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: AppTheme.headlineLg.copyWith(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsCard(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppTheme.outlineVariantColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Quick Actions',
              style: AppTheme.titleLg.copyWith(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Perform common recruiting operations instantly.',
              style: AppTheme.bodyMd.copyWith(color: AppTheme.outlineColor),
            ),
            const Divider(height: 32, color: AppTheme.outlineVariantColor),
            _buildActionItem(
              icon: Icons.post_add,
              title: 'Post New Job Listing',
              subtitle: 'Publish requirements and qualifications',
              color: AppTheme.secondaryColor,
              onTap: () => context.push('/jobs/create'),
            ),
            const SizedBox(height: 16),
            _buildActionItem(
              icon: Icons.category_outlined,
              title: 'Browse Categories',
              subtitle: 'Check job counts by category group',
              color: Colors.orange,
              onTap: () => _showCategoriesDialog(context, ref),
            ),
            const SizedBox(height: 16),
            _buildActionItem(
              icon: Icons.people_outline,
              title: 'View Candidates',
              subtitle: 'Manage applications in status pipeline',
              color: AppTheme.shortlistedText,
              onTap: () => context.go('/applicants'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppTheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTheme.titleMd.copyWith(color: AppTheme.primaryColor, fontSize: 15)),
                    Text(subtitle, style: AppTheme.labelSm.copyWith(color: AppTheme.outlineColor)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppTheme.outlineColor, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentApplicationsCard(BuildContext context, List recentApps) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppTheme.outlineVariantColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recent Applications',
                      style: AppTheme.titleLg.copyWith(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Last 5 incoming job application submissions.',
                      style: AppTheme.bodyMd.copyWith(color: AppTheme.outlineColor),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () => context.go('/applicants'),
                  child: const Text('View All', style: TextStyle(color: AppTheme.secondaryColor, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const Divider(height: 32, color: AppTheme.outlineVariantColor),
            if (recentApps.isEmpty) ...[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40.0),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.people_outline, size: 48, color: AppTheme.outlineColor),
                      SizedBox(height: 12),
                      Text('No recent applications found.', style: TextStyle(color: AppTheme.outlineColor)),
                    ],
                  ),
                ),
              ),
            ] else ...[
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recentApps.length,
                separatorBuilder: (context, index) => const Divider(height: 24, color: AppTheme.outlineVariantColor),
                itemBuilder: (context, index) {
                  final app = recentApps[index];
                  final appliedDate = DateFormat('MMM dd, hh:mm a').format(app.appliedAt);

                  Color statusColor = AppTheme.primaryColor;
                  Color statusBg = AppTheme.surfaceContainerLow;

                  if (app.status == 'Applied') {
                    statusColor = AppTheme.appliedText;
                    statusBg = AppTheme.appliedBg;
                  } else if (app.status == 'Shortlisted' || app.status == 'Interview') {
                    statusColor = AppTheme.shortlistedText;
                    statusBg = AppTheme.shortlistedBg;
                  } else if (app.status == 'Offered') {
                    statusColor = AppTheme.shortlistedText;
                    statusBg = AppTheme.shortlistedBg;
                  } else if (app.status == 'Rejected') {
                    statusColor = AppTheme.rejectedText;
                    statusBg = AppTheme.rejectedBg;
                  }

                  return Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppTheme.surfaceContainer,
                        child: Text(
                          app.applicantName.isNotEmpty ? app.applicantName.substring(0, 1).toUpperCase() : '?',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              app.applicantName,
                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                            ),
                            Text(
                              'Applied for: ${app.jobTitle}',
                              style: AppTheme.labelSm.copyWith(color: AppTheme.outlineColor),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(appliedDate, style: AppTheme.labelSm.copyWith(color: AppTheme.outlineColor)),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: statusBg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              app.status,
                              style: AppTheme.labelSm.copyWith(color: statusColor, fontWeight: FontWeight.bold, fontSize: 10),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: const Icon(Icons.chevron_right, color: AppTheme.outlineColor),
                        onPressed: () => context.push('/applicants/${app.id}'),
                      ),
                    ],
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
