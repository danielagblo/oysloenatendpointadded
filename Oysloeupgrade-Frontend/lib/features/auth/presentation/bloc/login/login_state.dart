import 'package:equatable/equatable.dart';

import '../../../domain/entities/auth_entity.dart';

enum LoginStatus { initial, submitting, success, failure, loggedOut }

class LoginState extends Equatable {
  const LoginState._({
    required this.status,
    this.session,
    this.errorMessage,
  });

  const LoginState.initial() : this._(status: LoginStatus.initial);

  const LoginState.submitting() : this._(status: LoginStatus.submitting);

  const LoginState.success(AuthSessionEntity session)
      : this._(status: LoginStatus.success, session: session);

  const LoginState.failure(String message)
      : this._(status: LoginStatus.failure, errorMessage: message);

  const LoginState.loggedOut() : this._(status: LoginStatus.loggedOut);

  final LoginStatus status;
  final AuthSessionEntity? session;
  final String? errorMessage;

  bool get isSubmitting => status == LoginStatus.submitting;
  bool get isSuccess => status == LoginStatus.success;
  bool get isFailure => status == LoginStatus.failure;
  bool get isLoggedOut => status == LoginStatus.loggedOut;

  @override
  List<Object?> get props => <Object?>[status, session, errorMessage];
}
