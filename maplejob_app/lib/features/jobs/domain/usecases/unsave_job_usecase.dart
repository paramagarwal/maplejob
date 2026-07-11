import '../repositories/job_repository.dart';

class UnsaveJobUseCase {
  final JobRepository _repository;
  UnsaveJobUseCase(this._repository);

  Future<void> call(String userId, String jobId) => _repository.unsaveJob(userId, jobId);
}
