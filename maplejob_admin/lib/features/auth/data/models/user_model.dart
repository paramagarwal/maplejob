import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/education_item.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.email,
    required super.fullName,
    required super.phone,
    required super.role,
    required super.createdAt,
    required super.updatedAt,
    super.dob,
    super.gender,
    super.address,
    super.resumeUrl,
    super.resumeName,
    super.linkedinUrl,
    super.skills = const [],
    super.education = const [],
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      email: map['email'] as String? ?? '',
      fullName: map['fullName'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      role: map['role'] == 'admin' ? UserRole.admin : UserRole.applicant,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      dob: (map['dob'] as Timestamp?)?.toDate(),
      gender: map['gender'] as String?,
      address: map['address'] as String?,
      resumeUrl: map['resumeUrl'] as String?,
      resumeName: map['resumeName'] as String?,
      linkedinUrl: map['linkedinUrl'] as String?,
      skills: List<String>.from(map['skills'] as List? ?? []),
      education: (map['education'] as List? ?? [])
          .map((item) => EducationItem.fromMap(Map<String, dynamic>.from(item)))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'fullName': fullName,
      'phone': phone,
      'role': role == UserRole.admin ? 'admin' : 'applicant',
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'dob': dob != null ? Timestamp.fromDate(dob!) : null,
      'gender': gender,
      'address': address,
      'resumeUrl': resumeUrl,
      'resumeName': resumeName,
      'linkedinUrl': linkedinUrl,
      'skills': skills,
      'education': education.map((item) => item.toMap()).toList(),
    };
  }

  UserModel copyWith({
    String? email,
    String? fullName,
    String? phone,
    UserRole? role,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? dob,
    String? gender,
    String? address,
    String? resumeUrl,
    String? resumeName,
    String? linkedinUrl,
    List<String>? skills,
    List<EducationItem>? education,
  }) {
    return UserModel(
      uid: uid,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      dob: dob ?? this.dob,
      gender: gender ?? this.gender,
      address: address ?? this.address,
      resumeUrl: resumeUrl ?? this.resumeUrl,
      resumeName: resumeName ?? this.resumeName,
      linkedinUrl: linkedinUrl ?? this.linkedinUrl,
      skills: skills ?? this.skills,
      education: education ?? this.education,
    );
  }
}
