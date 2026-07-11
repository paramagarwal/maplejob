import '../repositories/job_repository.dart';

class GetSavedJobIdsUseCase {
  final JobRepository _repository;
  GetSavedJobIdsUseCase(this._repository);

  Stream<List<String>> call(String userId) => _repository.getSavedJobIds(userId);
}
