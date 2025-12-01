import 'package:equatable/equatable.dart';

class ResetPasswordParams extends Equatable {
  const ResetPasswordParams({
    required this.phone,
    required this.newPassword,
    required this.confirmPassword,
    required this.token,
  });

  final String phone;
  final String newPassword;
  final String confirmPassword;
  final String token;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'phone': phone,
        'new_password': newPassword,
        'confirm_password': confirmPassword,
      };

  @override
  List<Object?> get props =>
      <Object?>[phone, newPassword, confirmPassword, token];
}
