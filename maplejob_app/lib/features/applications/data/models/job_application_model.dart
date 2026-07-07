import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/job_application.dart';

class JobApplicationModel extends JobApplication {
  const JobApplicationModel({
    required super.id,
    required super.jobId,
    required super.jobTitle,
    required super.department,
    required super.applicantId,
    required super.applicantName,
    required super.applicantEmail,
    required super.applicantPhone,
    required super.resumeUrl,
    required super.resumeName,
    required super.status,
    required super.appliedAt,
    required super.updatedAt,
    super.notes = '',
  });

  factory JobApplicationModel.fromMap(Map<String, dynamic> map, String id) {
    return JobApplicationModel(
      id: id,
      jobId: map['jobId'] as String? ?? '',
      jobTitle: map['jobTitle'] as String? ?? '',
      department: map['department'] as String? ?? '',
      applicantId: map['applicantId'] as String? ?? '',
      applicantName: map['applicantName'] as String? ?? '',
      applicantEmail: map['applicantEmail'] as String? ?? '',
      applicantPhone: map['applicantPhone'] as String? ?? '',
      resumeUrl: map['resumeUrl'] as String? ?? '',
      resumeName: map['resumeName'] as String? ?? '',
      status: map['status'] as String? ?? 'Applied',
      appliedAt: (map['appliedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      notes: map['notes'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'jobId': jobId,
      'jobTitle': jobTitle,
      'department': department,
      'applicantId': applicantId,
      'applicantName': applicantName,
      'applicantEmail': applicantEmail,
      'applicantPhone': applicantPhone,
      'resumeUrl': resumeUrl,
      'resumeName': resumeName,
      'status': status,
      'appliedAt': Timestamp.fromDate(appliedAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'notes': notes,
    };
  }

  JobApplicationModel copyWith({
    String? status,
    DateTime? updatedAt,
    String? notes,
  }) {
    return JobApplicationModel(
      id: id,
      jobId: jobId,
      jobTitle: jobTitle,
      department: department,
      applicantId: applicantId,
      applicantName: applicantName,
      applicantEmail: applicantEmail,
      applicantPhone: applicantPhone,
      resumeUrl: resumeUrl,
      resumeName: resumeName,
      status: status ?? this.status,
      appliedAt: appliedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      notes: notes ?? this.notes,
    );
  }
}
