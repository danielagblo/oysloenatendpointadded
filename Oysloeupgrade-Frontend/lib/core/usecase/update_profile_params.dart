import 'package:equatable/equatable.dart';

class UpdateProfileParams extends Equatable {
  final String? email;
  final String? phone;
  final String? name;
  final String? address;
  final String? secondNumber;
  final String? businessName;
  final String? idNumber;
  final String? accountName;
  final String? accountNumber;
  final String? mobileNetwork;
  final String? preferredNotificationEmail;
  final String? preferredNotificationPhone;
  final String? avatarFilePath;
  final String? businessLogoFilePath;
  final String? idFrontFilePath;
  final String? idBackFilePath;

  const UpdateProfileParams({
    this.email,
    this.phone,
    this.name,
    this.address,
    this.secondNumber,
    this.businessName,
    this.idNumber,
    this.accountName,
    this.accountNumber,
    this.mobileNetwork,
    this.preferredNotificationEmail,
    this.preferredNotificationPhone,
    this.avatarFilePath,
    this.businessLogoFilePath,
    this.idFrontFilePath,
    this.idBackFilePath,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{
      'email': _normalize(email),
      'phone': _normalize(phone),
      'name': _normalize(name),
      'address': _normalize(address),
      'second_number': _normalize(secondNumber),
      'business_name': _normalize(businessName),
      'id_number': _normalize(idNumber),
      'account_name': _normalize(accountName),
      'account_number': _normalize(accountNumber),
      'mobile_network': _normalize(mobileNetwork),
      'preferred_notification_email': _normalize(preferredNotificationEmail),
      'preferred_notification_phone': _normalize(preferredNotificationPhone),
    };
    data.removeWhere(
      (_, value) => value == null || (value is String && value.isEmpty),
    );
    return data;
  }

  String? _normalize(String? value) {
    if (value == null) return null;
    final String trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  @override
  List<Object?> get props => <Object?>[
        email,
        phone,
        name,
        address,
        secondNumber,
        businessName,
        idNumber,
        accountName,
        accountNumber,
        mobileNetwork,
        preferredNotificationEmail,
        preferredNotificationPhone,
        avatarFilePath,
        businessLogoFilePath,
        idFrontFilePath,
        idBackFilePath,
      ];
}
