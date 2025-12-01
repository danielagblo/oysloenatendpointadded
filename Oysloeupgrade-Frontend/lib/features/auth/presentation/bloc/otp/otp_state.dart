import 'package:equatable/equatable.dart';

import '../../../domain/entities/auth_entity.dart';
import '../../../domain/entities/otp_entity.dart';

sealed class OtpState extends Equatable {
  const OtpState();

  @override
  List<Object?> get props => [];
}

class OtpInitial extends OtpState {
  const OtpInitial();
}

class OtpSending extends OtpState {
  const OtpSending();
}

class OtpSent extends OtpState {
  final OtpResponseEntity response;

  const OtpSent(this.response);

  @override
  List<Object?> get props => [response];
}

class OtpVerifying extends OtpState {
  const OtpVerifying();
}

class OtpVerified extends OtpState {
  final AuthSessionEntity session;

  const OtpVerified(this.session);

  @override
  List<Object?> get props => [session];
}

class OtpError extends OtpState {
  final String message;

  const OtpError(this.message);

  @override
  List<Object?> get props => [message];
}