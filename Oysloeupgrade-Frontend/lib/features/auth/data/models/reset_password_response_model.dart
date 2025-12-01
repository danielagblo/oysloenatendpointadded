import '../../domain/entities/reset_password_entity.dart';

class ResetPasswordResponseModel extends ResetPasswordResponseEntity {
  const ResetPasswordResponseModel({
    super.status = '',
    super.message = '',
  });

  factory ResetPasswordResponseModel.fromJson(Map<String, dynamic> json) {
    return ResetPasswordResponseModel(
      status: json['status']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
    );
  }
}
