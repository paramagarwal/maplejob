import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/job_application.dart';
import '../../domain/repositories/application_repository.dart';
import '../../data/repositories/application_repository_impl.dart';
import '../../data/services/application_firestore_service.dart';
import '../../domain/usecases/get_all_applications_usecase.dart';
import '../../domain/usecases/update_application_status_usecase.dart';

final applicationFirestoreServiceProvider = Provider<ApplicationFirestoreService>((ref) {
  return ApplicationFirestoreService();
});

final applicationRepositoryProvider = Provider<ApplicationRepository>((ref) {
  return ApplicationRepositoryImpl(ref.watch(applicationFirestoreServiceProvider));
});

final getAllApplicationsUseCaseProvider = Provider<GetAllApplicationsUseCase>((ref) {
  return GetAllApplicationsUseCase(ref.watch(applicationRepositoryProvider));
});

final updateApplicationStatusUseCaseProvider = Provider<UpdateApplicationStatusUseCase>((ref) {
  return UpdateApplicationStatusUseCase(ref.watch(applicationRepositoryProvider));
});

final allApplicationsStreamProvider = StreamProvider<List<JobApplication>>((ref) {
  return ref.watch(getAllApplicationsUseCaseProvider).call();
});

class ApplicationController extends StateNotifier<AsyncValue<void>> {
  final UpdateApplicationStatusUseCase _updateApplicationStatusUseCase;
  ApplicationController(this._updateApplicationStatusUseCase) : super(const AsyncValue.data(null));

  Future<void> updateStatus(String id, String status, {String notes = ''}) async {
    state = const AsyncValue.loading();
    try {
      await _updateApplicationStatusUseCase(id, status, notes: notes);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}

final applicationControllerProvider = StateNotifierProvider<ApplicationController, AsyncValue<void>>((ref) {
  return ApplicationController(ref.watch(updateApplicationStatusUseCaseProvider));
});
