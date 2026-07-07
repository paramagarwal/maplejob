import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../app/config/theme.dart';
import '../../domain/entities/job_application.dart';
import '../providers/application_provider.dart';

class ApplicationStatusScreen extends ConsumerWidget {
  final String applicationId;
  const ApplicationStatusScreen({super.key, required this.applicationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applicationState = ref.watch(applicationStreamProvider(applicationId));

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Application Status', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: applicationState.when(
        data: (app) {
          if (app == null) {
            return const Center(child: Text('Application details not found.'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Details Card
                _buildHeaderCard(app),
                const SizedBox(height: 24.0),

                // Visual Timeline Card
                Card(
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: AppTheme.outlineVariantColor),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 32.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Application Pipeline',
                          style: AppTheme.titleLg.copyWith(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          'Track the progress of your submission in real-time.',
                          style: AppTheme.bodyMd.copyWith(color: AppTheme.outlineColor),
                        ),
                        const Divider(height: 32, color: AppTheme.outlineVariantColor),
                        _buildTimeline(app),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24.0),

                // Notes Card
                if (app.notes.isNotEmpty) _buildNotesCard(app),
                const SizedBox(height: 24.0),

                // Support Contact Card
                _buildContactCard(),
              ],
            ),
          );
        },
        error: (err, _) => Center(child: Text('Error loading status: $err')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildHeaderCard(JobApplication app) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppTheme.outlineVariantColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.business_center, color: AppTheme.primaryColor, size: 28),
            ),
            const SizedBox(width: 20.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    app.jobTitle,
                    style: AppTheme.titleLg.copyWith(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    app.department,
                    style: AppTheme.bodyMd.copyWith(color: AppTheme.outlineColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline(JobApplication app) {
    // Stage completeness checks
    final hasApplied = true;
    final hasShortlisted = app.status == 'Shortlisted' || app.status == 'Interview' || app.status == 'Offered' || app.status == 'Rejected';
    final hasInterviewed = app.status == 'Interview' || app.status == 'Offered';
    final hasOffered = app.status == 'Offered';
    final hasRejected = app.status == 'Rejected';

    final dateStr = DateFormat('MMM dd, yyyy').format(app.appliedAt);

    return Column(
      children: [
        _buildTimelineStep(
          title: 'Application Submitted',
          subtitle: 'Your profile has been received and is under review.',
          date: dateStr,
          isCompleted: hasApplied,
          isLast: false,
        ),
        _buildTimelineStep(
          title: 'Profile Shortlisted',
          subtitle: 'HR matched your credentials with target qualifications.',
          date: hasShortlisted && !hasRejected ? 'Completed' : '',
          isCompleted: hasShortlisted && !hasRejected,
          isLast: false,
          isWarning: hasRejected && app.status == 'Rejected', // show failure route if rejected
        ),
        _buildTimelineStep(
          title: 'Interview Scheduled',
          subtitle: 'Engagement, screening and executive discussion panels.',
          date: hasInterviewed ? 'Active/Passed' : '',
          isCompleted: hasInterviewed,
          isLast: false,
        ),
        if (hasRejected)
          _buildTimelineStep(
            title: 'Application Closed',
            subtitle: 'Thank you for your interest. We will keep your resume on file.',
            date: 'Decision Made',
            isCompleted: true,
            isLast: true,
            isError: true,
          )
        else
          _buildTimelineStep(
            title: 'Decision Made',
            subtitle: 'Official employment contract offered!',
            date: hasOffered ? 'Offered' : '',
            isCompleted: hasOffered,
            isLast: true,
          ),
      ],
    );
  }

  Widget _buildTimelineStep({
    required String title,
    required String subtitle,
    required String date,
    required bool isCompleted,
    required bool isLast,
    bool isWarning = false,
    bool isError = false,
  }) {
    Color stepColor = isCompleted ? AppTheme.secondaryColor : AppTheme.outlineColor;
    IconData icon = isCompleted ? Icons.check_circle : Icons.radio_button_unchecked;

    if (isWarning) {
      stepColor = Colors.orange;
      icon = Icons.warning_amber_rounded;
    }
    if (isError) {
      stepColor = AppTheme.errorColor;
      icon = Icons.cancel;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Indicator column
          Column(
            children: [
              Icon(icon, color: stepColor, size: 24),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isCompleted ? AppTheme.secondaryColor : AppTheme.outlineVariantColor,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16.0),

          // Content column
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: AppTheme.bodyLg.copyWith(
                          color: isCompleted ? AppTheme.primaryColor : AppTheme.outlineColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (date.isNotEmpty)
                        Text(
                          date,
                          style: AppTheme.labelSm.copyWith(
                            color: stepColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    subtitle,
                    style: AppTheme.bodyMd.copyWith(color: AppTheme.outlineColor),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesCard(JobApplication app) {
    return Card(
      elevation: 0,
      color: const Color(0xFFFFF8E1), // gentle warm amber for message notifications
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFFFECB3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.feedback_outlined, color: Colors.amber),
                const SizedBox(width: 10),
                Text(
                  'Message from Hiring Coordinator',
                  style: AppTheme.titleMd.copyWith(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24, color: Color(0xFFFFECB3)),
            Text(
              app.notes,
              style: AppTheme.bodyLg.copyWith(color: AppTheme.primaryColor, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard() {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppTheme.outlineVariantColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 20,
              backgroundColor: AppTheme.surfaceContainerLow,
              child: Icon(Icons.headset_mic, color: AppTheme.primaryColor),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Need Help or Updates?',
                    style: AppTheme.bodyLg.copyWith(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Reach out to careers@maplehubrealty.com for assistance.',
                    style: AppTheme.bodyMd.copyWith(color: AppTheme.outlineColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
