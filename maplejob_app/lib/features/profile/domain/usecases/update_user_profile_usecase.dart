import '../../../auth/domain/entities/user_entity.dart';
import '../repositories/user_repository.dart';

class UpdateUserProfileUseCase {
  final UserRepository _repository;

  UpdateUserProfileUseCase(this._repository);

  Future<void> call(UserEntity user) {
    return _repository.updateUserProfile(user);
  }
}
