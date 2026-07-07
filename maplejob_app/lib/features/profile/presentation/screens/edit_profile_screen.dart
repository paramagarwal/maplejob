import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../app/config/theme.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/domain/entities/education_item.dart';
import '../providers/profile_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _fullNameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _linkedinController;
  late TextEditingController _skillInputController;

  DateTime? _dob;
  String? _gender;
  List<String> _skills = [];
  List<EducationItem> _education = [];

  bool _isInit = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      final profileState = ref.watch(profileNotifierProvider);
      profileState.whenData((user) {
        if (user != null) {
          _fullNameController = TextEditingController(text: user.fullName);
          _phoneController = TextEditingController(text: user.phone);
          _addressController = TextEditingController(text: user.address ?? '');
          _linkedinController = TextEditingController(text: user.linkedinUrl ?? '');
          _skillInputController = TextEditingController();
          _dob = user.dob;
          _gender = user.gender;
          _skills = List.from(user.skills);
          _education = List.from(user.education);
          _isInit = true;
        }
      });
    }
  }

  @override
  void dispose() {
    if (_isInit) {
      _fullNameController.dispose();
      _phoneController.dispose();
      _addressController.dispose();
      _linkedinController.dispose();
      _skillInputController.dispose();
    }
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              onSurface: AppTheme.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _dob) {
      setState(() {
        _dob = picked;
      });
    }
  }

  void _addSkill() {
    final skill = _skillInputController.text.trim();
    if (skill.isNotEmpty && !_skills.contains(skill)) {
      setState(() {
        _skills.add(skill);
        _skillInputController.clear();
      });
    }
  }

  void _removeSkill(String skill) {
    setState(() {
      _skills.remove(skill);
    });
  }

  void _showAddEducationDialog() {
    final schoolCtrl = TextEditingController();
    final degreeCtrl = TextEditingController();
    final fieldCtrl = TextEditingController();
    final startYearCtrl = TextEditingController();
    final endYearCtrl = TextEditingController();
    final dialogKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Education Entry', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
          content: Form(
            key: dialogKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: schoolCtrl,
                    decoration: const InputDecoration(labelText: 'School / University', prefixIcon: Icon(Icons.school)),
                    validator: (v) => v!.isEmpty ? 'Field is required' : null,
                  ),
                  const SizedBox(height: 12.0),
                  TextFormField(
                    controller: degreeCtrl,
                    decoration: const InputDecoration(labelText: 'Degree / Certificate', prefixIcon: Icon(Icons.workspace_premium)),
                    validator: (v) => v!.isEmpty ? 'Field is required' : null,
                  ),
                  const SizedBox(height: 12.0),
                  TextFormField(
                    controller: fieldCtrl,
                    decoration: const InputDecoration(labelText: 'Field of Study', prefixIcon: Icon(Icons.book)),
                    validator: (v) => v!.isEmpty ? 'Field is required' : null,
                  ),
                  const SizedBox(height: 12.0),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: startYearCtrl,
                          decoration: const InputDecoration(labelText: 'Start Year'),
                          keyboardType: TextInputType.number,
                          validator: (v) => int.tryParse(v ?? '') == null ? 'Invalid year' : null,
                        ),
                      ),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: TextFormField(
                          controller: endYearCtrl,
                          decoration: const InputDecoration(labelText: 'End Year'),
                          keyboardType: TextInputType.number,
                          validator: (v) => int.tryParse(v ?? '') == null ? 'Invalid year' : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (dialogKey.currentState!.validate()) {
                  final entry = EducationItem(
                    school: schoolCtrl.text.trim(),
                    degree: degreeCtrl.text.trim(),
                    fieldOfStudy: fieldCtrl.text.trim(),
                    startYear: int.parse(startYearCtrl.text.trim()),
                    endYear: int.parse(endYearCtrl.text.trim()),
                  );
                  setState(() {
                    _education.add(entry);
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _removeEducation(int index) {
    setState(() {
      _education.removeAt(index);
    });
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final currentProfile = ref.read(profileNotifierProvider).value;
    if (currentProfile == null) return;

    final updated = (currentProfile as UserModel).copyWith(
      fullName: _fullNameController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      linkedinUrl: _linkedinController.text.trim(),
      dob: _dob,
      gender: _gender,
      skills: _skills,
      education: _education,
    );

    try {
      await ref.read(profileNotifierProvider.notifier).updateProfile(updated);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully.')),
        );
        context.pop();
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
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
    if (!_isInit) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        title: const Text('Edit Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _isLoading ? null : _handleSave,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12.0),
                  margin: const EdgeInsets.only(bottom: 20.0),
                  decoration: BoxDecoration(
                    color: AppTheme.rejectedBg,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Text(_errorMessage!, style: AppTheme.bodyMd.copyWith(color: AppTheme.rejectedText)),
                ),
              ],

              // Full Name
              Text('Full Name', style: AppTheme.labelLg.copyWith(color: AppTheme.primaryColor)),
              const SizedBox(height: 8.0),
              TextFormField(
                controller: _fullNameController,
                validator: (v) => v!.isEmpty ? 'Field is required' : null,
                decoration: const InputDecoration(prefixIcon: Icon(Icons.person_outline), hintText: 'John Doe'),
              ),
              const SizedBox(height: 20.0),

              // Phone Number
              Text('Phone Number', style: AppTheme.labelLg.copyWith(color: AppTheme.primaryColor)),
              const SizedBox(height: 8.0),
              TextFormField(
                controller: _phoneController,
                validator: (v) => v!.isEmpty ? 'Field is required' : null,
                decoration: const InputDecoration(prefixIcon: Icon(Icons.phone_outlined), hintText: '+1 (555) 000-0000'),
              ),
              const SizedBox(height: 20.0),

              // DOB and Gender row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('Date of Birth', style: AppTheme.labelLg.copyWith(color: AppTheme.primaryColor)),
                        const SizedBox(height: 8.0),
                        InkWell(
                          onTap: _selectDate,
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.calendar_today_outlined),
                            ),
                            child: Text(
                              _dob != null ? DateFormat('MM/dd/yyyy').format(_dob!) : 'Select Date',
                              style: TextStyle(color: _dob != null ? AppTheme.primaryColor : AppTheme.outlineColor),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('Gender', style: AppTheme.labelLg.copyWith(color: AppTheme.primaryColor)),
                        const SizedBox(height: 8.0),
                        DropdownButtonFormField<String>(
                          initialValue: _gender,
                          hint: const Text('Select'),
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                          items: ['Male', 'Female', 'Other', 'Prefer not to say']
                              .map((gender) => DropdownMenuItem(value: gender, child: Text(gender)))
                              .toList(),
                          onChanged: (val) => setState(() => _gender = val),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20.0),

              // Address
              Text('Address', style: AppTheme.labelLg.copyWith(color: AppTheme.primaryColor)),
              const SizedBox(height: 8.0),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(prefixIcon: Icon(Icons.location_on_outlined), hintText: 'Toronto, Canada'),
              ),
              const SizedBox(height: 20.0),

              // LinkedIn Profile
              Text('LinkedIn Profile URL', style: AppTheme.labelLg.copyWith(color: AppTheme.primaryColor)),
              const SizedBox(height: 8.0),
              TextFormField(
                controller: _linkedinController,
                decoration: const InputDecoration(prefixIcon: Icon(Icons.link_outlined), hintText: 'linkedin.com/in/username'),
              ),
              const SizedBox(height: 28.0),

              // Skills Segment
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Skills', style: AppTheme.titleMd.copyWith(color: AppTheme.primaryColor)),
                  const Text('Tap chip to delete', style: TextStyle(fontSize: 12, color: AppTheme.outlineColor)),
                ],
              ),
              const Divider(height: 20, color: AppTheme.outlineVariantColor),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _skillInputController,
                      decoration: const InputDecoration(hintText: 'Add a skill, e.g. UI/UX design'),
                      onFieldSubmitted: (_) => _addSkill(),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  ElevatedButton(
                    onPressed: _addSkill,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    child: const Icon(Icons.add),
                  ),
                ],
              ),
              const SizedBox(height: 12.0),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: _skills.map((skill) {
                  return InputChip(
                    label: Text(skill),
                    backgroundColor: AppTheme.surfaceContainerLow,
                    onDeleted: () => _removeSkill(skill),
                    deleteIconColor: AppTheme.outlineColor,
                  );
                }).toList(),
              ),
              const SizedBox(height: 28.0),

              // Education Segment
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Education History', style: AppTheme.titleMd.copyWith(color: AppTheme.primaryColor)),
                  ElevatedButton.icon(
                    onPressed: _showAddEducationDialog,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ],
              ),
              const Divider(height: 20, color: AppTheme.outlineVariantColor),
              if (_education.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text('No education details listed.', style: AppTheme.bodyMd.copyWith(color: AppTheme.outlineColor)),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _education.length,
                  separatorBuilder: (context, index) => const Divider(height: 24, color: AppTheme.outlineVariantColor),
                  itemBuilder: (context, index) {
                    final edu = _education[index];
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.school, color: AppTheme.primaryColor),
                        const SizedBox(width: 16.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${edu.degree} in ${edu.fieldOfStudy}',
                                style: AppTheme.bodyLg.copyWith(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                              ),
                              Text(edu.school, style: AppTheme.bodyMd.copyWith(color: AppTheme.outlineColor)),
                              Text('${edu.startYear} - ${edu.endYear}', style: AppTheme.labelSm.copyWith(color: AppTheme.secondaryColor)),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: AppTheme.errorColor),
                          onPressed: () => _removeEducation(index),
                        ),
                      ],
                    );
                  },
                ),

              const SizedBox(height: 40.0),

              // Save Button
              ElevatedButton(
                onPressed: _isLoading ? null : _handleSave,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Save Profile Updates'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
