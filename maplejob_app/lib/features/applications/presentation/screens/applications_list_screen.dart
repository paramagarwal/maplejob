import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../app/config/theme.dart';
import '../providers/application_provider.dart';

class ApplicationsListScreen extends ConsumerWidget {
  const ApplicationsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applicationsState = ref.watch(applicantApplicationsProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('My Applications', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: applicationsState.when(
        data: (applications) {
          if (applications.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.description_outlined, size: 64, color: AppTheme.outlineColor),
                    const SizedBox(height: 16.0),
                    Text(
                      'You have not submitted any job applications yet.',
                      style: AppTheme.bodyLg.copyWith(color: AppTheme.outlineColor),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24.0),
                    ElevatedButton(
                      onPressed: () => context.go('/home'),
                      child: const Text('Explore Jobs'),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: applications.length,
            itemBuilder: (context, index) {
              final app = applications[index];
              final dateStr = DateFormat('MMM dd, yyyy').format(app.appliedAt);

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

              return Card(
                margin: const EdgeInsets.only(bottom: 16.0),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppTheme.outlineVariantColor),
                ),
                child: InkWell(
                  onTap: () => context.push('/application/${app.id}'),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusBg,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                app.status,
                                style: AppTheme.labelSm.copyWith(color: statusColor, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Text(
                              dateStr,
                              style: AppTheme.labelSm.copyWith(color: AppTheme.outlineColor),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16.0),
                        Text(
                          app.jobTitle,
                          style: AppTheme.titleMd.copyWith(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          app.department,
                          style: AppTheme.bodyMd.copyWith(color: AppTheme.outlineColor),
                        ),
                        const Divider(height: 24, color: AppTheme.outlineVariantColor),
                        Row(
                          children: [
                            const Icon(Icons.picture_as_pdf_outlined, size: 16, color: AppTheme.outlineColor),
                            const SizedBox(width: 8.0),
                            Expanded(
                              child: Text(
                                app.resumeName,
                                style: AppTheme.labelSm.copyWith(color: AppTheme.primaryColor),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8.0),
                            Text(
                              'Track Progress',
                              style: AppTheme.labelLg.copyWith(color: AppTheme.secondaryColor, fontWeight: FontWeight.bold),
                            ),
                            const Icon(Icons.arrow_forward, size: 16, color: AppTheme.secondaryColor),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
        error: (err, _) => Center(child: Text('Error: $err')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
