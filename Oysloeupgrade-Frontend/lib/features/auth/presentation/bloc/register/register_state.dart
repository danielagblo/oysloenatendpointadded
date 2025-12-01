import 'package:equatable/equatable.dart';

import '../../../domain/entities/auth_entity.dart';

enum RegisterStatus { initial, submitting, success, failure }

class RegisterState extends Equatable {
  final RegisterStatus status;
  final AuthSessionEntity? session;
  final String? errorMessage;

  const RegisterState._({
    required this.status,
    this.session,
    this.errorMessage,
  });

  const RegisterState.initial() : this._(status: RegisterStatus.initial);

  const RegisterState.submitting()
      : this._(status: RegisterStatus.submitting);

  const RegisterState.success(AuthSessionEntity session)
      : this._(status: RegisterStatus.success, session: session);

  const RegisterState.failure(String message)
      : this._(status: RegisterStatus.failure, errorMessage: message);

  bool get isSubmitting => status == RegisterStatus.submitting;
  bool get isSuccess => status == RegisterStatus.success;
  bool get isFailure => status == RegisterStatus.failure;

  @override
  List<Object?> get props => [status, session, errorMessage];
}
