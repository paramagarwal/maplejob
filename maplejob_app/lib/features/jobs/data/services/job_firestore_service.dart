import 'package:cloud_firestore/cloud_firestore.dart';

class JobFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>> getJobsStream() {
    return _firestore
        .collection('jobs')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getJobById(String id) {
    return _firestore.collection('jobs').doc(id).get();
  }

  Future<void> createJob(Map<String, dynamic> data) {
    return _firestore.collection('jobs').add(data);
  }

  Future<void> updateJob(String id, Map<String, dynamic> data) {
    return _firestore.collection('jobs').doc(id).update(data);
  }

  Future<void> deleteJob(String id) {
    return _firestore.collection('jobs').doc(id).delete();
  }

  // Saved jobs operations
  Future<void> saveJob(String userId, String jobId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('saved_jobs')
        .doc(jobId)
        .set({
      'jobId': jobId,
      'savedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> unsaveJob(String userId, String jobId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('saved_jobs')
        .doc(jobId)
        .delete();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getSavedJobIdsStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('saved_jobs')
        .snapshots();
  }
}
