import 'package:flutter/material.dart';
import 'package:oysloe_mobile/core/themes/theme.dart';
import 'package:oysloe_mobile/core/themes/typo.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/widgets/subcategory_select_sheet.dart';

class CategorySelectSheet extends StatefulWidget {
  final String? selectedCategory;
  final Function(String category, List<String> subcategories)? onSubcategoriesSelected;

  const CategorySelectSheet({
    super.key,
    this.selectedCategory,
    this.onSubcategoriesSelected,
  });

  @override
  State<CategorySelectSheet> createState() => _CategorySelectSheetState();
}

class _CategorySelectSheetState extends State<CategorySelectSheet> {

  final List<_CategoryItem> _categories = const [
    _CategoryItem(
      name: 'Electronics',
      icon: 'assets/images/electronics.png',
      count: '98k',
    ),
    _CategoryItem(
      name: 'Vehicles',
      icon: 'assets/images/vehicle.png',
      count: '879',
    ),
    _CategoryItem(
      name: 'Fashion',
      icon: 'assets/images/fashion.png',
      count: '8799',
    ),
    _CategoryItem(
      name: 'Property',
      icon: 'assets/images/property.png',
      count: '98k',
    ),
    _CategoryItem(
      name: 'Sporting',
      icon: 'assets/images/games.png',
      count: '98k',
    ),
    _CategoryItem(
      name: 'Industry',
      icon: 'assets/images/industrial.png',
      count: '89799k',
    ),
    _CategoryItem(
      name: 'Furniture',
      icon: 'assets/images/furniture.png',
      count: '90k',
    ),
    _CategoryItem(
      name: 'Cosmetics',
      icon: 'assets/images/cosmetics.png',
      count: '90',
    ),
    _CategoryItem(
      name: 'Grocery',
      icon: 'assets/images/grocery.png',
      count: '8k',
    ),
  ];


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
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              itemCount: _categories.length,
              separatorBuilder: (context, index) => Divider(
                color: AppColors.grayE4,
                height: 1,
                thickness: 1,
              ),
              itemBuilder: (context, index) {
                final category = _categories[index];

                return InkWell(
                  onTap: () async {
                    // If Electronics, close this sheet and show subcategory sheet
                    if (category.name == 'Electronics') {
                      // Close category sheet first
                      Navigator.pop(context);
                      // Show subcategory sheet
                      final subcategories = await showSubcategorySelectSheet(
                        context,
                        categoryName: category.name,
                      );
                      if (subcategories != null) {
                        // Notify parent about subcategories selection
                        if (widget.onSubcategoriesSelected != null) {
                          widget.onSubcategoriesSelected!(category.name, subcategories);
                        }
                      }
                    } else {
                      // For other categories, immediately select and close
                      Navigator.pop(context, category.name);
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
                          decoration: BoxDecoration(
                            color: AppColors.grayF9,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Image.asset(
                            category.icon,
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

                        // Count
                        Text(
                          category.count,
                          style: AppTypography.body.copyWith(
                            color: AppColors.gray8B959E,
                          ),
                        ),
                        
                        // Show chevron for categories with subcategories
                        if (category.name == 'Electronics') ...[
                          SizedBox(width: 2.w),
                          Icon(
                            Icons.chevron_right,
                            color: AppColors.gray8B959E,
                            size: 20,
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryItem {
  final String name;
  final String icon;
  final String count;

  const _CategoryItem({
    required this.name,
    required this.icon,
    required this.count,
  });
}

Future<String?> showCategorySelectSheet(
  BuildContext context, {
  String? selectedCategory,
  Function(String category, List<String> subcategories)? onSubcategoriesSelected,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) => CategorySelectSheet(
        selectedCategory: selectedCategory,
        onSubcategoriesSelected: onSubcategoriesSelected,
      ),
    ),
  );
}

