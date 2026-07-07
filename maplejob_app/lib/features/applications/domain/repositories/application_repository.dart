import '../entities/job_application.dart';

abstract class ApplicationRepository {
  Stream<List<JobApplication>> getApplicationsByApplicant(String applicantId);
  Stream<List<JobApplication>> getAllApplications();
  Future<void> submitApplication(JobApplication application);
  Future<void> updateApplicationStatus(String id, String status, {String notes});
}
