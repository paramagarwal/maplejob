import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/job_application.dart';
import '../../domain/repositories/application_repository.dart';
import '../../data/repositories/application_repository_impl.dart';

final applicationRepositoryProvider = Provider<ApplicationRepository>((ref) {
  return ApplicationRepositoryImpl();
});

final allApplicationsStreamProvider = StreamProvider<List<JobApplication>>((ref) {
  return ref.watch(applicationRepositoryProvider).getAllApplications();
});

class ApplicationController extends StateNotifier<AsyncValue<void>> {
  final ApplicationRepository _repo;
  ApplicationController(this._repo) : super(const AsyncValue.data(null));

  Future<void> updateStatus(String id, String status, {String notes = ''}) async {
    state = const AsyncValue.loading();
    try {
      await _repo.updateApplicationStatus(id, status, notes: notes);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}

final applicationControllerProvider = StateNotifierProvider<ApplicationController, AsyncValue<void>>((ref) {
  return ApplicationController(ref.watch(applicationRepositoryProvider));
});
