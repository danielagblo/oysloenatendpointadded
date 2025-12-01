class AccountDeleteRequestEntity {
  const AccountDeleteRequestEntity({
    required this.id,
    required this.userId,
    required this.status,
    this.reason,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final int userId;
  final String status;
  final String? reason;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}


