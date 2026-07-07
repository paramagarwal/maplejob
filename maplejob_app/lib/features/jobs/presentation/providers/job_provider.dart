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
