import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/usecase/update_profile_params.dart';
import '../../../../../core/usecase/usecase.dart';
import '../../../../auth/domain/entities/auth_entity.dart';
import '../../../../auth/domain/usecases/get_cached_session_usecase.dart';
import '../../../../auth/domain/usecases/get_profile_usecase.dart';
import '../../../../auth/domain/usecases/update_profile_usecase.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(
    this._getCachedSessionUseCase,
    this._getProfileUseCase,
    this._updateProfileUseCase,
  ) : super(const ProfileState());

  final GetCachedSessionUseCase _getCachedSessionUseCase;
  final GetProfileUseCase _getProfileUseCase;
  final UpdateProfileUseCase _updateProfileUseCase;

  Future<void> hydrate() async {
    final AuthSessionEntity? cachedSession =
        await _getCachedSessionUseCase(const NoParams());

    if (cachedSession != null) {
      emit(
        state.copyWith(
          user: cachedSession.user,
          status: ProfileStatus.success,
          clearMessage: true,
        ),
      );
    }

    await fetchProfile(showLoader: cachedSession == null);
  }

  Future<void> fetchProfile({bool showLoader = true}) async {
    if (showLoader) {
      emit(
        state.copyWith(
          status: ProfileStatus.loading,
          clearMessage: true,
        ),
      );
    } else {
      emit(state.copyWith(clearMessage: true));
    }

    final result = await _getProfileUseCase(const NoParams());
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: state.user == null
              ? ProfileStatus.failure
              : ProfileStatus.success,
          message: failure.message,
          isMessageError: true,
        ),
      ),
      (user) => emit(
        state.copyWith(
          status: ProfileStatus.success,
          user: user,
          clearMessage: true,
        ),
      ),
    );
  }

  Future<void> updateProfile(UpdateProfileParams params) async {
    if (state.isUpdating) return;

    emit(
      state.copyWith(
        isUpdating: true,
        clearMessage: true,
      ),
    );

    final result = await _updateProfileUseCase(params);
    result.fold(
      (failure) => emit(
        state.copyWith(
          isUpdating: false,
          message: failure.message,
          isMessageError: true,
        ),
      ),
      (user) => emit(
        state.copyWith(
          isUpdating: false,
          user: user,
          message: 'Profile updated successfully',
          isMessageError: false,
          status: ProfileStatus.success,
        ),
      ),
    );
  }

  void clearMessage() {
    if (state.message == null) return;
    emit(state.copyWith(clearMessage: true));
  }
}
