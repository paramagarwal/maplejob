import '../../domain/entities/job_entity.dart';
import '../../domain/repositories/job_repository.dart';
import '../models/job_model.dart';
import '../services/job_firestore_service.dart';

class JobRepositoryImpl implements JobRepository {
  final JobFirestoreService _firestoreService;

  JobRepositoryImpl(this._firestoreService);

  @override
  Stream<List<JobEntity>> getJobs() {
    return _firestoreService.getJobsStream().map((snapshot) {
      return snapshot.docs.map((doc) {
        return JobModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  @override
  Future<JobEntity?> getJobById(String id) async {
    final doc = await _firestoreService.getJobById(id);
    if (doc.exists && doc.data() != null) {
      return JobModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  @override
  Future<void> createJob(JobEntity job) async {
    final model = JobModel(
      id: '',
      title: job.title,
      description: job.description,
      requirements: job.requirements,
      salary: job.salary,
      experience: job.experience,
      employmentType: job.employmentType,
      vacancyCount: job.vacancyCount,
      city: job.city,
      state: job.state,
      country: job.country,
      officeLocation: job.officeLocation,
      workMode: job.workMode,
      benefits: job.benefits,
      requiredSkills: job.requiredSkills,
      applicationDeadline: job.applicationDeadline,
      minimumQualification: job.minimumQualification,
      preferredQualification: job.preferredQualification,
      department: job.department,
      category: job.category,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isActive: job.isActive,
    );
    await _firestoreService.createJob(model.toMap());
  }

  @override
  Future<void> updateJob(JobEntity job) async {
    final model = JobModel(
      id: job.id,
      title: job.title,
      description: job.description,
      requirements: job.requirements,
      salary: job.salary,
      experience: job.experience,
      employmentType: job.employmentType,
      vacancyCount: job.vacancyCount,
      city: job.city,
      state: job.state,
      country: job.country,
      officeLocation: job.officeLocation,
      workMode: job.workMode,
      benefits: job.benefits,
      requiredSkills: job.requiredSkills,
      applicationDeadline: job.applicationDeadline,
      minimumQualification: job.minimumQualification,
      preferredQualification: job.preferredQualification,
      department: job.department,
      category: job.category,
      createdAt: job.createdAt,
      updatedAt: DateTime.now(),
      isActive: job.isActive,
    );
    await _firestoreService.updateJob(job.id, model.toMap());
  }

  @override
  Future<void> deleteJob(String id) async {
    await _firestoreService.deleteJob(id);
  }
}
