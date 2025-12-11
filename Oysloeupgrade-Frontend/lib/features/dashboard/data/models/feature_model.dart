import '../../domain/entities/feature_entity.dart';

class FeatureModel extends FeatureEntity {
  const FeatureModel({
    required super.id,
    required super.name,
    required super.categoryId,
    super.description,
    super.options,
  });

  factory FeatureModel.fromJson(Map<String, dynamic> json) {
    List<String>? options;

    // Parse options from the API - extract 'value' field from each object
    if (json['options'] != null && json['options'] is List) {
      options = (json['options'] as List)
          .map((item) {
            if (item is Map<String, dynamic>) {
              // Extract the 'value' field from the JSON object
              final value = item['value'];
              return value?.toString().trim() ?? '';
            }
            return item.toString().trim();
          })
          .where((value) => value.isNotEmpty)
          .toList();
    } else if (json['values'] != null && json['values'] is List) {
      options = (json['values'] as List)
          .map((item) {
            if (item is Map<String, dynamic>) {
              final value = item['value'];
              return value?.toString().trim() ?? '';
            }
            return item.toString().trim();
          })
          .where((value) => value.isNotEmpty)
          .toList();
    } else if (json['choices'] != null && json['choices'] is List) {
      options = (json['choices'] as List)
          .map((item) {
            if (item is Map<String, dynamic>) {
              final value = item['value'];
              return value?.toString().trim() ?? '';
            }
            return item.toString().trim();
          })
          .where((value) => value.isNotEmpty)
          .toList();
    }

    return FeatureModel(
      id: json['id'] as int? ?? 0,
      name: _resolveString(json['name']) ?? '',
      categoryId: json['category'] as int? ??
          json['category_id'] as int? ??
          json['subcategory'] as int? ??
          0,
      description: _resolveString(json['description']),
      options: options,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'category': categoryId,
      if (description != null) 'description': description,
      if (options != null) 'options': options,
    };
  }

  static String? _resolveString(dynamic value) {
    if (value == null) return null;
    final String resolved = value.toString().trim();
    return resolved.isEmpty ? null : resolved;
  }
}
