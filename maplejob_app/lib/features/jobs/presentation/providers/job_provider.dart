import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/job_entity.dart';
import '../../domain/repositories/job_repository.dart';
import '../../data/repositories/job_repository_impl.dart';
import '../../data/services/job_firestore_service.dart';
import '../../domain/usecases/get_jobs_usecase.dart';
import '../../domain/usecases/get_job_by_id_usecase.dart';
import '../../domain/usecases/save_job_usecase.dart';
import '../../domain/usecases/unsave_job_usecase.dart';
import '../../domain/usecases/get_saved_job_ids_usecase.dart';

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

final saveJobUseCaseProvider = Provider<SaveJobUseCase>((ref) {
  return SaveJobUseCase(ref.watch(jobRepositoryProvider));
});

final unsaveJobUseCaseProvider = Provider<UnsaveJobUseCase>((ref) {
  return UnsaveJobUseCase(ref.watch(jobRepositoryProvider));
});

final getSavedJobIdsUseCaseProvider = Provider<GetSavedJobIdsUseCase>((ref) {
  return GetSavedJobIdsUseCase(ref.watch(jobRepositoryProvider));
});

final jobsStreamProvider = StreamProvider<List<JobEntity>>((ref) {
  final useCase = ref.watch(getJobsUseCaseProvider);
  return useCase();
});

final savedJobIdsStreamProvider = StreamProvider<List<String>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return const Stream.empty();
  final useCase = ref.watch(getSavedJobIdsUseCaseProvider);
  return useCase(user.uid);
});
