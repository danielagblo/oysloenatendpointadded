import 'package:equatable/equatable.dart';

class LoginParams extends Equatable {
  final String email;
  final String password;

  const LoginParams({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => <String, dynamic>{
        'email': email,
        'password': password,
      };

  @override
  List<Object?> get props => <Object?>[email, password];
}
