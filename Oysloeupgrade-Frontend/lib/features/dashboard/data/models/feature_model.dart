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

    // Debug: Print the raw JSON to see what's coming from API
    print('Feature JSON: $json');

    if (json['options'] != null) {
      if (json['options'] is List) {
        options = (json['options'] as List).map((e) => e.toString()).toList();
      } else if (json['options'] is String) {
        // Handle comma-separated string options
        final optionsStr = json['options'] as String;
        if (optionsStr.trim().isNotEmpty) {
          options = optionsStr.split(',').map((e) => e.trim()).toList();
        }
      }
    }

    // Check for alternative field names
    if (options == null && json['values'] != null) {
      if (json['values'] is List) {
        options = (json['values'] as List).map((e) => e.toString()).toList();
      }
    }

    if (options == null && json['choices'] != null) {
      if (json['choices'] is List) {
        options = (json['choices'] as List).map((e) => e.toString()).toList();
      }
    }

    print('Feature ${json['name']} has options: $options');

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
