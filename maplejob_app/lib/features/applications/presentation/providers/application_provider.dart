import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/job_application.dart';
import '../../domain/repositories/application_repository.dart';
import '../../data/repositories/application_repository_impl.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final applicationRepositoryProvider = Provider<ApplicationRepository>((ref) {
  return ApplicationRepositoryImpl();
});

final applicantApplicationsProvider = StreamProvider<List<JobApplication>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);
  return ref.watch(applicationRepositoryProvider).getApplicationsByApplicant(user.uid);
});

final applicationStreamProvider = StreamProvider.family<JobApplication?, String>((ref, id) {
  final repo = ref.watch(applicationRepositoryProvider);
  return repo.getAllApplications().map((list) {
    try {
      return list.firstWhere((app) => app.id == id);
    } catch (_) {
      return null;
    }
  });
});
