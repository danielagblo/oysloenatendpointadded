import '../../domain/entities/otp_entity.dart';

class OtpResponseModel extends OtpResponseEntity {
  const OtpResponseModel({required super.message, super.token = ''});

  factory OtpResponseModel.fromJson(Map<String, dynamic> json) {
    return OtpResponseModel(
      message: json['message']?.toString() ?? '',
      token: json['token']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'token': token,
    }..removeWhere(
        (_, value) => value == null || (value is String && value.isEmpty));
  }
}
