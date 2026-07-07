import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> signInWithEmailAndPassword(String email, String password);

  Future<void> sendPasswordResetEmail(String email);

  Future<void> signOut();

  Future<UserEntity?> getCurrentUser();

  Stream<UserEntity?> authStateChanges();
}
