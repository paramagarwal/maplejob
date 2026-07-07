class EducationItem {
  final String school;
  final String degree;
  final String fieldOfStudy;
  final int startYear;
  final int endYear;

  const EducationItem({
    required this.school,
    required this.degree,
    required this.fieldOfStudy,
    required this.startYear,
    required this.endYear,
  });

  factory EducationItem.fromMap(Map<String, dynamic> map) {
    return EducationItem(
      school: map['school'] as String? ?? '',
      degree: map['degree'] as String? ?? '',
      fieldOfStudy: map['fieldOfStudy'] as String? ?? '',
      startYear: map['startYear'] as int? ?? 0,
      endYear: map['endYear'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'school': school,
      'degree': degree,
      'fieldOfStudy': fieldOfStudy,
      'startYear': startYear,
      'endYear': endYear,
    };
  }
}
