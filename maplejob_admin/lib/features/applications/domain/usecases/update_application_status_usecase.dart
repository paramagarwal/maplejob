import '../repositories/application_repository.dart';

class UpdateApplicationStatusUseCase {
  final ApplicationRepository _repository;
  UpdateApplicationStatusUseCase(this._repository);

  Future<void> call(String id, String status, {String notes = ''}) {
    return _repository.updateApplicationStatus(id, status, notes: notes);
  }
}
