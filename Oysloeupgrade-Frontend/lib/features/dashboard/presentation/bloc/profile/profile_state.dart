import 'package:equatable/equatable.dart';

import '../../../../auth/domain/entities/auth_entity.dart';

enum ProfileStatus { initial, loading, success, failure }

class ProfileState extends Equatable {
  final ProfileStatus status;
  final AuthUserEntity? user;
  final bool isUpdating;
  final String? message;
  final bool isMessageError;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.user,
    this.isUpdating = false,
    this.message,
    this.isMessageError = false,
  });

  ProfileState copyWith({
    ProfileStatus? status,
    AuthUserEntity? user,
    bool? isUpdating,
    String? message,
    bool? isMessageError,
    bool clearMessage = false,
  }) {
    return ProfileState(
      status: status ?? this.status,
      user: user ?? this.user,
      isUpdating: isUpdating ?? this.isUpdating,
      message: clearMessage ? null : message ?? this.message,
      isMessageError:
          clearMessage ? false : isMessageError ?? this.isMessageError,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        status,
        user,
        isUpdating,
        message,
        isMessageError,
      ];
}
