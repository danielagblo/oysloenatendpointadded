import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oysloe_mobile/core/themes/theme.dart';
import 'package:oysloe_mobile/core/themes/typo.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/widgets/category_select_sheet.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/widgets/region_select_sheet.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/bloc/products/products_cubit.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/bloc/products/products_state.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/bloc/categories/categories_cubit.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/bloc/categories/categories_state.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/bloc/subcategories/subcategories_cubit.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/bloc/locations/locations_cubit.dart';
import 'package:oysloe_mobile/features/dashboard/domain/entities/product_entity.dart';
import 'package:oysloe_mobile/features/dashboard/domain/entities/category_entity.dart';

class FilterBottomSheet extends StatefulWidget {
  final ScrollController? scrollController;
  
  const FilterBottomSheet({
    super.key,
    this.scrollController,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  // Static variables to preserve state across sheet recreations
  static RangeValues _priceRange = const RangeValues(0, 1000000);
  static String? _selectedCategory;
  static List<String> _selectedSubcategories = [];
  static String? _selectedRegion;
  static List<String> _selectedAreas = [];
  
  // Key to force BlocBuilder rebuild when filters change
  int _filterKey = 0;

  late TextEditingController _minPriceController;
  late TextEditingController _maxPriceController;

  @override
  void initState() {
    super.initState();
    _minPriceController = TextEditingController(
      text: _priceRange.start.toInt().toString(),
    );
    _maxPriceController = TextEditingController(
      text: _priceRange.end.toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  void _clearAll() {
    setState(() {
      _selectedCategory = null;
      _selectedSubcategories = [];
      _selectedRegion = null;
      _selectedAreas = [];
      _priceRange = const RangeValues(0, 1000000);
      _minPriceController.text = '0';
      _maxPriceController.text = '1000000.00';
      _filterKey++; // Force BlocBuilder to rebuild
    });
  }

  int _getFilteredProductsCount(
      List<ProductEntity> products, List<CategoryEntity> categories) {
    return products.where((product) {
      // Filter by active status
      if (product.status.toLowerCase() != 'active' || product.isTaken) {
        return false;
      }

      // Filter by category
      if (_selectedCategory != null) {
        final category = categories.firstWhere(
          (cat) => cat.name.toLowerCase() == _selectedCategory!.toLowerCase(),
          orElse: () => const CategoryEntity(id: -1, name: ''),
        );
        if (category.id != -1 && product.category != category.id) {
          return false;
        }
      }

      // Filter by location/areas
      if (_selectedAreas.isNotEmpty) {
        final productLocation = product.location?.label?.toLowerCase() ?? '';
        final productName = product.location?.name?.toLowerCase() ?? '';
        final matchesArea = _selectedAreas.any(
          (area) {
            final areaLower = area.toLowerCase();
            return productLocation.contains(areaLower) || 
                   productName.contains(areaLower);
          },
        );
        if (!matchesArea) return false;
      }
      
      // Also filter by region if region is selected but no areas
      if (_selectedRegion != null && _selectedAreas.isEmpty) {
        final productRegion = product.location?.region?.toLowerCase() ?? '';
        if (productRegion != _selectedRegion!.toLowerCase()) {
          return false;
        }
      }

      // Filter by price range
      try {
        final productPrice = double.tryParse(product.price) ?? 0;
        if (productPrice < _priceRange.start ||
            productPrice > _priceRange.end) {
          return false;
        }
      } catch (e) {
        // If price parsing fails, include the product
      }

      return true;
    }).length;
  }

  void _applyFilters() {
    // Return the applied filters
    Navigator.pop(context, {
      'category': _selectedCategory,
      'subcategories': _selectedSubcategories,
      'region': _selectedRegion,
      'areas': _selectedAreas,
      'priceMin': _priceRange.start,
      'priceMax': _priceRange.end,
    });
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
                'Filter',
                style: AppTypography.bodyLarge.copyWith(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(height: 2.h),

          // Scrollable content
          Flexible(
            child: SingleChildScrollView(
              controller: widget.scrollController,
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildFilterRow(
                    'Category',
                    category: _selectedCategory,
                    subcategories: _selectedSubcategories,
                    onTap: () async {
                      // Show category sheet on top
                      final result = await showCategorySelectSheet(
                        context,
                        selectedCategory: _selectedCategory,
                        onSubcategoriesSelected: (category, subcategories) {
                          // Update category and subcategories when subcategories are selected
                          setState(() {
                            _selectedCategory = category;
                            _selectedSubcategories = subcategories;
                            _filterKey++; // Force count recalculation
                          });
                        },
                      );
                      // Update the selected category if one was chosen (for non-Electronics categories)
                      if (result != null) {
                        setState(() {
                          _selectedCategory = result;
                          // Clear subcategories when category changes
                          _selectedSubcategories = [];
                          _filterKey++; // Force count recalculation
                        });
                      }
                    },
                  ),
                  _buildDivider(),
                  _buildFilterRow(
                    'Locations',
                    region: _selectedRegion,
                    areas: _selectedAreas,
                    onTap: () async {
                      // Show region selection sheet
                      await showRegionSelectSheet(
                        context,
                        onAreasSelected: (region, areas) {
                          setState(() {
                            _selectedRegion = region;
                            _selectedAreas = areas;
                            _filterKey++; // Force count recalculation
                          });
                        },
                      );
                    },
                  ),
                  _buildDivider(),
                  SizedBox(height: 2.h),

                  // Price section
                  Text(
                    'Price',
                    style: AppTypography.body.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.blueGray374957,
                    ),
                  ),
                  SizedBox(height: 2.h),

                  // Range slider
                  RangeSlider(
                    values: _priceRange,
                    min: 0,
                    max: 1000000,
                    activeColor: const Color(0xFF4ECDC4),
                    inactiveColor: AppColors.grayE4,
                    onChanged: (RangeValues values) {
                      setState(() {
                        _priceRange = values;
                        _minPriceController.text =
                            values.start.toInt().toString();
                        _maxPriceController.text =
                            values.end.toStringAsFixed(2);
                        _filterKey++; // Force count recalculation
                      });
                    },
                  ),

                  // Price input fields
                  Row(
                    children: [
                      Expanded(
                        child: _buildPriceInput(_minPriceController),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 2.w),
                        child: Text(
                          '-',
                          style: AppTypography.body.copyWith(
                            color: AppColors.blueGray374957,
                          ),
                        ),
                      ),
                      Expanded(
                        child: _buildPriceInput(_maxPriceController),
                      ),
                    ],
                  ),

                  SizedBox(height: 3.h),
                ],
              ),
            ),
          ),

          // Bottom buttons
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppColors.white,
              border: Border(
                top: BorderSide(
                  color: AppColors.grayE4,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: _clearAll,
                    child: Text(
                      'Clear all',
                      style: AppTypography.body.copyWith(
                        color: AppColors.blueGray374957,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  flex: 2,
                  child: Builder(
                    key: ValueKey(_filterKey),
                    builder: (context) {
                      return BlocBuilder<ProductsCubit, ProductsState>(
                        builder: (context, productsState) {
                          return BlocBuilder<CategoriesCubit, CategoriesState>(
                            builder: (context, categoriesState) {
                              int count = 0;
                          if (productsState.hasData &&
                              categoriesState.hasData) {
                            count = _getFilteredProductsCount(
                              productsState.products,
                              categoriesState.categories,
                            );
                          }

                          String displayCount;
                          if (count >= 1000000) {
                            displayCount =
                                '${(count / 1000000).toStringAsFixed(1)}M';
                          } else if (count >= 1000) {
                            displayCount =
                                '${(count / 1000).toStringAsFixed(1)}k';
                          } else {
                            displayCount = count.toString();
                          }

                          return ElevatedButton(
                            onPressed: _applyFilters,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF142032),
                              foregroundColor: AppColors.white,
                              padding: EdgeInsets.symmetric(vertical: 1.8.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'View all ($displayCount)',
                              style: AppTypography.body.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow(
    String label, {
    String? category,
    List<String>? subcategories,
    String? region,
    List<String>? areas,
    VoidCallback? onTap,
  }) {
    final hasCategorySelection = category != null;
    final hasLocationSelection = region != null && areas != null && areas.isNotEmpty;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 1.5.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: AppTypography.body.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.blueGray374957,
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: AppColors.gray8B959E,
                  size: 20,
                ),
              ],
            ),
            if (hasCategorySelection || hasLocationSelection) ...[
              SizedBox(height: 1.h),
              Wrap(
                spacing: 1.w,
                runSpacing: 0.8.h,
                children: [
                  if (hasCategorySelection) ...[
                    _buildChip(category),
                    if (subcategories != null && subcategories.isNotEmpty)
                      ...subcategories.take(3).map((sub) => _buildChip(sub)),
                    if (subcategories != null && subcategories.length > 3)
                      _buildChip('+${subcategories.length - 3} more'),
                  ],
                  if (hasLocationSelection) ...[
                    _buildChip(region!),
                    if (areas.length <= 3)
                      ...areas.map((area) => _buildChip(area))
                    else ...[
                      ...areas.take(2).map((area) => _buildChip(area)),
                      _buildChip('+${areas.length - 2} more'),
                    ],
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
      decoration: BoxDecoration(
        color: AppColors.grayF9,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.grayD9,
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: AppTypography.bodySmall.copyWith(
          color: AppColors.blueGray374957,
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: AppColors.grayE4,
      height: 1,
      thickness: 1,
    );
  }

  Widget _buildPriceInput(TextEditingController controller) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.grayE4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        style: AppTypography.body.copyWith(
          color: AppColors.blueGray374957,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
          prefixText: '₵ ',
          prefixStyle: AppTypography.body.copyWith(
            color: AppColors.gray8B959E,
          ),
        ),
      ),
    );
  }
}

Future<Map<String, dynamic>?> showFilterBottomSheet(BuildContext context) {
  // Capture BLoC instances before building the bottom sheet
  final productsCubit = context.read<ProductsCubit>();
  final categoriesCubit = context.read<CategoriesCubit>();
  final subcategoriesCubit = context.read<SubcategoriesCubit>();
  final locationsCubit = context.read<LocationsCubit>();

  return showModalBottomSheet<Map<String, dynamic>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (bottomSheetContext) => MultiBlocProvider(
      providers: [
        BlocProvider.value(value: productsCubit),
        BlocProvider.value(value: categoriesCubit),
        BlocProvider.value(value: subcategoriesCubit),
        BlocProvider.value(value: locationsCubit),
      ],
      child: DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.95,
        snap: true,
        snapSizes: const [0.3, 0.6, 0.95],
        builder: (context, scrollController) => FilterBottomSheet(
          scrollController: scrollController,
        ),
      ),
    ),
  );
}
