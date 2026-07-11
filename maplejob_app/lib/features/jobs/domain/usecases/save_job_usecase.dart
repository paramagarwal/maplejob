import '../repositories/job_repository.dart';

class SaveJobUseCase {
  final JobRepository _repository;
  SaveJobUseCase(this._repository);

  Future<void> call(String userId, String jobId) => _repository.saveJob(userId, jobId);
}
