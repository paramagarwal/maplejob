import 'dart:typed_data';
import '../../../auth/domain/entities/user_entity.dart';

abstract class UserRepository {
  Future<UserEntity?> getUserProfile(String uid);
  
  Future<void> updateUserProfile(UserEntity user);

  Future<String> uploadResume(String uid, String filename, Uint8List fileBytes);
}
