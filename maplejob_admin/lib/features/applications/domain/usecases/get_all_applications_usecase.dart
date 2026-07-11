import '../entities/job_application.dart';
import '../repositories/application_repository.dart';

class GetAllApplicationsUseCase {
  final ApplicationRepository _repository;
  GetAllApplicationsUseCase(this._repository);

  Stream<List<JobApplication>> call() {
    return _repository.getAllApplications();
  }
}
