import '../entities/job_application.dart';
import '../repositories/application_repository.dart';

class SubmitApplicationUseCase {
  final ApplicationRepository _repository;
  SubmitApplicationUseCase(this._repository);

  Future<void> call(JobApplication application) {
    return _repository.submitApplication(application);
  }
}
