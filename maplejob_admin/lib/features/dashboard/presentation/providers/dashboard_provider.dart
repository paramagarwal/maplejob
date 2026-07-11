import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../../data/repositories/dashboard_repository_impl.dart';
import '../../data/services/dashboard_firestore_service.dart';
import '../../domain/usecases/get_applicants_count_usecase.dart';
import '../../../jobs/presentation/providers/job_provider.dart';
import '../../../applications/presentation/providers/application_provider.dart';

final dashboardFirestoreServiceProvider = Provider<DashboardFirestoreService>((ref) {
  return DashboardFirestoreService();
});

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepositoryImpl(ref.watch(dashboardFirestoreServiceProvider));
});

final getApplicantsCountUseCaseProvider = Provider<GetApplicantsCountUseCase>((ref) {
  return GetApplicantsCountUseCase(ref.watch(dashboardRepositoryProvider));
});

final applicantsCountStreamProvider = StreamProvider<int>((ref) {
  return ref.watch(getApplicantsCountUseCaseProvider).call();
});

final dashboardStatsProvider = Provider<AsyncValue<DashboardStats>>((ref) {
  final jobsAsync = ref.watch(jobsStreamProvider);
  final appsAsync = ref.watch(allApplicationsStreamProvider);
  final applicantsAsync = ref.watch(applicantsCountStreamProvider);

  if (jobsAsync.hasError) return AsyncValue.error(jobsAsync.error!, jobsAsync.stackTrace!);
  if (appsAsync.hasError) return AsyncValue.error(appsAsync.error!, appsAsync.stackTrace!);
  if (applicantsAsync.hasError) return AsyncValue.error(applicantsAsync.error!, applicantsAsync.stackTrace!);

  if (jobsAsync.isLoading || appsAsync.isLoading || applicantsAsync.isLoading) {
    return const AsyncValue.loading();
  }

  final jobs = jobsAsync.value ?? [];
  final applications = appsAsync.value ?? [];
  final applicantsCount = applicantsAsync.value ?? 0;

  final now = DateTime.now();
  final totalJobs = jobs.length;
  final activeJobs = jobs.where((j) => j.isActive).length;
  final closedJobs = totalJobs - activeJobs;

  final appsToday = applications.where((a) {
    return a.appliedAt.year == now.year &&
           a.appliedAt.month == now.month &&
           a.appliedAt.day == now.day;
  }).length;

  final appsThisMonth = applications.where((a) {
    return a.appliedAt.year == now.year &&
           a.appliedAt.month == now.month;
  }).length;

  return AsyncValue.data(DashboardStats(
    totalJobs: totalJobs,
    activeJobs: activeJobs,
    closedJobs: closedJobs,
    totalApplicants: applicantsCount,
    applicationsToday: appsToday,
    applicationsThisMonth: appsThisMonth,
  ));
});
