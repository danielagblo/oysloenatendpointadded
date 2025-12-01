import 'package:equatable/equatable.dart';

class OtpResponseEntity extends Equatable {
  final String message;
  final String token;

  const OtpResponseEntity({
    required this.message,
    this.token = '',
  });

  @override
  List<Object?> get props => [message, token];
}
