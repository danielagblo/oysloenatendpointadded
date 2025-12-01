import 'package:hive/hive.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/category_model.dart';

abstract class CategoriesLocalDataSource {
  Future<void> cacheCategories(List<CategoryModel> categories);
  Future<CachedCategories?> readCategories();
  Future<void> clearCategories();
}

class CachedCategories {
  const CachedCategories({
    required this.categories,
    this.fetchedAt,
  });

  final List<CategoryModel> categories;
  final DateTime? fetchedAt;
}

class CategoriesLocalDataSourceImpl implements CategoriesLocalDataSource {
  CategoriesLocalDataSourceImpl({required Box<dynamic> box}) : _box = box;

  static const String _categoriesKey = 'cached_categories';

  final Box<dynamic> _box;

  @override
  Future<void> cacheCategories(List<CategoryModel> categories) async {
    try {
      await _box.put(_categoriesKey, <String, dynamic>{
        'fetched_at': DateTime.now().toIso8601String(),
        'items': categories.map((CategoryModel category) => category.toJson()).toList(),
      });
    } catch (error) {
      throw CacheException(error.toString());
    }
  }

  @override
  Future<CachedCategories?> readCategories() async {
    try {
      final dynamic raw = _box.get(_categoriesKey);
      if (raw is Map) {
        final Map<String, dynamic> normalized =
            _normalizeMap(raw.cast<dynamic, dynamic>());
        final List<dynamic> items =
            normalized['items'] as List<dynamic>? ?? const <dynamic>[];
        final List<CategoryModel> categories = items
            .whereType<Map<dynamic, dynamic>>()
            .map((Map<dynamic, dynamic> item) =>
                CategoryModel.fromJson(_normalizeMap(item)))
            .toList();

        final String? fetchedRaw = normalized['fetched_at'] as String?;
        final DateTime? fetchedAt =
            fetchedRaw != null ? DateTime.tryParse(fetchedRaw) : null;

        return CachedCategories(
          categories: categories,
          fetchedAt: fetchedAt,
        );
      }
      return null;
    } catch (error) {
      throw CacheException(error.toString());
    }
  }

  @override
  Future<void> clearCategories() async {
    try {
      await _box.delete(_categoriesKey);
    } catch (error) {
      throw CacheException(error.toString());
    }
  }
}

Map<String, dynamic> _normalizeMap(Map<dynamic, dynamic> source) {
  return source.map((dynamic key, dynamic value) {
    return MapEntry<String, dynamic>(
      key.toString(),
      _normalizeValue(value),
    );
  });
}

dynamic _normalizeValue(dynamic value) {
  if (value is Map) {
    return _normalizeMap(value.cast<dynamic, dynamic>());
  }
  if (value is List) {
    return value.map(_normalizeValue).toList();
  }
  return value;
}
