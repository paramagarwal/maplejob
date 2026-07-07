class JobApplication {
  final String id;
  final String jobId;
  final String jobTitle;
  final String department;
  final String applicantId;
  final String applicantName;
  final String applicantEmail;
  final String applicantPhone;
  final String resumeUrl;
  final String resumeName;
  final String status; // Applied, Shortlisted, Interview, Offered, Rejected
  final DateTime appliedAt;
  final DateTime updatedAt;
  final String notes;

  const JobApplication({
    required this.id,
    required this.jobId,
    required this.jobTitle,
    required this.department,
    required this.applicantId,
    required this.applicantName,
    required this.applicantEmail,
    required this.applicantPhone,
    required this.resumeUrl,
    required this.resumeName,
    required this.status,
    required this.appliedAt,
    required this.updatedAt,
    this.notes = '',
  });

  bool get isRejected => status == 'Rejected';
  bool get isOffered => status == 'Offered';
}
