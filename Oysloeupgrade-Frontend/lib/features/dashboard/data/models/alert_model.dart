import '../../../../core/utils/date_utils.dart';
import '../../domain/entities/alert_entity.dart';

class AlertModel extends AlertEntity {
  const AlertModel({
    required super.id,
    required super.title,
    required super.body,
    required super.kind,
    required super.isRead,
    required super.createdAt,
  });

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    return AlertModel(
      id: _parseId(json['id']),
      title: _parseString(json['title']) ?? '',
      body: _parseString(json['body']) ?? '',
      kind: _parseString(json['kind']) ?? '',
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateUtilsExt.parseOrEpoch(json['created_at'] as String?),
    );
  }

  factory AlertModel.fromEntity(AlertEntity entity) {
    return AlertModel(
      id: entity.id,
      title: entity.title,
      body: entity.body,
      kind: entity.kind,
      isRead: entity.isRead,
      createdAt: entity.createdAt,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'title': title,
        'body': body,
        'kind': kind,
        'is_read': isRead,
        'created_at': createdAt.toUtc().toIso8601String(),
      };

  static int _parseId(dynamic value) {
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  static String? _parseString(dynamic value) {
    if (value == null) return null;
    final String result = value.toString().trim();
    return result.isEmpty ? null : result;
  }
}
