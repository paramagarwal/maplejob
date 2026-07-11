import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../app/config/theme.dart';
import '../../../../app/widgets/responsive_admin_layout.dart';
import '../providers/application_provider.dart';

class ApplicantsListScreen extends ConsumerStatefulWidget {
  const ApplicantsListScreen({super.key});

  @override
  ConsumerState<ApplicantsListScreen> createState() => _ApplicantsListScreenState();
}

class _ApplicantsListScreenState extends ConsumerState<ApplicantsListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedStatus = 'All';
  String _selectedJobTitle = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final applicationsState = ref.watch(allApplicationsStreamProvider);

    return ResponsiveAdminLayout(
      activeRoute: '/applicants',
      appBar: AppBar(
        title: const Text('Applicant Tracking', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: applicationsState.when(
        data: (applications) {
          // Extract dynamic list of unique job titles for filtering
          final jobTitles = {'All', ...applications.map((a) => a.jobTitle)};

          // Filter logic
          final filtered = applications.where((app) {
            final query = _searchQuery.toLowerCase();
            final matchesQuery = app.applicantName.toLowerCase().contains(query) ||
                app.applicantEmail.toLowerCase().contains(query) ||
                app.jobTitle.toLowerCase().contains(query);

            final matchesStatus = _selectedStatus == 'All' || app.status == _selectedStatus;
            final matchesJob = _selectedJobTitle == 'All' || app.jobTitle == _selectedJobTitle;

            return matchesQuery && matchesStatus && matchesJob;
          }).toList();

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Filter bar card
                Card(
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: AppTheme.outlineVariantColor),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        // Search field
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller: _searchController,
                            onChanged: (val) => setState(() => _searchQuery = val),
                            decoration: InputDecoration(
                              hintText: 'Search by candidate, job...',
                              prefixIcon: const Icon(Icons.search, color: AppTheme.outlineColor),
                              isDense: true,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16.0),

                        // Job Title dropdown
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedJobTitle,
                            isExpanded: true,
                            decoration: InputDecoration(
                              labelText: 'Position',
                              isDense: true,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            items: jobTitles.map((title) {
                              return DropdownMenuItem(
                                value: title,
                                child: Text(title, overflow: TextOverflow.ellipsis),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _selectedJobTitle = val);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 16.0),

                        // Status dropdown
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedStatus,
                            decoration: InputDecoration(
                              labelText: 'Pipeline Stage',
                              isDense: true,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            items: ['All', 'Applied', 'Shortlisted', 'Interview', 'Offered', 'Rejected'].map((status) {
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
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24.0),

                // Table results card
                Expanded(
                  child: Card(
                    elevation: 0,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: AppTheme.outlineVariantColor),
                    ),
                    child: filtered.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(42.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.people_outline, size: 64, color: AppTheme.outlineColor),
                                  const SizedBox(height: 16.0),
                                  Text(
                                    'No job applications found matching your criteria.',
                                    style: AppTheme.bodyLg.copyWith(color: AppTheme.outlineColor),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          )
                        : SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: DataTable(
                                columns: const [
                                  DataColumn(label: Text('Candidate')),
                                  DataColumn(label: Text('Job Posting')),
                                  DataColumn(label: Text('Applied Date')),
                                  DataColumn(label: Text('Pipeline Stage')),
                                  DataColumn(label: Text('Actions')),
                                ],
                                rows: filtered.map((app) {
                                  final appliedDate = DateFormat('MMM dd, yyyy').format(app.appliedAt);

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

                                  return DataRow(
                                    cells: [
                                      DataCell(
                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                app.applicantName,
                                                style: const TextStyle(fontWeight: FontWeight.bold),
                                              ),
                                              Text(
                                                app.applicantEmail,
                                                style: AppTheme.labelSm.copyWith(color: AppTheme.outlineColor),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(app.jobTitle, style: const TextStyle(fontWeight: FontWeight.w500)),
                                              Text(
                                                app.department,
                                                style: AppTheme.labelSm.copyWith(color: AppTheme.outlineColor),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      DataCell(Text(appliedDate)),
                                      DataCell(
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: statusBg,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            app.status,
                                            style: AppTheme.labelSm.copyWith(
                                              color: statusColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        ElevatedButton(
                                          onPressed: () => context.push('/applicants/${app.id}'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppTheme.secondaryColor,
                                            foregroundColor: Colors.white,
                                          ),
                                          child: const Text('Review'),
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                  ),
                ),
              ],
            ),
          );
        },
        error: (err, _) => Center(child: Text('Error loading applicants: $err')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
