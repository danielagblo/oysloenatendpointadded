import '../../domain/entities/subcategory_entity.dart';

class SubcategoryModel extends SubcategoryEntity {
  const SubcategoryModel({
    required super.id,
    required super.name,
    required super.categoryId,
    super.description,
  });

  factory SubcategoryModel.fromJson(Map<String, dynamic> json) {
    return SubcategoryModel(
      id: json['id'] as int? ?? 0,
      name: _resolveString(json['name']) ?? '',
      categoryId: json['category'] as int? ?? json['category_id'] as int? ?? 0,
      description: _resolveString(json['description']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'category': categoryId,
      if (description != null) 'description': description,
    };
  }

  static String? _resolveString(dynamic value) {
    if (value == null) return null;
    final String resolved = value.toString().trim();
    return resolved.isEmpty ? null : resolved;
  }
}
