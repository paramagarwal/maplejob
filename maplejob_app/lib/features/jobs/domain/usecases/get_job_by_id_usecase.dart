import '../entities/job_entity.dart';
import '../repositories/job_repository.dart';

class GetJobByIdUseCase {
  final JobRepository _repository;
  GetJobByIdUseCase(this._repository);

  Future<JobEntity?> call(String id) => _repository.getJobById(id);
}
