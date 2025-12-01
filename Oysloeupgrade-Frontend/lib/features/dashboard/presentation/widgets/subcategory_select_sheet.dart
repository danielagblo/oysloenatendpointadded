import 'package:flutter/material.dart';
import 'package:oysloe_mobile/core/themes/theme.dart';
import 'package:oysloe_mobile/core/themes/typo.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class SubcategorySelectSheet extends StatefulWidget {
  final String categoryName;
  final List<String>? selectedSubcategories;

  const SubcategorySelectSheet({
    super.key,
    required this.categoryName,
    this.selectedSubcategories,
  });

  @override
  State<SubcategorySelectSheet> createState() => _SubcategorySelectSheetState();
}

class _SubcategorySelectSheetState extends State<SubcategorySelectSheet> {
  late List<String> _selectedItems;
  final TextEditingController _searchController = TextEditingController();
  List<_SubcategoryItem> _filteredSubcategories = [];

  final Map<String, List<_SubcategoryItem>> _subcategoriesMap = {
    'Electronics': [
      _SubcategoryItem(name: 'Smartphones', count: '98k'),
      _SubcategoryItem(name: 'Feature phones', count: '879'),
      _SubcategoryItem(name: 'Tablets', count: '8799'),
      _SubcategoryItem(name: 'Smartwatches', count: '98k'),
      _SubcategoryItem(name: 'Phone cases & covers', count: '98k'),
      _SubcategoryItem(name: 'Screen protectors', count: '89799k'),
      _SubcategoryItem(name: 'Laptop', count: '90k'),
      _SubcategoryItem(name: 'Desktops', count: '90'),
      _SubcategoryItem(name: 'Monitors', count: '8k'),
      _SubcategoryItem(name: 'Computer parts ( RAM,SSD,CPU,GPU)', count: '7k'),
      _SubcategoryItem(name: 'Storage Devices ( SSD, EXTERNA..', count: '7'),
      _SubcategoryItem(name: 'Keyboards & Mice', count: '1k'),
    ],
    // Add other categories as needed
  };

  @override
  void initState() {
    super.initState();
    _selectedItems = widget.selectedSubcategories ?? [];
    _filteredSubcategories = _subcategoriesMap[widget.categoryName] ?? [];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterSubcategories(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredSubcategories = _subcategoriesMap[widget.categoryName] ?? [];
      } else {
        _filteredSubcategories = (_subcategoriesMap[widget.categoryName] ?? [])
            .where((item) =>
                item.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _toggleSelection(String name) {
    setState(() {
      if (_selectedItems.contains(name)) {
        _selectedItems.remove(name);
      } else {
        _selectedItems.add(name);
      }
    });
  }

  void _clearAll() {
    setState(() {
      _selectedItems.clear();
    });
  }

  void _apply() {
    Navigator.pop(context, _selectedItems);
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

          // Header with back button and title
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Row(
              children: [
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Icon(
                    Icons.arrow_back,
                    color: AppColors.blueGray374957,
                    size: 24,
                  ),
                ),
                SizedBox(width: 3.w),
                Text(
                  widget.categoryName,
                  style: AppTypography.bodyLarge.copyWith(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 2.h),

          // Search bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.grayF9,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _filterSubcategories,
                style: AppTypography.body.copyWith(
                  color: AppColors.blueGray374957,
                ),
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: AppTypography.body.copyWith(
                    color: AppColors.gray8B959E,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppColors.gray8B959E,
                    size: 20,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 4.w,
                    vertical: 1.5.h,
                  ),
                  isDense: true,
                ),
              ),
            ),
          ),
          SizedBox(height: 2.h),

          // Subcategories list
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              itemCount: _filteredSubcategories.length,
              itemBuilder: (context, index) {
                final subcategory = _filteredSubcategories[index];
                final isSelected = _selectedItems.contains(subcategory.name);

                return InkWell(
                  onTap: () => _toggleSelection(subcategory.name),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 1.5.h),
                    child: Row(
                      children: [
                        // Subcategory name
                        Expanded(
                          child: Text(
                            subcategory.name,
                            style: AppTypography.body.copyWith(
                              fontWeight: FontWeight.w500,
                              color: AppColors.blueGray374957,
                            ),
                          ),
                        ),

                        // Count
                        Text(
                          subcategory.count,
                          style: AppTypography.body.copyWith(
                            color: AppColors.gray8B959E,
                          ),
                        ),
                        SizedBox(width: 3.w),

                        // Checkbox
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF4ECDC4)
                                  : AppColors.grayD9,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(4),
                            color: isSelected
                                ? const Color(0xFF4ECDC4)
                                : Colors.transparent,
                          ),
                          child: isSelected
                              ? Icon(
                                  Icons.check,
                                  color: AppColors.white,
                                  size: 14,
                                )
                              : null,
                        ),
                      ],
                    ),
                  ),
                );
              },
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
                    onPressed: _apply,
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
                      'View all (${_selectedItems.isEmpty ? '46k' : _selectedItems.length})',
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
}

class _SubcategoryItem {
  final String name;
  final String count;

  const _SubcategoryItem({
    required this.name,
    required this.count,
  });
}

Future<List<String>?> showSubcategorySelectSheet(
  BuildContext context, {
  required String categoryName,
  List<String>? selectedSubcategories,
}) {
  return showModalBottomSheet<List<String>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => SubcategorySelectSheet(
        categoryName: categoryName,
        selectedSubcategories: selectedSubcategories,
      ),
    ),
  );
}

