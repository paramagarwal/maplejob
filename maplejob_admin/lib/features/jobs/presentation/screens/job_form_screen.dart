import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../app/config/theme.dart';
import '../../data/models/job_model.dart';
import '../providers/job_provider.dart';

class JobFormScreen extends ConsumerStatefulWidget {
  final String? jobId;
  const JobFormScreen({super.key, this.jobId});

  @override
  ConsumerState<JobFormScreen> createState() => _JobFormScreenState();
}

class _JobFormScreenState extends ConsumerState<JobFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _reqsCtrl = TextEditingController();
  final _benefitsCtrl = TextEditingController();
  final _deptCtrl = TextEditingController();
  final _catCtrl = TextEditingController();
  final _salaryCtrl = TextEditingController();
  final _expCtrl = TextEditingController();
  final _locCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _countryCtrl = TextEditingController();
  final _vacanciesCtrl = TextEditingController(text: '1');
  final _skillsCtrl = TextEditingController();
  final _minQualCtrl = TextEditingController();
  final _prefQualCtrl = TextEditingController();

  String _employmentType = 'Full-Time';
  String _workMode = 'On-site';
  DateTime? _deadline;
  bool _isActive = true;
  DateTime _createdAt = DateTime.now();

  bool _isInit = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      if (widget.jobId != null) {
        _loadJobDetails();
      } else {
        _isInit = true;
      }
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _reqsCtrl.dispose();
    _benefitsCtrl.dispose();
    _deptCtrl.dispose();
    _catCtrl.dispose();
    _salaryCtrl.dispose();
    _expCtrl.dispose();
    _locCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _countryCtrl.dispose();
    _vacanciesCtrl.dispose();
    _skillsCtrl.dispose();
    _minQualCtrl.dispose();
    _prefQualCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadJobDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final repo = ref.read(jobRepositoryProvider);
      final job = await repo.getJobById(widget.jobId!);
      if (job != null) {
        _titleCtrl.text = job.title;
        _descCtrl.text = job.description;
        _reqsCtrl.text = job.requirements;
        _benefitsCtrl.text = job.benefits;
        _deptCtrl.text = job.department;
        _catCtrl.text = job.category;
        _salaryCtrl.text = job.salary;
        _expCtrl.text = job.experience;
        _locCtrl.text = job.officeLocation;
        _cityCtrl.text = job.city;
        _stateCtrl.text = job.state;
        _countryCtrl.text = job.country;
        _vacanciesCtrl.text = job.vacancyCount.toString();
        _skillsCtrl.text = job.requiredSkills.join(', ');
        _minQualCtrl.text = job.minimumQualification;
        _prefQualCtrl.text = job.preferredQualification;
        _employmentType = job.employmentType;
        _workMode = job.workMode;
        _deadline = job.applicationDeadline;
        _isActive = job.isActive;
        _createdAt = job.createdAt;
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load job details: $e';
      });
    } finally {
      setState(() {
        _isInit = true;
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDeadline() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _deadline ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _deadline = picked;
      });
    }
  }

  Future<void> _saveJob() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final skillsList = _skillsCtrl.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final job = JobModel(
      id: widget.jobId ?? '',
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      requirements: _reqsCtrl.text.trim(),
      salary: _salaryCtrl.text.trim(),
      experience: _expCtrl.text.trim(),
      employmentType: _employmentType,
      vacancyCount: int.tryParse(_vacanciesCtrl.text.trim()) ?? 1,
      city: _cityCtrl.text.trim(),
      state: _stateCtrl.text.trim(),
      country: _countryCtrl.text.trim(),
      officeLocation: _locCtrl.text.trim(),
      workMode: _workMode,
      benefits: _benefitsCtrl.text.trim(),
      requiredSkills: skillsList,
      applicationDeadline: _deadline,
      minimumQualification: _minQualCtrl.text.trim(),
      preferredQualification: _prefQualCtrl.text.trim(),
      department: _deptCtrl.text.trim(),
      category: _catCtrl.text.trim(),
      createdAt: _createdAt,
      updatedAt: DateTime.now(),
      isActive: _isActive,
    );

    try {
      if (widget.jobId != null) {
        await ref.read(jobControllerProvider.notifier).update(job);
      } else {
        await ref.read(jobControllerProvider.notifier).create(job);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Job posting ${widget.jobId != null ? "updated" : "created"} successfully.')),
        );
        context.pop();
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInit) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final isEdit = widget.jobId != null;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Job Posting' : 'Post New Job'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
                side: const BorderSide(color: AppTheme.outlineVariantColor, width: 1.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12.0),
                          margin: const EdgeInsets.only(bottom: 24.0),
                          decoration: BoxDecoration(
                            color: AppTheme.rejectedBg,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Text(_errorMessage!, style: AppTheme.bodyMd.copyWith(color: AppTheme.rejectedText)),
                        ),
                      ],

                      // Job Title
                      Text('Job Title *', style: AppTheme.labelLg.copyWith(color: AppTheme.primaryColor)),
                      const SizedBox(height: 8.0),
                      TextFormField(
                        controller: _titleCtrl,
                        decoration: const InputDecoration(hintText: 'e.g. Senior Real Estate Investment Analyst'),
                        validator: (v) => v!.trim().isEmpty ? 'Job title is required.' : null,
                      ),
                      const SizedBox(height: 24.0),

                      // Description & Requirements Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text('Job Description *', style: AppTheme.labelLg.copyWith(color: AppTheme.primaryColor)),
                                const SizedBox(height: 8.0),
                                TextFormField(
                                  controller: _descCtrl,
                                  maxLines: 6,
                                  decoration: const InputDecoration(hintText: 'Provide a detailed overview of the role...'),
                                  validator: (v) => v!.trim().isEmpty ? 'Job description is required.' : null,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text('Job Requirements *', style: AppTheme.labelLg.copyWith(color: AppTheme.primaryColor)),
                                const SizedBox(height: 8.0),
                                TextFormField(
                                  controller: _reqsCtrl,
                                  maxLines: 6,
                                  decoration: const InputDecoration(hintText: 'Provide requirements and prerequisite experiences...'),
                                  validator: (v) => v!.trim().isEmpty ? 'Job requirements are required.' : null,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24.0),

                      // Department, Category, Salary & Vacancy Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text('Department *', style: AppTheme.labelLg.copyWith(color: AppTheme.primaryColor)),
                                const SizedBox(height: 8.0),
                                TextFormField(
                                  controller: _deptCtrl,
                                  decoration: const InputDecoration(hintText: 'e.g. Acquisitions & Finance'),
                                  validator: (v) => v!.trim().isEmpty ? 'Department is required.' : null,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text('Category *', style: AppTheme.labelLg.copyWith(color: AppTheme.primaryColor)),
                                const SizedBox(height: 8.0),
                                TextFormField(
                                  controller: _catCtrl,
                                  decoration: const InputDecoration(hintText: 'e.g. Asset Management'),
                                  validator: (v) => v!.trim().isEmpty ? 'Category is required.' : null,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text('Salary *', style: AppTheme.labelLg.copyWith(color: AppTheme.primaryColor)),
                                const SizedBox(height: 8.0),
                                TextFormField(
                                  controller: _salaryCtrl,
                                  decoration: const InputDecoration(hintText: 'e.g. \$90,000 - \$110,000 / yr'),
                                  validator: (v) => v!.trim().isEmpty ? 'Salary detail is required.' : null,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text('Vacancies *', style: AppTheme.labelLg.copyWith(color: AppTheme.primaryColor)),
                                const SizedBox(height: 8.0),
                                TextFormField(
                                  controller: _vacanciesCtrl,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(hintText: 'e.g. 1'),
                                  validator: (v) => int.tryParse(v ?? '') == null ? 'Must be a number.' : null,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24.0),

                      // Location Details Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text('Office Location *', style: AppTheme.labelLg.copyWith(color: AppTheme.primaryColor)),
                                const SizedBox(height: 8.0),
                                TextFormField(
                                  controller: _locCtrl,
                                  decoration: const InputDecoration(hintText: 'e.g. 120 Adelaide St W, Suite 200'),
                                  validator: (v) => v!.trim().isEmpty ? 'Office location is required.' : null,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text('City *', style: AppTheme.labelLg.copyWith(color: AppTheme.primaryColor)),
                                const SizedBox(height: 8.0),
                                TextFormField(
                                  controller: _cityCtrl,
                                  decoration: const InputDecoration(hintText: 'e.g. Toronto'),
                                  validator: (v) => v!.trim().isEmpty ? 'City is required.' : null,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text('State / Province *', style: AppTheme.labelLg.copyWith(color: AppTheme.primaryColor)),
                                const SizedBox(height: 8.0),
                                TextFormField(
                                  controller: _stateCtrl,
                                  decoration: const InputDecoration(hintText: 'e.g. Ontario'),
                                  validator: (v) => v!.trim().isEmpty ? 'State is required.' : null,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text('Country *', style: AppTheme.labelLg.copyWith(color: AppTheme.primaryColor)),
                                const SizedBox(height: 8.0),
                                TextFormField(
                                  controller: _countryCtrl,
                                  decoration: const InputDecoration(hintText: 'e.g. Canada'),
                                  validator: (v) => v!.trim().isEmpty ? 'Country is required.' : null,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24.0),

                      // Employment Type, Work Mode, Experience, Deadline Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text('Employment Type *', style: AppTheme.labelLg.copyWith(color: AppTheme.primaryColor)),
                                const SizedBox(height: 8.0),
                                DropdownButtonFormField<String>(
                                  initialValue: _employmentType,
                                  decoration: const InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  ),
                                  items: ['Full-Time', 'Part-Time', 'Contract', 'Internship']
                                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                                      .toList(),
                                  onChanged: (val) => setState(() => _employmentType = val!),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text('Work Mode *', style: AppTheme.labelLg.copyWith(color: AppTheme.primaryColor)),
                                const SizedBox(height: 8.0),
                                DropdownButtonFormField<String>(
                                  initialValue: _workMode,
                                  decoration: const InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  ),
                                  items: ['On-site', 'Hybrid', 'Remote']
                                      .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                                      .toList(),
                                  onChanged: (val) => setState(() => _workMode = val!),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text('Experience Required *', style: AppTheme.labelLg.copyWith(color: AppTheme.primaryColor)),
                                const SizedBox(height: 8.0),
                                TextFormField(
                                  controller: _expCtrl,
                                  decoration: const InputDecoration(hintText: 'e.g. 5+ years'),
                                  validator: (v) => v!.trim().isEmpty ? 'Experience field is required.' : null,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text('Application Deadline', style: AppTheme.labelLg.copyWith(color: AppTheme.primaryColor)),
                                const SizedBox(height: 8.0),
                                InkWell(
                                  onTap: _selectDeadline,
                                  child: InputDecorator(
                                    decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    ),
                                    child: Text(
                                      _deadline != null ? DateFormat('MM/dd/yyyy').format(_deadline!) : 'Select Date',
                                      style: TextStyle(color: _deadline != null ? AppTheme.primaryColor : AppTheme.outlineColor),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24.0),

                      // Qualifications Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text('Minimum Qualification *', style: AppTheme.labelLg.copyWith(color: AppTheme.primaryColor)),
                                const SizedBox(height: 8.0),
                                TextFormField(
                                  controller: _minQualCtrl,
                                  decoration: const InputDecoration(hintText: 'e.g. Bachelor\'s Degree in Business/Finance'),
                                  validator: (v) => v!.trim().isEmpty ? 'Minimum qualification is required.' : null,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text('Preferred Qualification', style: AppTheme.labelLg.copyWith(color: AppTheme.primaryColor)),
                                const SizedBox(height: 8.0),
                                TextFormField(
                                  controller: _prefQualCtrl,
                                  decoration: const InputDecoration(hintText: 'e.g. MBA, CFA Charterholder'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24.0),

                      // Benefits
                      Text('Benefits', style: AppTheme.labelLg.copyWith(color: AppTheme.primaryColor)),
                      const SizedBox(height: 8.0),
                      TextFormField(
                        controller: _benefitsCtrl,
                        maxLines: 3,
                        decoration: const InputDecoration(hintText: 'Provide list of benefits, e.g. Health Insurance, Paid Time Off, Retirement Match...'),
                      ),
                      const SizedBox(height: 24.0),

                      // Skills & Active toggle Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text('Required Skills (Comma separated) *', style: AppTheme.labelLg.copyWith(color: AppTheme.primaryColor)),
                                const SizedBox(height: 8.0),
                                TextFormField(
                                  controller: _skillsCtrl,
                                  decoration: const InputDecoration(hintText: 'e.g. Financial Modeling, Argus Enterprise, Due Diligence'),
                                  validator: (v) => v!.trim().isEmpty ? 'At least one skill is required.' : null,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 32.0),
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Status', style: AppTheme.labelLg.copyWith(color: AppTheme.primaryColor)),
                                const SizedBox(height: 12.0),
                                Row(
                                  children: [
                                    Switch(
                                      value: _isActive,
                                      onChanged: (v) => setState(() => _isActive = v),
                                      activeTrackColor: AppTheme.secondaryColor,
                                    ),
                                    const SizedBox(width: 8.0),
                                    Text(
                                      _isActive ? 'Active (Open)' : 'Closed',
                                      style: AppTheme.bodyMd.copyWith(
                                        color: AppTheme.primaryColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 48.0),

                      // Submit button
                      ElevatedButton(
                        onPressed: _isLoading ? null : _saveJob,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                              )
                            : Text(isEdit ? 'Save Changes' : 'Publish Job Posting'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
