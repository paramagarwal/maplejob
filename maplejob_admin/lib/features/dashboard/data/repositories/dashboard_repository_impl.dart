import '../../domain/repositories/dashboard_repository.dart';
import '../services/dashboard_firestore_service.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardFirestoreService _firestoreService;

  DashboardRepositoryImpl(this._firestoreService);

  @override
  Stream<int> getApplicantsCount() {
    return _firestoreService.getApplicantsCountStream();
  }
}
