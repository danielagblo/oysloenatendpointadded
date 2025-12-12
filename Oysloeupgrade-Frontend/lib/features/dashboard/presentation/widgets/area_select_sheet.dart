import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oysloe_mobile/core/themes/theme.dart';
import 'package:oysloe_mobile/core/themes/typo.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/bloc/locations/locations_cubit.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/bloc/locations/locations_state.dart';
import 'package:oysloe_mobile/features/dashboard/domain/entities/location_entity.dart';

class AreaSelectSheet extends StatefulWidget {
  final String regionName;
  final List<String>? selectedAreas;

  const AreaSelectSheet({
    super.key,
    required this.regionName,
    this.selectedAreas,
  });

  @override
  State<AreaSelectSheet> createState() => _AreaSelectSheetState();
}

class _AreaSelectSheetState extends State<AreaSelectSheet> {
  late List<String> _selectedItems;
  final TextEditingController _searchController = TextEditingController();
  List<LocationEntity> _filteredAreas = [];
  List<LocationEntity> _allAreas = [];

  @override
  void initState() {
    super.initState();
    _selectedItems = widget.selectedAreas ?? [];
    // Fetch locations when sheet opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LocationsCubit>().fetch();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterAreas(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredAreas = _allAreas;
      } else {
        _filteredAreas = _allAreas
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
                  widget.regionName,
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
                onChanged: _filterAreas,
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

          // Areas list
          Flexible(
            child: BlocBuilder<LocationsCubit, LocationsState>(
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
                        state.message ?? 'Failed to load locations',
                        style: AppTypography.body.copyWith(
                          color: AppColors.gray8B959E,
                        ),
                      ),
                    ),
                  );
                }

                // Filter locations by region
                final regionLocations = state.locations
                    .where((loc) => loc.region == widget.regionName)
                    .toList();

                // Update local state when data is available
                if (state.hasData && _allAreas.isEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    setState(() {
                      _allAreas = regionLocations;
                      _filteredAreas = regionLocations;
                    });
                  });
                }

                final displayList = _filteredAreas.isEmpty && _searchController.text.isEmpty
                    ? regionLocations
                    : _filteredAreas;

                if (displayList.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(4.h),
                      child: Text(
                        'No locations available for this region',
                        style: AppTypography.body.copyWith(
                          color: AppColors.gray8B959E,
                        ),
                      ),
                    ),
                  );
                }

                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...displayList.map((location) => _buildAreaItem(location)),
                      SizedBox(height: 2.h),
                    ],
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
                    child: BlocBuilder<LocationsCubit, LocationsState>(
                      builder: (context, state) {
                        final regionLocationsCount = state.locations
                            .where((loc) => loc.region == widget.regionName)
                            .length;
                        final displayCount = _selectedItems.isEmpty 
                            ? regionLocationsCount 
                            : _selectedItems.length;
                        return Text(
                          'View all ($displayCount)',
                          style: AppTypography.body.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      },
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

  Widget _buildAreaItem(LocationEntity location) {
    final isSelected = _selectedItems.contains(location.name);

    return InkWell(
      onTap: () => _toggleSelection(location.name),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 1.5.h),
        child: Row(
          children: [
            // Area name
            Expanded(
              child: Text(
                location.name,
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
  }
}


Future<List<String>?> showAreaSelectSheet(
  BuildContext context, {
  required String regionName,
  List<String>? selectedAreas,
}) {
  // Capture BLoC instance before building the bottom sheet
  final locationsCubit = context.read<LocationsCubit>();

  return showModalBottomSheet<List<String>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (bottomSheetContext) => BlocProvider.value(
      value: locationsCubit,
      child: DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => AreaSelectSheet(
          regionName: regionName,
          selectedAreas: selectedAreas,
        ),
      ),
    ),
  );
}

