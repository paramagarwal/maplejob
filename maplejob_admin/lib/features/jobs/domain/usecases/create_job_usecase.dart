import '../entities/job_entity.dart';
import '../repositories/job_repository.dart';

class CreateJobUseCase {
  final JobRepository _repository;
  CreateJobUseCase(this._repository);

  Future<void> call(JobEntity job) => _repository.createJob(job);
}
