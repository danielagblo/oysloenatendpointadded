import '../../../../core/utils/date_utils.dart';
import '../../domain/entities/product_entity.dart';

class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.pid,
    required super.name,
    required super.description,
    required super.price,
    required super.type,
    required super.status,
    required super.image,
    required super.images,
    required super.productFeatures,
    required super.category,
    required super.createdAt,
    required super.updatedAt,
    super.location,
    super.isTaken = false,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as int? ?? 0,
      pid: _resolveString(json['pid']) ?? '',
      name: _resolveString(json['name']) ?? '',
      description: _resolveString(json['description']) ?? '',
      price: _resolveString(json['price']) ?? '',
      type: _resolveString(json['type']) ?? '',
      status: _resolveString(json['status']) ?? '',
      image: _resolveString(json['image']) ?? '',
      images: _parseImages(json['images']),
      productFeatures: _parseProductFeatures(json['product_features']),
      category: _parseCategory(json['category']),
      createdAt: DateUtilsExt.parseOrEpoch(json['created_at'] as String?),
      updatedAt: DateUtilsExt.parseOrEpoch(json['updated_at'] as String?),
      location: _parseLocation(json['location']),
      isTaken: json['is_taken'] as bool? ?? false,
    );
  }

  static List<String> _parseImages(dynamic value) {
    if (value is List<dynamic>) {
      return value
          .map((dynamic item) {
            if (item is Map<String, dynamic>) {
              return _resolveString(item['image']);
            }
            return _resolveString(item);
          })
          .whereType<String>()
          .toList();
    }
    return <String>[];
  }

  static int _parseCategory(dynamic value) {
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    if (value is Map<String, dynamic>) {
      final dynamic idCandidate = value['id'];
      if (idCandidate is int) return idCandidate;
      if (idCandidate is String) {
        return int.tryParse(idCandidate) ?? 0;
      }
    }
    return 0;
  }

  static List<String> _parseProductFeatures(dynamic value) {
    if (value is List<dynamic>) {
      return value
          .map<String?>((dynamic item) => _formatFeature(item))
          .whereType<String>()
          .toList();
    }
    return <String>[];
  }

  static String? _formatFeature(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      String? name = _resolveString(raw['name']) ??
          _resolveString(raw['label']) ??
          _resolveString(raw['title']);

      if (name == null && raw['feature'] is Map<String, dynamic>) {
        final Map<String, dynamic> featureMap =
            Map<String, dynamic>.from(raw['feature'] as Map);
        name = _resolveString(featureMap['name']) ??
            _resolveString(featureMap['label']) ??
            _resolveString(featureMap['title']);
      }

      final String? value =
          _resolveString(raw['value']) ?? _resolveString(raw['description']);

      if (name != null && value != null) {
        return '$name: $value';
      }

      return value ?? name;
    }

    if (raw == null) return null;

    return _resolveString(raw);
  }

  static String? _resolveString(dynamic value) {
    if (value == null) return null;
    final String result = value.toString().trim();
    return result.isEmpty ? null : result;
  }

  static ProductLocation? _parseLocation(dynamic value) {
    if (value is Map<String, dynamic>) {
      return ProductLocation(
        id: _parseNullableInt(value['id']),
        name: _resolveString(value['name']),
        region: _resolveString(value['region']),
      );
    }

    final String? resolved = _resolveString(value);
    if (resolved != null) {
      return ProductLocation(name: resolved);
    }
    return null;
  }

  static int? _parseNullableInt(dynamic value) {
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }
}
