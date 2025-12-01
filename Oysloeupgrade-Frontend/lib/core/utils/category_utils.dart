import 'dart:collection';

import 'package:oysloe_mobile/features/dashboard/domain/entities/product_entity.dart';

/// Represents an aggregated stat for a category.
class CategoryStat {
  final int categoryId;
  final String label; // Display name resolved by caller or fallback
  final int count;
  /// Ratio within the considered (non-excluded) population. 0..1
  final double ratio;

  const CategoryStat({
    required this.categoryId,
    required this.label,
    required this.count,
    required this.ratio,
  });
}

/// Signature to resolve a category id to a display name.
typedef CategoryNameResolver = String? Function(int categoryId);

/// Compute top-N categories by count, excluding any category whose resolved
/// display name equals [excludedLabel] (case-insensitive) or whose id is in
/// [excludedCategoryIds].
///
/// If [resolveName] returns null for a given id, a fallback name like
/// "Category &lt;id&gt;" will be used.
List<CategoryStat> computeTopCategories(
  List<ProductEntity> products, {
  int topN = 5,
  CategoryNameResolver? resolveName,
  Set<int> excludedCategoryIds = const <int>{},
  String excludedLabel = 'services',
}) {
  if (products.isEmpty || topN <= 0) return const <CategoryStat>[];

  final Map<int, int> counts = <int, int>{};

  for (final ProductEntity p in products) {
    final int cat = p.category;
    if (excludedCategoryIds.contains(cat)) continue;

    final String? name = resolveName?.call(cat);
    if (name != null && name.toLowerCase().trim() == excludedLabel) continue;

    counts.update(cat, (prev) => prev + 1, ifAbsent: () => 1);
  }

  // Total within considered population (post-exclusion)
  final int total = counts.values.fold(0, (a, b) => a + b);
  if (total == 0) return const <CategoryStat>[];

  // Create a stable list of entries for deterministic ordering on ties.
  final List<MapEntry<int, int>> entries = counts.entries.toList()
    ..sort((a, b) {
      final int cmp = b.value.compareTo(a.value);
      if (cmp != 0) return cmp;
      return a.key.compareTo(b.key); // tie-breaker by ID asc
    });

  final int take = topN.clamp(0, entries.length);
  final List<CategoryStat> stats = <CategoryStat>[];

  for (int i = 0; i < take; i++) {
    final entry = entries[i];
    final int id = entry.key;
    final int count = entry.value;
    final String label = (resolveName?.call(id) ?? 'Category $id');
    final double ratio = total == 0 ? 0.0 : count / total;
    stats.add(CategoryStat(
      categoryId: id,
      label: label,
      count: count,
      ratio: ratio,
    ));
  }

  return UnmodifiableListView<CategoryStat>(stats);
}

/// Utility to format counts like 35+, 100+, 1.2k+, 45k+
String formatCountCompact(int count) {
  if (count >= 1000000) {
    // 1M+ style
    final double m = count / 1000000.0;
    final String s = (m % 1 == 0) ? m.toStringAsFixed(0) : m.toStringAsFixed(1);
    return '${s}M+';
  }
  if (count >= 1000) {
    final double k = count / 1000.0;
    final String s = (k % 1 == 0) ? k.toStringAsFixed(0) : k.toStringAsFixed(1);
    return '${s}k+';
  }
  return '$count+';
}
