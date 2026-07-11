import '../repositories/dashboard_repository.dart';

class GetApplicantsCountUseCase {
  final DashboardRepository _repository;
  GetApplicantsCountUseCase(this._repository);

  Stream<int> call() {
    return _repository.getApplicantsCount();
  }
}
