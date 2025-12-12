import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oysloe_mobile/core/themes/theme.dart';
import 'package:oysloe_mobile/core/themes/typo.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/bloc/subcategories/subcategories_cubit.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/bloc/subcategories/subcategories_state.dart';
import 'package:oysloe_mobile/features/dashboard/domain/entities/subcategory_entity.dart';

class SubcategorySelectSheet extends StatefulWidget {
  final int categoryId;
  final String categoryName;
  final List<String>? selectedSubcategories;

  const SubcategorySelectSheet({
    super.key,
    required this.categoryId,
    required this.categoryName,
    this.selectedSubcategories,
  });

  @override
  State<SubcategorySelectSheet> createState() => _SubcategorySelectSheetState();
}

class _SubcategorySelectSheetState extends State<SubcategorySelectSheet> {
  late List<String> _selectedItems;
  final TextEditingController _searchController = TextEditingController();
  List<SubcategoryEntity> _filteredSubcategories = [];
  List<SubcategoryEntity> _allSubcategories = [];

  @override
  void initState() {
    super.initState();
    _selectedItems = widget.selectedSubcategories ?? [];
    // Fetch subcategories when sheet opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SubcategoriesCubit>().fetch();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterSubcategories(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredSubcategories = _allSubcategories;
      } else {
        _filteredSubcategories = _allSubcategories
            .where(
                (item) => item.name.toLowerCase().contains(query.toLowerCase()))
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
            child: BlocBuilder<SubcategoriesCubit, SubcategoriesState>(
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
                        state.message ?? 'Failed to load subcategories',
                        style: AppTypography.body.copyWith(
                          color: AppColors.gray8B959E,
                        ),
                      ),
                    ),
                  );
                }

                if (state.hasData) {
                  // Filter subcategories for the selected category
                  final categorySubcategories = state.subcategories
                      .where((s) => s.categoryId == widget.categoryId)
                      .toList();

                  // Update local state with filtered data
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_allSubcategories.isEmpty) {
                      setState(() {
                        _allSubcategories = categorySubcategories;
                        _filteredSubcategories = categorySubcategories;
                      });
                    }
                  });

                  final displayList = _filteredSubcategories.isEmpty &&
                          _searchController.text.isEmpty
                      ? categorySubcategories
                      : _filteredSubcategories;

                  if (displayList.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(4.h),
                        child: Text(
                          'No subcategories available',
                          style: AppTypography.body.copyWith(
                            color: AppColors.gray8B959E,
                          ),
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    itemCount: displayList.length,
                    itemBuilder: (context, index) {
                      final subcategory = displayList[index];
                      final isSelected =
                          _selectedItems.contains(subcategory.name);

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
                  );
                }

                return const SizedBox.shrink();
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
                      'Apply${_selectedItems.isNotEmpty ? ' (${_selectedItems.length})' : ''}',
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

Future<List<String>?> showSubcategorySelectSheet(
  BuildContext context, {
  required int categoryId,
  required String categoryName,
  List<String>? selectedSubcategories,
}) {
  // Capture BLoC instance before building the bottom sheet
  final subcategoriesCubit = context.read<SubcategoriesCubit>();

  return showModalBottomSheet<List<String>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (bottomSheetContext) => BlocProvider.value(
      value: subcategoriesCubit,
      child: DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => SubcategorySelectSheet(
          categoryId: categoryId,
          categoryName: categoryName,
          selectedSubcategories: selectedSubcategories,
        ),
      ),
    ),
  );
}
