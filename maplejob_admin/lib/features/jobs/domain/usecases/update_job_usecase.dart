import '../entities/job_entity.dart';
import '../repositories/job_repository.dart';

class UpdateJobUseCase {
  final JobRepository _repository;
  UpdateJobUseCase(this._repository);

  Future<void> call(JobEntity job) => _repository.updateJob(job);
}
