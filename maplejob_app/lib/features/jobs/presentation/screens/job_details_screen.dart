import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../app/config/theme.dart';
import '../../domain/entities/job_entity.dart';
import '../providers/job_provider.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../../../../app/services/analytics_service.dart';
import '../../../applications/presentation/providers/application_provider.dart';
import '../../../applications/domain/entities/job_application.dart';

class JobDetailsScreen extends ConsumerStatefulWidget {
  final String jobId;
  const JobDetailsScreen({super.key, required this.jobId});

  @override
  ConsumerState<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends ConsumerState<JobDetailsScreen> {
  bool _isLoading = false;
  JobEntity? _job;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadJobDetails();
  }

  Future<void> _loadJobDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repo = ref.read(jobRepositoryProvider);
      final job = await repo.getJobById(widget.jobId);
      if (job != null) {
        AnalyticsService().logJobView(job.id, job.title);
      }
      if (mounted) {
        setState(() {
          _job = job;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _applyForJob() async {
    final profile = ref.read(profileNotifierProvider).value;
    if (profile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to apply for this job.')),
      );
      return;
    }

    // Check if resume is uploaded
    final hasResume = profile.resumeUrl?.isNotEmpty == true;
    if (!hasResume) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Resume Required', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
            content: const Text('You must upload a PDF resume to your profile before applying to job positions.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.push('/profile/edit');
                },
                child: const Text('Go to Profile'),
              ),
            ],
          );
        },
      );
      return;
    }

    // Profile completion requirements check (e.g. must be >= 50% or have phone/email filled)
    if (profile.fullName.isEmpty || profile.phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete your full name and phone number in your profile before applying.')),
      );
      context.push('/profile/edit');
      return;
    }

    // Submit immediate application flow (will be wired up to Application repository in Phase 7)
    setState(() {
      _isLoading = true;
    });

    try {
      final appRepo = ref.read(applicationRepositoryProvider);
      await appRepo.submitApplication(
        JobApplication(
          id: '',
          jobId: _job!.id,
          jobTitle: _job!.title,
          department: _job!.department,
          applicantId: profile.uid,
          applicantName: profile.fullName,
          applicantEmail: profile.email,
          applicantPhone: profile.phone,
          resumeUrl: profile.resumeUrl ?? '',
          resumeName: profile.resumeName ?? '',
          status: 'Applied',
          appliedAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      // Log Analytics Event
      await AnalyticsService().logApplicationSubmitted(
        _job!.id,
        _job!.title,
        _job!.department,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Application to ${_job!.title} submitted successfully!')),
        );
        context.push('/success');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit application: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _job == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Job Details')),
        body: Center(child: Text('Error: $_errorMessage')),
      );
    }

    if (_job == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Job Details')),
        body: const Center(child: Text('Job not found.')),
      );
    }

    final deadlineStr = _job!.applicationDeadline != null
        ? DateFormat('MMMM dd, yyyy').format(_job!.applicationDeadline!)
        : 'Open';

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(_job!.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero Card
            _buildHeroCard(),
            const SizedBox(height: 20.0),

            // Main Details Row/Column
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 750) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 6,
                        child: _buildMainDetailsColumn(),
                      ),
                      const SizedBox(width: 20.0),
                      Expanded(
                        flex: 4,
                        child: _buildSideOverviewColumn(deadlineStr),
                      ),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      _buildMainDetailsColumn(),
                      const SizedBox(height: 20.0),
                      _buildSideOverviewColumn(deadlineStr),
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 32.0),

            // Apply Button
            ElevatedButton(
              onPressed: _isLoading ? null : _applyForJob,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                    )
                  : const Text('Submit Application'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard() {
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _job!.department,
                    style: AppTheme.labelSm.copyWith(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8.0),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _job!.workMode,
                    style: AppTheme.labelSm.copyWith(color: AppTheme.secondaryColor, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Text(
              _job!.title,
              style: AppTheme.headlineLgMobile.copyWith(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 18, color: AppTheme.outlineColor),
                const SizedBox(width: 4.0),
                Text(
                  '${_job!.city}, ${_job!.country}',
                  style: AppTheme.bodyMd.copyWith(color: AppTheme.outlineColor),
                ),
                const SizedBox(width: 20.0),
                const Icon(Icons.monetization_on_outlined, size: 18, color: AppTheme.outlineColor),
                const SizedBox(width: 4.0),
                Text(
                  _job!.salary,
                  style: AppTheme.bodyMd.copyWith(color: AppTheme.outlineColor, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainDetailsColumn() {
    return Column(
      children: [
        _buildContentCard('Job Description', _job!.description, Icons.description_outlined),
        const SizedBox(height: 20.0),
        _buildContentCard('Prerequisites & Requirements', _job!.requirements, Icons.list_alt_outlined),
        const SizedBox(height: 20.0),
        _buildContentCard('Benefits & Perks', _job!.benefits.isNotEmpty ? _job!.benefits : 'Competitive compensation package.', Icons.star_border),
      ],
    );
  }

  Widget _buildContentCard(String title, String content, IconData icon) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppTheme.outlineVariantColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppTheme.secondaryColor),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: AppTheme.titleMd.copyWith(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24, color: AppTheme.outlineVariantColor),
            Text(
              content,
              style: AppTheme.bodyLg.copyWith(color: AppTheme.primaryColor, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSideOverviewColumn(String deadlineStr) {
    return Column(
      children: [
        // Job Summary Card
        Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppTheme.outlineVariantColor),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Job Overview',
                  style: AppTheme.titleMd.copyWith(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                ),
                const Divider(height: 24, color: AppTheme.outlineVariantColor),
                _buildOverviewRow('Employment Type', _job!.employmentType, Icons.work_outline),
                const SizedBox(height: 16),
                _buildOverviewRow('Experience Required', _job!.experience, Icons.timeline_outlined),
                const SizedBox(height: 16),
                _buildOverviewRow('Min Qualification', _job!.minimumQualification, Icons.school_outlined),
                const SizedBox(height: 16),
                _buildOverviewRow('Deadline', deadlineStr, Icons.calendar_today_outlined),
                const SizedBox(height: 16),
                _buildOverviewRow('Office Address', _job!.officeLocation, Icons.location_city_outlined),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20.0),

        // Required Skills Card
        Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppTheme.outlineVariantColor),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Required Skills',
                  style: AppTheme.titleMd.copyWith(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                ),
                const Divider(height: 24, color: AppTheme.outlineVariantColor),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: _job!.requiredSkills.map((skill) {
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
        ),
      ],
    );
  }

  Widget _buildOverviewRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppTheme.secondaryColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTheme.labelSm.copyWith(color: AppTheme.outlineColor)),
              const SizedBox(height: 2.0),
              Text(
                value,
                style: AppTheme.bodyMd.copyWith(color: AppTheme.primaryColor, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
