import '../../domain/entities/account_delete_request_entity.dart';
import 'package:meta/meta.dart';

@immutable
class AccountDeleteRequestModel extends AccountDeleteRequestEntity {
  const AccountDeleteRequestModel({
    required super.id,
    required super.userId,
    required super.status,
    super.reason,
    super.createdAt,
    super.updatedAt,
  });

  factory AccountDeleteRequestModel.fromJson(Map<String, dynamic> json) {
    return AccountDeleteRequestModel(
      id: json['id'] is int ? json['id'] as int : int.parse('${json['id']}'),
      userId: json['user'] is int
          ? json['user'] as int
          : int.tryParse('${json['user']}') ?? 0,
      status: (json['status'] ?? '').toString(),
      reason: json['reason']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }
}


