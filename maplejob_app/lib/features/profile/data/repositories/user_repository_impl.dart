import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/data/models/user_model.dart';
import '../../domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserRepositoryImpl();

  @override
  Future<UserEntity?> getUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromMap(doc.data()!, uid);
    }
    return null;
  }

  @override
  Future<void> updateUserProfile(UserEntity user) async {
    final userModel = UserModel(
      uid: user.uid,
      email: user.email,
      fullName: user.fullName,
      phone: user.phone,
      role: user.role,
      createdAt: user.createdAt,
      updatedAt: DateTime.now(), // update Timestamp
      dob: user.dob,
      gender: user.gender,
      address: user.address,
      resumeUrl: user.resumeUrl,
      resumeName: user.resumeName,
      linkedinUrl: user.linkedinUrl,
      skills: user.skills,
      education: user.education,
    );
    
    await _firestore.collection('users').doc(user.uid).set(userModel.toMap(), SetOptions(merge: true));
  }

  @override
  Future<String> uploadResume(String uid, String filename, Uint8List fileBytes) async {
    final storageRef = FirebaseStorage.instance.ref().child('resumes/$uid/$filename');
    final metadata = SettableMetadata(contentType: 'application/pdf');
    final uploadTask = storageRef.putData(fileBytes, metadata);
    final snapshot = await uploadTask;
    final downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }
}
