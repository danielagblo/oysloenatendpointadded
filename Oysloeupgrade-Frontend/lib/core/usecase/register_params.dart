import 'package:equatable/equatable.dart';

class RegisterParams extends Equatable {
  final String email;
  final String phone;
  final String password;
  final String name;
  final String? address;
  final String? referralCode;

  const RegisterParams({
    required this.email,
    required this.phone,
    required this.password,
    required this.name,
    this.address,
    this.referralCode,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'phone': phone,
        'password': password,
        'name': name,
        'address': address,
        'referral_code': referralCode,
      }..removeWhere(
          (_, value) => value == null || (value is String && value.isEmpty));

  @override
  List<Object?> get props => [
        email,
        phone,
        password,
        name,
        address,
        referralCode,
      ];
}
