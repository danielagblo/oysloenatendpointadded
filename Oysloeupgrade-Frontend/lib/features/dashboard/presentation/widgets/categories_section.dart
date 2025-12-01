import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shimmer/shimmer.dart';
import 'package:oysloe_mobile/core/routes/routes.dart';
import 'package:oysloe_mobile/core/themes/theme.dart';

import '../../domain/entities/category_entity.dart';
import '../bloc/categories/categories_cubit.dart';
import '../bloc/categories/categories_state.dart';

class CategoriesSection extends StatelessWidget {
  const CategoriesSection({super.key, this.onCategoryTap});

  final void Function(int categoryId, String label)? onCategoryTap;

  static const List<String> _preferredOrder = <String>[
    'Electronics',
    'Furniture',
    'Vehicle',
    'Industry',
    'Fashion',
    'Grocery',
    'Games',
    'Cosmetics',
    'Property',
    'Services',
  ];

  static const Map<String, String> _assetByName = <String, String>{
    'electronics': 'assets/images/electronics.png',
    'furniture': 'assets/images/furniture.png',
    'vehicle': 'assets/images/vehicle.png',
    'cars': 'assets/images/vehicle.png',
    'automobile': 'assets/images/vehicle.png',
    'industry': 'assets/images/industrial.png',
    'industrial': 'assets/images/industrial.png',
    'fashion': 'assets/images/fashion.png',
    'clothing': 'assets/images/fashion.png',
    'grocery': 'assets/images/grocery.png',
    'food': 'assets/images/grocery.png',
    'games': 'assets/images/games.png',
    'gaming': 'assets/images/games.png',
    'cosmetics': 'assets/images/cosmetics.png',
    'beauty': 'assets/images/cosmetics.png',
    'property': 'assets/images/property.png',
    'real estate': 'assets/images/property.png',
    'services': 'assets/images/services.png',
  };

  static const String _defaultAsset = 'assets/images/services.png';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoriesCubit, CategoriesState>(
      builder: (context, state) {
        if (state.hasError && !state.hasData) {
          return _CategoriesError(
            message: state.message ?? 'Unable to load categories',
            onRetry: () =>
                context.read<CategoriesCubit>().fetch(forceRefresh: true),
          );
        }

        if (!state.hasData) {
          return const _CategoriesSkeleton();
        }

        final List<_CategoryDisplay> categories =
            _prepareCategories(state.categories);

        if (categories.isEmpty) {
          return _CategoriesError(
            message: 'No categories available',
            onRetry: () =>
                context.read<CategoriesCubit>().fetch(forceRefresh: true),
          );
        }

        return _CategoriesGrid(
          categories: categories,
          onTap: (category) => _handleTap(context, category),
        );
      },
    );
  }

  void _handleTap(BuildContext context, _CategoryDisplay category) {
    if (onCategoryTap != null) {
      onCategoryTap!(category.id, category.label);
      return;
    }

    if (category.label.trim().toLowerCase() == 'services') {
      context.pushNamed(AppRouteNames.dashboardServices);
    }
  }

  List<_CategoryDisplay> _prepareCategories(List<CategoryEntity> categories) {
    final List<CategoryEntity> sanitized = categories
        .where((CategoryEntity category) => category.name.trim().isNotEmpty)
        .toList();

    if (sanitized.isEmpty) {
      return const <_CategoryDisplay>[];
    }

    final List<CategoryEntity> remaining = List<CategoryEntity>.from(sanitized);
    final List<_CategoryDisplay> ordered = <_CategoryDisplay>[];

    CategoryEntity? extract(String target) {
      final String normalizedTarget = target.trim().toLowerCase();
      final int index = remaining.indexWhere(
        (CategoryEntity category) =>
            category.name.trim().toLowerCase() == normalizedTarget,
      );
      if (index == -1) {
        return null;
      }
      return remaining.removeAt(index);
    }

    for (final String label in _preferredOrder) {
      final CategoryEntity? match = extract(label);
      if (match != null) {
        ordered.add(_CategoryDisplay(
          id: match.id,
          label: match.name,
          asset: _resolveAsset(match.name),
        ));
      }
    }

    if (remaining.isNotEmpty) {
      remaining.sort(
        (CategoryEntity a, CategoryEntity b) =>
            a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );

      ordered.addAll(
        remaining.map(
          (CategoryEntity category) => _CategoryDisplay(
            id: category.id,
            label: category.name,
            asset: _resolveAsset(category.name),
          ),
        ),
      );
    }

    return ordered;
  }

  static String _resolveAsset(String name) {
    final String normalized = name.trim().toLowerCase();
    return _assetByName[normalized] ?? _defaultAsset;
  }
}

