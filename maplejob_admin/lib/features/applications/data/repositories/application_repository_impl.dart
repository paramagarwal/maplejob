import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/job_application.dart';
import '../../domain/repositories/application_repository.dart';
import '../models/job_application_model.dart';
import '../services/application_firestore_service.dart';

class ApplicationRepositoryImpl implements ApplicationRepository {
  final ApplicationFirestoreService _firestoreService;

  ApplicationRepositoryImpl(this._firestoreService);

  @override
  Stream<List<JobApplication>> getApplicationsByApplicant(String applicantId) {
    return _firestoreService
        .getApplicationsByApplicant(applicantId)
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return JobApplicationModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  @override
  Stream<List<JobApplication>> getAllApplications() {
    return _firestoreService.getAllApplications().map((snapshot) {
      return snapshot.docs.map((doc) {
        return JobApplicationModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  @override
  Future<void> submitApplication(JobApplication application) async {
    final model = JobApplicationModel(
      id: '',
      jobId: application.jobId,
      jobTitle: application.jobTitle,
      department: application.department,
      applicantId: application.applicantId,
      applicantName: application.applicantName,
      applicantEmail: application.applicantEmail,
      applicantPhone: application.applicantPhone,
      resumeUrl: application.resumeUrl,
      resumeName: application.resumeName,
      status: 'Applied', // default status
      appliedAt: DateTime.now(),
      updatedAt: DateTime.now(),
      notes: application.notes,
    );
    await _firestoreService.submitApplication(model.toMap());
  }

  @override
  Future<void> updateApplicationStatus(String id, String status, {String notes = ''}) async {
    final Map<String, dynamic> data = {
      'status': status,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    };
    if (notes.isNotEmpty) {
      data['notes'] = notes;
    }
    await _firestoreService.updateApplicationStatus(id, data);

    try {
      final appDoc = await _firestoreService.getApplicationById(id);
      if (appDoc.exists && appDoc.data() != null) {
        final applicantId = appDoc.data()!['applicantId'] as String?;
        final jobTitle = appDoc.data()!['jobTitle'] as String?;
        if (applicantId != null && jobTitle != null) {
          final notifData = {
            'title': 'Application Status Updated',
            'message': 'Your application for "$jobTitle" has been updated to "$status".${notes.isNotEmpty ? "\nNote: $notes" : ""}',
            'type': 'statusUpdate',
            'isRead': false,
            'timestamp': Timestamp.fromDate(DateTime.now()),
          };
          await _firestoreService.createNotification(applicantId, notifData);
        }
      }
    } catch (e) {
      // Silent catch to prevent status update rollback
      debugPrint('Failed to write trigger notification: $e');
    }
  }
}
