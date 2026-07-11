import '../../../auth/domain/entities/user_entity.dart';
import '../repositories/user_repository.dart';

class GetUserProfileUseCase {
  final UserRepository _repository;

  GetUserProfileUseCase(this._repository);

  Future<UserEntity?> call(String uid) {
    return _repository.getUserProfile(uid);
  }
}
