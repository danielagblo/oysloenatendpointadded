import 'package:equatable/equatable.dart';

import '../../../domain/entities/otp_entity.dart';
import '../../../domain/entities/reset_password_entity.dart';

sealed class PasswordResetState extends Equatable {
  const PasswordResetState();

  @override
  List<Object?> get props => <Object?>[];
}

class PasswordResetInitial extends PasswordResetState {
  const PasswordResetInitial();
}

class PasswordResetSendingOtp extends PasswordResetState {
  const PasswordResetSendingOtp();
}

class PasswordResetOtpSent extends PasswordResetState {
  const PasswordResetOtpSent(this.response);

  final OtpResponseEntity response;

  @override
  List<Object?> get props => <Object?>[response];
}

class PasswordResetVerifyingOtp extends PasswordResetState {
  const PasswordResetVerifyingOtp();
}

class PasswordResetOtpVerified extends PasswordResetState {
  const PasswordResetOtpVerified(this.response);

  final OtpResponseEntity response;

  @override
  List<Object?> get props => <Object?>[response];
}

class PasswordResetSubmitting extends PasswordResetState {
  const PasswordResetSubmitting();
}

class PasswordResetSuccess extends PasswordResetState {
  const PasswordResetSuccess(this.response);

  final ResetPasswordResponseEntity response;

  @override
  List<Object?> get props => <Object?>[response];
}

class PasswordResetError extends PasswordResetState {
  const PasswordResetError(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
