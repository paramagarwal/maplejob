import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/config/theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/job_provider.dart';
import '../../../notifications/presentation/providers/notifications_provider.dart';

class JobsListScreen extends ConsumerStatefulWidget {
  const JobsListScreen({super.key});

  @override
  ConsumerState<JobsListScreen> createState() => _JobsListScreenState();
}

class _JobsListScreenState extends ConsumerState<JobsListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';

  // Filters state
  String _selectedEmploymentType = 'All';
  String _selectedWorkMode = 'All';
  String _selectedExperience = 'All';
  String _selectedSalaryRange = 'All';
  bool _showSavedOnly = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int? _parseSalary(String salaryStr) {
    try {
      final parts = salaryStr.split('-');
      final firstPart = parts[0].replaceAll(RegExp(r'[^\d]'), '');
      if (firstPart.isEmpty) return null;
      return int.tryParse(firstPart);
    } catch (_) {
      return null;
    }
  }

  Future<void> _toggleSaveJob(String jobId, bool isSaved) async {
    final authUser = ref.read(authControllerProvider).value;
    if (authUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to save jobs.')),
      );
      return;
    }

    try {
      if (isSaved) {
        await ref.read(unsaveJobUseCaseProvider).call(authUser.uid, jobId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Job removed from saved list.')),
          );
        }
      } else {
        await ref.read(saveJobUseCaseProvider).call(authUser.uid, jobId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Job saved successfully.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update saved job: $e')),
        );
      }
    }
  }

  void _showFiltersBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(24.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Filters', style: AppTheme.titleLg.copyWith(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                        TextButton(
                          onPressed: () {
                            setModalState(() {
                              _selectedEmploymentType = 'All';
                              _selectedWorkMode = 'All';
                              _selectedExperience = 'All';
                              _selectedSalaryRange = 'All';
                              _showSavedOnly = false;
                            });
                          },
                          child: const Text('Reset All', style: TextStyle(color: AppTheme.secondaryColor)),
                        ),
                      ],
                    ),
                    const Divider(height: 24),

                    // Job Type
                    Text('Job Type', style: AppTheme.labelLg.copyWith(color: AppTheme.primaryColor)),
                    const SizedBox(height: 8.0),
                    Wrap(
                      spacing: 8.0,
                      children: ['All', 'Full-Time', 'Part-Time', 'Contract', 'Internship'].map((type) {
                        final isSel = _selectedEmploymentType == type;
                        return ChoiceChip(
                          label: Text(type),
                          selected: isSel,
                          onSelected: (val) {
                            if (val) {
                              setModalState(() => _selectedEmploymentType = type);
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16.0),

                    // Work Mode
                    Text('Work Mode', style: AppTheme.labelLg.copyWith(color: AppTheme.primaryColor)),
                    const SizedBox(height: 8.0),
                    Wrap(
                      spacing: 8.0,
                      children: ['All', 'On-site', 'Hybrid', 'Remote'].map((mode) {
                        final isSel = _selectedWorkMode == mode;
                        return ChoiceChip(
                          label: Text(mode),
                          selected: isSel,
                          onSelected: (val) {
                            if (val) {
                              setModalState(() => _selectedWorkMode = mode);
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16.0),

                    // Experience level
                    Text('Experience Level', style: AppTheme.labelLg.copyWith(color: AppTheme.primaryColor)),
                    const SizedBox(height: 8.0),
                    Wrap(
                      spacing: 8.0,
                      children: ['All', 'Entry-level', 'Mid-level', 'Senior'].map((exp) {
                        final isSel = _selectedExperience == exp;
                        return ChoiceChip(
                          label: Text(exp),
                          selected: isSel,
                          onSelected: (val) {
                            if (val) {
                              setModalState(() => _selectedExperience = exp);
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16.0),

                    // Salary Range
                    Text('Salary Range', style: AppTheme.labelLg.copyWith(color: AppTheme.primaryColor)),
                    const SizedBox(height: 8.0),
                    Wrap(
                      spacing: 8.0,
                      children: ['All', 'Under \$50k', '\$50k - \$100k', '\$100k - \$150k', 'Over \$150k'].map((sal) {
                        final isSel = _selectedSalaryRange == sal;
                        return ChoiceChip(
                          label: Text(sal),
                          selected: isSel,
                          onSelected: (val) {
                            if (val) {
                              setModalState(() => _selectedSalaryRange = sal);
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16.0),

                    // Saved Only Switch
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Show Saved Only', style: AppTheme.labelLg.copyWith(color: AppTheme.primaryColor)),
                        Switch(
                          value: _showSavedOnly,
                          onChanged: (val) {
                            setModalState(() => _showSavedOnly = val);
                          },
                          activeThumbColor: AppTheme.secondaryColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32.0),

                    ElevatedButton(
                      onPressed: () {
                        setState(() {}); // trigger refresh of list
                        Navigator.pop(context);
                      },
                      child: const Text('Apply Filters'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final jobsState = ref.watch(jobsStreamProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Explore Jobs', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          ref.watch(unreadNotificationsCountProvider) > 0
              ? Badge(
                  label: Text(ref.watch(unreadNotificationsCountProvider).toString()),
                  offset: const Offset(-4, 4),
                  child: IconButton(
                    icon: const Icon(Icons.notifications_none),
                    onPressed: () => context.push('/notifications'),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.notifications_none),
                  onPressed: () => context.push('/notifications'),
                ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () => context.push('/profile'),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: jobsState.when(
        data: (jobs) {
          // Extract categories dynamically
          final categories = {'All', ...jobs.map((j) => j.category)};

          // Filter jobs
          final filtered = jobs.where((job) {
            if (!job.isActive) return false; // applicants only see open jobs
            
            final query = _searchQuery.toLowerCase();
            final matchesQuery = job.title.toLowerCase().contains(query) ||
                job.description.toLowerCase().contains(query) ||
                job.requiredSkills.any((s) => s.toLowerCase().contains(query));

            final matchesCat = _selectedCategory == 'All' || job.category == _selectedCategory;
            final matchesType = _selectedEmploymentType == 'All' || job.employmentType == _selectedEmploymentType;
            final matchesMode = _selectedWorkMode == 'All' || job.workMode == _selectedWorkMode;
            
            // Experience match helper
            bool matchesExp = true;
            if (_selectedExperience != 'All') {
              final expLower = job.experience.toLowerCase();
              if (_selectedExperience == 'Entry-level') {
                matchesExp = expLower.contains('entry') || expLower.contains('1-2') || expLower.contains('0-2');
              } else if (_selectedExperience == 'Mid-level') {
                matchesExp = expLower.contains('mid') || expLower.contains('3-5') || expLower.contains('2-5');
              } else if (_selectedExperience == 'Senior') {
                matchesExp = expLower.contains('senior') || expLower.contains('5+') || expLower.contains('8+') || expLower.contains('lead');
              }
            }

            // Saved Only match helper
            bool matchesSaved = true;
            if (_showSavedOnly) {
              final savedIds = ref.watch(savedJobIdsStreamProvider).value ?? [];
              matchesSaved = savedIds.contains(job.id);
            }

            // Salary match helper
            bool matchesSalary = true;
            if (_selectedSalaryRange != 'All') {
              final parsedVal = _parseSalary(job.salary);
              if (parsedVal != null) {
                if (_selectedSalaryRange == 'Under \$50k') {
                  matchesSalary = parsedVal < 50000;
                } else if (_selectedSalaryRange == '\$50k - \$100k') {
                  matchesSalary = parsedVal >= 50000 && parsedVal <= 100000;
                } else if (_selectedSalaryRange == '\$100k - \$150k') {
                  matchesSalary = parsedVal >= 100000 && parsedVal <= 150000;
                } else if (_selectedSalaryRange == 'Over \$150k') {
                  matchesSalary = parsedVal > 150000;
                }
              } else {
                matchesSalary = false;
              }
            }

            return matchesQuery && matchesCat && matchesType && matchesMode && matchesExp && matchesSaved && matchesSalary;
          }).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Search & Filter Header Section
              Container(
                color: AppTheme.primaryColor,
                padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 24.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) => setState(() => _searchQuery = val),
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Search jobs, skills, keywords...',
                          hintStyle: const TextStyle(color: Color.fromRGBO(255, 255, 255, 0.5)),
                          prefixIcon: const Icon(Icons.search, color: Colors.white70),
                          filled: true,
                          fillColor: const Color.fromRGBO(255, 255, 255, 0.08),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppTheme.secondaryColor, width: 1.5),
                          ),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, color: Colors.white),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                )
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    InkWell(
                      onTap: _showFiltersBottomSheet,
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.secondaryColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.tune, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),

              // Category Pills Section
              Container(
                height: 56,
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: categories.map((cat) {
                    final isSel = _selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(cat),
                        selected: isSel,
                        onSelected: (val) {
                          if (val) {
                            setState(() => _selectedCategory = cat);
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),

              // JobList count header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${filtered.length} Job${filtered.length == 1 ? "" : "s"} Found',
                      style: AppTheme.labelLg.copyWith(color: AppTheme.outlineColor, fontWeight: FontWeight.bold),
                    ),
                    if (_selectedEmploymentType != 'All' ||
                        _selectedWorkMode != 'All' ||
                        _selectedExperience != 'All' ||
                        _selectedSalaryRange != 'All' ||
                        _showSavedOnly)
                      Text(
                        'Filters Active',
                        style: AppTheme.labelSm.copyWith(color: AppTheme.secondaryColor, fontWeight: FontWeight.bold),
                      ),
                  ],
                ),
              ),

              // Listings
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(40.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.work_off_outlined, size: 64, color: AppTheme.outlineColor),
                              const SizedBox(height: 16.0),
                              Text(
                                'No jobs found matching your criteria.',
                                style: AppTheme.bodyLg.copyWith(color: AppTheme.outlineColor),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final job = filtered[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16.0),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              side: const BorderSide(color: AppTheme.outlineVariantColor, width: 1.0),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              onTap: () => context.push('/job/${job.id}'),
                              child: Padding(
                                padding: const EdgeInsets.all(18.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                job.title,
                                                style: AppTheme.titleMd.copyWith(
                                                  color: AppTheme.primaryColor,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                job.department,
                                                style: AppTheme.bodyMd.copyWith(color: AppTheme.outlineColor),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            ref.watch(savedJobIdsStreamProvider).when(
                                                  data: (savedIds) {
                                                    final isSaved = savedIds.contains(job.id);
                                                    return IconButton(
                                                      icon: Icon(
                                                        isSaved ? Icons.bookmark : Icons.bookmark_border,
                                                        color: isSaved ? AppTheme.secondaryColor : AppTheme.outlineColor,
                                                      ),
                                                      onPressed: () => _toggleSaveJob(job.id, isSaved),
                                                    );
                                                  },
                                                  loading: () => const SizedBox(
                                                    width: 24,
                                                    height: 24,
                                                    child: CircularProgressIndicator(strokeWidth: 2),
                                                  ),
                                                  error: (e, s) => const SizedBox(),
                                                ),
                                            const Icon(Icons.chevron_right, color: AppTheme.outlineColor),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12.0),
                                    Row(
                                      children: [
                                        const Icon(Icons.location_on_outlined, size: 16, color: AppTheme.outlineColor),
                                        const SizedBox(width: 4.0),
                                        Text(
                                          '${job.city}, ${job.country}',
                                          style: AppTheme.labelSm.copyWith(color: AppTheme.outlineColor),
                                        ),
                                        const SizedBox(width: 16.0),
                                        const Icon(Icons.work_outline, size: 16, color: AppTheme.outlineColor),
                                        const SizedBox(width: 4.0),
                                        Text(
                                          job.employmentType,
                                          style: AppTheme.labelSm.copyWith(color: AppTheme.outlineColor),
                                        ),
                                      ],
                                    ),
                                    const Divider(height: 24, color: AppTheme.outlineVariantColor),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          job.salary,
                                          style: AppTheme.bodyMd.copyWith(
                                            color: AppTheme.secondaryColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: AppTheme.surfaceContainerLow,
                                            borderRadius: BorderRadius.circular(6.0),
                                          ),
                                          child: Text(
                                            job.workMode,
                                            style: AppTheme.labelSm.copyWith(
                                              color: AppTheme.primaryColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
        error: (err, _) => Center(child: Text('Error loading jobs: $err')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
