import '../../../auth/domain/entities/auth_entity.dart';

class EditProfileDraft {
  final String? name;
  final String? businessName;
  final String? firstNumber;
  final String? secondNumber;
  final String? nationalId;
  final String? email;
  final String? address;
  final String? accountName;
  final String? accountNumber;
  final String? mobileNetwork;
  final String? profileImageUrl;
  final String? businessLogoUrl;
  final String? idFrontUrl;
  final String? idBackUrl;
  final String? profileImagePath;
  final String? businessLogoPath;
  final String? idFrontPath;
  final String? idBackPath;

  const EditProfileDraft({
    this.name,
    this.businessName,
    this.firstNumber,
    this.secondNumber,
    this.nationalId,
    this.email,
    this.address,
    this.accountName,
    this.accountNumber,
    this.mobileNetwork,
    this.profileImageUrl,
    this.businessLogoUrl,
    this.idFrontUrl,
    this.idBackUrl,
    this.profileImagePath,
    this.businessLogoPath,
    this.idFrontPath,
    this.idBackPath,
  });

  factory EditProfileDraft.fromUser(AuthUserEntity user) {
    return EditProfileDraft(
      name: user.name,
      businessName: user.businessName,
      firstNumber: user.phone,
      secondNumber: user.secondNumber,
      nationalId: user.idNumber,
      email: user.email,
      address: user.address,
      accountName: user.accountName,
      accountNumber: user.accountNumber,
      mobileNetwork: user.mobileNetwork,
      profileImageUrl: user.avatar,
      businessLogoUrl: user.businessLogo,
      idFrontUrl: user.idFrontPage,
      idBackUrl: user.idBackPage,
    );
  }

  EditProfileDraft copyWith({
    String? name,
    String? businessName,
    String? firstNumber,
    String? secondNumber,
    String? nationalId,
    String? email,
    String? address,
    String? accountName,
    String? accountNumber,
    String? mobileNetwork,
    String? profileImageUrl,
    String? businessLogoUrl,
    String? idFrontUrl,
    String? idBackUrl,
    String? profileImagePath,
    String? businessLogoPath,
    String? idFrontPath,
    String? idBackPath,
  }) {
    return EditProfileDraft(
      name: name ?? this.name,
      businessName: businessName ?? this.businessName,
      firstNumber: firstNumber ?? this.firstNumber,
      secondNumber: secondNumber ?? this.secondNumber,
      nationalId: nationalId ?? this.nationalId,
      email: email ?? this.email,
      address: address ?? this.address,
      accountName: accountName ?? this.accountName,
      accountNumber: accountNumber ?? this.accountNumber,
      mobileNetwork: mobileNetwork ?? this.mobileNetwork,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      businessLogoUrl: businessLogoUrl ?? this.businessLogoUrl,
      idFrontUrl: idFrontUrl ?? this.idFrontUrl,
      idBackUrl: idBackUrl ?? this.idBackUrl,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      businessLogoPath: businessLogoPath ?? this.businessLogoPath,
      idFrontPath: idFrontPath ?? this.idFrontPath,
      idBackPath: idBackPath ?? this.idBackPath,
    );
  }
}
