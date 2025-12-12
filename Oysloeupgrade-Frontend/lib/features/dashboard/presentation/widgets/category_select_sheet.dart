import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oysloe_mobile/core/themes/theme.dart';
import 'package:oysloe_mobile/core/themes/typo.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/widgets/subcategory_select_sheet.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/bloc/categories/categories_cubit.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/bloc/categories/categories_state.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/bloc/subcategories/subcategories_cubit.dart';

class CategorySelectSheet extends StatefulWidget {
  final String? selectedCategory;
  final Function(String category, List<String> subcategories)?
      onSubcategoriesSelected;

  const CategorySelectSheet({
    super.key,
    this.selectedCategory,
    this.onSubcategoriesSelected,
  });

  @override
  State<CategorySelectSheet> createState() => _CategorySelectSheetState();
}

class _CategorySelectSheetState extends State<CategorySelectSheet> {
  @override
  void initState() {
    super.initState();
    // Fetch categories when sheet opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoriesCubit>().fetch();
    });
  }

  String _getCategoryAsset(String categoryName) {
    final name = categoryName.toLowerCase().trim();

    const Map<String, String> assetByName = {
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

    return assetByName[name] ?? 'assets/images/services.png';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 2.h),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.grayD9,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: 2.h),

          // Title
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Categories',
                style: AppTypography.bodyLarge.copyWith(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(height: 2.h),

          // Categories list
          Flexible(
            child: BlocBuilder<CategoriesCubit, CategoriesState>(
              builder: (context, state) {
                if (state.isLoading && !state.hasData) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(4.h),
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  );
                }

                if (state.hasError) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(4.h),
                      child: Text(
                        state.message ?? 'Failed to load categories',
                        style: AppTypography.body.copyWith(
                          color: AppColors.gray8B959E,
                        ),
                      ),
                    ),
                  );
                }

                if (!state.hasData || state.categories.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(4.h),
                      child: Text(
                        'No categories available',
                        style: AppTypography.body.copyWith(
                          color: AppColors.gray8B959E,
                        ),
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  itemCount: state.categories.length,
                  separatorBuilder: (context, index) => Divider(
                    color: AppColors.grayE4,
                    height: 1,
                    thickness: 1,
                  ),
                  itemBuilder: (context, index) {
                    final category = state.categories[index];

                    return InkWell(
                      onTap: () async {
                        // Close category sheet first
                        Navigator.pop(context);
                        // Show subcategory sheet for category selection
                        final subcategories = await showSubcategorySelectSheet(
                          context,
                          categoryId: category.id,
                          categoryName: category.name,
                        );
                        if (subcategories != null && subcategories.isNotEmpty) {
                          // Notify parent about subcategories selection
                          if (widget.onSubcategoriesSelected != null) {
                            widget.onSubcategoriesSelected!(
                                category.name, subcategories);
                          }
                        } else if (subcategories != null) {
                          // Empty list means user wants just the category without subcategories
                          if (widget.onSubcategoriesSelected != null) {
                            widget.onSubcategoriesSelected!(category.name, []);
                          }
                        }
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 1.8.h),
                        child: Row(
                          children: [
                            // Category icon
                            Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                color: AppColors.white,
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(6),
                              child: Image.asset(
                                _getCategoryAsset(category.name),
                                fit: BoxFit.contain,
                              ),
                            ),
                            SizedBox(width: 3.w),

                            // Category name
                            Expanded(
                              child: Text(
                                category.name,
                                style: AppTypography.body.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.blueGray374957,
                                ),
                              ),
                            ),

                            // Chevron icon
                            Icon(
                              Icons.chevron_right,
                              color: AppColors.gray8B959E,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

Future<String?> showCategorySelectSheet(
  BuildContext context, {
  String? selectedCategory,
  Function(String category, List<String> subcategories)?
      onSubcategoriesSelected,
}) {
  // Capture BLoC instances before building the bottom sheet
  final categoriesCubit = context.read<CategoriesCubit>();
  final subcategoriesCubit = context.read<SubcategoriesCubit>();

  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (bottomSheetContext) => MultiBlocProvider(
      providers: [
        BlocProvider.value(value: categoriesCubit),
        BlocProvider.value(value: subcategoriesCubit),
      ],
      child: DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => CategorySelectSheet(
          selectedCategory: selectedCategory,
          onSubcategoriesSelected: onSubcategoriesSelected,
        ),
      ),
    ),
  );
}
