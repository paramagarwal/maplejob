import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/job_entity.dart';
import '../../domain/repositories/job_repository.dart';
import '../../data/repositories/job_repository_impl.dart';

final jobRepositoryProvider = Provider<JobRepository>((ref) {
  return JobRepositoryImpl();
});

final jobsStreamProvider = StreamProvider<List<JobEntity>>((ref) {
  final repo = ref.watch(jobRepositoryProvider);
  return repo.getJobs();
});

class JobController extends StateNotifier<AsyncValue<void>> {
  final JobRepository _repo;
  JobController(this._repo) : super(const AsyncValue.data(null));

  Future<void> create(JobEntity job) async {
    state = const AsyncValue.loading();
    try {
      await _repo.createJob(job);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> update(JobEntity job) async {
    state = const AsyncValue.loading();
    try {
      await _repo.updateJob(job);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> delete(String id) async {
    state = const AsyncValue.loading();
    try {
      await _repo.deleteJob(id);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}

final jobControllerProvider = StateNotifierProvider<JobController, AsyncValue<void>>((ref) {
  return JobController(ref.watch(jobRepositoryProvider));
});