class _CategoriesGrid extends StatelessWidget {
  const _CategoriesGrid({
    required this.categories,
    required this.onTap,
  });

  final List<_CategoryDisplay> categories;
  final ValueChanged<_CategoryDisplay> onTap;

  @override
  Widget build(BuildContext context) {
    const int crossAxisCount = 4;
    final int total = categories.length;
    final int remainder = total % crossAxisCount;
    final int leftPad = remainder == 0 ? 0 : (crossAxisCount - remainder) ~/ 2;
    final int totalSlots =
        remainder == 0 ? total : total + (crossAxisCount - remainder);
    final int lastRowStart = totalSlots - crossAxisCount;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.only(top: 1.2.h),
      itemCount: totalSlots,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 1.2.h,
        crossAxisSpacing: 2.4.w,
        childAspectRatio: 0.9,
      ),
      itemBuilder: (context, index) {
        final int? mappedIndex = _resolveCategoryIndex(
            index, total, remainder, leftPad, lastRowStart);
        if (mappedIndex == null || mappedIndex >= categories.length) {
          return const SizedBox.shrink();
        }

        final _CategoryDisplay category = categories[mappedIndex];
        return _CategoryCard(
          label: category.label,
          asset: category.asset,
          onTap: () => onTap(category),
        );
      },
    );
  }

  int? _resolveCategoryIndex(
    int index,
    int total,
    int remainder,
    int leftPad,
    int lastRowStart,
  ) {
    if (total == 0) {
      return null;
    }

    if (remainder == 0 || index < lastRowStart) {
      return index;
    }

    final int positionInLastRow = index - lastRowStart;
    if (positionInLastRow < leftPad ||
        positionInLastRow >= leftPad + remainder) {
      return null;
    }

    return total - remainder + (positionInLastRow - leftPad);
  }
}

class _CategoriesSkeleton extends StatelessWidget {
  const _CategoriesSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.grayE4,
      highlightColor: AppColors.white,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.only(top: 1.2.h),
        itemCount: 8,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 1.2.h,
          crossAxisSpacing: 2.4.w,
          childAspectRatio: 0.9,
        ),
        itemBuilder: (_, __) => Container(
          decoration: BoxDecoration(
            color: AppColors.grayF9,
            borderRadius: BorderRadius.circular(9),
          ),
          padding: EdgeInsets.symmetric(vertical: 1.2.h, horizontal: 2.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(height: 0.8.h),
              Container(
                height: 10.sp,
                width: 38.sp,
                decoration: BoxDecoration(
                  color: AppColors.grayE4,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoriesError extends StatelessWidget {
  const _CategoriesError({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.blueGray374957,
            fontSize: 13.sp,
          ),
        ),
        SizedBox(height: 1.h),
        TextButton(
          onPressed: onRetry,
          child: const Text('Retry'),
        ),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.label, required this.asset, this.onTap});

  final String label;
  final String asset;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.grayF9,
          borderRadius: BorderRadius.circular(9),
        ),
        padding: EdgeInsets.symmetric(vertical: 1.2.h, horizontal: 2.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: Image.asset(asset, fit: BoxFit.contain),
              ),
            ),
            SizedBox(height: 0.8.h),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.blueGray374957,
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryDisplay {
  const _CategoryDisplay({
    required this.id,
    required this.label,
    required this.asset,
  });

  final int id;
  final String label;
  final String asset;
}
