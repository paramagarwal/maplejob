import '../repositories/job_repository.dart';

class DeleteJobUseCase {
  final JobRepository _repository;
  DeleteJobUseCase(this._repository);

  Future<void> call(String id) => _repository.deleteJob(id);
}
