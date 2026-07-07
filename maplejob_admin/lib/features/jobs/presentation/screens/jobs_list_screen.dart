import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/config/theme.dart';
import '../../domain/entities/job_entity.dart';
import '../providers/job_provider.dart';
import '../../../../app/widgets/admin_drawer.dart';

class JobsListScreen extends ConsumerStatefulWidget {
  const JobsListScreen({super.key});

  @override
  ConsumerState<JobsListScreen> createState() => _JobsListScreenState();
}

class _JobsListScreenState extends ConsumerState<JobsListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _toggleJobStatus(JobEntity job) async {
    final updated = (job as dynamic).copyWith(isActive: !job.isActive);
    try {
      await ref.read(jobControllerProvider.notifier).update(updated);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Job status set to ${!job.isActive ? "Active" : "Closed"}.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update job status: $e')),
        );
      }
    }
  }

  Future<void> _deleteJob(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Job Posting'),
          content: const Text('Are you sure you want to permanently delete this job listing? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor, foregroundColor: Colors.white),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        await ref.read(jobControllerProvider.notifier).delete(id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Job posting deleted successfully.')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete job posting: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final jobsState = ref.watch(jobsStreamProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      drawer: const AdminDrawer(activeRoute: '/jobs'),
      appBar: AppBar(
        title: const Text('Job Management', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          ElevatedButton.icon(
            onPressed: () => context.push('/jobs/create'),
            icon: const Icon(Icons.add),
            label: const Text('Post New Job'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.secondaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(width: 24.0),
        ],
      ),
      body: jobsState.when(
        data: (jobs) {
          final filtered = jobs.where((job) {
            final query = _searchQuery.toLowerCase();
            return job.title.toLowerCase().contains(query) ||
                job.department.toLowerCase().contains(query) ||
                job.category.toLowerCase().contains(query);
          }).toList();

          return Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Search / Filter Row
                Row(
                  children: [
                    SizedBox(
                      width: 400,
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) => setState(() => _searchQuery = val),
                        decoration: InputDecoration(
                          hintText: 'Search jobs by title, department or category...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                )
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24.0),

                // Table Card
                Expanded(
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      side: const BorderSide(color: AppTheme.outlineVariantColor, width: 1.0),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: filtered.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(40.0),
                              child: Text(
                                _searchQuery.isNotEmpty ? 'No jobs match your search query.' : 'No job postings created yet.',
                                style: AppTheme.bodyLg.copyWith(color: AppTheme.outlineColor),
                              ),
                            ),
                          )
                        : ListView.separated(
                            itemCount: filtered.length,
                            separatorBuilder: (context, index) => const Divider(height: 1, color: AppTheme.outlineVariantColor),
                            itemBuilder: (context, index) {
                              final job = filtered[index];
                              return Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Row(
                                  children: [
                                    // Info Section
                                    Expanded(
                                      flex: 4,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            job.title,
                                            style: AppTheme.titleMd.copyWith(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 4.0),
                                          Row(
                                            children: [
                                              _buildBadge(job.department, AppTheme.surfaceContainerLow, AppTheme.primaryColor),
                                              const SizedBox(width: 8.0),
                                              _buildBadge(job.workMode, AppTheme.surfaceContainerHigh, AppTheme.secondaryColor),
                                              const SizedBox(width: 8.0),
                                              Text(
                                                '${job.city}, ${job.country}',
                                                style: AppTheme.labelSm.copyWith(color: AppTheme.outlineColor),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Vacancy / Salary Section
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Salary & Vacancies', style: AppTheme.labelSm.copyWith(color: AppTheme.outlineColor)),
                                          const SizedBox(height: 4.0),
                                          Text(
                                            job.salary,
                                            style: AppTheme.bodyMd.copyWith(color: AppTheme.primaryColor, fontWeight: FontWeight.w500),
                                          ),
                                          Text(
                                            '${job.vacancyCount} ${job.vacancyCount == 1 ? "vacancy" : "vacancies"}',
                                            style: AppTheme.labelSm.copyWith(color: AppTheme.outlineColor),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Status Badge Section
                                    Expanded(
                                      flex: 2,
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: job.isActive ? AppTheme.appliedBg : AppTheme.rejectedBg,
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              job.isActive ? 'Active' : 'Closed',
                                              style: AppTheme.labelSm.copyWith(
                                                color: job.isActive ? AppTheme.appliedText : AppTheme.rejectedText,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8.0),
                                          Switch(
                                            value: job.isActive,
                                            onChanged: (_) => _toggleJobStatus(job),
                                            activeTrackColor: AppTheme.secondaryColor,
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Actions Section
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit_outlined, color: AppTheme.primaryColor),
                                          tooltip: 'Edit Job details',
                                          onPressed: () => context.push('/jobs/edit/${job.id}'),
                                        ),
                                        const SizedBox(width: 8.0),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline, color: AppTheme.errorColor),
                                          tooltip: 'Delete Job posting',
                                          onPressed: () => _deleteJob(job.id),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
          );
        },
        error: (err, _) => Center(child: Text('Error loading jobs: $err')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildBadge(String label, Color bg, Color textCol) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6.0),
      ),
      child: Text(
        label,
        style: AppTheme.labelSm.copyWith(color: textCol, fontWeight: FontWeight.bold),
      ),
    );
  }
}
