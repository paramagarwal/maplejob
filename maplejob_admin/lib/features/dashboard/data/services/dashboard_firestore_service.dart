import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<int> getApplicantsCountStream() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'applicant')
        .snapshots()
        .map((snap) => snap.size);
  }
}
