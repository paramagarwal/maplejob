import '../entities/job_entity.dart';

abstract class JobRepository {
  Stream<List<JobEntity>> getJobs();
  
  Future<JobEntity?> getJobById(String id);
  
  Future<void> createJob(JobEntity job);
  
  Future<void> updateJob(JobEntity job);
  
  Future<void> deleteJob(String id);
}
