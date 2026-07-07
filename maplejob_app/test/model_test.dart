import 'package:flutter_test/flutter_test.dart';
import 'package:maplejob_app/features/auth/domain/entities/user_entity.dart';
import 'package:maplejob_app/features/auth/data/models/user_model.dart';
import 'package:maplejob_app/features/auth/domain/entities/education_item.dart';
import 'package:maplejob_app/features/jobs/data/models/job_model.dart';

void main() {
  group('UserModel Tests', () {
    test('Should calculate 10% completion for email-only candidate profile', () {
      final user = UserModel(
        uid: 'test_uid',
        email: 'candidate@maple.com',
        fullName: '',
        phone: '',
        role: UserRole.applicant,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Email is filled (10%), other 9 sections are empty.
      expect(user.completionPercentage, equals(10));
    });

    test('Should calculate 100% completion for fully populated candidate profile', () {
      final user = UserModel(
        uid: 'test_uid',
        email: 'candidate@maple.com',
        fullName: 'John Doe',
        phone: '+15550199',
        role: UserRole.applicant,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        dob: DateTime(1995, 10, 10),
        gender: 'Male',
        address: '123 Maple Street',
        resumeUrl: 'https://storage/resume.pdf',
        resumeName: 'resume.pdf',
        linkedinUrl: 'https://linkedin.com/in/johndoe',
        skills: ['Flutter', 'Dart'],
        education: [
          const EducationItem(
            school: 'Stanford University',
            degree: 'BS',
            fieldOfStudy: 'Computer Science',
            startYear: 2013,
            endYear: 2017,
          ),
        ],
      );

      expect(user.completionPercentage, equals(100));
    });
  });

  group('JobModel Serialization Tests', () {
    test('Should map values correctly to and from map', () {
      final now = DateTime.now();
      final originalJob = JobModel(
        id: 'job_123',
        title: 'Senior Broker',
        description: 'Lead sales matches.',
        requirements: 'Experienced agent.',
        salary: '\$90,000',
        experience: '5+ years',
        employmentType: 'Full-time',
        vacancyCount: 3,
        city: 'Vancouver',
        state: 'BC',
        country: 'Canada',
        officeLocation: 'Suite 200, Downtown',
        workMode: 'Hybrid',
        benefits: 'Full health plan.',
        requiredSkills: ['Negotiation', 'Sales'],
        applicationDeadline: now,
        minimumQualification: 'Real estate license.',
        preferredQualification: 'BSc in Business or related.',
        department: 'Sales',
        category: 'Brokerage',
        createdAt: now,
        updatedAt: now,
        isActive: true,
      );

      final map = originalJob.toMap();
      expect(map['title'], equals('Senior Broker'));
      expect(map['salary'], equals('\$90,000'));
      expect(map['isActive'], isTrue);
    });
  });
}
