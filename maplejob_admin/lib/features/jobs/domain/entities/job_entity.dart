class JobEntity {
  final String id;
  final String title;
  final String description;
  final String requirements;
  final String salary;
  final String experience;
  final String employmentType; // e.g. Full-Time, Part-Time, Contract
  final int vacancyCount;
  final String city;
  final String state;
  final String country;
  final String officeLocation;
  final String workMode; // e.g. Remote, Hybrid, On-site
  final String benefits;
  final List<String> requiredSkills;
  final DateTime? applicationDeadline;
  final String minimumQualification;
  final String preferredQualification;
  final String department;
  final String category;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  const JobEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.requirements,
    required this.salary,
    required this.experience,
    required this.employmentType,
    required this.vacancyCount,
    required this.city,
    required this.state,
    required this.country,
    required this.officeLocation,
    required this.workMode,
    required this.benefits,
    required this.requiredSkills,
    this.applicationDeadline,
    required this.minimumQualification,
    required this.preferredQualification,
    required this.department,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
  });

  bool get isClosed => !isActive;
}
