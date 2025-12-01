import 'package:equatable/equatable.dart';

class ResetPasswordResponseEntity extends Equatable {
  const ResetPasswordResponseEntity({
    this.status = '',
    this.message = '',
  });

  final String status;
  final String message;

  @override
  List<Object?> get props => <Object?>[status, message];
}
