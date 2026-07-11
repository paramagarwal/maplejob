import '../entities/job_application.dart';
import '../repositories/application_repository.dart';

class GetApplicantApplicationsUseCase {
  final ApplicationRepository _repository;
  GetApplicantApplicationsUseCase(this._repository);

  Stream<List<JobApplication>> call(String applicantId) {
    return _repository.getApplicationsByApplicant(applicantId);
  }
}
