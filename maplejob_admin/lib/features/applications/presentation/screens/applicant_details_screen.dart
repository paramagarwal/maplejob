import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../app/config/theme.dart';
import '../../../auth/data/models/user_model.dart';
import '../../domain/entities/job_application.dart';
import '../providers/application_provider.dart';

// Stream candidate profile details recursively from Firestore
final candidateProfileProvider = StreamProvider.family<UserModel?, String>((ref, uid) {
  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .snapshots()
      .map((doc) {
    if (doc.exists && doc.data() != null) {
      return UserModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  });
});

class ApplicantDetailsScreen extends ConsumerStatefulWidget {
  final String applicationId;
  const ApplicantDetailsScreen({super.key, required this.applicationId});

  @override
  ConsumerState<ApplicantDetailsScreen> createState() => _ApplicantDetailsScreenState();
}

class _ApplicantDetailsScreenState extends ConsumerState<ApplicantDetailsScreen> {
  final _notesController = TextEditingController();
  String _selectedStatus = 'Applied';
  bool _isSaving = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open link: $url')),
        );
      }
    }
  }

  Future<void> _saveChanges() async {
    setState(() {
      _isSaving = true;
    });

    try {
      await ref.read(applicationControllerProvider.notifier).updateStatus(
            widget.applicationId,
            _selectedStatus,
            notes: _notesController.text.trim(),
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Candidate evaluation updated successfully.')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final applicationsState = ref.watch(allApplicationsStreamProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Candidate Evaluation', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: applicationsState.when(
        data: (applications) {
          JobApplication? app;
          try {
            app = applications.firstWhere((a) => a.id == widget.applicationId);
          } catch (_) {
            app = null;
          }

          if (app == null) {
            return const Center(child: Text('Application not found.'));
          }

          // Initialize states on first run
          if (_notesController.text.isEmpty && app.notes.isNotEmpty) {
            _notesController.text = app.notes;
          }
          // Only override if not user-edited
          if (_selectedStatus == 'Applied' && app.status != 'Applied') {
            _selectedStatus = app.status;
          }

          final candidateProfileState = ref.watch(candidateProfileProvider(app.applicantId));

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left profile details column
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // General Overview Card
                      _buildProfileSummaryCard(app),
                      const SizedBox(height: 20),

                      // Complete profile details from /users collection
                      candidateProfileState.when(
                        data: (profile) {
                          if (profile == null) {
                            return _buildWarningCard('Detailed candidate profile is not completed yet.');
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildSkillsCard(profile),
                              const SizedBox(height: 20),
                              _buildEducationCard(profile),
                            ],
                          );
                        },
                        error: (err, _) => _buildWarningCard('Error loading candidate profile details.'),
                        loading: () => const Center(child: CircularProgressIndicator()),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),

                // Right action and feedback column
                Expanded(
                  flex: 4,
                  child: _buildActionFeedbackCard(app),
                ),
              ],
            ),
          );
        },
        error: (err, _) => Center(child: Text('Error: $err')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildProfileSummaryCard(JobApplication app) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppTheme.outlineVariantColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppTheme.surfaceContainer,
                  child: Text(
                    app.applicantName.substring(0, 1).toUpperCase(),
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        app.applicantName,
                        style: AppTheme.titleLg.copyWith(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Applying for: ${app.jobTitle} (${app.department})',
                        style: AppTheme.bodyMd.copyWith(color: AppTheme.outlineColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 32, color: AppTheme.outlineVariantColor),

            // Info rows
            _buildInfoRow(Icons.email_outlined, 'Email', app.applicantEmail),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.phone_outlined, 'Phone', app.applicantPhone),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.calendar_today_outlined, 'Applied At', DateFormat('MMM dd, yyyy').format(app.appliedAt)),
            const SizedBox(height: 24),

            // Resume File Link
            if (app.resumeUrl.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: AppTheme.outlineVariantColor),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.picture_as_pdf, color: AppTheme.rejectedText, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            app.resumeName,
                            style: AppTheme.bodyMd.copyWith(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text('Candidate PDF resume attachment', style: AppTheme.labelSm.copyWith(color: AppTheme.outlineColor)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                     ElevatedButton.icon(
                       onPressed: () => _launchUrl(app.resumeUrl),
                       icon: const Icon(Icons.download, size: 16),
                       label: const Text('View PDF'),
                       style: ElevatedButton.styleFrom(
                         backgroundColor: AppTheme.secondaryColor,
                         foregroundColor: Colors.white,
                       ),
                     ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.outlineColor),
        const SizedBox(width: 12),
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w500, color: AppTheme.outlineColor)),
        Expanded(child: Text(value, style: const TextStyle(color: AppTheme.primaryColor))),
      ],
    );
  }

  Widget _buildWarningCard(String msg) {
    return Card(
      elevation: 0,
      color: const Color(0xFFFFF8E1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFFFECB3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.amber),
            const SizedBox(width: 12),
            Text(msg, style: const TextStyle(color: AppTheme.primaryColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillsCard(UserModel profile) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppTheme.outlineVariantColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Professional Skills', style: AppTheme.titleLg.copyWith(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
            const Divider(height: 24, color: AppTheme.outlineVariantColor),
            if (profile.skills.isEmpty)
              Text('No skills listed.', style: TextStyle(color: AppTheme.outlineColor))
            else
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: profile.skills.map((skill) {
                  return Chip(
                    label: Text(skill, style: AppTheme.labelSm.copyWith(color: AppTheme.primaryColor)),
                    backgroundColor: AppTheme.surfaceContainerLow,
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEducationCard(UserModel profile) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppTheme.outlineVariantColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Education Timeline', style: AppTheme.titleLg.copyWith(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
            const Divider(height: 24, color: AppTheme.outlineVariantColor),
            if (profile.education.isEmpty)
              Text('No education listed.', style: TextStyle(color: AppTheme.outlineColor))
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: profile.education.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final edu = profile.education[index];
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.school, color: AppTheme.secondaryColor, size: 20),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${edu.degree} in ${edu.fieldOfStudy}',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                            ),
                             Text(edu.school, style: const TextStyle(color: AppTheme.outlineColor)),
                            Text(
                              '${edu.startYear} - ${edu.endYear}',
                              style: AppTheme.labelSm.copyWith(color: AppTheme.secondaryColor, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionFeedbackCard(JobApplication app) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppTheme.outlineVariantColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Application Stage & Notes',
              style: AppTheme.titleLg.copyWith(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 24, color: AppTheme.outlineVariantColor),

            // Dropdown selection
            const Text('Transition Pipeline Stage', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.outlineColor)),
            const SizedBox(height: 8),
             DropdownButtonFormField<String>(
               initialValue: _selectedStatus,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              items: ['Applied', 'Shortlisted', 'Interview', 'Offered', 'Rejected'].map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(status),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedStatus = val);
                }
              },
            ),
            const SizedBox(height: 24),

            // Screening notes text field
            const Text('Hiring Feedback / Interview Notes', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.outlineColor)),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: 'Enter screening notes, interview schedules, test scores, or offer particulars...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 32),

            // Submit actions
            ElevatedButton(
              onPressed: _isSaving ? null : _saveChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.secondaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Save Evaluation Changes', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
