import 'package:flutter/material.dart';
import 'package:oysloe_mobile/core/themes/theme.dart';
import 'package:oysloe_mobile/core/themes/typo.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/widgets/category_select_sheet.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/widgets/region_select_sheet.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

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
  static String? _selectedAdPurpose;
  static String? _selectedHighlight;
  static String? _selectedBrand;
  static String? _selectedSize;
  
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
      _selectedAdPurpose = null;
      _selectedHighlight = null;
      _selectedBrand = null;
      _selectedSize = null;
      _priceRange = const RangeValues(0, 1000000);
      _minPriceController.text = '0';
      _maxPriceController.text = '1,000,000.00';
    });
  }

  void _applyFilters() {
    // Return the applied filters
    Navigator.pop(context, {
      'category': _selectedCategory,
      'subcategories': _selectedSubcategories,
      'region': _selectedRegion,
      'areas': _selectedAreas,
      'adPurpose': _selectedAdPurpose,
      'highlight': _selectedHighlight,
      'brand': _selectedBrand,
      'size': _selectedSize,
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
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildFilterRow(
                    'Category',
                    _selectedSubcategories.isNotEmpty
                        ? '$_selectedCategory ($_selectedSubcategories.length)'
                        : _selectedCategory,
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
                          });
                        },
                      );
                      // Update the selected category if one was chosen (for non-Electronics categories)
                      if (result != null) {
                        setState(() {
                          _selectedCategory = result;
                          // Clear subcategories when category changes
                          _selectedSubcategories = [];
                        });
                      }
                    },
                  ),
                  _buildDivider(),
                  _buildFilterRow(
                    'Locations',
                    _selectedAreas.isNotEmpty
                        ? '$_selectedRegion ($_selectedAreas.length)'
                        : _selectedRegion,
                    onTap: () async {
                      // Show region selection sheet
                      await showRegionSelectSheet(
                        context,
                        onAreasSelected: (region, areas) {
                          setState(() {
                            _selectedRegion = region;
                            _selectedAreas = areas;
                          });
                        },
                      );
                    },
                  ),
                  _buildDivider(),
                  SizedBox(height: 2.h),
                  _buildFilterRow('Ad purpose', _selectedAdPurpose),
                  _buildDivider(),
                  _buildFilterRow('Highlight', _selectedHighlight),
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
                        _minPriceController.text = values.start.toInt().toString();
                        _maxPriceController.text = values.end.toStringAsFixed(2);
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
                  _buildDivider(),
                  _buildFilterRow('Brand', _selectedBrand),
                  _buildDivider(),
                  _buildFilterRow('Size', _selectedSize),
                  _buildDivider(),
                  _buildFilterRow('Size', _selectedSize),
                  
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
                  child: ElevatedButton(
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
                      'View all (456k)',
                      style: AppTypography.body.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow(String label, String? value, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 1.5.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTypography.body.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.blueGray374957,
              ),
            ),
            Row(
              children: [
                if (value != null)
                  Text(
                    value,
                    style: AppTypography.body.copyWith(
                      color: AppColors.gray8B959E,
                    ),
                  ),
                SizedBox(width: 2.w),
                Icon(
                  Icons.chevron_right,
                  color: AppColors.gray8B959E,
                  size: 20,
                ),
              ],
            ),
          ],
        ),
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
  return showModalBottomSheet<Map<String, dynamic>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => const FilterBottomSheet(),
    ),
  );
}

