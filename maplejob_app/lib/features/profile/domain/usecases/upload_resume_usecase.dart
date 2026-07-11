import 'dart:typed_data';
import '../repositories/user_repository.dart';

class UploadResumeUseCase {
  final UserRepository _repository;

  UploadResumeUseCase(this._repository);

  Future<String> call(String uid, String filename, Uint8List fileBytes) {
    return _repository.uploadResume(uid, filename, fileBytes);
  }
}
