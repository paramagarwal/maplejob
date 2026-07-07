import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> signInWithEmailAndPassword(String email, String password);
  
  Future<UserEntity> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  });

  Future<UserEntity> signInWithGoogle();

  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(Exception exception) onError,
  });

  Future<UserEntity> signInWithPhoneNumber({
    required String verificationId,
    required String smsCode,
  });

  Future<void> sendPasswordResetEmail(String email);

  Future<void> sendEmailVerification();

  Future<void> signOut();

  Future<UserEntity?> getCurrentUser();

  Stream<UserEntity?> authStateChanges();
}
