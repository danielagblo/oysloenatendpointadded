import 'package:equatable/equatable.dart';

class SendOtpParams extends Equatable {
  final String phone;

  const SendOtpParams({required this.phone});

  Map<String, String> toQueryParams() => {'phone': phone};

  @override
  List<Object?> get props => [phone];
}

class VerifyOtpParams extends Equatable {
  final String phone;
  final String otp;

  const VerifyOtpParams({
    required this.phone,
    required this.otp,
  });

  Map<String, dynamic> toJson() => {
        'phone': phone,
        'otp': otp,
      };

  @override
  List<Object?> get props => [phone, otp];
}