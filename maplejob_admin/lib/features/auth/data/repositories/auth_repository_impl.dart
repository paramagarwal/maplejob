import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final fb.FirebaseAuth _firebaseAuth = fb.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthRepositoryImpl();

  @override
  Future<UserEntity> signInWithEmailAndPassword(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user == null) {
        throw Exception('User is null after sign in.');
      }

      // Check role
      final userDoc = await _firestore.collection('users').doc(credential.user!.uid).get();
      if (!userDoc.exists || userDoc.data() == null) {
        // Sign out if profile is missing
        await _firebaseAuth.signOut();
        throw Exception('Access Denied: Admin profile does not exist.');
      }

      final userModel = UserModel.fromMap(userDoc.data()!, credential.user!.uid);
      if (userModel.role != UserRole.admin) {
        // Sign out if not an admin
        await _firebaseAuth.signOut();
        throw Exception('Access Denied: You must be an administrator to log into this dashboard.');
      }

      return userModel;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final fb.User? firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) return null;

    final userDoc = await _firestore.collection('users').doc(firebaseUser.uid).get();
    if (userDoc.exists && userDoc.data() != null) {
      final userModel = UserModel.fromMap(userDoc.data()!, firebaseUser.uid);
      if (userModel.role == UserRole.admin) {
        return userModel;
      }
    }
    // Force sign out if session exists but user is not admin
    await signOut();
    return null;
  }

  @override
  Stream<UserEntity?> authStateChanges() {
    return _firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      try {
        final userDoc = await _firestore.collection('users').doc(firebaseUser.uid).get();
        if (userDoc.exists && userDoc.data() != null) {
          final userModel = UserModel.fromMap(userDoc.data()!, firebaseUser.uid);
          if (userModel.role == UserRole.admin) {
            return userModel;
          }
        }
        await signOut();
        return null;
      } catch (e) {
        return null;
      }
    });
  }
}
