import '../entities/job_entity.dart';
import '../repositories/job_repository.dart';

class GetJobsUseCase {
  final JobRepository _repository;
  GetJobsUseCase(this._repository);

  Stream<List<JobEntity>> call() => _repository.getJobs();
}
