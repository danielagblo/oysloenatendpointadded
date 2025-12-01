import 'package:equatable/equatable.dart';

class AuthUserEntity extends Equatable {
  final String id;
  final String email;
  final String phone;
  final String name;
  final int? activeAds;
  final int? takenAds;
  final DateTime? lastLogin;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? address;
  final String? avatar;
  final String? businessName;
  final String? idNumber;
  final String? secondNumber;
  final String? businessLogo;
  final String? idFrontPage;
  final String? idBackPage;
  final String? accountNumber;
  final String? accountName;
  final String? mobileNetwork;
  final bool? deleted;
  final String? level;
  final int? referralPoints;
  final String? referralCode;
  final bool? isActive;
  final bool? isStaff;
  final bool? isSuperuser;
  final bool? createdFromApp;
  final bool? phoneVerified;
  final bool? emailVerified;
  final String? preferredNotificationEmail;
  final String? preferredNotificationPhone;
  final bool? adminVerified;

  const AuthUserEntity({
    required this.id,
    required this.email,
    required this.phone,
    required this.name,
    this.activeAds,
    this.takenAds,
    this.lastLogin,
    this.createdAt,
    this.updatedAt,
    this.address,
    this.avatar,
    this.businessName,
    this.idNumber,
    this.secondNumber,
    this.businessLogo,
    this.idFrontPage,
    this.idBackPage,
    this.accountNumber,
    this.accountName,
    this.mobileNetwork,
    this.deleted,
    this.level,
    this.referralPoints,
    this.referralCode,
    this.isActive,
    this.isStaff,
    this.isSuperuser,
    this.createdFromApp,
    this.phoneVerified,
    this.emailVerified,
    this.preferredNotificationEmail,
    this.preferredNotificationPhone,
    this.adminVerified,
  });

  @override
  List<Object?> get props => [
        id,
        email,
        phone,
        name,
        activeAds,
        takenAds,
        lastLogin,
        createdAt,
        updatedAt,
        address,
        avatar,
        businessName,
        idNumber,
        secondNumber,
        businessLogo,
        idFrontPage,
        idBackPage,
        accountNumber,
        accountName,
        mobileNetwork,
        deleted,
        level,
        referralPoints,
        referralCode,
        isActive,
        isStaff,
        isSuperuser,
        createdFromApp,
        phoneVerified,
        emailVerified,
        preferredNotificationEmail,
        preferredNotificationPhone,
        adminVerified,
      ];
}

class AuthSessionEntity extends Equatable {
  final AuthUserEntity user;
  final String token;

  const AuthSessionEntity({required this.user, required this.token});

  @override
  List<Object?> get props => [user, token];
}
