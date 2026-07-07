import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final fb.FirebaseAuth _firebaseAuth = fb.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  AuthRepositoryImpl() {
    _initGoogleSignIn();
  }

  Future<void> _initGoogleSignIn() async {
    try {
      await _googleSignIn.initialize();
    } catch (e) {
      // Ignored for platform checks
    }
  }

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
      final userModel = await _fetchOrCreateUserDoc(credential.user!);
      return userModel;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserEntity> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user == null) {
        throw Exception('User is null after account creation.');
      }

      final userModel = UserModel(
        uid: credential.user!.uid,
        email: email,
        fullName: fullName,
        phone: phone,
        role: UserRole.applicant,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Write to Firestore users collection
      await _firestore.collection('users').doc(credential.user!.uid).set(userModel.toMap());
      return userModel;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserEntity> signInWithGoogle() async {
    try {
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final fb.AuthCredential credential = fb.GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      if (userCredential.user == null) {
        throw Exception('User is null after Google authentication.');
      }

      // Check if user exists, else create new applicant profile
      final userDoc = await _firestore.collection('users').doc(userCredential.user!.uid).get();
      if (userDoc.exists && userDoc.data() != null) {
        return UserModel.fromMap(userDoc.data()!, userCredential.user!.uid);
      } else {
        final userModel = UserModel(
          uid: userCredential.user!.uid,
          email: userCredential.user!.email ?? '',
          fullName: userCredential.user!.displayName ?? '',
          phone: userCredential.user!.phoneNumber ?? '',
          role: UserRole.applicant,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await _firestore.collection('users').doc(userCredential.user!.uid).set(userModel.toMap());
        return userModel;
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(Exception exception) onError,
  }) async {
    try {
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (fb.PhoneAuthCredential credential) async {
          // Automatic SMS resolution or instant validation on Android
          await _firebaseAuth.signInWithCredential(credential);
        },
        verificationFailed: (fb.FirebaseAuthException e) {
          onError(e);
        },
        codeSent: (String verificationId, int? resendToken) {
          onCodeSent(verificationId, resendToken);
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      onError(Exception(e.toString()));
    }
  }

  @override
  Future<UserEntity> signInWithPhoneNumber({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final credential = fb.PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      if (userCredential.user == null) {
        throw Exception('User is null after Phone OTP authentication.');
      }
      final userModel = await _fetchOrCreateUserDoc(userCredential.user!);
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
  Future<void> sendEmailVerification() async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      await user.sendEmailVerification();
    }
  }

  @override
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final fb.User? firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) return null;
    return await _fetchOrCreateUserDoc(firebaseUser);
  }

  @override
  Stream<UserEntity?> authStateChanges() {
    return _firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      try {
        return await _fetchOrCreateUserDoc(firebaseUser);
      } catch (e) {
        return null;
      }
    });
  }

  // Helper method to fetch or write placeholder document in Firestore
  Future<UserEntity> _fetchOrCreateUserDoc(fb.User user) async {
    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    if (userDoc.exists && userDoc.data() != null) {
      return UserModel.fromMap(userDoc.data()!, user.uid);
    } else {
      // Default fallback if created via a direct OAuth/Phone flow where doc is not initialized
      final userModel = UserModel(
        uid: user.uid,
        email: user.email ?? '',
        fullName: user.displayName ?? '',
        phone: user.phoneNumber ?? '',
        role: UserRole.applicant,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _firestore.collection('users').doc(user.uid).set(userModel.toMap());
      return userModel;
    }
  }
}
