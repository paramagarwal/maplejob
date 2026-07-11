import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/job_entity.dart';
import '../../domain/repositories/job_repository.dart';
import '../../data/repositories/job_repository_impl.dart';
import '../../data/services/job_firestore_service.dart';
import '../../domain/usecases/get_jobs_usecase.dart';
import '../../domain/usecases/get_job_by_id_usecase.dart';
import '../../domain/usecases/create_job_usecase.dart';
import '../../domain/usecases/update_job_usecase.dart';
import '../../domain/usecases/delete_job_usecase.dart';

final jobFirestoreServiceProvider = Provider<JobFirestoreService>((ref) {
  return JobFirestoreService();
});

final jobRepositoryProvider = Provider<JobRepository>((ref) {
  return JobRepositoryImpl(ref.watch(jobFirestoreServiceProvider));
});

final getJobsUseCaseProvider = Provider<GetJobsUseCase>((ref) {
  return GetJobsUseCase(ref.watch(jobRepositoryProvider));
});

final getJobByIdUseCaseProvider = Provider<GetJobByIdUseCase>((ref) {
  return GetJobByIdUseCase(ref.watch(jobRepositoryProvider));
});

final createJobUseCaseProvider = Provider<CreateJobUseCase>((ref) {
  return CreateJobUseCase(ref.watch(jobRepositoryProvider));
});

final updateJobUseCaseProvider = Provider<UpdateJobUseCase>((ref) {
  return UpdateJobUseCase(ref.watch(jobRepositoryProvider));
});

final deleteJobUseCaseProvider = Provider<DeleteJobUseCase>((ref) {
  return DeleteJobUseCase(ref.watch(jobRepositoryProvider));
});

final jobsStreamProvider = StreamProvider<List<JobEntity>>((ref) {
  final useCase = ref.watch(getJobsUseCaseProvider);
  return useCase();
});

class JobController extends StateNotifier<AsyncValue<void>> {
  final CreateJobUseCase _createJobUseCase;
  final UpdateJobUseCase _updateJobUseCase;
  final DeleteJobUseCase _deleteJobUseCase;

  JobController(
    this._createJobUseCase,
    this._updateJobUseCase,
    this._deleteJobUseCase,
  ) : super(const AsyncValue.data(null));

  Future<void> create(JobEntity job) async {
    state = const AsyncValue.loading();
    try {
      await _createJobUseCase(job);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> update(JobEntity job) async {
    state = const AsyncValue.loading();
    try {
      await _updateJobUseCase(job);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> delete(String id) async {
    state = const AsyncValue.loading();
    try {
      await _deleteJobUseCase(id);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}

final jobControllerProvider = StateNotifierProvider<JobController, AsyncValue<void>>((ref) {
  return JobController(
    ref.watch(createJobUseCaseProvider),
    ref.watch(updateJobUseCaseProvider),
    ref.watch(deleteJobUseCaseProvider),
  );
});
