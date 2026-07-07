import 'education_item.dart';

enum UserRole {
  applicant,
  admin,
}

class UserEntity {
  final String uid;
  final String email;
  final String fullName;
  final String phone;
  final UserRole role;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Profile specific fields
  final DateTime? dob;
  final String? gender;
  final String? address;
  final String? resumeUrl;
  final String? resumeName;
  final String? linkedinUrl;
  final List<String> skills;
  final List<EducationItem> education;

  const UserEntity({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.phone,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
    this.dob,
    this.gender,
    this.address,
    this.resumeUrl,
    this.resumeName,
    this.linkedinUrl,
    this.skills = const [],
    this.education = const [],
  });

  bool get isAdmin => role == UserRole.admin;
  bool get isApplicant => role == UserRole.applicant;

  double get completionPercentage {
    int filledFields = 0;
    if (fullName.trim().isNotEmpty) filledFields++;
    if (email.trim().isNotEmpty) filledFields++;
    if (phone.trim().isNotEmpty) filledFields++;
    if (dob != null) filledFields++;
    if (gender != null && gender!.trim().isNotEmpty) filledFields++;
    if (address != null && address!.trim().isNotEmpty) filledFields++;
    if (resumeUrl != null && resumeUrl!.trim().isNotEmpty) filledFields++;
    if (linkedinUrl != null && linkedinUrl!.trim().isNotEmpty) filledFields++;
    if (skills.isNotEmpty) filledFields++;
    if (education.isNotEmpty) filledFields++;
    return (filledFields / 10.0) * 100.0;
  }
}
