import '../../domain/entities/auth_entity.dart';

class AuthUserModel extends AuthUserEntity {
  const AuthUserModel({
    required super.id,
    required super.email,
    required super.phone,
    required super.name,
    super.activeAds,
    super.takenAds,
    super.lastLogin,
    super.createdAt,
    super.updatedAt,
    super.address,
    super.avatar,
    super.businessName,
    super.idNumber,
    super.secondNumber,
    super.businessLogo,
    super.idFrontPage,
    super.idBackPage,
    super.accountNumber,
    super.accountName,
    super.mobileNetwork,
    super.deleted,
    super.level,
    super.referralPoints,
    super.referralCode,
    super.isActive,
    super.isStaff,
    super.isSuperuser,
    super.createdFromApp,
    super.phoneVerified,
    super.emailVerified,
    super.preferredNotificationEmail,
    super.preferredNotificationPhone,
    super.adminVerified,
  });

  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    return AuthUserModel(
      id: json['id'].toString(),
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      name: json['name'] as String? ?? '',
      activeAds: _parseInt(json['active_ads']),
      takenAds: _parseInt(json['taken_ads']),
      lastLogin: _parseDate(json['last_login']),
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
      address: json['address'] as String?,
      avatar: json['avatar'] as String?,
      businessName: json['business_name'] as String?,
      idNumber: json['id_number'] as String?,
      secondNumber: json['second_number'] as String?,
      businessLogo: json['business_logo'] as String?,
      idFrontPage: json['id_front_page'] as String?,
      idBackPage: json['id_back_page'] as String?,
      accountNumber: json['account_number'] as String?,
      accountName: json['account_name'] as String?,
      mobileNetwork: json['mobile_network'] as String?,
      deleted: json['deleted'] as bool?,
      level: json['level'] as String?,
      referralPoints: json['referral_points'] is int
          ? json['referral_points'] as int
          : int.tryParse('${json['referral_points']}'),
      referralCode: json['referral_code'] as String?,
      isActive: json['is_active'] as bool?,
      isStaff: json['is_staff'] as bool?,
      isSuperuser: json['is_superuser'] as bool?,
      createdFromApp: json['created_from_app'] as bool?,
      phoneVerified: json['phone_verified'] as bool?,
      emailVerified: json['email_verified'] as bool?,
      preferredNotificationEmail:
          json['preferred_notification_email'] as String?,
      preferredNotificationPhone:
          json['preferred_notification_phone'] as String?,
      adminVerified: json['admin_verified'] as bool?,
    );
  }

  factory AuthUserModel.fromEntity(AuthUserEntity entity) {
    return AuthUserModel(
      id: entity.id,
      email: entity.email,
      phone: entity.phone,
      name: entity.name,
      activeAds: entity.activeAds,
      takenAds: entity.takenAds,
      lastLogin: entity.lastLogin,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      address: entity.address,
      avatar: entity.avatar,
      businessName: entity.businessName,
      idNumber: entity.idNumber,
      secondNumber: entity.secondNumber,
      businessLogo: entity.businessLogo,
      idFrontPage: entity.idFrontPage,
      idBackPage: entity.idBackPage,
      accountNumber: entity.accountNumber,
      accountName: entity.accountName,
      mobileNetwork: entity.mobileNetwork,
      deleted: entity.deleted,
      level: entity.level,
      referralPoints: entity.referralPoints,
      referralCode: entity.referralCode,
      isActive: entity.isActive,
      isStaff: entity.isStaff,
      isSuperuser: entity.isSuperuser,
      createdFromApp: entity.createdFromApp,
      phoneVerified: entity.phoneVerified,
      emailVerified: entity.emailVerified,
      preferredNotificationEmail: entity.preferredNotificationEmail,
      preferredNotificationPhone: entity.preferredNotificationPhone,
      adminVerified: entity.adminVerified,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'email': email,
        'phone': phone,
        'name': name,
        'active_ads': activeAds,
        'taken_ads': takenAds,
        'last_login': lastLogin?.toIso8601String(),
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'address': address,
        'avatar': avatar,
        'business_name': businessName,
        'id_number': idNumber,
        'second_number': secondNumber,
        'business_logo': businessLogo,
        'id_front_page': idFrontPage,
        'id_back_page': idBackPage,
        'account_number': accountNumber,
        'account_name': accountName,
        'mobile_network': mobileNetwork,
        'deleted': deleted,
        'level': level,
        'referral_points': referralPoints,
        'referral_code': referralCode,
        'is_active': isActive,
        'is_staff': isStaff,
        'is_superuser': isSuperuser,
        'created_from_app': createdFromApp,
        'phone_verified': phoneVerified,
        'email_verified': emailVerified,
        'preferred_notification_email': preferredNotificationEmail,
        'preferred_notification_phone': preferredNotificationPhone,
        'admin_verified': adminVerified,
      }..removeWhere(
          (_, value) => value == null || (value is String && value.isEmpty),
        );
}

class AuthSessionModel extends AuthSessionEntity {
  const AuthSessionModel({required super.user, required super.token});

  factory AuthSessionModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> userJson =
        json['user'] as Map<String, dynamic>? ?? const <String, dynamic>{};
    return AuthSessionModel(
      user: AuthUserModel.fromJson(userJson),
      token: json['token'] as String? ?? '',
    );
  }

  factory AuthSessionModel.fromEntity(AuthSessionEntity entity) {
    final AuthUserModel userModel = entity.user is AuthUserModel
        ? entity.user as AuthUserModel
        : AuthUserModel.fromEntity(entity.user);
    return AuthSessionModel(user: userModel, token: entity.token);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'user': (user is AuthUserModel
                ? user as AuthUserModel
                : AuthUserModel.fromEntity(user))
            .toJson(),
        'token': token,
      };
}

DateTime? _parseDate(dynamic raw) {
  if (raw == null) return null;
  if (raw is DateTime) return raw;
  if (raw is String && raw.isNotEmpty) {
    return DateTime.tryParse(raw);
  }
  return null;
}

int? _parseInt(dynamic raw) {
  if (raw == null) return null;
  if (raw is int) return raw;
  if (raw is String) {
    return int.tryParse(raw);
  }
  return null;
}
