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
    super.totalReports = 0,
    super.totalFavourites = 0,
    super.isFavourite = false,
    super.location,
    super.isTaken = false,
    super.sellerName,
    super.sellerAvatar,
    super.sellerVerified,
    super.sellerBusinessName,
    super.sellerId,
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
      totalReports: _parseInt(json['total_reports']),
      totalFavourites: _parseInt(json['total_favourites']),
      isFavourite: json['favourited_by_user'] as bool? ??
          json['is_favourite'] as bool? ??
          false,
      location: _parseLocation(json['location']),
      isTaken: json['is_taken'] as bool? ?? false,
      sellerName: _parseSellerName(json),
      sellerAvatar: _parseSellerAvatar(json),
      sellerVerified: _parseSellerVerified(json),
      sellerBusinessName: _parseSellerBusinessName(json),
      sellerId: _parseSellerId(json),
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

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  static Map<String, dynamic>? _extractSeller(dynamic json) {
    if (json is! Map<String, dynamic>) return null;
    final dynamic candidate =
        json['owner'] ?? json['user'] ?? json['seller'] ?? json['created_by'];
    if (candidate is Map<String, dynamic>) {
      return Map<String, dynamic>.from(candidate);
    }
    return null;
  }

  static String? _parseSellerName(Map<String, dynamic> json) {
    final Map<String, dynamic>? seller = _extractSeller(json);
    if (seller == null) return null;
    return _resolveString(
      seller['name'] ??
          seller['full_name'] ??
          seller['username'] ??
          seller['first_name'],
    );
  }

  static String? _parseSellerAvatar(Map<String, dynamic> json) {
    final Map<String, dynamic>? seller = _extractSeller(json);
    if (seller == null) return null;
    return _resolveString(
      seller['avatar'] ??
          seller['image'] ??
          seller['profile_image'] ??
          seller['photo'],
    );
  }

  static bool? _parseSellerVerified(Map<String, dynamic> json) {
    final Map<String, dynamic>? seller = _extractSeller(json);
    if (seller == null) return null;
    final dynamic value =
        seller['admin_verified'] ?? seller['is_verified'] ?? seller['verified'];
    if (value is bool) return value;
    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }
    if (value is num) return value != 0;
    return null;
  }

  static String? _parseSellerBusinessName(Map<String, dynamic> json) {
    final Map<String, dynamic>? seller = _extractSeller(json);
    if (seller == null) return null;
    return _resolveString(
      seller['business_name'] ??
          seller['businessName'] ??
          seller['company_name'] ??
          seller['companyName'],
    );
  }

  static int? _parseSellerId(Map<String, dynamic> json) {
    final Map<String, dynamic>? seller = _extractSeller(json);
    if (seller == null) return null;
    return _parseNullableInt(
        seller['id'] ?? seller['user_id'] ?? seller['userId']);
  }
}
