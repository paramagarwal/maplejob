import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/job_application.dart';
import '../../domain/repositories/application_repository.dart';
import '../models/job_application_model.dart';

class ApplicationRepositoryImpl implements ApplicationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ApplicationRepositoryImpl();

  @override
  Stream<List<JobApplication>> getApplicationsByApplicant(String applicantId) {
    return _firestore
        .collection('applications')
        .where('applicantId', isEqualTo: applicantId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return JobApplicationModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  @override
  Stream<List<JobApplication>> getAllApplications() {
    return _firestore
        .collection('applications')
        .orderBy('appliedAt', descending: true)
        .snapshots()
        .map((snapshot) {
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
    await _firestore.collection('applications').add(model.toMap());
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
    await _firestore.collection('applications').doc(id).update(data);

    try {
      final appDoc = await _firestore.collection('applications').doc(id).get();
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
          await _firestore
              .collection('users')
              .doc(applicantId)
              .collection('notifications')
              .add(notifData);
        }
      }
    } catch (e) {
      // Silent catch to prevent status update rollback
      debugPrint('Failed to write trigger notification: $e');
    }
  }
}
