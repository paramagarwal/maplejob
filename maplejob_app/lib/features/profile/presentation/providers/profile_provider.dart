import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/data/models/user_model.dart';
import '../../domain/repositories/user_repository.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepositoryImpl();
});

class ProfileNotifier extends StateNotifier<AsyncValue<UserEntity?>> {
  final UserRepository _userRepository;
  final Ref _ref;

  ProfileNotifier(this._userRepository, this._ref) : super(const AsyncValue.loading()) {
    _init();
  }

  void _init() {
    // Listen to Auth State. Whenever auth state changes, load the profile
    _ref.listen<AsyncValue<UserEntity?>>(authControllerProvider, (previous, next) {
      next.when(
        data: (user) {
          if (user != null) {
            loadProfile(user.uid);
          } else {
            state = const AsyncValue.data(null);
          }
        },
        error: (err, stack) => state = AsyncValue.error(err, stack),
        loading: () => state = const AsyncValue.loading(),
      );
    });

    // Initial load if auth user is already available
    final authUser = _ref.read(authControllerProvider).value;
    if (authUser != null) {
      loadProfile(authUser.uid);
    } else {
      state = const AsyncValue.data(null);
    }
  }

  Future<void> loadProfile(String uid) async {
    state = const AsyncValue.loading();
    try {
      final profile = await _userRepository.getUserProfile(uid);
      state = AsyncValue.data(profile);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateProfile(UserEntity updatedUser) async {
    state = const AsyncValue.loading();
    try {
      await _userRepository.updateUserProfile(updatedUser);
      state = AsyncValue.data(updatedUser);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> uploadAndSetResume(String filename, Uint8List fileBytes) async {
    final user = state.value;
    if (user == null) return;
    
    state = const AsyncValue.loading();
    try {
      final downloadUrl = await _userRepository.uploadResume(user.uid, filename, fileBytes);
      final updatedUser = (user as UserModel).copyWith(
        resumeUrl: downloadUrl,
        resumeName: filename,
      );
      await _userRepository.updateUserProfile(updatedUser);
      state = AsyncValue.data(updatedUser);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}

final profileNotifierProvider = StateNotifierProvider<ProfileNotifier, AsyncValue<UserEntity?>>((ref) {
  return ProfileNotifier(ref.watch(userRepositoryProvider), ref);
});
