import 'package:flutter/material.dart';
import 'package:oysloe_mobile/core/themes/theme.dart';
import 'package:oysloe_mobile/core/themes/typo.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

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
  List<_AreaItem> _filteredAreas = [];

  final Map<String, List<_AreaItem>> _areasMap = {
    'Greater Accra': [
      _AreaItem(name: 'Accra', count: '879', isPopular: true),
      _AreaItem(name: 'Kwame Nkrumah Circle', count: '8799', isPopular: true),
      _AreaItem(name: 'Spintex', count: '98k', isPopular: true),
      _AreaItem(name: 'Kanieshie', count: '89799k', isPopular: false),
      _AreaItem(name: 'Afienya', count: '90k', isPopular: false),
      _AreaItem(name: 'Domenya', count: '90', isPopular: false),
      _AreaItem(name: 'Fashion', count: '8k', isPopular: false),
      _AreaItem(name: 'Accra', count: '7k', isPopular: false),
      _AreaItem(name: 'Kwame Nkrumah Circle', count: '745', isPopular: false),
      _AreaItem(name: 'Spintex', count: '1k', isPopular: false),
    ],
    // Add other regions as needed
  };

  List<_AreaItem> get _popularAreas =>
      (_areasMap[widget.regionName] ?? []).where((area) => area.isPopular).toList();

  List<_AreaItem> get _otherAreas =>
      (_areasMap[widget.regionName] ?? []).where((area) => !area.isPopular).toList();

  @override
  void initState() {
    super.initState();
    _selectedItems = widget.selectedAreas ?? [];
    _filteredAreas = _areasMap[widget.regionName] ?? [];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterAreas(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredAreas = _areasMap[widget.regionName] ?? [];
      } else {
        _filteredAreas = (_areasMap[widget.regionName] ?? [])
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
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Popular areas (if not searching)
                  if (_searchController.text.isEmpty && _popularAreas.isNotEmpty) ...[
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                      decoration: BoxDecoration(
                        color: AppColors.grayF9,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.grayD9.withValues(alpha: 0.3),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Text(
                        'Popular areas',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.gray8B959E,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: 1.h),
                    ..._popularAreas.map((area) => _buildAreaItem(area)),
                    SizedBox(height: 2.h),
                  ],

                  // Other areas
                  if (_searchController.text.isEmpty && _otherAreas.isNotEmpty) ...[
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                      decoration: BoxDecoration(
                        color: AppColors.grayF9,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.grayD9.withValues(alpha: 0.3),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Text(
                        'Other areas',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.gray8B959E,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: 1.h),
                    ..._otherAreas.map((area) => _buildAreaItem(area)),
                  ],

                  // Search results
                  if (_searchController.text.isNotEmpty)
                    ..._filteredAreas.map((area) => _buildAreaItem(area)),

                  SizedBox(height: 2.h),
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
                      'View all (${_selectedItems.isEmpty ? '456k' : _selectedItems.length})',
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

  Widget _buildAreaItem(_AreaItem area) {
    final isSelected = _selectedItems.contains(area.name);

    return InkWell(
      onTap: () => _toggleSelection(area.name),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 1.5.h),
        child: Row(
          children: [
            // Area name
            Expanded(
              child: Text(
                area.name,
                style: AppTypography.body.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppColors.blueGray374957,
                ),
              ),
            ),

            // Count
            Text(
              area.count,
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
  }
}

class _AreaItem {
  final String name;
  final String count;
  final bool isPopular;

  const _AreaItem({
    required this.name,
    required this.count,
    this.isPopular = false,
  });
}

Future<List<String>?> showAreaSelectSheet(
  BuildContext context, {
  required String regionName,
  List<String>? selectedAreas,
}) {
  return showModalBottomSheet<List<String>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => AreaSelectSheet(
        regionName: regionName,
        selectedAreas: selectedAreas,
      ),
    ),
  );
}

