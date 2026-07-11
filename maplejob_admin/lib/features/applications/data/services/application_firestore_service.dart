import 'package:cloud_firestore/cloud_firestore.dart';

class ApplicationFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>> getApplicationsByApplicant(String applicantId) {
    return _firestore
        .collection('applications')
        .where('applicantId', isEqualTo: applicantId)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getAllApplications() {
    return _firestore
        .collection('applications')
        .orderBy('appliedAt', descending: true)
        .snapshots();
  }

  Future<DocumentReference<Map<String, dynamic>>> submitApplication(Map<String, dynamic> data) {
    return _firestore.collection('applications').add(data);
  }

  Future<void> updateApplicationStatus(String id, Map<String, dynamic> data) {
    return _firestore.collection('applications').doc(id).update(data);
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getApplicationById(String id) {
    return _firestore.collection('applications').doc(id).get();
  }

  Future<void> createNotification(String userId, Map<String, dynamic> data) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .add(data);
  }
}
